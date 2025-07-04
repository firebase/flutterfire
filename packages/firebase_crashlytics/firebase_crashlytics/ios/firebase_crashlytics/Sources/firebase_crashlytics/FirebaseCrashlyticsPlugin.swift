// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCrashlytics
import Flutter
import Foundation

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif

// Constants
private let kFLTFirebaseCrashlyticsChannelName = "plugins.flutter.io/firebase_crashlytics"

// Argument Keys
private let kCrashlyticsArgumentException = "exception"
private let kCrashlyticsArgumentInformation = "information"
private let kCrashlyticsArgumentStackTraceElements = "stackTraceElements"
private let kCrashlyticsArgumentReason = "reason"
private let kCrashlyticsArgumentIdentifier = "identifier"
private let kCrashlyticsArgumentKey = "key"
private let kCrashlyticsArgumentValue = "value"
private let kCrashlyticsArgumentFatal = "fatal"

private let kCrashlyticsArgumentFile = "file"
private let kCrashlyticsArgumentLine = "line"
private let kCrashlyticsArgumentMethod = "method"

private let kCrashlyticsArgumentEnabled = "enabled"
private let kCrashlyticsArgumentUnsentReports = "unsentReports"
private let kCrashlyticsArgumentDidCrashOnPreviousExecution = "didCrashOnPreviousExecution"

@objc(FirebaseCrashlyticsPlugin)
public class FirebaseCrashlyticsPlugin: NSObject, FLTFirebasePluginProtocol, CrashlyticsHostApi {
  
  private override init() {
      super.init()
      // Register with the Flutter Firebase plugin registry.
    FLTFirebasePluginRegistry.sharedInstance().register(self)
    Crashlytics.crashlytics().setValue("Flutter", forKey: "developmentPlatformName")
    Crashlytics.crashlytics().setValue("-1", forKey: "developmentPlatformVersion")

  }
  
  
  // MARK: - Singleton

  // Returns a singleton instance of the Firebase Crashlytics plugin.
  public static let sharedInstance = FirebaseCrashlyticsPlugin()

  // MARK: - FlutterPlugin
  
