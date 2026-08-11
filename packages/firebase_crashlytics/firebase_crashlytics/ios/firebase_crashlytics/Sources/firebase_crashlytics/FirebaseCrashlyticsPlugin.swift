// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCrashlytics

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

private let kFLTFirebaseCrashlyticsChannelName = "plugins.flutter.io/firebase_crashlytics"
private let kFLTFirebaseCrashlyticsTestChannelName =
  "plugins.flutter.io/firebase_crashlytics_test_stream"

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

public class FirebaseCrashlyticsPlugin: NSObject, FLTFirebasePluginProtocol, FlutterPlugin,
  FlutterStreamHandler
{
  private var testEventChannel: FlutterEventChannel?
  private var testEventSink: FlutterEventSink?

  private static let shared = FirebaseCrashlyticsPlugin()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger

    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif

    let channel = FlutterMethodChannel(
      name: kFLTFirebaseCrashlyticsChannelName,
      binaryMessenger: binaryMessenger
    )

    let instance = shared
    FLTFirebasePluginRegistry.sharedInstance().register(instance)
    CrashlyticsPlatformHelpers.setDevelopmentPlatformName("Flutter", version: "-1")
    registrar.addMethodCallDelegate(instance, channel: channel)

    instance.testEventChannel = FlutterEventChannel(
      name: kFLTFirebaseCrashlyticsTestChannelName,
      binaryMessenger: binaryMessenger
    )
    instance.testEventChannel?.setStreamHandler(instance)
  }

  public func firebaseLibraryVersion() -> String {
    versionNumber
  }

  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    completion()
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    [
      "isCrashlyticsCollectionEnabled": Crashlytics.crashlytics().isCrashlyticsCollectionEnabled()
    ]
  }

  @objc public func firebaseLibraryName() -> String {
    "flutter-fire-cls"
  }

  @objc public func flutterChannelName() -> String {
    kFLTFirebaseCrashlyticsChannelName
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any] ?? [:]

    switch call.method {
    case "Crashlytics#recordError":
      recordError(arguments: arguments, result: result)
    case "Crashlytics#setUserIdentifier":
      setUserIdentifier(arguments: arguments, result: result)
    case "Crashlytics#setCustomKey":
      setCustomKey(arguments: arguments, result: result)
    case "Crashlytics#log":
      log(arguments: arguments, result: result)
    case "Crashlytics#crash":
      NSException(
        name: NSExceptionName("FirebaseCrashlyticsTestCrash"),
        reason: "This is a test crash caused by calling .crash() in Dart.",
        userInfo: nil
      ).raise()
    case "Crashlytics#setCrashlyticsCollectionEnabled":
      setCrashlyticsCollectionEnabled(arguments: arguments, result: result)
    case "Crashlytics#checkForUnsentReports":
      checkForUnsentReports(result: result)
    case "Crashlytics#sendUnsentReports":
      sendUnsentReports(result: result)
    case "Crashlytics#deleteUnsentReports":
      deleteUnsentReports(result: result)
    case "Crashlytics#didCrashOnPreviousExecution":
      didCrashOnPreviousExecution(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Firebase Crashlytics API

  private func recordError(arguments: [String: Any], result: @escaping FlutterResult) {
    var reason = arguments[kCrashlyticsArgumentReason] as? String
    let information = arguments[kCrashlyticsArgumentInformation] as? String ?? ""
    let dartExceptionMessage = arguments[kCrashlyticsArgumentException] as? String ?? ""
    let errorElements =
      arguments[kCrashlyticsArgumentStackTraceElements] as? [[String: Any]] ?? []
    let fatal = (arguments[kCrashlyticsArgumentFatal] as? NSNumber)?.boolValue ?? false

    if !information.isEmpty {
      Crashlytics.crashlytics().log(information)
    }

    var frames: [StackFrame] = []
    for errorElement in errorElements {
      frames.append(generateFrame(errorElement: errorElement))
    }

    if let reasonValue = reason {
      let crashlyticsErrorReason = "thrown \(reasonValue)"
      testEventSink?(crashlyticsErrorReason)
      Crashlytics.crashlytics().setCustomValue(
        crashlyticsErrorReason,
        forKey: "flutter_error_reason"
      )
      reason = "\(dartExceptionMessage). Error thrown \(reasonValue)."
    } else {
      reason = dartExceptionMessage
    }

    if fatal {
      let timeInterval = Date().timeIntervalSince1970
      Crashlytics.crashlytics().setCustomValue(
        Int(timeInterval.rounded()),
        forKey: "com.firebase.crashlytics.flutter.fatal"
      )
    }

    Crashlytics.crashlytics().setCustomValue(
      dartExceptionMessage,
      forKey: "flutter_error_exception"
    )

    let exception = ExceptionModel(name: "FlutterError", reason: reason ?? "")
    exception.stackTrace = frames
    CrashlyticsPlatformHelpers.record(exception, fatal: fatal)
    result(nil)
  }

  private func setUserIdentifier(arguments: [String: Any], result: @escaping FlutterResult) {
    let identifier = arguments[kCrashlyticsArgumentIdentifier] as? String ?? ""
    Crashlytics.crashlytics().setUserID(identifier)
    result(nil)
  }

  private func setCustomKey(arguments: [String: Any], result: @escaping FlutterResult) {
    let key = arguments[kCrashlyticsArgumentKey] as? String ?? ""
    let value = arguments[kCrashlyticsArgumentValue] as? String ?? ""
    Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    result(nil)
  }

  private func log(arguments: [String: Any], result: @escaping FlutterResult) {
    let message = arguments["message"] as? String ?? ""
    Crashlytics.crashlytics().log(message)
    result(nil)
  }

  private func setCrashlyticsCollectionEnabled(
    arguments: [String: Any],
    result: @escaping FlutterResult
  ) {
    let enabled = (arguments[kCrashlyticsArgumentEnabled] as? NSNumber)?.boolValue ?? false
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(enabled)
    result([
      "isCrashlyticsCollectionEnabled": Crashlytics.crashlytics().isCrashlyticsCollectionEnabled()
    ])
  }

  private func checkForUnsentReports(result: @escaping FlutterResult) {
    Crashlytics.crashlytics().checkForUnsentReports { unsentReports in
      result([kCrashlyticsArgumentUnsentReports: unsentReports])
    }
  }

  private func sendUnsentReports(result: @escaping FlutterResult) {
    Crashlytics.crashlytics().sendUnsentReports()
    result(nil)
  }

  private func deleteUnsentReports(result: @escaping FlutterResult) {
    Crashlytics.crashlytics().deleteUnsentReports()
    result(nil)
  }

  private func didCrashOnPreviousExecution(result: @escaping FlutterResult) {
    let didCrash = Crashlytics.crashlytics().didCrashDuringPreviousExecution()
    result([kCrashlyticsArgumentDidCrashOnPreviousExecution: didCrash])
  }

  // MARK: - Utilities

  private func generateFrame(errorElement: [String: Any]) -> StackFrame {
    let methodName = errorElement[kCrashlyticsArgumentMethod] as? String ?? ""
    let className = errorElement["class"] as? String ?? ""
    let symbol = "\(className).\(methodName)"
    let file = errorElement[kCrashlyticsArgumentFile] as? String ?? ""
    let line = (errorElement[kCrashlyticsArgumentLine] as? NSNumber)?.intValue ?? 0
    return StackFrame(symbol: symbol, file: file, line: line)
  }

  // MARK: - FlutterStreamHandler

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    testEventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    testEventSink = nil
    return nil
  }
}
