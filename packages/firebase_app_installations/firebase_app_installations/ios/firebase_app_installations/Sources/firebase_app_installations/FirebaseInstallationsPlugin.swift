// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseInstallations

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

let kFLTFirebaseInstallationsChannelName = "plugins.flutter.io/firebase_app_installations"

public class FirebaseInstallationsPlugin: NSObject, FLTFirebasePluginProtocol, FlutterPlugin,
  FirebaseAppInstallationsHostApi
{
  private var messenger: FlutterBinaryMessenger
  private var streamHandler = [String: IdChangedStreamHandler?]()

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger

    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif

    let instance = FirebaseInstallationsPlugin(messenger: binaryMessenger)
    FLTFirebasePluginRegistry.sharedInstance().register(instance)
    FirebaseAppInstallationsHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
  }

  public func firebaseLibraryVersion() -> String {
    versionNumber
  }

  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    completion()
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    [:]
  }

  @objc public func firebaseLibraryName() -> String {
    "flutter-fire-installations"
  }

  @objc public func flutterChannelName() -> String {
    kFLTFirebaseInstallationsChannelName
  }

  /// Gets Installations instance for a Firebase App.
  private func getInstallations(appName: String) -> Installations {
    let app: FirebaseApp = FLTFirebasePlugin.firebaseAppNamed(appName)!
    return Installations.installations(app: app)
  }

  private func mapInstallationsErrorCodes(code: UInt) -> String {
    let error = InstallationsErrorCode(
      InstallationsErrorCode
        .Code(rawValue: Int(code)) ?? InstallationsErrorCode.unknown
    )

    switch error {
    case InstallationsErrorCode.invalidConfiguration:
      return "invalid-configuration"
    case InstallationsErrorCode.keychain:
      return "invalid-keychain"
    case InstallationsErrorCode.serverUnreachable:
      return "server-unreachable"
    case InstallationsErrorCode.unknown:
      return "unknown"
    default:
      return "unknown"
    }
  }

  private func createFlutterError(_ error: Error) -> FlutterError {
    let nsError = error as NSError
    return FlutterError(
      code: mapInstallationsErrorCodes(code: UInt(nsError.code)),
      message: nsError.localizedDescription,
      details: nil
    )
  }

  public func delete(
    appName: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let instance = getInstallations(appName: appName)
    instance.delete { (error: Error?) in
      if let error {
        completion(.failure(self.createFlutterError(error)))
      } else {
        completion(.success(()))
      }
    }
  }

  public func getId(
    appName: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let instance = getInstallations(appName: appName)
    instance.installationID { (id: String?, error: Error?) in
      if let error {
        completion(.failure(self.createFlutterError(error)))
      } else if let id {
        completion(.success(id))
      } else {
        completion(
          .failure(
            FlutterError(
              code: "unknown",
              message: "Installation ID was nil",
              details: nil
            )
          )
        )
      }
    }
  }

  public func getToken(
    appName: String,
    forceRefresh: Bool,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let instance = getInstallations(appName: appName)
    instance.authTokenForcingRefresh(forceRefresh) {
      (
        tokenResult: InstallationsAuthTokenResult?,
        error: Error?
      ) in
      if let error {
        completion(.failure(self.createFlutterError(error)))
      } else if let token = tokenResult?.authToken {
        completion(.success(token))
      } else {
        completion(
          .failure(
            FlutterError(
              code: "unknown",
              message: "Installation token was nil",
              details: nil
            )
          )
        )
      }
    }
  }

  public func registerIdChangeListener(
    appName: String,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let instance = getInstallations(appName: appName)
    let eventChannelName = kFLTFirebaseInstallationsChannelName + "/token/" + appName

    let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: messenger)

    if streamHandler[eventChannelName] == nil {
      streamHandler[eventChannelName] = IdChangedStreamHandler(instance: instance)
    }

    eventChannel.setStreamHandler(streamHandler[eventChannelName]!)

    completion(.success(eventChannelName))
  }
}