  @objc
  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger

    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif
    CrashlyticsHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: sharedInstance)
  }
  
  func recordError(arguments: [String: Any?],
                   completion: @escaping (Result<Void, any Error>) -> Void) {
    let reason = arguments[kCrashlyticsArgumentReason] as? String
    let information = arguments[kCrashlyticsArgumentInformation] as? String
    let dartExceptionMessage = arguments[kCrashlyticsArgumentException] as? String ?? ""
    let errorElements = arguments[kCrashlyticsArgumentStackTraceElements] as? [[String: Any]] ?? []
    let fatal = arguments[kCrashlyticsArgumentFatal] as? Bool ?? false

    // Log additional information so it's captured on the Firebase Crashlytics dashboard.
    if let info = information, !info.isEmpty {
      Crashlytics.crashlytics().log(info)
    }

    // Report crash.
    var frames = [StackFrame]()
    for errorElement in errorElements {
      if let frame = generateFrame(errorElement) {
        frames.append(frame)
      }
    }

    var finalReason = ""
    if let unwrappedReason = reason {
      finalReason = "\(dartExceptionMessage). Error thrown \(unwrappedReason)."
      // Log additional custom value to match Android.
      Crashlytics.crashlytics().setCustomValue(
        "thrown \(unwrappedReason)",
        forKey: "flutter_error_reason"
      )
    } else {
      finalReason = dartExceptionMessage
    }

    if fatal {
      let timeInterval = Date().timeIntervalSince1970
      Crashlytics.crashlytics().setCustomValue(
        Int64(timeInterval),
        forKey: "com.firebase.crashlytics.flutter.fatal"
      )
    }

    // Log additional custom value to match Android.
    Crashlytics.crashlytics().setCustomValue(
      dartExceptionMessage,
      forKey: "flutter_error_exception"
    )

    let exception = ExceptionModel(name: "FlutterError", reason: finalReason)
    exception.stackTrace = frames
    exception.onDemand = true
    exception.isFatal = fatal

    if fatal {
      Crashlytics.crashlytics().record(onDemandExceptionModel: exception)
    } else {
      Crashlytics.crashlytics().record(exceptionModel: exception)
    }
    completion(.success(()))
  }

  func setCustomKey(arguments: [String: Any?],
                    completion: @escaping (Result<Void, any Error>) -> Void) {
    guard let key = arguments[kCrashlyticsArgumentKey] as? String,
          let value = arguments[kCrashlyticsArgumentValue] as? String else {
      completion(.success(()))
      return
    }

    Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    completion(.success(()))
  }

  func setUserIdentifier(arguments: [String: Any?],
                         completion: @escaping (Result<Void, any Error>) -> Void) {
    guard let identifier = arguments[kCrashlyticsArgumentIdentifier] as? String else {
      completion(.success(()))
      return
    }

    Crashlytics.crashlytics().setUserID(identifier)
    completion(.success(()))
  }

  func log(arguments: [String: Any?], completion: @escaping (Result<Void, any Error>) -> Void) {
    guard let message = arguments["message"] as? String else {
      completion(.success(()))
      return
    }

    Crashlytics.crashlytics().log(message)
    completion(.success(()))
  }

  func setCrashlyticsCollectionEnabled(arguments: [String: Bool],
                                       completion: @escaping (Result<[String: Bool]?, any Error>)
                                         -> Void) {
    guard let enabled = arguments[kCrashlyticsArgumentEnabled] else {
      completion(.success(nil))
      return
    }

    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(enabled)

    completion(.success([
      "isCrashlyticsCollectionEnabled": Crashlytics.crashlytics()
        .isCrashlyticsCollectionEnabled(),
    ]))
  }

  func checkForUnsentReports(completion: @escaping (Result<[String: Any?], any Error>) -> Void) {
    Crashlytics.crashlytics().checkForUnsentReports { unsentReports in
      completion(.success([kCrashlyticsArgumentUnsentReports: unsentReports]))
    }
  }

  func sendUnsentReports(completion: @escaping (Result<Void, any Error>) -> Void) {
    Crashlytics.crashlytics().sendUnsentReports()
    completion(.success(()))
  }

  func deleteUnsentReports(completion: @escaping (Result<Void, any Error>) -> Void) {
    Crashlytics.crashlytics().deleteUnsentReports()
    completion(.success(()))
  }

  func didCrashOnPreviousExecution(completion: @escaping (Result<[String: Any?], any Error>)
    -> Void) {
    let didCrash = Crashlytics.crashlytics().didCrashDuringPreviousExecution()
    completion(.success([kCrashlyticsArgumentDidCrashOnPreviousExecution: didCrash]))
  }

  func crash(completion: @escaping (Result<Void, any Error>) -> Void) {
    NSException(
      name: NSExceptionName("FirebaseCrashlyticsTestCrash"),
      reason: "This is a test crash caused by calling .crash() in Dart.",
      userInfo: nil
    ).raise()
  }

  // MARK: - Firebase Crashlytics API

  private func recordError(_ arguments: Any?,
                           withMethodCallResult result: FLTFirebaseMethodCallResult) {
    guard let args = arguments as? [String: Any] else {
      result.success(nil)
      return
    }

    let reason = args[kCrashlyticsArgumentReason] as? String
    let information = args[kCrashlyticsArgumentInformation] as? String
    let dartExceptionMessage = args[kCrashlyticsArgumentException] as? String ?? ""
    let errorElements = args[kCrashlyticsArgumentStackTraceElements] as? [[String: Any]] ?? []
    let fatal = args[kCrashlyticsArgumentFatal] as? Bool ?? false

    // Log additional information so it's captured on the Firebase Crashlytics dashboard.
    if let info = information, !info.isEmpty {
      Crashlytics.crashlytics().log(info)
    }

    // Report crash.
    var frames = [StackFrame]()
    for errorElement in errorElements {
      if let frame = generateFrame(errorElement) {
        frames.append(frame)
      }
    }

    var finalReason = ""
    if let unwrappedReason = reason {
      finalReason = "\(dartExceptionMessage). Error thrown \(unwrappedReason)."
      // Log additional custom value to match Android.
      Crashlytics.crashlytics().setCustomValue(
        "thrown \(unwrappedReason)",
        forKey: "flutter_error_reason"
      )
    } else {
      finalReason = dartExceptionMessage
    }

    if fatal {
      let timeInterval = Date().timeIntervalSince1970
      Crashlytics.crashlytics().setCustomValue(
        Int64(timeInterval),
        forKey: "com.firebase.crashlytics.flutter.fatal"
      )
    }

    // Log additional custom value to match Android.
    Crashlytics.crashlytics().setCustomValue(
      dartExceptionMessage,
      forKey: "flutter_error_exception"
    )

    let exception = ExceptionModel(name: "FlutterError", reason: finalReason)
    exception.stackTrace = frames
    exception.onDemand = true
    exception.isFatal = fatal

    if fatal {
      Crashlytics.crashlytics().record(onDemandExceptionModel: exception)
    } else {
      Crashlytics.crashlytics().record(exceptionModel: exception)
    }
    result.success(nil)
  }

  private func setUserIdentifier(_ arguments: Any?,
                                 withMethodCallResult result: FLTFirebaseMethodCallResult) {
    guard let args = arguments as? [String: Any],
          let identifier = args[kCrashlyticsArgumentIdentifier] as? String else {
      result.success(nil)
      return
    }

    Crashlytics.crashlytics().setUserID(identifier)
    result.success(nil)
  }

  private func setCustomKey(_ arguments: Any?,
                            withMethodCallResult result: FLTFirebaseMethodCallResult) {
    guard let args = arguments as? [String: Any],
          let key = args[kCrashlyticsArgumentKey] as? String,
          let value = args[kCrashlyticsArgumentValue] as? String else {
      result.success(nil)
      return
    }

    Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    result.success(nil)
  }

  private func log(_ arguments: Any?, withMethodCallResult result: FLTFirebaseMethodCallResult) {
    guard let args = arguments as? [String: Any],
          let message = args["message"] as? String else {
      result.success(nil)
      return
    }

    Crashlytics.crashlytics().log(message)
    result.success(nil)
  }

  private func setCrashlyticsCollectionEnabled(_ arguments: Any?,
                                               withMethodCallResult result: FLTFirebaseMethodCallResult) {
    guard let args = arguments as? [String: Any],
          let enabled = args[kCrashlyticsArgumentEnabled] as? Bool else {
      result.success(nil)
      return
    }

    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(enabled)
    result.success([
      "isCrashlyticsCollectionEnabled": Crashlytics.crashlytics()
        .isCrashlyticsCollectionEnabled,
    ])
  }

  private func checkForUnsentReports(withMethodCallResult result: FLTFirebaseMethodCallResult) {
    Crashlytics.crashlytics().checkForUnsentReports { unsentReports in
      result.success([kCrashlyticsArgumentUnsentReports: unsentReports])
    }
  }

  private func sendUnsentReports(withMethodCallResult result: FLTFirebaseMethodCallResult) {
    Crashlytics.crashlytics().sendUnsentReports()
    result.success(nil)
  }

  private func deleteUnsentReports(withMethodCallResult result: FLTFirebaseMethodCallResult) {
    Crashlytics.crashlytics().deleteUnsentReports()
    result.success(nil)
  }

  private func didCrashOnPreviousExecution(withMethodCallResult result: FLTFirebaseMethodCallResult) {
    let didCrash = Crashlytics.crashlytics().didCrashDuringPreviousExecution()
    result.success([kCrashlyticsArgumentDidCrashOnPreviousExecution: didCrash])
  }

  private func generateFrame(_ errorElement: [String: Any]) -> StackFrame? {
    guard let methodName = errorElement[kCrashlyticsArgumentMethod] as? String,
          let className = errorElement["class"] as? String,
          let file = errorElement[kCrashlyticsArgumentFile] as? String,
          let line = errorElement[kCrashlyticsArgumentLine] as? Int else {
      return nil
    }

    let symbol = "\(className).\(methodName)"
    return StackFrame(symbol: symbol, file: file, line: line)
  }

  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    // Not required for this plugin, nothing to cleanup between reloads.
    completion()
  }

  public func firebaseLibraryName() -> String {
    "flutter-fire-cls"
  }

  public func firebaseLibraryVersion() -> String {
    versionNumber
  }

  public func flutterChannelName() -> String {
    kFLTFirebaseCrashlyticsChannelName
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    ["isCrashlyticsCollectionEnabled": Crashlytics.crashlytics().isCrashlyticsCollectionEnabled]
  }
}
