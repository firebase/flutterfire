// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseAnalytics
import StoreKit

#if canImport(FlutterMacOS)
  import FlutterMacOS
#else
  import Flutter
  import UIKit
#endif

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif

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

// swift-format-ignore: AlwaysUseLowerCamelCase
let FLTFirebaseAnalyticsChannelName = "plugins.flutter.io/firebase_analytics"

/// Integration-test channel. Used by the example e2e suite to drive campaign
/// URL / universal-link handling against the live Analytics SDK.
// swift-format-ignore: AlwaysUseLowerCamelCase
let FLTFirebaseAnalyticsTestChannelName = "plugins.flutter.io/firebase_analytics_test"

extension FlutterError: Error {}

public class FirebaseAnalyticsPlugin: NSObject, FLTFirebasePluginProtocol, FlutterPlugin,
  FirebaseAnalyticsHostApi
{
  #if os(iOS)
    fileprivate var testChannel: FlutterMethodChannel?
    fileprivate static var sceneDelegateRegistered = false
    fileprivate static var lastHandledCampaignUrl: String?
  #endif

  public static func register(with registrar: any FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger

    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif

    let instance = FirebaseAnalyticsPlugin()
    FirebaseAnalyticsHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
    #if os(iOS)
      registerSceneDelegateIfAvailable(registrar, instance: instance)
      instance.registerCampaignTestChannel(registrar)
    #endif
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

  func setUserProperty(
    name: String, value: String?,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    Analytics.setUserProperty(value, forName: name)
    completion(.success(()))
  }

  func setAnalyticsCollectionEnabled(
    enabled: Bool,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    Analytics.setAnalyticsCollectionEnabled(enabled)
    completion(.success(()))
  }

  func resetAnalyticsData(completion: @escaping (Result<Void, any Error>) -> Void) {
    Analytics.resetAnalyticsData()
    completion(.success(()))
  }

  func setSessionTimeoutDuration(
    timeout: Int64,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    Analytics.setSessionTimeoutInterval(TimeInterval(timeout))
    completion(.success(()))
  }

  func setConsent(
    consent: [String: Bool?],
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    var parameters: [ConsentType: ConsentStatus] = [:]
    if let adStorage = consent[kFLTFirebaseAnalyticsAdStorageConsentGranted] as? Bool {
      parameters[.adStorage] = adStorage ? .granted : .denied
    }
    if let analyticsStorage = consent[kFLTFirebaseAnalyticsStorageConsentGranted] as? Bool {
      parameters[.analyticsStorage] = analyticsStorage ? .granted : .denied
    }
    if let adPersonalization =
      consent[kFLTFirebaseAdPersonalizationSignalsConsentGranted] as? Bool
    {
      parameters[.adPersonalization] = adPersonalization ? .granted : .denied
    }
    if let adUserData = consent[kFLTFirebaseAdUserDataConsentGranted] as? Bool {
      parameters[.adUserData] = adUserData ? .granted : .denied
    }
    Analytics.setConsent(parameters)
    completion(.success(()))
  }

  func setDefaultEventParameters(
    parameters: [String: Any?]?,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
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

  func initiateOnDeviceConversionMeasurement(
    arguments: [String: String?],
    completion:
      @escaping (Result<Void, any Error>)
      -> Void
  ) {
    if let emailAddress = arguments["emailAddress"] as? String {
      Analytics.initiateOnDeviceConversionMeasurement(emailAddress: emailAddress)
    }
    if let phoneNumber = arguments["phoneNumber"] as? String {
      Analytics.initiateOnDeviceConversionMeasurement(phoneNumber: phoneNumber)
    }
    if let hashedEmailAddress = arguments["hashedEmailAddress"] as? String,
      let data = hexStringToData(hashedEmailAddress)
    {
      Analytics.initiateOnDeviceConversionMeasurement(hashedEmailAddress: data)
    }
    if let hashedPhoneNumber = arguments["hashedPhoneNumber"] as? String,
      let data = hexStringToData(hashedPhoneNumber)
    {
      Analytics.initiateOnDeviceConversionMeasurement(hashedPhoneNumber: data)
    }
    completion(.success(()))
  }

  func logTransaction(
    transactionId: String,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    #if os(macOS)
      if #available(macOS 12.0, *) {
        logTransactionWithStoreKit(transactionId: transactionId, completion: completion)
      } else {
        completion(
          .failure(
            FlutterError(
              code: "firebase_analytics",
              message: "logTransaction() is only supported on macOS 12.0 or newer",
              details: nil
            )
          )
        )
      }
    #else
      if #available(iOS 15.0, *) {
        logTransactionWithStoreKit(transactionId: transactionId, completion: completion)
      } else {
        completion(
          .failure(
            FlutterError(
              code: "firebase_analytics",
              message: "logTransaction() is only supported on iOS 15.0 or newer",
              details: nil
            )
          )
        )
      }
    #endif
  }

  #if os(macOS)
    @available(macOS 12.0, *)
  #else
    @available(iOS 15.0, *)
  #endif
  private func logTransactionWithStoreKit(
    transactionId: String,
    completion: @escaping (Result<Void, any Error>) -> Void
  ) {
    Task {
      do {
        guard let id = UInt64(transactionId) else {
          completion(
            .failure(
              FlutterError(
                code: "firebase_analytics",
                message: "Invalid transactionId",
                details: nil
              )
            )
          )
          return
        }

        var foundTransaction: Transaction?
        for await result in Transaction.all {
          switch result {
          case .verified(let transaction):
            if transaction.id == id {
              foundTransaction = transaction
              break
            }
          case .unverified:
            continue
          }
        }

        guard let transaction = foundTransaction else {
          completion(
            .failure(
              FlutterError(
                code: "firebase_analytics",
                message: "Transaction not found",
                details: nil
              )
            )
          )
          return
        }

        Analytics.logTransaction(transaction)
        completion(.success(()))
      } catch {
        completion(.failure(error))
      }
    }
  }

  private func hexStringToData(_ hexString: String) -> Data? {
    let length = hexString.count
    guard length % 2 == 0 else { return nil }

    var data = Data(capacity: length / 2)
    var index = hexString.startIndex

    for _ in 0..<(length / 2) {
      let nextIndex = hexString.index(index, offsetBy: 2)
      guard let byte = UInt8(hexString[index..<nextIndex], radix: 16) else {
        return nil
      }
      data.append(byte)
      index = nextIndex
    }

    return data
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

#if os(iOS)
  /// Registers for UIScene callbacks when the host Flutter SDK supports it.
  ///
  /// `addSceneDelegate(_:)` and `FlutterSceneLifeCycleDelegate` were added in
  /// Flutter 3.38. Calling via `responds(to:)` keeps this plugin compiling on
  /// older Flutter versions; the methods below are unused until registration
  /// succeeds.
  private func registerSceneDelegateIfAvailable(
    _ registrar: FlutterPluginRegistrar,
    instance: FirebaseAnalyticsPlugin
  ) {
    let selector = NSSelectorFromString("addSceneDelegate:")
    guard (registrar as AnyObject).responds(to: selector) else {
      return
    }
    _ = (registrar as AnyObject).perform(selector, with: instance)
    FirebaseAnalyticsPlugin.sceneDelegateRegistered = true
  }

  /// Forwards UIScene URL and universal-link opens to Analytics.
  ///
  /// The native SDK only swizzles `UIApplicationDelegate`. Under UIScene, UIKit
  /// delivers those opens here instead, so campaign attribution (`firebase_campaign`)
  /// is lost unless we call `handleOpen` / `handleUserActivity` ourselves.
  ///
  /// Always returns `false` so later plugins (Auth, Messaging, etc.) still receive
  /// the same scene events. Selectors match `FlutterSceneLifeCycleDelegate`
  /// without conforming to that protocol, which is absent from older Flutter SDKs.
  extension FirebaseAnalyticsPlugin {
    @objc(scene:willConnectToSession:options:)
    public func scene(
      _: UIScene,
      willConnectTo _: UISceneSession,
      options connectionOptions: UIScene.ConnectionOptions?
    ) -> Bool {
      handleCampaign(urlContexts: connectionOptions?.urlContexts)
      handleCampaign(userActivities: connectionOptions?.userActivities)
      return false
    }

    @objc(scene:openURLContexts:)
    public func scene(
      _: UIScene,
      openURLContexts urlContexts: Set<UIOpenURLContext>
    ) -> Bool {
      handleCampaign(urlContexts: urlContexts)
      return false
    }

    @objc(scene:continueUserActivity:)
    public func scene(_: UIScene, continue userActivity: NSUserActivity) -> Bool {
      handleCampaign(userActivity: userActivity)
      return false
    }

    fileprivate func handleCampaign(url: URL) {
      Self.lastHandledCampaignUrl = url.absoluteString
      Analytics.handleOpen(url)
    }

    fileprivate func handleCampaign(userActivity: NSUserActivity) {
      if let url = userActivity.webpageURL {
        Self.lastHandledCampaignUrl = url.absoluteString
      }
      Analytics.handleUserActivity(userActivity)
    }

    private func handleCampaign(urlContexts: Set<UIOpenURLContext>?) {
      guard let urlContexts else { return }
      for context in urlContexts {
        handleCampaign(url: context.url)
      }
    }

    private func handleCampaign(userActivities: Set<NSUserActivity>?) {
      guard let userActivities else { return }
      for activity in userActivities {
        handleCampaign(userActivity: activity)
      }
    }

    fileprivate func registerCampaignTestChannel(_ registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(
        name: FLTFirebaseAnalyticsTestChannelName,
        binaryMessenger: registrar.messenger()
      )
      testChannel = channel
      channel.setMethodCallHandler { [weak self] call, result in
        guard let self else {
          result(
            FlutterError(
              code: "unavailable",
              message: "Plugin deallocated",
              details: nil
            )
          )
          return
        }
        self.handleTestChannel(call, result: result)
      }
    }

    private func handleTestChannel(
      _ call: FlutterMethodCall,
      result: @escaping FlutterResult
    ) {
      switch call.method {
      case "isSceneDelegateRegistered":
        result(Self.sceneDelegateRegistered)
      case "getLastHandledCampaignUrl":
        result(Self.lastHandledCampaignUrl)
      case "handleCampaignUrl":
        guard let urlString = call.arguments as? String, let url = URL(string: urlString)
        else {
          result(
            FlutterError(
              code: "invalid-argument",
              message: "Expected a URL string",
              details: nil
            )
          )
          return
        }
        handleCampaign(url: url)
        result(nil)
      case "handleCampaignUserActivity":
        guard let urlString = call.arguments as? String, let url = URL(string: urlString)
        else {
          result(
            FlutterError(
              code: "invalid-argument",
              message: "Expected a URL string",
              details: nil
            )
          )
          return
        }
        guard let scene = UIApplication.shared.connectedScenes.first else {
          result(
            FlutterError(
              code: "unavailable",
              message: "No connected UIScene",
              details: nil
            )
          )
          return
        }
        let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        activity.webpageURL = url
        _ = self.scene(scene, continue: activity)
        result(Self.lastHandledCampaignUrl)
      case "openUrl":
        guard let urlString = call.arguments as? String, let url = URL(string: urlString)
        else {
          result(
            FlutterError(
              code: "invalid-argument",
              message: "Expected a URL string",
              details: nil
            )
          )
          return
        }
        Self.lastHandledCampaignUrl = nil
        UIApplication.shared.open(url, options: [:]) { success in
          result(success)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
#endif
