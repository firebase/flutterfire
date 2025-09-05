// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(macOS)
import FlutterMacOS
#else
import Flutter
#endif

import FirebaseAppCheck

#if canImport(firebase_core)
import firebase_core
#endif

private let kFLTFirebaseAppCheckChannelName = "plugins.flutter.io/firebase_app_check"

public class FLTFirebaseAppCheckPlugin: NSObject, FLTFirebasePluginProtocol, FlutterPlugin, FirebaseAppCheckHostApi {
    private var eventChannels: [String: FlutterEventChannel] = [:]
    private var streamHandlers: [String: FlutterStreamHandler] = [:]
    private var binaryMessenger: FlutterBinaryMessenger?
    private var providerFactory: FLTAppCheckProviderFactory?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let binaryMessenger: FlutterBinaryMessenger
        
        #if os(macOS)
        binaryMessenger = registrar.messenger
        #elseif os(iOS)
        binaryMessenger = registrar.messenger()
        #endif
        
        let channel = FlutterMethodChannel(
            name: kFLTFirebaseAppCheckChannelName,
            binaryMessenger: binaryMessenger
        )
        let instance = FLTFirebaseAppCheckPlugin()
        instance.binaryMessenger = binaryMessenger
        instance.providerFactory = FLTAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(instance.providerFactory)
        
        // Set up Pigeon API
        FirebaseAppCheckHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
        
