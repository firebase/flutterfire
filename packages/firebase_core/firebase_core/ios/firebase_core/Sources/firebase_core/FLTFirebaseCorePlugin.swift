// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCore

#if canImport(firebase_core_objc)
  @_exported import firebase_core_objc
#endif

#if canImport(FlutterMacOS)
  import FlutterMacOS
#else
  import Flutter
#endif

extension FlutterError: Error {}

private let kFLTFirebaseCoreChannelName =
  "dev.flutter.pigeon.FirebaseCoreHostApi.initializeApp"

@objc(FLTFirebaseCorePlugin)
public class FLTFirebaseCorePlugin: FLTFirebasePlugin, FlutterPlugin, FLTFirebasePluginProtocol,
  FirebaseCoreHostApi, FirebaseAppHostApi
{
  private var coreInitialized = false

  private static let shared: FLTFirebaseCorePlugin = {
    let instance = FLTFirebaseCorePlugin()
    FLTFirebasePluginRegistry.sharedInstance().register(instance)

    // Initialize default Firebase app, but only if the plist file options exist.
    //  - If it is missing then there is no default app discovered in Dart and
    //    Dart throws an error.
    //  - Without this the iOS/macOS app would crash immediately on calling
    //    FirebaseApp.configure() without providing helpful context about the crash.
    //
    // Default app exists check is for backwards compatibility of legacy
    // FlutterFire plugins that call FirebaseApp.configure() themselves internally.
    if FirebaseOptions.defaultOptions() != nil,
      FirebaseApp.allApps?["__FIRAPP_DEFAULT"] == nil
    {
      FirebaseApp.configure()
    }

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
    #if os(iOS)
      registrar.publish(instance)
    #endif
    FirebaseCoreHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
    FirebaseAppHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
  }

  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    completion()
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    [:]
  }

  @objc public func firebaseLibraryName() -> String {
    "flutter-fire-core"
  }

  public func firebaseLibraryVersion() -> String {
    versionNumber
  }

  @objc public func flutterChannelName() -> String {
    kFLTFirebaseCoreChannelName
  }

  private func pigeonOptions(from options: FirebaseOptions) -> CoreFirebaseOptions {
    CoreFirebaseOptions(
      apiKey: options.apiKey ?? "",
      appId: options.googleAppID,
      messagingSenderId: options.gcmSenderID,
      projectId: options.projectID ?? "",
      authDomain: nil,
      databaseURL: options.databaseURL,
      storageBucket: options.storageBucket,
      measurementId: nil,
      trackingId: nil,
      deepLinkURLScheme: nil,
      androidClientId: nil,
      iosClientId: options.clientID,
      iosBundleId: options.bundleID,
      appGroupId: options.appGroupID
    )
  }

  private func pluginConstantsDictionary(from firebaseApp: FirebaseApp) -> [String?: Any?] {
    let raw = FLTFirebasePluginRegistry.sharedInstance().pluginConstants(for: firebaseApp)
    var constants: [String?: Any?] = [:]
    for (key, value) in raw {
      if let stringKey = key as? String {
        constants[stringKey] = value
      }
    }
    return constants
  }

  private func initializeResponse(from firebaseApp: FirebaseApp) -> CoreInitializeResponse {
    return CoreInitializeResponse(
      name: FLTFirebasePlugin.firebaseAppName(fromIosName: firebaseApp.name),
      options: pigeonOptions(from: firebaseApp.options),
      isAutomaticDataCollectionEnabled: firebaseApp.isDataCollectionDefaultEnabled,
      pluginConstants: pluginConstantsDictionary(from: firebaseApp)
    )
  }

  func initializeApp(
    appName: String,
    initializeAppRequest: CoreFirebaseOptions,
    completion: @escaping (Result<CoreInitializeResponse, Error>) -> Void
  ) {
    let appNameIos = FLTFirebasePlugin.firebaseAppName(fromDartName: appName)

    if let existing = FLTFirebasePlugin.firebaseAppNamed(appNameIos) {
      completion(.success(initializeResponse(from: existing)))
      return
    }

    let options = FirebaseOptions(
      googleAppID: initializeAppRequest.appId,
      gcmSenderID: initializeAppRequest.messagingSenderId
    )
    options.apiKey = initializeAppRequest.apiKey
    options.projectID = initializeAppRequest.projectId

    if let databaseURL = initializeAppRequest.databaseURL {
      options.databaseURL = databaseURL
    }
    if let storageBucket = initializeAppRequest.storageBucket {
      options.storageBucket = storageBucket
    }
    if let iosBundleId = initializeAppRequest.iosBundleId {
      options.bundleID = iosBundleId
    }
    if let iosClientId = initializeAppRequest.iosClientId {
      options.clientID = iosClientId
    }
    if let appGroupId = initializeAppRequest.appGroupId {
      options.appGroupID = appGroupId
    }

    if let authDomain = initializeAppRequest.authDomain {
      FLTFirebasePlugin.setCustomAuthDomain(authDomain, forAppName: appNameIos)
    }

    FirebaseApp.configure(name: appNameIos, options: options)

    if let firebaseApp = FirebaseApp.app(name: appNameIos) {
      completion(.success(initializeResponse(from: firebaseApp)))
    } else {
      completion(
        .failure(
          FlutterError(
            code: "initialize-failed",
            message: "Failed to initialize a Firebase app instance.",
            details: nil
          )
        )
      )
    }
  }

  func initializeCore(
    completion: @escaping (Result<[CoreInitializeResponse], Error>) -> Void
  ) {
    let initializeCoreBlock = {
      let firebaseApps = FirebaseApp.allApps ?? [:]
      let responses = firebaseApps.values.map { self.initializeResponse(from: $0) }
      completion(.success(Array(responses)))
    }

    if !coreInitialized {
      coreInitialized = true
      initializeCoreBlock()
    } else {
      FLTFirebasePluginRegistry.sharedInstance().didReinitializeFirebaseCore(initializeCoreBlock)
    }
  }

  func optionsFromResource(
    completion: @escaping (Result<CoreFirebaseOptions, Error>) -> Void
  ) {
    // Unsupported on iOS/macOS. Dart only calls this on Android.
    completion(
      .success(
        CoreFirebaseOptions(
          apiKey: "",
          appId: "",
          messagingSenderId: "",
          projectId: ""
        )
      )
    )
  }

  func delete(
    appName: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let firebaseApp = FLTFirebasePlugin.firebaseAppNamed(appName) else {
      completion(.success(()))
      return
    }

    firebaseApp.delete { success in
      if success {
        completion(.success(()))
      } else {
        completion(
          .failure(
            FlutterError(
              code: "delete-failed",
              message: "Failed to delete a Firebase app instance.",
              details: nil
            )
          )
        )
      }
    }
  }

  func setAutomaticDataCollectionEnabled(
    appName: String,
    enabled: Bool,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    if let firebaseApp = FLTFirebasePlugin.firebaseAppNamed(appName) {
      firebaseApp.isDataCollectionDefaultEnabled = enabled
    }
    completion(.success(()))
  }

  func setAutomaticResourceManagementEnabled(
    appName: String,
    enabled: Bool,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    // Unsupported on iOS/macOS.
    completion(.success(()))
  }
}
