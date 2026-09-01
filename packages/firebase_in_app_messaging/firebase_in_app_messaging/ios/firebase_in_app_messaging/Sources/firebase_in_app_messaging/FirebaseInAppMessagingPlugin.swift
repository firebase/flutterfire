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

public class FirebaseInAppMessagingPlugin: NSObject, FLTFirebasePluginProtocol, FlutterPlugin,
  FirebaseInAppMessagingHostApi
{
  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger

    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif

    let instance = FirebaseInAppMessagingPlugin()
    FLTFirebasePluginRegistry.sharedInstance().register(instance)
    FirebaseInAppMessagingHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
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

  public func triggerEvent(
    appName: String,
    eventName: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let inAppMessaging = InAppMessaging.inAppMessaging()
    inAppMessaging.triggerEvent(eventName)
    completion(.success(()))
  }

  public func setMessagesSuppressed(
    appName: String,
    suppress: Bool,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let inAppMessaging = InAppMessaging.inAppMessaging()
    inAppMessaging.messageDisplaySuppressed = suppress
    completion(.success(()))
  }

  public func setAutomaticDataCollectionEnabled(
    appName: String,
    enabled: Bool,
    completion:
      @escaping (Result<Void, Error>)
      -> Void
  ) {
    let inAppMessaging = InAppMessaging.inAppMessaging()
    inAppMessaging.automaticDataCollectionEnabled = enabled
    completion(.success(()))
  }
}
