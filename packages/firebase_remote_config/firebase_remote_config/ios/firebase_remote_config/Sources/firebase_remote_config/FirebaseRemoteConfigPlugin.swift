// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if canImport(FlutterMacOS)
  import FlutterMacOS
#else
  import Flutter
#endif

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif
import FirebaseRemoteConfig

let kFirebaseRemoteConfigChannelName = "plugins.flutter.io/firebase_remote_config"
let kFirebaseRemoteConfigUpdatedChannelName = "plugins.flutter.io/firebase_remote_config_updated"

extension FlutterError: Error {}

public class FirebaseRemoteConfigPlugin: NSObject, FlutterPlugin, FlutterStreamHandler,
  FLTFirebasePluginProtocol, FirebaseRemoteConfigHostApi {
  private var listenersMap: [String: ConfigUpdateListenerRegistration] = [:]
  private var fetchAndActivateRetry = false

  static let shared: FirebaseRemoteConfigPlugin = {
    let instance = FirebaseRemoteConfigPlugin()
    FLTFirebasePluginRegistry.sharedInstance().register(instance)
    instance.fetchAndActivateRetry = false
    return instance
  }()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger

    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif

    let instance = shared
    FirebaseRemoteConfigHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)

    let eventChannel = FlutterEventChannel(
      name: kFirebaseRemoteConfigUpdatedChannelName,
      binaryMessenger: binaryMessenger
    )
    eventChannel.setStreamHandler(instance)

    if FirebaseApp.responds(to: NSSelectorFromString("registerLibrary:withVersion:")) {
      FirebaseApp.perform(
        NSSelectorFromString("registerLibrary:withVersion:"),
        with: instance.firebaseLibraryName(),
        with: instance.firebaseLibraryVersion()
      )
    }
  }

  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    completion()
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    let firebaseRemoteConfig = RemoteConfig.remoteConfig(app: firebaseApp)
    let configProperties = configProperties(for: firebaseRemoteConfig)
    var configValues: [String: Any] = configProperties
    configValues["parameters"] = getAllParameters(for: firebaseRemoteConfig)

    return configValues
  }

  func fetch(appName: String, completion: @escaping (Result<Void, any Error>) -> Void) {
    getRemoteConfig(from: appName).fetch { status, error in
      if let error {
        completion(.failure(self.createFlutterError(error)))
      } else {
        completion(Result.success(()))
      }
    }
  }

  func fetchAndActivate(appName: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
    getRemoteConfig(from: appName).fetchAndActivate { status, error in
      if let error {
        completion(.failure(self.createFlutterError(error)))
      } else {
        completion(Result.success(status == .successFetchedFromRemote))
      }
    }
  }

  func activate(appName: String, completion: @escaping (Result<Bool, any Error>) -> Void) {
    getRemoteConfig(from: appName).activate { status, error in
      if let error {
        completion(.failure(self.createFlutterError(error)))
      } else {
        completion(Result.success(status))
      }
    }
  }

  func setConfigSettings(appName: String, settings: RemoteConfigPigeonSettings,
                         completion: @escaping (Result<Void, any Error>) -> Void) {
    let fetchTimeout = settings.fetchTimeoutSeconds
    let minFetchInterval = settings.minimumFetchIntervalSeconds
    let configSettings = RemoteConfigSettings()
    configSettings.fetchTimeout = Double(fetchTimeout)
    configSettings.minimumFetchInterval = Double(minFetchInterval)
    getRemoteConfig(from: appName).configSettings = configSettings
    completion(.success(()))
  }

  func setDefaults(appName: String, defaultParameters: [String: Any?],
                   completion: @escaping (Result<Void, any Error>) -> Void) {
    var filtered: [String: NSObject] = [:]

    for (key, value) in defaultParameters {
      if let nonNil = value, let obj = nonNil as? NSObject {
        filtered[key] = obj
      }
    }

    getRemoteConfig(from: appName).setDefaults(filtered)
    completion(.success(()))
  }

  func ensureInitialized(appName: String, completion: @escaping (Result<Void, any Error>) -> Void) {
    getRemoteConfig(from: appName).ensureInitialized { error in
      if let error {
        completion(.failure(self.createFlutterError(error)))
      } else {
        completion(.success(()))
      }
    }
  }

  func setCustomSignals(appName: String, customSignals: [String: Any?],
                        completion: @escaping (Result<Void, any Error>) -> Void) {
    let signalValues = convertToCustomSignalValues(customSignals)
    Task {
      do {
        try await getRemoteConfig(from: appName).setCustomSignals(signalValues)
        completion(.success(()))
      } catch {
        completion(.failure(createFlutterError(error)))
      }
    }
  }

  func getAll(appName: String, completion: @escaping (Result<[String: Any?], any Error>) -> Void) {
    let remoteConfig = getRemoteConfig(from: appName)
    let allKeys = Set(remoteConfig.allKeys(from: .static))
      .union(remoteConfig.allKeys(from: .default))
      .union(remoteConfig.allKeys(from: .remote))

    var parameters: [String: Any] = [:]
    for key in allKeys {
      let value = remoteConfig.configValue(forKey: key)
      parameters[key] = [
        "value": FlutterStandardTypedData(bytes: value.dataValue),
        "source": mapSource(value.source),
      ]
    }
    completion(.success(parameters))
  }

  func getProperties(appName: String,
                     completion: @escaping (Result<[String: Any], any Error>) -> Void) {
    let config = getRemoteConfig(from: appName)
    completion(.success(configProperties(for: config)))
  }

  public func firebaseLibraryName() -> String {
    "flutter-fire-rc"
  }

  public func firebaseLibraryVersion() -> String {
    versionNumber
  }

  public func flutterChannelName() -> String {
    kFirebaseRemoteConfigChannelName
  }

  public func onListen(withArguments arguments: Any?,
                       eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    guard let args = arguments as? [String: Any], let appName = args["appName"] as? String else {
      return nil
    }
    let remoteConfig = getRemoteConfig(from: appName)
    listenersMap[appName] = remoteConfig.addOnConfigUpdateListener { update, error in
      if let error {
        print("Remote Config update error: \(error.localizedDescription)")
        return
      }
      if let update {
        events(Array(update.updatedKeys))
      }
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    guard let args = arguments as? [String: Any], let appName = args["appName"] as? String else {
      return nil
    }
    listenersMap[appName]?.remove()
    listenersMap.removeValue(forKey: appName)
    return nil
  }

  private func getRemoteConfig(from appName: String) -> RemoteConfig {
    let app = FLTFirebasePlugin.firebaseAppNamed(appName)
    return RemoteConfig.remoteConfig(app: app!)
  }

  private func getAllParameters(for remoteConfig: RemoteConfig) -> [String: Any] {
    var keySet = Set<String>()
    keySet.formUnion(remoteConfig.allKeys(from: .static))
    keySet.formUnion(remoteConfig.allKeys(from: .default))
    keySet.formUnion(remoteConfig.allKeys(from: .remote))

    var parameters: [String: Any] = [:]
    for key in keySet {
      parameters[key] = createRemoteConfigValueDict(remoteConfig.configValue(forKey: key))
    }

    return parameters
  }

  private func createRemoteConfigValueDict(_ remoteConfigValue: RemoteConfigValue)
    -> [String: Any] {
    [
      "value": FlutterStandardTypedData(bytes: remoteConfigValue.dataValue),
      "source": mapSource(remoteConfigValue.source),
    ]
  }

  private func mapSource(_ source: RemoteConfigSource) -> String {
    switch source {
    case .static: return "static"
    case .default: return "default"
    case .remote: return "remote"
    @unknown default: return "static"
    }
  }

  private func mapFetchStatus(_ status: RemoteConfigFetchStatus) -> String {
    switch status {
    case .success: return "success"
    case .failure: return "failure"
    case .throttled: return "throttled"
    case .noFetchYet: return "noFetchYet"
    @unknown default: return "failure"
    }
  }

  private func configProperties(for config: RemoteConfig) -> [String: Any] {
    [
      "fetchTimeout": Int(config.configSettings.fetchTimeout),
      "minimumFetchInterval": Int(config.configSettings.minimumFetchInterval),
      "lastFetchTime": Int(config.lastFetchTime?.timeIntervalSince1970 ?? 0 * 1000),
      "lastFetchStatus": mapFetchStatus(config.lastFetchStatus),
    ]
  }

  private func createFlutterError(_ error: Error) -> FlutterError {
    let nsError = error as NSError
    return FlutterError(
      code: "firebase_remote_config",
      message: nsError.localizedDescription,
      details: nsError.userInfo["details"]
    )
  }

  private func convertToCustomSignalValues(_ raw: [String: Any?]) -> [String: CustomSignalValue?] {
    raw.mapValues { value in
      guard let unwrapped = value else {
        return nil
      }

      switch unwrapped {
      case let string as String:
        return .string(string)
      case let int as Int:
        return .integer(int)
      case let double as Double:
        return .double(double)
      default:
        return nil
      }
    }
  }
}
