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

// Firebase default app names
let kFIRDefaultAppNameIOS = "__FIRAPP_DEFAULT"
let kFIRDefaultAppNameDart = "[DEFAULT]"

/// Block that is capable of sending a success response to a method call operation.
public typealias FLTFirebaseMethodCallSuccessBlock = (Any?) -> Void

/// Block that is capable of sending an error response to a method call operation.
public typealias FLTFirebaseMethodCallErrorBlock = (String?, String?, [String: Any]?, Error?)
  -> Void

/// A protocol that all FlutterFire plugins should implement.
@objc public protocol FLTFirebasePlugin {
  /// FlutterFire plugins implementing FLTFirebasePlugin should provide this method
  /// to be notified when FirebaseCore#initializeCore was called again (first time is ignored).
  ///
  /// This can be used by plugins to know when they might need to cleanup previous
  /// resources between Hot Restarts as `initializeCore` can only be called once in Dart.
  @objc func didReinitializeFirebaseCore(completion: @escaping () -> Void)

  /// FlutterFire plugins implementing FLTFirebasePlugin must provide this method
  /// to provide it's constants that are initialized during FirebaseCore.initializeApp in Dart.
  ///
  /// - Parameter firebaseApp: The Firebase App that the plugin should return constants for.
  /// - Returns: A dictionary of constants for the plugin.
  @objc func pluginConstants(for firebaseApp: FirebaseApp) -> [String: Any]

  /// The Firebase library name of the plugin, used by FirebaseApp.registerLibrary
  /// to register this plugin with the Firebase backend.
  @objc var firebaseLibraryName: String { get }

  /// The Firebase library version of the plugin, used by FirebaseApp.registerLibrary
  /// to register this plugin with the Firebase backend.
  @objc var firebaseLibraryVersion: String { get }

  /// FlutterFire plugins implementing FLTFirebasePlugin must provide this method
  /// to provide its main method channel name, used by FirebaseCore.initializeApp
  /// in Dart to identify constants specific to a plugin.
  @objc var flutterChannelName: String { get }
}

/// An interface representing a returned result from a Flutter Method Call.
@objc public class FLTFirebaseMethodCallResult: NSObject {
  @objc public let success: FLTFirebaseMethodCallSuccessBlock
  @objc public let error: FLTFirebaseMethodCallErrorBlock

  private init(success: @escaping FLTFirebaseMethodCallSuccessBlock,
               error: @escaping FLTFirebaseMethodCallErrorBlock) {
    self.success = success
    self.error = error
    super.init()
  }

  @objc public static func create(success: @escaping FLTFirebaseMethodCallSuccessBlock,
                                  andErrorBlock error: @escaping FLTFirebaseMethodCallErrorBlock)
    -> FLTFirebaseMethodCallResult {
    FLTFirebaseMethodCallResult(success: success, error: error)
  }
}

@objc open class FLTFirebasePluginHelper: NSObject {
  /// Creates a standardized instance of FlutterError using the values returned
  /// through FLTFirebaseMethodCallErrorBlock.
  ///
  /// - Parameters:
  ///   - code: Error Code.
  ///   - message: Error Message.
  ///   - details: Optional dictionary of additional key/values to return to Dart.
  ///   - error: Optional Error that this error relates to.
  /// - Returns: FlutterError instance.
  @objc public static func createFlutterError(code: String,
                                              message: String,
                                              optionalDetails details: [String: Any]?,
                                              andOptionalError error: Error?) -> FlutterError {
    var detailsDict = details ?? [:]
    if let error = error as NSError? {
      detailsDict["nativeErrorCode"] = String(error.code)
      detailsDict["nativeErrorMessage"] = error.localizedDescription
    }
    return FlutterError(code: code, message: message, details: detailsDict)
  }

  /// Converts the '[DEFAULT]' app name used in dart and other SDKs to the
  /// '__FIRAPP_DEFAULT' iOS equivalent.
  ///
  /// If name is not '[DEFAULT]' then just returns the same name that was passed in.
  ///
  /// - Parameter appName: The name of the Firebase App.
  /// - Returns: The iOS-compatible app name.
  @objc public static func firebaseAppName(fromDartName appName: String) -> String {
    appName == kFIRDefaultAppNameDart ? kFIRDefaultAppNameIOS : appName
  }

  /// Converts the '__FIRAPP_DEFAULT' app name used in iOS to '[DEFAULT]' - used in
  /// Dart & other SDKs.
  ///
  /// If name is not '__FIRAPP_DEFAULT' then just returns the same name that was passed in.
  ///
  /// - Parameter appName: The name of the Firebase App.
  /// - Returns: The Dart-compatible app name.
  @objc public static func firebaseAppName(fromIosName appName: String) -> String {
    appName == kFIRDefaultAppNameIOS ? kFIRDefaultAppNameDart : appName
  }

  /// Retrieves a FirebaseApp instance based on the app name provided from Dart code.
  ///
  /// - Parameter appName: The name of the Firebase App.
  /// - Returns: FirebaseApp instance, or nil if it doesn't exist.
  @objc public static func firebaseApp(named appName: String) -> FirebaseApp? {
    let iosName = firebaseAppName(fromDartName: appName)
    return FirebaseApp.app(name: iosName)
  }
}
