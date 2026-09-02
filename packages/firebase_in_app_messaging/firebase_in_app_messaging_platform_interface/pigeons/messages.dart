// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    dartTestOut: 'test/pigeon/test_api.dart',
    dartPackageName: 'firebase_in_app_messaging_platform_interface',
    kotlinOut:
        '../firebase_in_app_messaging/android/src/main/kotlin/io/flutter/plugins/firebase/inappmessaging/GeneratedAndroidFirebaseInAppMessaging.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.firebase.inappmessaging',
    ),
    swiftOut:
        '../firebase_in_app_messaging/ios/firebase_in_app_messaging/Sources/firebase_in_app_messaging/FirebaseInAppMessagingMessages.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)

/// How an in-app message was dismissed.
enum FiamDismissType {
  /// The message was swiped away. Only reported on iOS, for banner messages.
  swipe,

  /// The user tapped a button to close the message.
  clickedCancel,

  /// The message was dismissed automatically. Only reported on iOS, for banner
  /// messages.
  auto,

  /// The way the message was dismissed is unknown. Always reported on Android,
  /// which does not expose a dismiss type.
  unknown,
}

/// Metadata of the campaign an in-app message belongs to.
class FiamCampaignMetadata {
  const FiamCampaignMetadata({
    required this.campaignId,
    required this.campaignName,
    required this.isTestMessage,
  });

  final String campaignId;
  final String campaignName;
  final bool isTestMessage;
}

/// The action attached to the button a user tapped on an in-app message.
class FiamAction {
  const FiamAction({this.actionUrl, this.buttonText});

  final String? actionUrl;
  final String? buttonText;
}

@HostApi(dartHostTestHandler: 'TestFirebaseInAppMessagingHostApi')
abstract class FirebaseInAppMessagingHostApi {
  @async
  void triggerEvent(String appName, String eventName);

  @async
  void setMessagesSuppressed(String appName, bool suppress);

  @async
  void setAutomaticDataCollectionEnabled(String appName, bool enabled);

  /// Attaches the native message lifecycle listeners that forward events to
  /// [FirebaseInAppMessagingFlutterApi]. Calling this more than once is a no-op.
  @async
  void addEventListeners(String appName);
}

@FlutterApi()
abstract class FirebaseInAppMessagingFlutterApi {
  void onMessageClicked(
      FiamCampaignMetadata campaignMetadata, FiamAction action);

  void onMessageImpression(FiamCampaignMetadata campaignMetadata);

  void onMessageDismissed(
    FiamCampaignMetadata campaignMetadata,
    FiamDismissType dismissType,
  );

  void onMessageDisplayError(
    FiamCampaignMetadata campaignMetadata,
    String? errorMessage,
  );
}
