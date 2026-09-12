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
  private var flutterApi: FirebaseInAppMessagingFlutterApi?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger

    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif

    let instance = FirebaseInAppMessagingPlugin()
    instance.flutterApi = FirebaseInAppMessagingFlutterApi(binaryMessenger: binaryMessenger)
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

  public func addEventListeners(
    appName: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    // `delegate` is a weak reference, this instance is retained by
    // `FLTFirebasePluginRegistry`.
    InAppMessaging.inAppMessaging().delegate = self
    completion(.success(()))
  }
}

/// The delegate callbacks are documented as being called on the main thread,
/// which is also where the Pigeon channels have to be used.
extension FirebaseInAppMessagingPlugin: InAppMessagingDisplayDelegate {
  public func messageClicked(
    _ inAppMessage: InAppMessagingDisplayMessage,
    with action: InAppMessagingAction
  ) {
    flutterApi?.onMessageClicked(
      campaignMetadata: Self.campaignMetadata(inAppMessage),
      action: FiamAction(
        actionUrl: action.actionURL?.absoluteString,
        buttonText: action.actionText
      )
    ) { _ in }
  }

  public func impressionDetected(for inAppMessage: InAppMessagingDisplayMessage) {
    flutterApi?.onMessageImpression(
      campaignMetadata: Self.campaignMetadata(inAppMessage)
    ) { _ in }
  }

  public func messageDismissed(
    _ inAppMessage: InAppMessagingDisplayMessage,
    dismissType: InAppMessagingDismissType
  ) {
    flutterApi?.onMessageDismissed(
      campaignMetadata: Self.campaignMetadata(inAppMessage),
      dismissType: Self.dismissType(dismissType)
    ) { _ in }
  }

  public func displayError(
    for inAppMessage: InAppMessagingDisplayMessage,
    error: Error
  ) {
    flutterApi?.onMessageDisplayError(
      campaignMetadata: Self.campaignMetadata(inAppMessage),
      errorMessage: error.localizedDescription
    ) { _ in }
  }

  private static func campaignMetadata(_ inAppMessage: InAppMessagingDisplayMessage)
    -> FiamCampaignMetadata
  {
    FiamCampaignMetadata(
      campaignId: inAppMessage.campaignInfo.messageID,
      campaignName: inAppMessage.campaignInfo.campaignName,
      isTestMessage: inAppMessage.campaignInfo.renderAsTestMessage
    )
  }

  private static func dismissType(_ dismissType: InAppMessagingDismissType) -> FiamDismissType {
    switch dismissType {
    case .typeUserSwipe:
      return .swipe
    case .typeUserTapClose:
      return .clickedCancel
    case .typeAuto:
      return .auto
    default:
      return .unknown
    }
  }
}
