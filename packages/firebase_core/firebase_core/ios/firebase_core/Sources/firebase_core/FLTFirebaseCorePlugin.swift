// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCore
import Foundation

#if os(macOS)
  import FlutterMacOS
#else
  import Flutter
#endif

@objc public class FLTFirebaseCorePlugin: FLTFirebasePluginHelper, FlutterPlugin, FLTFirebasePlugin,
  FirebaseCoreHostApi, FirebaseAppHostApi {
  private var coreInitialized = false
  private static var customAuthDomains: [String: String] = [:]

  // MARK: - FlutterPlugin

  @objc public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = sharedInstance()
    #if os(macOS)
      let messenger = registrar.messenger
    #else
      registrar.publish(instance)
      let messenger = registrar.messenger()
    #endif
    FirebaseCoreHostApiSetup.setUp(binaryMessenger: messenger, api: instance)
    FirebaseAppHostApiSetup.setUp(binaryMessenger: messenger, api: instance)
  }

  // Returns a singleton instance of the Firebase Core plugin.
  @objc public static func sharedInstance() -> FLTFirebaseCorePlugin {
    enum Singleton {
      static let instance: FLTFirebaseCorePlugin = {
        let instance = FLTFirebaseCorePlugin()
        // Register with the Flutter Firebase plugin registry.
        FLTFirebasePluginRegistry.shared.registerFirebasePlugin(instance)

        // Initialize default Firebase app, but only if the plist file options exist.
        //  - If it is missing then there is no default app discovered in Dart and
        //  Dart throws an error.
        //  - Without this the iOS/MacOS app would crash immediately on calling
        //  FirebaseApp.configure() without providing helpful context about the crash to the user.
        //
        // Default app exists check is for backwards compatibility of legacy
        // FlutterFire plugins that call FirebaseApp.configure() themselves internally.
        if let options = FirebaseOptions.defaultOptions(),
           FirebaseApp.app(name: kFIRDefaultAppNameIOS) == nil {
          FirebaseApp.configure(options: options)
        }

        return instance
      }()
    }
    return Singleton.instance
  }

  @objc public static func getCustomDomain(_ appName: String) -> String? {
    customAuthDomains[appName]
  }

  // MARK: - Helpers

  private func optionsFromFIROptions(_ options: FirebaseOptions) -> CoreFirebaseOptions {
    CoreFirebaseOptions(
      apiKey: options.apiKey ?? "",
      appId: options.googleAppID,
      messagingSenderId: options.gcmSenderID,
      projectId: options.projectID ?? "",
      databaseURL: options.databaseURL,
      storageBucket: options.storageBucket,
      iosClientId: options.clientID,
      iosBundleId: options.bundleID,
      appGroupId: options.appGroupID
    )
  }

  private func initializeResponse(from firebaseApp: FirebaseApp) -> CoreInitializeResponse {
    let appNameDart = FLTFirebasePluginHelper.firebaseAppName(fromIosName: firebaseApp.name)
    return CoreInitializeResponse(
      name: appNameDart,
      options: optionsFromFIROptions(firebaseApp.options),
      isAutomaticDataCollectionEnabled: firebaseApp.isDataCollectionDefaultEnabled,
      pluginConstants: FLTFirebasePluginRegistry.shared.pluginConstants(forFIRApp: firebaseApp)
    )
  }

  // MARK: - FLTFirebasePlugin

  @objc public func didReinitializeFirebaseCore(completion: @escaping () -> Void) {
    completion()
  }

  @objc public func pluginConstants(for firebaseApp: FirebaseApp) -> [String: Any] {
    [:]
  }

  @objc public var firebaseLibraryName: String {
    "flutter-fire-core"
  }

  @objc public var firebaseLibraryVersion: String {
    // TODO: Get version from Package.swift or build configuration
    "4.2.0"
  }

  @objc public var flutterChannelName: String {
    // The pigeon channel depends on each function
    "dev.flutter.pigeon.FirebaseCoreHostApi.initializeApp"
  }

  // MARK: - API

  func initializeApp(appName: String,
                     initializeAppRequest: CoreFirebaseOptions,
                     completion: @escaping (Result<CoreInitializeResponse, Error>) -> Void) {
    let appNameIos = FLTFirebasePluginHelper.firebaseAppName(fromDartName: appName)

    // If app already exists and has the same configuration, return it
    // Otherwise, we need to delete and recreate it with the new options
    if let existingApp = FLTFirebasePluginHelper.firebaseApp(named: appName) {
      let existingOptions = existingApp.options
      
      // Check if the existing app has the required databaseURL if one is being provided
      if let newDatabaseURL = initializeAppRequest.databaseURL,
         existingOptions.databaseURL == nil || existingOptions.databaseURL != newDatabaseURL {
        // Need to reconfigure - delete the existing app first
        existingApp.delete { success in
          if success {
            // Now configure with new options
            self.configureNewApp(appName: appName, appNameIos: appNameIos,
                               initializeAppRequest: initializeAppRequest,
                               completion: completion)
          } else {
            completion(.failure(NSError(domain: "FLTFirebaseCore",
                                       code: -1,
                                       userInfo: [
                                         NSLocalizedDescriptionKey: "Failed to delete existing Firebase app for reconfiguration",
                                       ])))
          }
        }
        return
      }
      
      // App exists with same config, return it
      completion(.success(initializeResponse(from: existingApp)))
      return
    }

    // No existing app, create new one
    configureNewApp(appName: appName, appNameIos: appNameIos,
                   initializeAppRequest: initializeAppRequest,
                   completion: completion)
  }
  
  private func configureNewApp(appName: String,
                              appNameIos: String,
                              initializeAppRequest: CoreFirebaseOptions,
                              completion: @escaping (Result<CoreInitializeResponse, Error>) -> Void) {
    let appId = initializeAppRequest.appId
    let messagingSenderId = initializeAppRequest.messagingSenderId

    let options = FirebaseOptions(googleAppID: appId, gcmSenderID: messagingSenderId)
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
      FLTFirebaseCorePlugin.customAuthDomains[appNameIos] = authDomain
    }

    FirebaseApp.configure(name: appNameIos, options: options)

    if let firebaseApp = FirebaseApp.app(name: appNameIos) {
      completion(.success(initializeResponse(from: firebaseApp)))
    } else {
      completion(.failure(NSError(domain: "FLTFirebaseCore",
                                  code: -1,
                                  userInfo: [
                                    NSLocalizedDescriptionKey: "Failed to configure Firebase app",
                                  ])))
    }
  }

  func initializeCore(completion: @escaping (Result<[CoreInitializeResponse], Error>) -> Void) {
    let initializeCoreBlock: () -> Void = {
      var firebaseAppsArray: [CoreInitializeResponse] = []

      if let firebaseApps = FirebaseApp.allApps {
        for (_, firebaseApp) in firebaseApps {
          firebaseAppsArray.append(self.initializeResponse(from: firebaseApp))
        }
      }

      completion(.success(firebaseAppsArray))
    }

    if !coreInitialized {
      coreInitialized = true
      initializeCoreBlock()
    } else {
      FLTFirebasePluginRegistry.shared.didReinitializeFirebaseCore(completion: initializeCoreBlock)
    }
  }

  func optionsFromResource(completion: @escaping (Result<CoreFirebaseOptions, Error>) -> Void) {
    // Unsupported on iOS/MacOS - return empty options with minimal required fields
    completion(.success(CoreFirebaseOptions(
      apiKey: "",
      appId: "",
      messagingSenderId: "",
      projectId: ""
    )))
  }

  func delete(appName: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let firebaseApp = FLTFirebasePluginHelper.firebaseApp(named: appName) else {
      completion(.success(()))
      return
    }

    firebaseApp.delete { success in
      if success {
        completion(.success(()))
      } else {
        completion(.failure(NSError(domain: "FLTFirebaseCore",
                                    code: -1,
                                    userInfo: [
                                      NSLocalizedDescriptionKey: "Failed to delete a Firebase app instance.",
                                    ])))
      }
    }
  }

  func setAutomaticDataCollectionEnabled(appName: String,
                                         enabled: Bool,
                                         completion: @escaping (Result<Void, Error>) -> Void) {
    if let firebaseApp = FLTFirebasePluginHelper.firebaseApp(named: appName) {
      firebaseApp.isDataCollectionDefaultEnabled = enabled
    }
    completion(.success(()))
  }

  func setAutomaticResourceManagementEnabled(appName: String,
                                             enabled: Bool,
                                             completion: @escaping (Result<Void, Error>) -> Void) {
    // Unsupported on iOS/MacOS.
    completion(.success(()))
  }
}
