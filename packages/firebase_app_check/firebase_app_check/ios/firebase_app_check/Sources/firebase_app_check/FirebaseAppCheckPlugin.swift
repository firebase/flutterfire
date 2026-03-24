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
import FirebaseAppCheck
import FirebaseCore

let kFirebaseAppCheckChannelName = "plugins.flutter.io/firebase_app_check"
let kFirebaseAppCheckTokenChannelPrefix = "plugins.flutter.io/firebase_app_check/token/"

extension FlutterError: @retroactive Error {}

public class FirebaseAppCheckPlugin: NSObject, FlutterPlugin,
  FLTFirebasePluginProtocol, FirebaseAppCheckHostApi {
  private var eventChannels: [String: FlutterEventChannel] = [:]
  private var streamHandlers: [String: AppCheckTokenStreamHandler] = [:]
  private var providerFactory: AppCheckProviderFactory?

  static let shared: FirebaseAppCheckPlugin = {
    let instance = FirebaseAppCheckPlugin()
    FLTFirebasePluginRegistry.sharedInstance().register(instance)
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
    instance.binaryMessenger = binaryMessenger
    FirebaseAppCheckHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)

    if FirebaseApp.responds(to: NSSelectorFromString("registerLibrary:withVersion:")) {
      FirebaseApp.perform(
        NSSelectorFromString("registerLibrary:withVersion:"),
        with: instance.firebaseLibraryName(),
        with: instance.firebaseLibraryVersion()
      )
    }
  }

  private var binaryMessenger: FlutterBinaryMessenger?

  func activate(
    appName: String, androidProvider: String?, appleProvider: String?,
    debugToken: String?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let app = FLTFirebasePlugin.firebaseAppNamed(appName)!
    let provider = appleProvider ?? "deviceCheck"

    if providerFactory == nil {
      providerFactory = AppCheckProviderFactory()
    }

    providerFactory!.configure(app: app, providerName: provider, debugToken: debugToken)
    AppCheck.setAppCheckProviderFactory(providerFactory)

    completion(.success(()))
  }

  func getToken(
    appName: String, forceRefresh: Bool,
    completion: @escaping (Result<String?, Error>) -> Void
  ) {
    let app = FLTFirebasePlugin.firebaseAppNamed(appName)!
    let appCheck = AppCheck.appCheck(app: app)

    appCheck.token(forcingRefresh: forceRefresh) { token, error in
      if let error {
        completion(.failure(self.createFlutterError(error)))
      } else {
        completion(.success(token?.token))
      }
    }
  }

  func setTokenAutoRefreshEnabled(
    appName: String, isTokenAutoRefreshEnabled: Bool,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let app = FLTFirebasePlugin.firebaseAppNamed(appName)!
    let appCheck = AppCheck.appCheck(app: app)
    appCheck.isTokenAutoRefreshEnabled = isTokenAutoRefreshEnabled
    completion(.success(()))
  }

  func registerTokenListener(
    appName: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let name = kFirebaseAppCheckTokenChannelPrefix + appName

    guard let messenger = binaryMessenger else {
      completion(.failure(FlutterError(
        code: "no-messenger",
        message: "Binary messenger not available",
        details: nil
      )))
      return
    }

    let channel = FlutterEventChannel(name: name, binaryMessenger: messenger)
    let handler = AppCheckTokenStreamHandler()
    channel.setStreamHandler(handler)

    eventChannels[name] = channel
    streamHandlers[name] = handler

    completion(.success(name))
  }

  func getLimitedUseAppCheckToken(
    appName: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let app = FLTFirebasePlugin.firebaseAppNamed(appName)!
    let appCheck = AppCheck.appCheck(app: app)

    appCheck.limitedUseToken { token, error in
      if let error {
        completion(.failure(self.createFlutterError(error)))
      } else {
        completion(.success(token?.token ?? ""))
      }
    }
  }

  // MARK: - FLTFirebasePluginProtocol

  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    for (_, channel) in eventChannels {
      channel.setStreamHandler(nil)
    }
    for (_, handler) in streamHandlers {
      handler.onCancel(withArguments: nil)
    }
    eventChannels.removeAll()
    streamHandlers.removeAll()
    completion()
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    return [:]
  }

  public func firebaseLibraryName() -> String {
    "flutter-fire-appcheck"
  }

  public func firebaseLibraryVersion() -> String {
    versionNumber
  }

  public func flutterChannelName() -> String {
    kFirebaseAppCheckChannelName
  }

  private func createFlutterError(_ error: Error) -> FlutterError {
    let nsError = error as NSError
    var code = "unknown"
    switch nsError.code {
    case 0:  // FIRAppCheckErrorCodeServerUnreachable
      code = "server-unreachable"
    case 1:  // FIRAppCheckErrorCodeInvalidConfiguration
      code = "invalid-configuration"
    case 2:  // FIRAppCheckErrorCodeKeychain
      code = "code-keychain"
    case 3:  // FIRAppCheckErrorCodeUnsupported
      code = "code-unsupported"
    default:
      code = "unknown"
    }
    return FlutterError(
      code: code,
      message: nsError.localizedDescription,
      details: nil
    )
  }
}

