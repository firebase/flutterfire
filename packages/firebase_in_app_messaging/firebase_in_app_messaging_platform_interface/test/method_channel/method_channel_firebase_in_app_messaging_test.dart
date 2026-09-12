// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging_platform_interface/firebase_in_app_messaging_platform_interface.dart';
import 'package:firebase_in_app_messaging_platform_interface/src/method_channel/method_channel_firebase_in_app_messaging.dart';
import 'package:firebase_in_app_messaging_platform_interface/src/pigeon/messages.pigeon.dart'
    as pigeon;
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';
import '../pigeon/test_api.dart';

void main() {
  setupFirebaseInAppMessagingMocks();

  late FirebaseApp app;
  late MethodChannelFirebaseInAppMessaging inAppMessaging;
  late _TestFirebaseInAppMessagingHostApi hostApi;

  setUpAll(() async {
    app = await Firebase.initializeApp();
    hostApi = _TestFirebaseInAppMessagingHostApi();
    TestFirebaseInAppMessagingHostApi.setUp(hostApi);
    inAppMessaging = MethodChannelFirebaseInAppMessaging(app: app);
  });

  tearDownAll(() {
    TestFirebaseInAppMessagingHostApi.setUp(null);
  });

  setUp(() {
    hostApi.reset();
  });

  test('triggerEvent forwards the app and event names', () async {
    await inAppMessaging.triggerEvent('campaign-event');

    expect(hostApi.appName, app.name);
    expect(hostApi.eventName, 'campaign-event');
  });

  test('setMessagesSuppressed forwards the app name and value', () async {
    await inAppMessaging.setMessagesSuppressed(true);

    expect(hostApi.appName, app.name);
    expect(hostApi.messagesSuppressed, isTrue);
  });

  test(
    'setAutomaticDataCollectionEnabled forwards the app name and value',
    () async {
      await inAppMessaging.setAutomaticDataCollectionEnabled(false);

      expect(hostApi.appName, app.name);
      expect(hostApi.automaticDataCollectionEnabled, isFalse);
    },
  );

  test('listening to an event stream adds the native listeners once', () async {
    final clicked = inAppMessaging.onMessageClicked.listen((_) {});
    final dismissed = inAppMessaging.onMessageDismissed.listen((_) {});
    addTearDown(clicked.cancel);
    addTearDown(dismissed.cancel);

    // The host API is called without being awaited by the getters.
    await pumpEventQueue();

    expect(hostApi.addEventListenersCount, 1);
    expect(hostApi.appName, app.name);
  });

  test('onMessageClicked emits the campaign metadata and the action', () async {
    final event = inAppMessaging.onMessageClicked.first;

    await _sendFlutterApiMessage('onMessageClicked', [
      pigeon.FiamCampaignMetadata(
        campaignId: 'campaign-id',
        campaignName: 'campaign-name',
        isTestMessage: true,
      ),
      pigeon.FiamAction(
        actionUrl: 'https://example.com',
        buttonText: 'Open',
      ),
    ]);

    final clickEvent = await event;
    expect(clickEvent.campaignMetadata.campaignId, 'campaign-id');
    expect(clickEvent.campaignMetadata.campaignName, 'campaign-name');
    expect(clickEvent.campaignMetadata.isTestMessage, isTrue);
    expect(clickEvent.action.actionUrl, 'https://example.com');
    expect(clickEvent.action.buttonText, 'Open');
  });

  test('onMessageImpression emits the campaign metadata', () async {
    final event = inAppMessaging.onMessageImpression.first;

    await _sendFlutterApiMessage('onMessageImpression', [
      pigeon.FiamCampaignMetadata(
        campaignId: 'campaign-id',
        campaignName: 'campaign-name',
        isTestMessage: false,
      ),
    ]);

    final impressionEvent = await event;
    expect(impressionEvent.campaignMetadata.campaignId, 'campaign-id');
    expect(impressionEvent.campaignMetadata.isTestMessage, isFalse);
  });

  test('onMessageDismissed emits the dismiss type', () async {
    final event = inAppMessaging.onMessageDismissed.first;

    await _sendFlutterApiMessage('onMessageDismissed', [
      pigeon.FiamCampaignMetadata(
        campaignId: 'campaign-id',
        campaignName: 'campaign-name',
        isTestMessage: false,
      ),
      pigeon.FiamDismissType.clickedCancel,
    ]);

    final dismissEvent = await event;
    expect(dismissEvent.campaignMetadata.campaignId, 'campaign-id');
    expect(dismissEvent.dismissType, InAppMessagingDismissType.clickedCancel);
  });

  test('onMessageDisplayError emits the error message', () async {
    final event = inAppMessaging.onMessageDisplayError.first;

    await _sendFlutterApiMessage('onMessageDisplayError', [
      pigeon.FiamCampaignMetadata(
        campaignId: 'campaign-id',
        campaignName: 'campaign-name',
        isTestMessage: false,
      ),
      'IMAGE_FETCH_ERROR',
    ]);

    final errorEvent = await event;
    expect(errorEvent.campaignMetadata.campaignId, 'campaign-id');
    expect(errorEvent.errorMessage, 'IMAGE_FETCH_ERROR');
  });
}

/// Simulates the native side calling [pigeon.FirebaseInAppMessagingFlutterApi].
Future<void> _sendFlutterApiMessage(
  String methodName,
  List<Object?> arguments,
) {
  const codec = pigeon.FirebaseInAppMessagingFlutterApi.pigeonChannelCodec;

  return TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
    'dev.flutter.pigeon.firebase_in_app_messaging_platform_interface'
    '.FirebaseInAppMessagingFlutterApi.$methodName',
    codec.encodeMessage(arguments),
    (_) {},
  );
}

class _TestFirebaseInAppMessagingHostApi
    implements TestFirebaseInAppMessagingHostApi {
  String? appName;
  String? eventName;
  bool? messagesSuppressed;
  bool? automaticDataCollectionEnabled;
  int addEventListenersCount = 0;

  void reset() {
    appName = null;
    eventName = null;
    messagesSuppressed = null;
    automaticDataCollectionEnabled = null;
    addEventListenersCount = 0;
  }

  @override
  Future<void> triggerEvent(String appName, String eventName) async {
    this.appName = appName;
    this.eventName = eventName;
  }

  @override
  Future<void> setMessagesSuppressed(String appName, bool suppress) async {
    this.appName = appName;
    messagesSuppressed = suppress;
  }

  @override
  Future<void> setAutomaticDataCollectionEnabled(
    String appName,
    bool enabled,
  ) async {
    this.appName = appName;
    automaticDataCollectionEnabled = enabled;
  }

  @override
  Future<void> addEventListeners(String appName) async {
    this.appName = appName;
    addEventListenersCount++;
  }
}
