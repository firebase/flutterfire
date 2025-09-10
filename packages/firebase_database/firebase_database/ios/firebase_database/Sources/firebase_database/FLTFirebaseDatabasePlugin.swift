// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCore
import FirebaseDatabase
import Flutter
import Foundation

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif

@objc(FLTFirebaseDatabasePlugin)
public class FLTFirebaseDatabasePlugin: NSObject, FlutterPlugin, FLTFirebasePluginProtocol {
  private var binaryMessenger: FlutterBinaryMessenger
  private var hostApi: FLTFirebaseDatabaseHostApi

  init(messenger: FlutterBinaryMessenger) {
    binaryMessenger = messenger
    hostApi = FLTFirebaseDatabaseHostApi(binaryMessenger: messenger)
    super.init()
  }

  @objc public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FLTFirebaseDatabasePlugin(
      messenger: registrar.messenger()
    )

    // Set up Pigeon API
    FirebaseDatabaseHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance.hostApi)
    
    FLTFirebasePluginRegistry.sharedInstance().register(instance)

    #if !targetEnvironment(macCatalyst)
      registrar.publish(instance)
    #endif
  }

  func cleanup(completion: (() -> Void)? = nil) {
    // Cleanup is now handled by the hostApi
    completion?()
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    cleanup()
  }

  // MARK: - FLTFirebasePlugin

  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    cleanup()
    completion()
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    [:]
  }

  @objc public func firebaseLibraryName() -> String {
    "flutter-fire-rtdb"
  }

  @objc public func firebaseLibraryVersion() -> String {
    "12.0.1"
  }

  @objc public func flutterChannelName() -> String {
    "plugins.flutter.io/firebase_database"
  }

}
