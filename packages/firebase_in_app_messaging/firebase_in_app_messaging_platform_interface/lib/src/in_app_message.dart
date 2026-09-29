// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'events.dart';

/// Layout chosen for the campaign in the Firebase Console.
enum InAppMessageType {
  /// Top or bottom banner.
  banner,

  /// Centered modal.
  modal,

  /// Card with optional portrait and landscape images.
  card,

  /// Image with an optional tap action.
  imageOnly,

  /// Unrecognized native message type.
  unknown,
}

/// Styled text from a campaign.
class InAppMessageText {
  /// Creates an [InAppMessageText].
  const InAppMessageText({
    required this.text,
    this.hexColor,
  });

  /// Visible copy.
  final String text;

  /// Optional `#RRGGBB` or `#AARRGGBB` color from the console.
  final String? hexColor;
}

/// A campaign action used when rendering with a custom Flutter UI.
class InAppMessageAction {
  /// Creates an [InAppMessageAction].
  const InAppMessageAction({
    required this.id,
    this.actionUrl,
    this.buttonText,
    this.buttonTextHexColor,
    this.buttonBackgroundHexColor,
  });

  /// Plugin-generated id used when reporting a click to native.
  final String id;

  /// URL or deep link from the console. The plugin does not open this.
  final String? actionUrl;

  /// Button label, if the layout has a button.
  final String? buttonText;

  /// Optional `#RRGGBB` or `#AARRGGBB` button text color.
  final String? buttonTextHexColor;

  /// Optional `#RRGGBB` or `#AARRGGBB` button background color.
  final String? buttonBackgroundHexColor;
}

/// A campaign the native SDK decided to show, forwarded for Flutter rendering.
///
/// Only delivered after `setCustomDisplayEnabled(true)`. Call [impress],
/// [click], [dismiss], or [reportError] so analytics and frequency capping
/// keep working.
class InAppMessage {
  /// Creates an [InAppMessage].
  InAppMessage({
    required this.campaignMetadata,
    required this.messageType,
    this.title,
    this.body,
    this.imageUrl,
    this.landscapeImageUrl,
    this.backgroundHexColor,
    this.action,
    this.primaryAction,
    this.secondaryAction,
    this.data = const <String, String>{},
    required Future<void> Function() onImpress,
    required Future<void> Function(InAppMessageAction action) onClick,
    required Future<void> Function(InAppMessagingDismissType type) onDismiss,
    required Future<void> Function(String reason) onError,
  })  : _onImpress = onImpress,
        _onClick = onClick,
        _onDismiss = onDismiss,
        _onError = onError;

  final Future<void> Function() _onImpress;
  final Future<void> Function(InAppMessageAction action) _onClick;
  final Future<void> Function(InAppMessagingDismissType type) _onDismiss;
  final Future<void> Function(String reason) _onError;
  bool _terminal = false;

  /// Campaign id, name, and test-message flag.
  final InAppMessagingCampaignMetadata campaignMetadata;

  /// Console layout type.
  final InAppMessageType messageType;

  /// Title copy and color.
  final InAppMessageText? title;

  /// Body copy and color.
  final InAppMessageText? body;

  /// Image URL for banner, modal, image-only, and card portrait.
  final String? imageUrl;

  /// Landscape image URL for card campaigns.
  final String? landscapeImageUrl;

  /// Optional `#RRGGBB` or `#AARRGGBB` background color.
  final String? backgroundHexColor;

  /// Single action for banner, modal, and image-only layouts.
  final InAppMessageAction? action;

  /// Primary action for card layouts.
  final InAppMessageAction? primaryAction;

  /// Secondary action for card layouts.
  final InAppMessageAction? secondaryAction;

  /// Custom key/value metadata from the console campaign.
  final Map<String, String> data;

  /// Reports that the user saw the message (frequency capping).
  Future<void> impress() => _onImpress();

  /// Reports that the user followed [action]. Does not open [actionUrl].
  Future<void> click(InAppMessageAction action) async {
    if (_terminal) {
      return;
    }
    _terminal = true;
    await _onClick(action);
  }

  /// Reports that the message was dismissed without following an action.
  Future<void> dismiss([
    InAppMessagingDismissType type = InAppMessagingDismissType.clickedCancel,
  ]) async {
    if (_terminal) {
      return;
    }
    _terminal = true;
    await _onDismiss(type);
  }

  /// Reports that Flutter failed to display the message (for example image load).
  Future<void> reportError(String reason) async {
    if (_terminal) {
      return;
    }
    _terminal = true;
    await _onError(reason);
  }
}
