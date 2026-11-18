// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseInAppMessaging
import UIKit

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
  private var customDisplayEnabled = false
  private var pendingMessage: InAppMessagingDisplayMessage?
  private var pendingDelegate: InAppMessagingDisplayDelegate?
  private var pendingActions: [String: InAppMessagingAction] = [:]
  /// The SDK's original display component. `messageDisplayComponent` is non-null
  /// in Swift, so disable restores this instead of assigning `nil`.
  private var defaultDisplayComponent: (any InAppMessagingDisplay)?

  /// Retained so `messageDisplayComponent` is not deallocated.
  private static var sharedInstance: FirebaseInAppMessagingPlugin?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger: FlutterBinaryMessenger

    #if os(macOS)
      binaryMessenger = registrar.messenger
    #elseif os(iOS)
      binaryMessenger = registrar.messenger()
    #endif

    let instance = FirebaseInAppMessagingPlugin()
    instance.flutterApi = FirebaseInAppMessagingFlutterApi(binaryMessenger: binaryMessenger)
    sharedInstance = instance
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

  public func setCustomDisplayEnabled(
    appName: String,
    enabled: Bool,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    customDisplayEnabled = enabled
    let inAppMessaging = InAppMessaging.inAppMessaging()
    if enabled {
      if defaultDisplayComponent == nil,
        !(inAppMessaging.messageDisplayComponent is FirebaseInAppMessagingPlugin)
      {
        defaultDisplayComponent = inAppMessaging.messageDisplayComponent
      }
      inAppMessaging.messageDisplayComponent = self
    } else if let original = defaultDisplayComponent {
      inAppMessaging.messageDisplayComponent = original
      dismissPending(type: .typeAuto)
    } else {
      dismissPending(type: .typeAuto)
    }
    completion(.success(()))
  }

  public func reportImpression(
    campaignId: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    if let message = pendingMessage, let delegate = pendingDelegate {
      delegate.impressionDetected?(for: message)
    }
    completion(.success(()))
  }

  public func reportClick(
    campaignId: String,
    actionId: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    if let message = pendingMessage, let delegate = pendingDelegate {
      if let action = pendingActions[actionId] {
        delegate.messageClicked?(message, with: action)
      } else {
        delegate.messageDismissed?(message, dismissType: .typeUserTapClose)
      }
    }
    clearPending()
    completion(.success(()))
  }

  public func reportDismiss(
    campaignId: String,
    dismissType: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    dismissPending(type: nativeDismissType(dismissType))
    completion(.success(()))
  }

  public func reportDisplayError(
    campaignId: String,
    reason: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    if let message = pendingMessage, let delegate = pendingDelegate {
      let error = NSError(
        domain: "firebase_in_app_messaging",
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: reason]
      )
      delegate.displayError?(for: message, error: error)
    }
    clearPending()
    completion(.success(()))
  }

  private func dismissPending(type: InAppMessagingDismissType) {
    if let message = pendingMessage, let delegate = pendingDelegate {
      delegate.messageDismissed?(message, dismissType: type)
    }
    clearPending()
  }

  private func clearPending() {
    pendingMessage = nil
    pendingDelegate = nil
    pendingActions = [:]
  }

  private func nativeDismissType(_ dismissType: String) -> InAppMessagingDismissType {
    switch dismissType {
    case "auto":
      return .typeAuto
    case "swipe":
      return .typeUserSwipe
    default:
      return .typeUserTapClose
    }
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

  fileprivate static func campaignMetadata(_ inAppMessage: InAppMessagingDisplayMessage)
    -> FiamCampaignMetadata
  {
    FiamCampaignMetadata(
      campaignId: inAppMessage.campaignInfo.messageID,
      campaignName: inAppMessage.campaignInfo.campaignName,
      isTestMessage: inAppMessage.campaignInfo.renderAsTestMessage
    )
  }

  fileprivate static func dismissType(_ dismissType: InAppMessagingDismissType) -> FiamDismissType {
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

extension FirebaseInAppMessagingPlugin: InAppMessagingDisplay {
  public func displayMessage(
    _ messageForDisplay: InAppMessagingDisplayMessage,
    displayDelegate: InAppMessagingDisplayDelegate
  ) {
    DispatchQueue.main.async { [weak self] in
      self?.handleDisplay(messageForDisplay, displayDelegate: displayDelegate)
    }
  }

  private func handleDisplay(
    _ messageForDisplay: InAppMessagingDisplayMessage,
    displayDelegate: InAppMessagingDisplayDelegate
  ) {
    guard customDisplayEnabled else {
      displayDelegate.messageDismissed?(messageForDisplay, dismissType: .typeAuto)
      return
    }

    let payload = Self.toDisplayMessage(messageForDisplay)
    pendingMessage = messageForDisplay
    pendingDelegate = displayDelegate
    pendingActions = Self.collectActions(messageForDisplay)
    flutterApi?.onMessageDisplay(message: payload) { _ in }
  }

  private static func toDisplayMessage(_ message: InAppMessagingDisplayMessage)
    -> FiamDisplayMessage
  {
    let metadata = campaignMetadata(message)
    let campaignId = metadata.campaignId

    if let modal = message as? InAppMessagingModalDisplay {
      return FiamDisplayMessage(
        campaignMetadata: metadata,
        messageType: "MODAL",
        title: FiamText(text: modal.title, hexColor: hexString(from: modal.textColor)),
        body: modal.bodyText.map { FiamText(text: $0, hexColor: hexString(from: modal.textColor)) },
        imageUrl: modal.imageData?.imageURL,
        landscapeImageUrl: nil,
        backgroundHexColor: hexString(from: modal.displayBackgroundColor),
        action: displayAction(
          id: "\(campaignId)_action",
          text: modal.actionButton?.buttonText,
          textColor: modal.actionButton?.buttonTextColor,
          backgroundColor: modal.actionButton?.buttonBackgroundColor,
          url: modal.actionURL
        ),
        primaryAction: nil,
        secondaryAction: nil,
        data: appData(message)
      )
    }

    if let banner = message as? InAppMessagingBannerDisplay {
      return FiamDisplayMessage(
        campaignMetadata: metadata,
        messageType: "BANNER",
        title: FiamText(text: banner.title, hexColor: hexString(from: banner.textColor)),
        body: banner.bodyText.map {
          FiamText(text: $0, hexColor: hexString(from: banner.textColor))
        },
        imageUrl: banner.imageData?.imageURL,
        landscapeImageUrl: nil,
        backgroundHexColor: hexString(from: banner.displayBackgroundColor),
        action: displayAction(
          id: "\(campaignId)_action",
          text: nil,
          textColor: nil,
          backgroundColor: nil,
          url: banner.actionURL
        ),
        primaryAction: nil,
        secondaryAction: nil,
        data: appData(message)
      )
    }

    if let card = message as? InAppMessagingCardDisplay {
      return FiamDisplayMessage(
        campaignMetadata: metadata,
        messageType: "CARD",
        title: FiamText(text: card.title, hexColor: hexString(from: card.textColor)),
        body: card.body.map { FiamText(text: $0, hexColor: hexString(from: card.textColor)) },
        imageUrl: card.portraitImageData.imageURL,
        landscapeImageUrl: card.landscapeImageData?.imageURL,
        backgroundHexColor: hexString(from: card.displayBackgroundColor),
        action: nil,
        primaryAction: displayAction(
          id: "\(campaignId)_primary",
          text: card.primaryActionButton.buttonText,
          textColor: card.primaryActionButton.buttonTextColor,
          backgroundColor: card.primaryActionButton.buttonBackgroundColor,
          url: card.primaryActionURL
        ),
        secondaryAction: displayAction(
          id: "\(campaignId)_secondary",
          text: card.secondaryActionButton?.buttonText,
          textColor: card.secondaryActionButton?.buttonTextColor,
          backgroundColor: card.secondaryActionButton?.buttonBackgroundColor,
          url: card.secondaryActionURL
        ),
        data: appData(message)
      )
    }

    if let imageOnly = message as? InAppMessagingImageOnlyDisplay {
      return FiamDisplayMessage(
        campaignMetadata: metadata,
        messageType: "IMAGE_ONLY",
        title: nil,
        body: nil,
        imageUrl: imageOnly.imageData.imageURL,
        landscapeImageUrl: nil,
        backgroundHexColor: nil,
        action: displayAction(
          id: "\(campaignId)_action",
          text: nil,
          textColor: nil,
          backgroundColor: nil,
          url: imageOnly.actionURL
        ),
        primaryAction: nil,
        secondaryAction: nil,
        data: appData(message)
      )
    }

    return FiamDisplayMessage(
      campaignMetadata: metadata,
      messageType: "UNKNOWN",
      title: nil,
      body: nil,
      imageUrl: nil,
      landscapeImageUrl: nil,
      backgroundHexColor: nil,
      action: nil,
      primaryAction: nil,
      secondaryAction: nil,
      data: appData(message)
    )
  }

  private static func collectActions(_ message: InAppMessagingDisplayMessage)
    -> [String: InAppMessagingAction]
  {
    let campaignId = campaignMetadata(message).campaignId
    var actions: [String: InAppMessagingAction] = [:]

    if let modal = message as? InAppMessagingModalDisplay {
      actions["\(campaignId)_action"] = InAppMessagingAction(
        actionText: modal.actionButton?.buttonText,
        actionURL: modal.actionURL
      )
    } else if let banner = message as? InAppMessagingBannerDisplay {
      actions["\(campaignId)_action"] = InAppMessagingAction(
        actionText: nil,
        actionURL: banner.actionURL
      )
    } else if let card = message as? InAppMessagingCardDisplay {
      actions["\(campaignId)_primary"] = InAppMessagingAction(
        actionText: card.primaryActionButton.buttonText,
        actionURL: card.primaryActionURL
      )
      if let secondary = card.secondaryActionButton {
        actions["\(campaignId)_secondary"] = InAppMessagingAction(
          actionText: secondary.buttonText,
          actionURL: card.secondaryActionURL
        )
      }
    } else if let imageOnly = message as? InAppMessagingImageOnlyDisplay {
      actions["\(campaignId)_action"] = InAppMessagingAction(
        actionText: nil,
        actionURL: imageOnly.actionURL
      )
    }

    return actions
  }

  private static func displayAction(
    id: String,
    text: String?,
    textColor: UIColor?,
    backgroundColor: UIColor?,
    url: URL?
  ) -> FiamDisplayAction? {
    if text == nil, url == nil {
      return nil
    }
    return FiamDisplayAction(
      id: id,
      actionUrl: url?.absoluteString,
      buttonText: text,
      buttonTextHexColor: textColor.map { hexString(from: $0) },
      buttonBackgroundHexColor: backgroundColor.map { hexString(from: $0) }
    )
  }

  private static func appData(_ message: InAppMessagingDisplayMessage) -> [String?: String?]? {
    guard let appData = message.appData, !appData.isEmpty else { return nil }
    var mapped: [String?: String?] = [:]
    for (key, value) in appData {
      mapped[String(describing: key)] = String(describing: value)
    }
    return mapped
  }

  private static func hexString(from color: UIColor) -> String {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    if alpha < 1 {
      return String(
        format: "#%02X%02X%02X%02X",
        Int(alpha * 255),
        Int(red * 255),
        Int(green * 255),
        Int(blue * 255)
      )
    }
    return String(
      format: "#%02X%02X%02X",
      Int(red * 255),
      Int(green * 255),
      Int(blue * 255)
    )
  }
}
