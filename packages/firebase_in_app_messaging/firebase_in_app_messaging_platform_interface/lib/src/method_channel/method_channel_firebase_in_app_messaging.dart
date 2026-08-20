// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging_platform_interface/firebase_in_app_messaging_platform_interface.dart';
import 'package:firebase_in_app_messaging_platform_interface/src/pigeon/messages.pigeon.dart'
    as pigeon;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'utils/exception.dart';

/// Receives the message lifecycle events sent by the native SDKs and forwards
/// them to the streams exposed by [MethodChannelFirebaseInAppMessaging].
class _FirebaseInAppMessagingFlutterApi
    implements pigeon.FirebaseInAppMessagingFlutterApi {
  @override
  void onMessageClicked(
    pigeon.FiamCampaignMetadata campaignMetadata,
    pigeon.FiamAction action,
  ) {
    MethodChannelFirebaseInAppMessaging.clickedController.add(
      InAppMessagingClickEvent(
        campaignMetadata: _campaignMetadata(campaignMetadata),
        action: InAppMessagingAction(
          actionUrl: action.actionUrl,
          buttonText: action.buttonText,
        ),
      ),
    );
  }

  @override
  void onMessageImpression(pigeon.FiamCampaignMetadata campaignMetadata) {
    MethodChannelFirebaseInAppMessaging.impressionController.add(
      InAppMessagingImpressionEvent(
        campaignMetadata: _campaignMetadata(campaignMetadata),
      ),
    );
  }

  @override
  void onMessageDismissed(
    pigeon.FiamCampaignMetadata campaignMetadata,
    pigeon.FiamDismissType dismissType,
  ) {
    MethodChannelFirebaseInAppMessaging.dismissedController.add(
      InAppMessagingDismissEvent(
        campaignMetadata: _campaignMetadata(campaignMetadata),
        dismissType: _dismissType(dismissType),
      ),
    );
  }

  @override
  void onMessageDisplayError(
    pigeon.FiamCampaignMetadata campaignMetadata,
    String? errorMessage,
  ) {
    MethodChannelFirebaseInAppMessaging.displayErrorController.add(
      InAppMessagingDisplayErrorEvent(
        campaignMetadata: _campaignMetadata(campaignMetadata),
        errorMessage: errorMessage,
      ),
    );
  }

  static InAppMessagingCampaignMetadata _campaignMetadata(
    pigeon.FiamCampaignMetadata metadata,
  ) {
    return InAppMessagingCampaignMetadata(
      campaignId: metadata.campaignId,
      campaignName: metadata.campaignName,
      isTestMessage: metadata.isTestMessage,
    );
  }

  static InAppMessagingDismissType _dismissType(
    pigeon.FiamDismissType dismissType,
  ) {
    switch (dismissType) {
      case pigeon.FiamDismissType.swipe:
        return InAppMessagingDismissType.swipe;
      case pigeon.FiamDismissType.clickedCancel:
        return InAppMessagingDismissType.clickedCancel;
      case pigeon.FiamDismissType.auto:
        return InAppMessagingDismissType.auto;
      case pigeon.FiamDismissType.unknown:
        return InAppMessagingDismissType.unknown;
    }
  }
}

class MethodChannelFirebaseInAppMessaging
    extends FirebaseInAppMessagingPlatform {
  MethodChannelFirebaseInAppMessaging({FirebaseApp? app}) : super(app);

  /// Internal stub class initializer.
  ///
  /// When the user code calls a method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseInAppMessaging._() : super(null);

  /// The [MethodChannelFirebaseInAppMessaging] method channel.
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_in_app_messaging',
  );

  static final pigeonChannel = pigeon.FirebaseInAppMessagingHostApi();

  // The message lifecycle controllers live as long as the app does, they are
  // never closed.
  @visibleForTesting
  // ignore: close_sinks
  static final clickedController =
      StreamController<InAppMessagingClickEvent>.broadcast();

  @visibleForTesting
  // ignore: close_sinks
  static final impressionController =
      StreamController<InAppMessagingImpressionEvent>.broadcast();

  @visibleForTesting
  // ignore: close_sinks
  static final dismissedController =
      StreamController<InAppMessagingDismissEvent>.broadcast();

  @visibleForTesting
  // ignore: close_sinks
  static final displayErrorController =
      StreamController<InAppMessagingDisplayErrorEvent>.broadcast();

  static bool _eventListenersAdded = false;

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseInAppMessaging get instance {
    return MethodChannelFirebaseInAppMessaging._();
  }

  @override
  FirebaseInAppMessagingPlatform delegateFor({FirebaseApp? app}) {
    return MethodChannelFirebaseInAppMessaging(app: app);
  }

  @override
  Future<void> triggerEvent(String eventName) async {
    try {
      await pigeonChannel.triggerEvent(app!.name, eventName);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setMessagesSuppressed(bool suppress) async {
    try {
      await pigeonChannel.setMessagesSuppressed(app!.name, suppress);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {
    try {
      await pigeonChannel.setAutomaticDataCollectionEnabled(app!.name, enabled);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Stream<InAppMessagingClickEvent> get onMessageClicked {
    _ensureEventListeners();
    return clickedController.stream;
  }

  @override
  Stream<InAppMessagingImpressionEvent> get onMessageImpression {
    _ensureEventListeners();
    return impressionController.stream;
  }

  @override
  Stream<InAppMessagingDismissEvent> get onMessageDismissed {
    _ensureEventListeners();
    return dismissedController.stream;
  }

  @override
  Stream<InAppMessagingDisplayErrorEvent> get onMessageDisplayError {
    _ensureEventListeners();
    return displayErrorController.stream;
  }

  /// The message lifecycle listeners are attached natively the first time one
  /// of the event streams is used, so that apps which never listen keep the
  /// previous behavior - most notably they keep ownership of the iOS
  /// `InAppMessaging` display delegate.
  void _ensureEventListeners() {
    if (_eventListenersAdded) return;
    _eventListenersAdded = true;

    pigeon.FirebaseInAppMessagingFlutterApi.setUp(
      _FirebaseInAppMessagingFlutterApi(),
    );

    pigeonChannel.addEventListeners(app!.name).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      _eventListenersAdded = false;
      for (final controller in [
        clickedController,
        impressionController,
        dismissedController,
        displayErrorController,
      ]) {
        if (controller.hasListener) {
          controller.addError(error, stackTrace);
        }
      }
    });
  }
}