// MARK: - Token Stream Handler

class AppCheckTokenStreamHandler: NSObject, FlutterStreamHandler {
  private var observer: NSObjectProtocol?

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    observer = NotificationCenter.default.addObserver(
      forName: NSNotification.Name("FIRAppCheckAppCheckTokenDidChangeNotification"),
      object: nil,
      queue: nil
    ) { notification in
      if let token = notification.userInfo?["FIRAppCheckTokenNotificationKey"] as? String {
        events(["token": token])
      }
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if let observer {
      NotificationCenter.default.removeObserver(observer)
      self.observer = nil
    }
    return nil
  }
}

// MARK: - App Check Provider Factory

class AppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  private var providers: [String: AppCheckProviderWrapper] = [:]

  func createProvider(with app: FirebaseApp) -> (any AppCheckProvider)? {
    if providers[app.name] == nil {
      let wrapper = AppCheckProviderWrapper()
      wrapper.configure(app: app, providerName: "deviceCheck", debugToken: nil)
      providers[app.name] = wrapper
    }
    return providers[app.name]
  }

  func configure(app: FirebaseApp, providerName: String, debugToken: String?) {
    if providers[app.name] == nil {
      providers[app.name] = AppCheckProviderWrapper()
    }
    providers[app.name]?.configure(app: app, providerName: providerName, debugToken: debugToken)
  }
}

class AppCheckProviderWrapper: NSObject, AppCheckProvider {
  private var delegateProvider: (any AppCheckProvider)?

  func configure(app: FirebaseApp, providerName: String, debugToken: String?) {
    switch providerName {
    case "debug":
      if let debugToken {
        setenv("FIRAAppCheckDebugToken", debugToken, 1)
      }
      delegateProvider = AppCheckDebugProvider(app: app)
      if debugToken == nil, let debugProvider = delegateProvider as? AppCheckDebugProvider {
        print("Firebase App Check Debug Token: \(debugProvider.localDebugToken())")
      }
    case "appAttest":
      if #available(iOS 14.0, macCatalyst 14.0, tvOS 15.0, watchOS 9.0, *) {
        delegateProvider = AppAttestProvider(app: app)
      } else {
        delegateProvider = AppCheckDebugProvider(app: app)
      }
    case "appAttestWithDeviceCheckFallback":
      if #available(iOS 14.0, *) {
        delegateProvider = AppAttestProvider(app: app)
      } else {
        delegateProvider = DeviceCheckProvider(app: app)
      }
    default:
      // deviceCheck
      delegateProvider = DeviceCheckProvider(app: app)
    }
  }

  func getToken() async throws -> AppCheckToken {
    guard let delegateProvider else {
      throw NSError(
        domain: "firebase_app_check", code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Provider not configured"])
    }
    return try await delegateProvider.getToken()
  }
}
