// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// How an in-app message was dismissed.
enum InAppMessagingDismissType {
  /// The message was swiped away.
  ///
  /// Only reported on iOS, for banner messages.
  swipe,

  /// The user tapped a button to close the message.
  clickedCancel,

  /// The message was dismissed automatically after being displayed.
  ///
  /// Only reported on iOS, for banner messages.
  auto,

  /// The way the message was dismissed is unknown.
  ///
  /// Always reported on Android, as the Android SDK does not expose how a
  /// message was dismissed.
  unknown,
}

/// Metadata of the campaign an in-app message belongs to.
class InAppMessagingCampaignMetadata {
  const InAppMessagingCampaignMetadata({
    required this.campaignId,
    required this.campaignName,
    required this.isTestMessage,
  });

  /// The identifier of the campaign this message belongs to.
  ///
  /// This maps to `messageID` on iOS.
  final String campaignId;

  /// The name of the campaign, as entered in the Firebase console.
  final String campaignName;

  /// Whether the message was rendered as a test message ("Test on device").
  final bool isTestMessage;

  @override
  String toString() => 'InAppMessagingCampaignMetadata('
      'campaignId: $campaignId, '
      'campaignName: $campaignName, '
      'isTestMessage: $isTestMessage)';
}

/// The action attached to the button the user tapped on an in-app message.
class InAppMessagingAction {
  const InAppMessagingAction({this.actionUrl, this.buttonText});

  /// The URL the campaign asked to open, if the message defines one.
  final String? actionUrl;

  /// The text of the button that was tapped, if the message defines one.
  final String? buttonText;

  @override
  String toString() =>
      'InAppMessagingAction(actionUrl: $actionUrl, buttonText: $buttonText)';
}

/// Emitted when the user taps the action button of an in-app message.
class InAppMessagingClickEvent {
  const InAppMessagingClickEvent({
    required this.campaignMetadata,
    required this.action,
  });

  /// Metadata of the campaign the clicked message belongs to.
  final InAppMessagingCampaignMetadata campaignMetadata;

  /// The action that was triggered by the tap.
  final InAppMessagingAction action;

  @override
  String toString() => 'InAppMessagingClickEvent('
      'campaignMetadata: $campaignMetadata, action: $action)';
}

/// Emitted when an in-app message has been displayed long enough to count as
/// an impression.
class InAppMessagingImpressionEvent {
  const InAppMessagingImpressionEvent({required this.campaignMetadata});

  /// Metadata of the campaign the displayed message belongs to.
  final InAppMessagingCampaignMetadata campaignMetadata;

  @override
  String toString() =>
      'InAppMessagingImpressionEvent(campaignMetadata: $campaignMetadata)';
}

/// Emitted when an in-app message is dismissed.
class InAppMessagingDismissEvent {
  const InAppMessagingDismissEvent({
    required this.campaignMetadata,
    required this.dismissType,
  });

  /// Metadata of the campaign the dismissed message belongs to.
  final InAppMessagingCampaignMetadata campaignMetadata;

  /// How the message was dismissed.
  final InAppMessagingDismissType dismissType;

  @override
  String toString() => 'InAppMessagingDismissEvent('
      'campaignMetadata: $campaignMetadata, dismissType: $dismissType)';
}

/// Emitted when an in-app message could not be rendered.
class InAppMessagingDisplayErrorEvent {
  const InAppMessagingDisplayErrorEvent({
    required this.campaignMetadata,
    this.errorMessage,
  });

  /// Metadata of the campaign whose message failed to render.
  final InAppMessagingCampaignMetadata campaignMetadata;

  /// A description of what went wrong.
  ///
  /// On Android this is the name of the underlying
  /// `InAppMessagingErrorReason` (for example `IMAGE_FETCH_ERROR`), on iOS the
  /// localized description of the error reported by the SDK.
  final String? errorMessage;

  @override
  String toString() => 'InAppMessagingDisplayErrorEvent('
      'campaignMetadata: $campaignMetadata, errorMessage: $errorMessage)';
}
