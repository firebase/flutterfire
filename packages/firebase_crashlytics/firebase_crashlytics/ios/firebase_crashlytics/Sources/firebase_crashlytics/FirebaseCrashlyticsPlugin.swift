// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseCrashlytics

#if canImport(firebase_crashlytics_objc)
  import firebase_crashlytics_objc
#endif

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

public class FirebaseCrashlyticsPlugin: NSObject, FLTFirebasePluginProtocol, FlutterPlugin,
  FlutterStreamHandler, FirebaseCrashlyticsHostApi
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

    let instance = shared
    FLTFirebasePluginRegistry.sharedInstance().register(instance)
    CrashlyticsPlatformHelpers.setDevelopmentPlatformName("Flutter", version: "-1")
    FirebaseCrashlyticsHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)

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

  // MARK: - FirebaseCrashlyticsHostApi

  func checkForUnsentReports(completion: @escaping (Result<Bool, Error>) -> Void) {
    Crashlytics.crashlytics().checkForUnsentReports { unsentReports in
      completion(.success(unsentReports))
    }
  }

  func crash(completion: @escaping (Result<Void, Error>) -> Void) {
    NSException(
      name: NSExceptionName("FirebaseCrashlyticsTestCrash"),
      reason: "This is a test crash caused by calling .crash() in Dart.",
      userInfo: nil
    ).raise()
  }

  func deleteUnsentReports(completion: @escaping (Result<Void, Error>) -> Void) {
    Crashlytics.crashlytics().deleteUnsentReports()
    completion(.success(()))
  }

  func didCrashOnPreviousExecution(completion: @escaping (Result<Bool, Error>) -> Void) {
    completion(.success(Crashlytics.crashlytics().didCrashDuringPreviousExecution()))
  }

  func recordError(
    request: RecordErrorRequest,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    var reason = request.reason
    let information = request.information
    let dartExceptionMessage = request.exception
    let fatal = request.fatal

    if !information.isEmpty {
      Crashlytics.crashlytics().log(information)
    }

    var frames: [StackFrame] = []
    for errorElement in request.stackTraceElements {
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
    completion(.success(()))
  }

  func log(message: String, completion: @escaping (Result<Void, Error>) -> Void) {
    Crashlytics.crashlytics().log(message)
    completion(.success(()))
  }

  func sendUnsentReports(completion: @escaping (Result<Void, Error>) -> Void) {
    Crashlytics.crashlytics().sendUnsentReports()
    completion(.success(()))
  }

  func setCrashlyticsCollectionEnabled(
    enabled: Bool,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(enabled)
    completion(.success(Crashlytics.crashlytics().isCrashlyticsCollectionEnabled()))
  }

  func setUserIdentifier(
    identifier: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    Crashlytics.crashlytics().setUserID(identifier)
    completion(.success(()))
  }

  func setCustomKey(
    key: String,
    value: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    completion(.success(()))
  }

  // MARK: - Utilities

  private func generateFrame(errorElement: CrashlyticsStackFrame) -> StackFrame {
    let methodName = errorElement.method
    let className = errorElement.className ?? ""
    let symbol = "\(className).\(methodName)"
    let file = errorElement.file
    let line = Int(errorElement.line) ?? 0
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
