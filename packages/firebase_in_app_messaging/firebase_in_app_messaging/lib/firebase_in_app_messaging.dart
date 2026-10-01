// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePlugin;
import 'package:firebase_in_app_messaging_platform_interface/firebase_in_app_messaging_platform_interface.dart';

export 'package:firebase_in_app_messaging_platform_interface/firebase_in_app_messaging_platform_interface.dart'
    show
        InAppMessagingAction,
        InAppMessagingCampaignMetadata,
        InAppMessagingClickEvent,
        InAppMessagingDismissEvent,
        InAppMessagingDismissType,
        InAppMessagingDisplayErrorEvent,
        InAppMessagingImpressionEvent,
        InAppMessage,
        InAppMessageAction,
        InAppMessageText,
        InAppMessageType;

class FirebaseInAppMessaging extends FirebasePlugin {
  FirebaseInAppMessaging._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_in_app_messaging');

  /// The [FirebaseApp] for this current [FirebaseAnalytics] instance.
  final FirebaseApp app;

  // Cached and lazily loaded instance of [FirebaseInAppMessagingPlatform] to avoid
  // creating a [MethodChannelFirebaseInAppMessaging] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseInAppMessagingPlatform? _delegatePackingProperty;

  FirebaseInAppMessagingPlatform get _delegate {
    return _delegatePackingProperty ??=
        FirebaseInAppMessagingPlatform.instanceFor(app: app);
  }

  static final Map<String, FirebaseInAppMessaging> _cachedInstances = {};

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseInAppMessaging get instance {
    return FirebaseInAppMessaging._instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp].
  static FirebaseInAppMessaging _instanceFor({required FirebaseApp app}) {
    if (_cachedInstances.containsKey(app.name)) {
      return _cachedInstances[app.name]!;
    }

    FirebaseInAppMessaging newInstance = FirebaseInAppMessaging._(app: app);
    _cachedInstances[app.name] = newInstance;

    return newInstance;
  }

  /// Programmatically trigger a contextual trigger.
  Future<void> triggerEvent(String eventName) {
    return _delegate.triggerEvent(eventName);
  }

  /// Enable or disable suppression of Firebase In App Messaging messages.
  ///
  /// When enabled, no in app messages will be rendered until either you either
  /// disable suppression, or the app restarts, as this state is not preserved
  /// over app restarts.
  Future<void> setMessagesSuppressed(bool suppress) {
    return _delegate.setMessagesSuppressed(suppress);
  }

  /// Determine whether automatic data collection is enabled or not.
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) {
    return _delegate.setAutomaticDataCollectionEnabled(enabled);
  }

  /// Notifies when the user taps the action button of an in-app message.
  ///
  /// Use [InAppMessagingClickEvent.action] to know which URL the campaign
  /// asked to open, and [InAppMessagingClickEvent.campaignMetadata] to know
  /// which campaign the message came from.
  ///
  /// Listening to any of the message lifecycle streams makes the plugin become
  /// the `InAppMessaging` display delegate on iOS. If your app also sets that
  /// delegate from native code, the one set last wins.
  Stream<InAppMessagingClickEvent> get onMessageClicked =>
      _delegate.onMessageClicked;

  /// Notifies when an in-app message has been displayed long enough to count
  /// as an impression.
  Stream<InAppMessagingImpressionEvent> get onMessageImpression =>
      _delegate.onMessageImpression;

  /// Notifies when an in-app message is dismissed.
  ///
  /// [InAppMessagingDismissEvent.dismissType] is always
  /// [InAppMessagingDismissType.unknown] on Android, which does not report how
  /// a message was dismissed.
  Stream<InAppMessagingDismissEvent> get onMessageDismissed =>
      _delegate.onMessageDismissed;

  /// Notifies when an in-app message could not be rendered, for example
  /// because its image failed to download.
  Stream<InAppMessagingDisplayErrorEvent> get onMessageDisplayError =>
      _delegate.onMessageDisplayError;

  /// Opt in to custom Flutter rendering for In-App Messaging campaigns.
  ///
  /// When [enabled] is `true`, native modal / card / banner / image-only
  /// templates are not shown. Eligible campaigns are delivered on
  /// [onMessageDisplay] instead. Call this after [Firebase.initializeApp]
  /// and before campaigns may trigger.
  ///
  /// Apps must report [InAppMessage.impress], [InAppMessage.click], or
  /// [InAppMessage.dismiss] so analytics and frequency capping keep working.
  /// The plugin does not open [InAppMessageAction.actionUrl].
  ///
  /// Reporting those callbacks still notifies the lifecycle streams
  /// ([onMessageClicked], [onMessageImpression], and so on) if you listen
  /// to them.
  Future<void> setCustomDisplayEnabled(bool enabled) {
    return _delegate.setCustomDisplayEnabled(enabled);
  }

  /// Campaigns the native SDK wants shown while custom display is enabled.
  ///
  /// This is not Firebase Cloud Messaging's `onMessage`, and it is not
  /// [onMessageClicked]. It fires only after [setCustomDisplayEnabled] is
  /// `true`, at the moment the SDK would have drawn a native template.
  Stream<InAppMessage> get onMessageDisplay => _delegate.onMessageDisplay;
}
