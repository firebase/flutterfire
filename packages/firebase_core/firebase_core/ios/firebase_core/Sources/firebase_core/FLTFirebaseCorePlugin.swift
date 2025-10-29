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

@objc public class FLTFirebaseCorePlugin: FLTFirebasePlugin, FlutterPlugin, FirebaseCoreHostApi, FirebaseAppHostApi {
    private var coreInitialized = false
    private static var customAuthDomains: [String: String] = [:]
    
    // MARK: - FlutterPlugin
    
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = sharedInstance()
        #if !os(macOS)
        registrar.publish(instance)
        #endif
        FirebaseCoreHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
        FirebaseAppHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    }
    
    // Returns a singleton instance of the Firebase Core plugin.
    @objc public static func sharedInstance() -> FLTFirebaseCorePlugin {
        struct Singleton {
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
        return customAuthDomains[appName]
    }
    
    // MARK: - Helpers
    
    private func optionsFromFIROptions(_ options: FirebaseOptions) -> CoreFirebaseOptions {
        let pigeonOptions = CoreFirebaseOptions()
        pigeonOptions.apiKey = options.apiKey
        pigeonOptions.appId = options.googleAppID
        pigeonOptions.messagingSenderId = options.gcmSenderID
        pigeonOptions.projectId = options.projectID
        pigeonOptions.databaseURL = options.databaseURL
        pigeonOptions.storageBucket = options.storageBucket
        pigeonOptions.iosBundleId = options.bundleID
        pigeonOptions.iosClientId = options.clientID
        pigeonOptions.appGroupId = options.appGroupID
        return pigeonOptions
    }
    
    private func initializeResponse(from firebaseApp: FirebaseApp) -> CoreInitializeResponse {
        let appNameDart = FLTFirebasePlugin.firebaseAppName(fromIosName: firebaseApp.name)
        let response = CoreInitializeResponse()
        response.name = appNameDart
        response.options = optionsFromFIROptions(firebaseApp.options)
        response.isAutomaticDataCollectionEnabled = firebaseApp.isDataCollectionDefaultEnabled as NSNumber
        response.pluginConstants = FLTFirebasePluginRegistry.shared.pluginConstants(forFIRApp: firebaseApp)
        return response
    }
    
    // MARK: - FLTFirebasePlugin
    
    @objc public func didReinitializeFirebaseCore(completion: @escaping () -> Void) {
        completion()
    }
    
    @objc public func pluginConstants(for firebaseApp: FirebaseApp) -> [String: Any] {
        return [:]
    }
    
    @objc public var firebaseLibraryName: String {
        return String(cString: LIBRARY_NAME, encoding: .utf8) ?? ""
    }
    
    @objc public var firebaseLibraryVersion: String {
        return String(cString: LIBRARY_VERSION, encoding: .utf8) ?? ""
    }
    
    @objc public var flutterChannelName: String {
        // The pigeon channel depends on each function
        return "dev.flutter.pigeon.FirebaseCoreHostApi.initializeApp"
    }
    
    // MARK: - API
    
    public func initializeApp(
        appName: String,
        initializeAppRequest: CoreFirebaseOptions,
        completion: @escaping (Result<CoreInitializeResponse, Error>) -> Void
    ) {
        let appNameIos = FLTFirebasePlugin.firebaseAppName(fromDartName: appName)
        
        if let existingApp = FLTFirebasePlugin.firebaseApp(named: appName) {
            completion(.success(initializeResponse(from: existingApp)))
            return
        }
        
        guard let appId = initializeAppRequest.appId,
              let messagingSenderId = initializeAppRequest.messagingSenderId else {
            completion(.failure(NSError(domain: "FLTFirebaseCore",
                                       code: -1,
                                       userInfo: [NSLocalizedDescriptionKey: "Missing required options"])))
            return
        }
        
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
                                       userInfo: [NSLocalizedDescriptionKey: "Failed to configure Firebase app"])))
        }
    }
    
    public func initializeCore(completion: @escaping (Result<[CoreInitializeResponse], Error>) -> Void) {
        let initializeCoreBlock: () -> Void = {
            let firebaseApps = FirebaseApp.allApps() ?? [:]
            var firebaseAppsArray: [CoreInitializeResponse] = []
            
            for (_, firebaseApp) in firebaseApps {
                firebaseAppsArray.append(self.initializeResponse(from: firebaseApp))
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
    
    public func optionsFromResource(completion: @escaping (Result<CoreFirebaseOptions, Error>) -> Void) {
        // Unsupported on iOS/MacOS.
        completion(.success(CoreFirebaseOptions()))
    }
    
    public func delete(appName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let firebaseApp = FLTFirebasePlugin.firebaseApp(named: appName) else {
            completion(.success(()))
            return
        }
        
        firebaseApp.delete { success in
            if success {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "FLTFirebaseCore",
                                           code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "Failed to delete a Firebase app instance."])))
            }
        }
    }
    
    public func setAutomaticDataCollectionEnabled(
        appName: String,
        enabled: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        if let firebaseApp = FLTFirebasePlugin.firebaseApp(named: appName) {
            firebaseApp.isDataCollectionDefaultEnabled = enabled
        }
        completion(.success(()))
    }
    
    public func setAutomaticResourceManagementEnabled(
        appName: String,
        enabled: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Unsupported on iOS/MacOS.
        completion(.success(()))
    }
}

