// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
import FirebaseAnalytics

let kFLTFirebaseAnalyticsName = "name"
let kFLTFirebaseAnalyticsValue = "value"
let kFLTFirebaseAnalyticsEnabled = "enabled"
let kFLTFirebaseAnalyticsEventName = "eventName"
let kFLTFirebaseAnalyticsParameters = "parameters"
let kFLTFirebaseAnalyticsAdStorageConsentGranted = "adStorageConsentGranted"
let kFLTFirebaseAnalyticsStorageConsentGranted = "analyticsStorageConsentGranted"
let kFLTFirebaseAdPersonalizationSignalsConsentGranted = "adPersonalizationSignalsConsentGranted"
let kFLTFirebaseAdUserDataConsentGranted = "adUserDataConsentGranted"
let kFLTFirebaseAnalyticsUserId = "userId"

let FLTFirebaseAnalyticsChannelName = "plugins.flutter.io/firebase_analytics"

public class FirebaseAnalyticsPlugin: NSObject, FLTFirebasePluginProtocol, FlutterPlugin,
  FirebaseAnalyticsHostApi {
  public static func register(with registrar: any FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger

    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif

    let instance = FirebaseAnalyticsPlugin()
    FirebaseAnalyticsHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
  }

  func logEvent(event: [String: Any?], completion: @escaping (Result<Void, any Error>) -> Void) {
    guard let eventName = event[kFLTFirebaseAnalyticsEventName] as? String else {
      completion(.success(()))
      return
    }
    let parameters = event[kFLTFirebaseAnalyticsParameters] as? [String: Any]
    Analytics.logEvent(eventName, parameters: parameters)
    completion(.success(()))
  }

  func setUserId(userId: String?, completion: @escaping (Result<Void, any Error>) -> Void) {
    Analytics.setUserID(userId)
    completion(.success(()))
  }

  func setUserProperty(name: String, value: String?,
                       completion: @escaping (Result<Void, any Error>) -> Void) {
    Analytics.setUserProperty(value, forName: name)
    completion(.success(()))
  }

  func setAnalyticsCollectionEnabled(enabled: Bool,
                                     completion: @escaping (Result<Void, any Error>) -> Void) {
    Analytics.setAnalyticsCollectionEnabled(enabled)
    completion(.success(()))
  }

  func resetAnalyticsData(completion: @escaping (Result<Void, any Error>) -> Void) {
    Analytics.resetAnalyticsData()
    completion(.success(()))
  }

  func setSessionTimeoutDuration(timeout: Int64,
                                 completion: @escaping (Result<Void, any Error>) -> Void) {
    Analytics.setSessionTimeoutInterval(TimeInterval(timeout))
    completion(.success(()))
  }

  func setConsent(consent: [String: Bool?],
                  completion: @escaping (Result<Void, any Error>) -> Void) {
    var parameters: [ConsentType: ConsentStatus] = [:]
    if let adStorage = consent[kFLTFirebaseAnalyticsAdStorageConsentGranted] as? Bool {
      parameters[.adStorage] = adStorage ? .granted : .denied
    }
    if let analyticsStorage = consent[kFLTFirebaseAnalyticsStorageConsentGranted] as? Bool {
      parameters[.analyticsStorage] = analyticsStorage ? .granted : .denied
    }
    if let adPersonalization =
      consent[kFLTFirebaseAdPersonalizationSignalsConsentGranted] as? Bool {
      parameters[.adPersonalization] = adPersonalization ? .granted : .denied
    }
    if let adUserData = consent[kFLTFirebaseAdUserDataConsentGranted] as? Bool {
      parameters[.adUserData] = adUserData ? .granted : .denied
    }
    Analytics.setConsent(parameters)
    completion(.success(()))
  }

  func setDefaultEventParameters(parameters: [String: Any?]?,
                                 completion: @escaping (Result<Void, any Error>) -> Void) {
    Analytics.setDefaultEventParameters(parameters)
    completion(.success(()))
  }

  func getAppInstanceId(completion: @escaping (Result<String?, any Error>) -> Void) {
    let instanceID = Analytics.appInstanceID()
    completion(.success(instanceID))
  }

  func getSessionId(completion: @escaping (Result<Int64?, any Error>) -> Void) {
    Analytics.sessionID { sessionID, error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(sessionID))
      }
    }
  }

  func initiateOnDeviceConversionMeasurement(arguments: [String: String?],
                                             completion: @escaping (Result<Void, any Error>)
                                               -> Void) {
    if let emailAddress = arguments["emailAddress"] as? String {
      Analytics.initiateOnDeviceConversionMeasurement(emailAddress: emailAddress)
    }
    if let phoneNumber = arguments["phoneNumber"] as? String {
      Analytics.initiateOnDeviceConversionMeasurement(phoneNumber: phoneNumber)
    }
    if let hashedEmailAddress = arguments["hashedEmailAddress"] as? String,
       let data = hashedEmailAddress.data(using: .utf8) {
      Analytics.initiateOnDeviceConversionMeasurement(hashedEmailAddress: data)
    }
    if let hashedPhoneNumber = arguments["hashedPhoneNumber"] as? String,
       let data = hashedPhoneNumber.data(using: .utf8) {
      Analytics.initiateOnDeviceConversionMeasurement(hashedPhoneNumber: data)
    }
    completion(.success(()))
  }

  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    completion()
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    [:]
  }

  public func firebaseLibraryName() -> String {
    "flutter-fire-analytics"
  }

  public func firebaseLibraryVersion() -> String {
    versionNumber
  }

  public func flutterChannelName() -> String {
    FLTFirebaseAnalyticsChannelName
  }
}