        FLTFirebasePluginRegistry.sharedInstance().register(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func cleanup(completion: (() -> Void)?) {
        for channel in eventChannels.values {
            channel.setStreamHandler(nil)
        }
        eventChannels.removeAll()
        
        for handler in streamHandlers.values {
            handler.onCancel(withArguments: nil)
        }
        streamHandlers.removeAll()
        
        // Clean up Pigeon API
        if let messenger = binaryMessenger {
            FirebaseAppCheckHostApiSetup.setUp(binaryMessenger: messenger, api: nil)
        }
        
        completion?()
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        cleanup(completion: nil)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let errorBlock: FLTFirebaseMethodCallErrorBlock = { code, message, details, error in
            var errorDetails: [String: Any] = [:]
            let errorCode: String
            
            if let appCheckError = error as? NSError {
                switch AppCheckErrorCode.Code(rawValue: appCheckError.code) {
                case .serverUnreachable:
                    errorCode = "server-unreachable"
                case .invalidConfiguration:
                    errorCode = "invalid-configuration"
                case .keychain:
                    errorCode = "code-keychain"
                case .unsupported:
                    errorCode = "code-unsupported"
                case .unknown:
                    fallthrough
                default:
                    errorCode = "unknown"
                }
            } else {
                errorCode = "unknown"
            }
            
            let errorMessage = error?.localizedDescription ?? ""
            errorDetails["code"] = errorCode
            errorDetails["message"] = errorMessage
            result(FlutterError(code: errorCode, message: errorMessage, details: errorDetails))
        }
        
        let methodCallResult = FLTFirebaseMethodCallResult.create(
            success: result,
            andErrorBlock: errorBlock
        )
        
        switch call.method {
        case "FirebaseAppCheck#activate":
            activate(call.arguments, withMethodCallResult: methodCallResult)
        case "FirebaseAppCheck#getToken":
            getToken(call.arguments, withMethodCallResult: methodCallResult)
        case "FirebaseAppCheck#setTokenAutoRefreshEnabled":
            setTokenAutoRefreshEnabled(call.arguments, withMethodCallResult: methodCallResult)
        case "FirebaseAppCheck#registerTokenListener":
            registerTokenListener(call.arguments, withMethodCallResult: methodCallResult)
        case "FirebaseAppCheck#getLimitedUseAppCheckToken":
            getLimitedUseAppCheckToken(call.arguments, withMethodCallResult: methodCallResult)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Firebase App Check API
    
    private func activate(_ arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any],
              let appNameDart = args["appName"] as? String,
              let providerName = args["appleProvider"] as? String else {
            result.error(nil, nil, nil, NSError(domain: "FLTFirebaseAppCheck", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid arguments"]))
            return
        }
        
        guard let app = FLTFirebasePlugin.firebaseAppNamed(appNameDart) else {
            result.error(nil, nil, nil, NSError(domain: "FLTFirebaseAppCheck", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase app not found"]))
            return
        }
        providerFactory?.configure(app: app, providerName: providerName)
        result.success(nil)
    }
    
    private func registerTokenListener(_ arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let args = arguments as? [String: Any],
              let appName = args["appName"] as? String else {
            result.error(nil, nil, nil, NSError(domain: "FLTFirebaseAppCheck", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid arguments"]))
            return
        }
        
        let name = "\(kFLTFirebaseAppCheckChannelName)/token/\(appName)"
        
        guard let messenger = binaryMessenger else {
            result.error(nil, nil, nil, NSError(domain: "FLTFirebaseAppCheck", code: -1, userInfo: [NSLocalizedDescriptionKey: "Binary messenger not available"]))
            return
        }
        
        let channel = FlutterEventChannel(name: name, binaryMessenger: messenger)
        let handler = FLTTokenRefreshStreamHandler()
        channel.setStreamHandler(handler)
        
        eventChannels[name] = channel
        streamHandlers[name] = handler
        result.success(name)
    }
    
    private func getToken(_ arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let appCheck = getAppCheck(fromArguments: arguments) else {
            result.error(nil, nil, nil, NSError(domain: "FLTFirebaseAppCheck", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get AppCheck instance"]))
            return
        }
        
        let forceRefresh = (arguments as? [String: Any])?["forceRefresh"] as? Bool ?? false
        
        appCheck.token(forcingRefresh: forceRefresh) { token, error in
            if let error = error {
                result.error(nil, nil, nil, error)
            } else {
                result.success(token?.token)
            }
        }
    }
    
    private func getLimitedUseAppCheckToken(_ arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let appCheck = getAppCheck(fromArguments: arguments) else {
            result.error(nil, nil, nil, NSError(domain: "FLTFirebaseAppCheck", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get AppCheck instance"]))
            return
        }
        
        appCheck.limitedUseToken { token, error in
            if let error = error {
                result.error(nil, nil, nil, error)
            } else {
                result.success(token?.token)
            }
        }
    }
    
    private func setTokenAutoRefreshEnabled(_ arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
        guard let appCheck = getAppCheck(fromArguments: arguments),
              let args = arguments as? [String: Any],
              let isEnabled = args["isTokenAutoRefreshEnabled"] as? Bool else {
            result.error(nil, nil, nil, NSError(domain: "FLTFirebaseAppCheck", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid arguments"]))
            return
        }
        
        appCheck.isTokenAutoRefreshEnabled = isEnabled
        result.success(nil)
    }
    
    // MARK: - FLTFirebasePluginProtocol
    
    public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
        cleanup(completion: completion)
    }
    
    public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
        return [:]
    }
    
    public func firebaseLibraryVersion() -> String {
        return "LIBRARY_VERSION"
    }
    
    @objc public func firebaseLibraryName() -> String {
        return "flutter-fire-appcheck"
    }
    
    @objc public func flutterChannelName() -> String {
        return kFLTFirebaseAppCheckChannelName
    }
    
    // MARK: - Utilities
    
    private func getAppCheck(fromArguments arguments: Any?) -> AppCheck? {
        guard let args = arguments as? [String: Any],
              let appNameDart = args["appName"] as? String,
              let app = FLTFirebasePlugin.firebaseAppNamed(appNameDart) else {
            return nil
        }
        
        return AppCheck.appCheck(app: app)
    }
    
    // MARK: - FirebaseAppCheckHostApi implementation
    
    func activate(
        appName: String, 
        webProvider: AppCheckWebProvider, 
        androidProvider: AppCheckAndroidProvider, 
        appleProvider: AppCheckAppleProvider, 
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let app = FLTFirebasePlugin.firebaseAppNamed(appName) else {
            completion(.failure(NSError(domain: "firebase_app_check", code: 1, userInfo: [NSLocalizedDescriptionKey: "Firebase app not found"])))
            return
        }
        
        let factory = FLTAppCheckProviderFactory()
        factory.configure(app: app, providerName: appleProvider.providerName)
        
        AppCheck.setAppCheckProviderFactory(factory)
        completion(.success(()))
    }
    
    func getToken(appName: String, forceRefresh: Bool, completion: @escaping (Result<String?, Error>) -> Void) {
        guard let app = FLTFirebasePlugin.firebaseAppNamed(appName) else {
            completion(.failure(NSError(domain: "firebase_app_check", code: 1, userInfo: [NSLocalizedDescriptionKey: "Firebase app not found"])))
            return
        }
        
        guard let appCheck = AppCheck.appCheck(app: app) else {
            completion(.failure(NSError(domain: "firebase_app_check", code: 1, userInfo: [NSLocalizedDescriptionKey: "AppCheck instance not available"])))
            return
        }
        
        appCheck.token(forcingRefresh: forceRefresh) { token, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(token?.token))
            }
        }
    }
    
    func setTokenAutoRefreshEnabled(appName: String, isTokenAutoRefreshEnabled: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let app = FLTFirebasePlugin.firebaseAppNamed(appName) else {
            completion(.failure(NSError(domain: "firebase_app_check", code: 1, userInfo: [NSLocalizedDescriptionKey: "Firebase app not found"])))
            return
        }
        
        guard let appCheck = AppCheck.appCheck(app: app) else {
            completion(.failure(NSError(domain: "firebase_app_check", code: 1, userInfo: [NSLocalizedDescriptionKey: "AppCheck instance not available"])))
            return
        }
        
        appCheck.isTokenAutoRefreshEnabled = isTokenAutoRefreshEnabled
        completion(.success(()))
    }
    
    func getLimitedUseToken(appName: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let app = FLTFirebasePlugin.firebaseAppNamed(appName) else {
            completion(.failure(NSError(domain: "firebase_app_check", code: 1, userInfo: [NSLocalizedDescriptionKey: "Firebase app not found"])))
            return
        }
        
        guard let appCheck = AppCheck.appCheck(app: app) else {
            completion(.failure(NSError(domain: "firebase_app_check", code: 1, userInfo: [NSLocalizedDescriptionKey: "AppCheck instance not available"])))
            return
        }
        
        appCheck.limitedUseToken { token, error in
            if let error = error {
                completion(.failure(error))
            } else if let token = token?.token {
                completion(.success(token))
            } else {
                completion(.failure(NSError(domain: "firebase_app_check", code: 2, userInfo: [NSLocalizedDescriptionKey: "Token is nil"])))
            }
        }
    }
} 