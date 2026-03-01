// Copyright 2021 The Chromium Authors. All rights reserved.
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
import FirebaseInstallations

let kFLTFirebaseInstallationsChannelName = "plugins.flutter.io/firebase_app_installations"

public class FirebaseInstallationsPlugin: NSObject, FLTFirebasePluginProtocol,
  FlutterPlugin, FirebaseAppInstallationsHostApi {
  private var eventSink: FlutterEventSink?
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

    let channel = FlutterMethodChannel(
      name: kFLTFirebaseInstallationsChannelName,
      binaryMessenger: binaryMessenger
    )
    let instance = FirebaseInstallationsPlugin(messenger: binaryMessenger)
    FLTFirebasePluginRegistry.sharedInstance().register(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)

    // Set up Pigeon host API handlers for Dart-side FirebaseAppInstallationsHostApi.
    FirebaseAppInstallationsHostApiSetup.setUp(
      binaryMessenger: binaryMessenger,
      api: instance
    )
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
  /// - Returns: a Firebase Installations instance for the passed app from Dart
  private func getInstallations(appName: String) -> Installations {
    let app: FirebaseApp = FLTFirebasePlugin.firebaseAppNamed(appName)!
    return Installations.installations(app: app)
  }

  private func getInstallations(app: AppInstallationsPigeonFirebaseApp) -> Installations {
    getInstallations(appName: app.appName)
  }

  /// Gets Installations Id for an instance.
  /// - Parameter arguments: the arguments passed by the Dart calling method
  /// - Parameter result: the result instance used to send the result to Dart.
  /// - Parameter errorBlock: the error block used to send the error to Dart.
  private func getId(arguments: NSDictionary, result: @escaping FlutterResult,
                     errorBlock: @escaping FLTFirebaseMethodCallErrorBlock) {
    let instance = getInstallations(appName: arguments["appName"] as! String)
    instance.installationID { (id: String?, error: Error?) in
      if let error {
        errorBlock(nil, nil, nil, error)
      } else {
        result(id)
      }
    }
  }

  /// Deletes the Installations Id for an instance.
  /// - Parameter arguments: the arguments passed by the Dart calling method
  /// - Parameter result: the result instance used to send the result to Dart.
  /// - Parameter errorBlock: the error block used to send the error to Dart.
  private func deleteId(arguments: NSDictionary, result: @escaping FlutterResult,
                        errorBlock: @escaping FLTFirebaseMethodCallErrorBlock) {
    let instance = getInstallations(appName: arguments["appName"] as! String)
    instance.delete { (error: Error?) in
      if let error {
        errorBlock(nil, nil, nil, error)
      } else {
        result(nil)
      }
    }
  }

  /// Gets the Auth Token for an instance.
  /// - Parameter arguments: the arguments passed by the Dart calling method
  /// - Parameter result: the result instance used to send the result to Dart.
  /// - Parameter errorBlock: the error block used to send the error to Dart.
  private func getToken(arguments: NSDictionary, result: @escaping FlutterResult,
                        errorBlock: @escaping FLTFirebaseMethodCallErrorBlock) {
    let instance = getInstallations(appName: arguments["appName"] as! String)
    let forceRefresh = arguments["forceRefresh"] as? Bool ?? false
    instance
      .authTokenForcingRefresh(forceRefresh) { (tokenResult: InstallationsAuthTokenResult?,
                                                error: Error?) in
          if let error {
            errorBlock(nil, nil, nil, error)
          } else {
            result(tokenResult?.authToken)
          }
      }
  }

  // MARK: - FirebaseAppInstallationsHostApi (Pigeon)

  func initializeApp(app: AppInstallationsPigeonFirebaseApp,
                     settings: AppInstallationsPigeonSettings,
                     completion: @escaping (Result<Void, Error>) -> Void) {
    // Currently no per-app settings are applied on iOS; ensure the instance is created.
    _ = getInstallations(app: app)
    completion(.success(()))
  }

  func delete(app: AppInstallationsPigeonFirebaseApp,
              completion: @escaping (Result<Void, Error>) -> Void) {
    let instance = getInstallations(app: app)
    instance.delete { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func getId(app: AppInstallationsPigeonFirebaseApp,
             completion: @escaping (Result<String, Error>) -> Void) {
    let instance = getInstallations(app: app)
    instance.installationID { id, error in
      if let error {
        completion(.failure(error))
      } else if let id {
        completion(.success(id))
      } else {
        completion(.failure(NSError(domain: "firebase_app_installations",
                                    code: -1,
                                    userInfo: [
                                      NSLocalizedDescriptionKey: "Installation ID is nil.",
                                    ])))
      }
    }
  }

  func getToken(app: AppInstallationsPigeonFirebaseApp,
                forceRefresh: Bool,
                completion: @escaping (Result<String, Error>) -> Void) {
    let instance = getInstallations(app: app)
    instance.authTokenForcingRefresh(forceRefresh) { tokenResult, error in
      if let error {
        completion(.failure(error))
      } else if let token = tokenResult?.authToken {
        completion(.success(token))
      } else {
        completion(.failure(NSError(domain: "firebase_app_installations",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Auth token is nil."])))
      }
    }
  }

  func onIdChange(app: AppInstallationsPigeonFirebaseApp,
                  newId: String,
                  completion: @escaping (Result<Void, Error>) -> Void) {
    // The Dart side currently uses an EventChannel-based listener, so this Pigeon hook
    // is a no-op placeholder to satisfy the interface.
    completion(.success(()))
  }

  func registerIdChangeListener(app: AppInstallationsPigeonFirebaseApp,
                                completion: @escaping (Result<String, Error>) -> Void) {
    let instance = getInstallations(app: app)
    let appName = app.appName
    let eventChannelName = kFLTFirebaseInstallationsChannelName + "/token/" + appName

    let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: messenger)

    if streamHandler[eventChannelName] == nil {
      streamHandler[eventChannelName] = IdChangedStreamHandler(instance: instance)
    }

    eventChannel.setStreamHandler(streamHandler[eventChannelName]!)

    completion(.success(eventChannelName))
  }

  /// Registers a listener for changes in the Installations Id.
  /// - Parameter arguments: the arguments passed by the Dart calling method
  /// - Parameter result: the result instance used to send the result to Dart.
  /// - Parameter errorBlock: the error block used to send the error to Dart.
  private func registerIdChangeListener(arguments: NSDictionary, result: @escaping FlutterResult,
                                        errorBlock: @escaping FLTFirebaseMethodCallErrorBlock) {
    let instance = getInstallations(appName: arguments["appName"] as! String)
    let appName = arguments["appName"] as! String
    let eventChannelName = kFLTFirebaseInstallationsChannelName + "/token/" + appName

    let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: messenger)

    if streamHandler[eventChannelName] == nil {
      streamHandler[eventChannelName] = IdChangedStreamHandler(instance: instance)
    }

    eventChannel.setStreamHandler(streamHandler[eventChannelName]!)

    result(eventChannelName)
  }

  private func mapInstallationsErrorCodes(code: UInt) -> NSString {
    let error = InstallationsErrorCode(InstallationsErrorCode
      .Code(rawValue: Int(code)) ?? InstallationsErrorCode.unknown)

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

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? NSDictionary else {
      result(FlutterError(
        code: "invalid-arguments",
        message: "Arguments are not a dictionary",
        details: nil
      ))
      return
    }

    let errorBlock: FLTFirebaseMethodCallErrorBlock = { (code, message, details,
                                                         error: Error?) in
        var errorDetails = [String: Any?]()

        errorDetails["code"] = code ?? self
          .mapInstallationsErrorCodes(code: UInt((error! as NSError).code))
        errorDetails["message"] = message ?? error?
          .localizedDescription ?? "An unknown error has occurred."
        errorDetails["additionalData"] = details

        if code == "unknown" {
          NSLog(
            "FLTFirebaseInstallations: An error occurred while calling method %@",
            call.method
          )
        }

        result(FLTFirebasePlugin.createFlutterError(fromCode: errorDetails["code"] as! String,
                                                    message: errorDetails["message"] as! String,
                                                    optionalDetails: errorDetails[
                                                      "additionalData"
                                                    ] as? [AnyHashable: Any],
                                                    andOptionalNSError: error))
    }

    switch call.method {
    case "FirebaseInstallations#getId":
      getId(arguments: args, result: result, errorBlock: errorBlock)
    case "FirebaseInstallations#delete":
      deleteId(arguments: args, result: result, errorBlock: errorBlock)
    case "FirebaseInstallations#getToken":
      getToken(arguments: args, result: result, errorBlock: errorBlock)
    case "FirebaseInstallations#registerIdChangeListener":
      registerIdChangeListener(arguments: args, result: result, errorBlock: errorBlock)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
