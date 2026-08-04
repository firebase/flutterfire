// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseInAppMessaging

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

let kFLTFirebaseInAppMessagingChannelName = "plugins.flutter.io/firebase_in_app_messaging"

public class FirebaseInAppMessagingPlugin: NSObject, FLTFirebasePluginProtocol, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger

    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif

    let channel = FlutterMethodChannel(
      name: kFLTFirebaseInAppMessagingChannelName,
      binaryMessenger: binaryMessenger
    )
    let instance = FirebaseInAppMessagingPlugin()
    FLTFirebasePluginRegistry.sharedInstance().register(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)
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
    "flutter-fire-fiam"
  }

  @objc public func flutterChannelName() -> String {
    kFLTFirebaseInAppMessagingChannelName
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as! NSDictionary
    let inAppMessaging = InAppMessaging.inAppMessaging()

    switch call.method {
    case "FirebaseInAppMessaging#triggerEvent":
      let eventName = arguments["eventName"] as! String
      inAppMessaging.triggerEvent(eventName)
      result(nil)
    case "FirebaseInAppMessaging#setMessagesSuppressed":
      let suppress = arguments["suppress"] as? Bool ?? false
      inAppMessaging.messageDisplaySuppressed = suppress
      result(nil)
    case "FirebaseInAppMessaging#setAutomaticDataCollectionEnabled":
      let enabled = arguments["enabled"] as? Bool ?? false
      inAppMessaging.automaticDataCollectionEnabled = enabled
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
