// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCore
import Foundation

#if canImport(FirebaseCoreInternal)
import FirebaseCoreInternal
#endif

@objc public class FLTFirebasePluginRegistry: NSObject {
    private var registeredPlugins: [String: FLTFirebasePlugin] = [:]
    
    private override init() {
        super.init()
    }
    
    /// Get the shared singleton instance of the plugin registry.
    ///
    /// - Returns: Shared FLTFirebasePluginRegistry instance.
    @objc public static let shared = FLTFirebasePluginRegistry()
    
    /// For compatibility with Objective-C code
    @objc public static func sharedInstance() -> FLTFirebasePluginRegistry {
        return shared
    }
    
    /// Register a FlutterFire plugin with the plugin registry.
    ///
    /// Plugins must conform to the FLTFirebasePlugin protocol.
    ///
    /// - Parameter firebasePlugin: The plugin conforming to FLTFirebasePlugin protocol.
    @objc public func registerFirebasePlugin(_ firebasePlugin: FLTFirebasePlugin) {
        // Register the library with the Firebase backend.
        #if canImport(FirebaseCoreInternal)
        FirebaseApp.registerLibrary(withName: firebasePlugin.firebaseLibraryName,
                                    withVersion: firebasePlugin.firebaseLibraryVersion)
        #endif
        
        // Store the plugin delegate for later usage.
        registeredPlugins[firebasePlugin.flutterChannelName] = firebasePlugin
    }
    
    /// Each FlutterFire plugin implementing FLTFirebasePlugin provides this method,
    /// allowing its constants to be initialized during FirebaseCore.initializeApp in Dart.
    /// Here we call this method on each of the registered plugins and gather their constants for use in Dart.
    ///
    /// Constants for specific plugins are stored using the Flutter plugins channel name as the key.
    ///
    /// - Parameter firebaseApp: Firebase App instance these constants relate to.
    /// - Returns: Dictionary of plugins and their constants.
    @objc public func pluginConstants(forFIRApp firebaseApp: FirebaseApp) -> [String: Any] {
        var pluginConstants: [String: Any] = [:]
        
        for (channelName, plugin) in registeredPlugins {
            pluginConstants[channelName] = plugin.pluginConstants(for: firebaseApp)
        }
        
        return pluginConstants
    }
    
    /// Each FlutterFire plugin implementing this method are notified that
    /// FirebaseCore#initializeCore was called again.
    ///
    /// This is used by plugins to know if they need to cleanup previous
    /// resources between Hot Restarts as `initializeCore` can only be called once in Dart.
    ///
    /// - Parameter completion: Completion handler called when all plugins have completed.
    @objc public func didReinitializeFirebaseCore(completion: @escaping () -> Void) {
        var pluginsCompleted = 0
        let pluginsCount = registeredPlugins.count
        
        let allPluginsCompletion: () -> Void = {
            pluginsCompleted += 1
            if pluginsCompleted == pluginsCount {
                completion()
            }
        }
        
        for plugin in registeredPlugins.values {
            plugin.didReinitializeFirebaseCore(completion: allPluginsCompletion)
        }
    }
}

