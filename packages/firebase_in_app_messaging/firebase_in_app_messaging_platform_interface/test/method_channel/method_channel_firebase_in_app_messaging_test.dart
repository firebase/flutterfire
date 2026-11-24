// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging_platform_interface/firebase_in_app_messaging_platform_interface.dart';
import 'package:firebase_in_app_messaging_platform_interface/src/method_channel/method_channel_firebase_in_app_messaging.dart';
import 'package:firebase_in_app_messaging_platform_interface/src/pigeon/messages.pigeon.dart'
    as pigeon;
import 'package:flutter/foundation.dart';
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
      pigeon.FiamAction(actionUrl: 'https://example.com', buttonText: 'Open'),
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

  test('setCustomDisplayEnabled forwards the app name and value', () async {
    await inAppMessaging.setCustomDisplayEnabled(true);

    expect(hostApi.appName, app.name);
    expect(hostApi.customDisplayEnabled, isTrue);
  });

  test('onMessageDisplay emits the campaign payload', () async {
    await inAppMessaging.setCustomDisplayEnabled(true);
    final event = inAppMessaging.onMessageDisplay.first;

    await _sendFlutterApiMessage('onMessageDisplay', [
      pigeon.FiamDisplayMessage(
        campaignMetadata: pigeon.FiamCampaignMetadata(
          campaignId: 'campaign-id',
          campaignName: 'campaign-name',
          isTestMessage: false,
        ),
        messageType: 'MODAL',
        title: pigeon.FiamText(text: 'Hello', hexColor: '#FFFFFF'),
        body: pigeon.FiamText(text: 'World'),
        imageUrl: 'https://example.com/image.png',
        action: pigeon.FiamDisplayAction(
          id: 'campaign-id_action',
          actionUrl: 'https://example.com',
          buttonText: 'Open',
        ),
        data: <String?, String?>{'promo': 'SAVE10'},
      ),
    ]);

    final message = await event;
    expect(message.campaignMetadata.campaignId, 'campaign-id');
    expect(message.messageType, InAppMessageType.modal);
    expect(message.title?.text, 'Hello');
    expect(message.body?.text, 'World');
    expect(message.action?.actionUrl, 'https://example.com');
    expect(message.data['promo'], 'SAVE10');

    await message.impress();
    expect(hostApi.campaignId, 'campaign-id');
  });

  group('onMessageDisplay without a listener', () {
    final defaultTimeout =
        MethodChannelFirebaseInAppMessaging.pendingDisplayTimeout;

    setUp(() async {
      MethodChannelFirebaseInAppMessaging.pendingDisplayTimeout =
          const Duration(milliseconds: 50);
      await inAppMessaging.setCustomDisplayEnabled(true);
      hostApi.reset();
    });

    tearDown(() {
      MethodChannelFirebaseInAppMessaging.pendingDisplayTimeout =
          defaultTimeout;
      debugDefaultTargetPlatformOverride = null;
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      group(platform.name, () {
        setUp(() => debugDefaultTargetPlatformOverride = platform);

        test('holds the message for the first listener', () async {
          await _sendFlutterApiMessage('onMessageDisplay', [
            _displayMessage('held-campaign'),
          ]);

          final messages = <InAppMessage>[];
          final subscription = inAppMessaging.onMessageDisplay.listen(
            messages.add,
          );
          addTearDown(subscription.cancel);
          await pumpEventQueue();

          expect(messages, hasLength(1));
          expect(messages.single.campaignMetadata.campaignId, 'held-campaign');

          // The held message was delivered, so it is not reported.
          await Future<void>.delayed(_pastPendingDisplayTimeout);
          expect(hostApi.campaignId, isNull);
        });

        test(
          'does not report a held message that its campaign replaces',
          () async {
            await _sendFlutterApiMessage('onMessageDisplay', [
              _displayMessage('same-campaign'),
            ]);
            await _sendFlutterApiMessage('onMessageDisplay', [
              _displayMessage('same-campaign'),
            ]);

            final message = await inAppMessaging.onMessageDisplay.first;
            expect(message.campaignMetadata.campaignId, 'same-campaign');
            await Future<void>.delayed(_pastPendingDisplayTimeout);
            expect(hostApi.campaignId, isNull);
          },
        );

        test(
          'drops the held message when custom display is disabled',
          () async {
            await _sendFlutterApiMessage('onMessageDisplay', [
              _displayMessage('disabled-campaign'),
            ]);
            await inAppMessaging.setCustomDisplayEnabled(false);

            final messages = <InAppMessage>[];
            final subscription = inAppMessaging.onMessageDisplay.listen(
              messages.add,
            );
            addTearDown(subscription.cancel);
            await Future<void>.delayed(_pastPendingDisplayTimeout);

            expect(messages, isEmpty);
            expect(hostApi.campaignId, isNull);
          },
        );
      });
    }

    // iOS shows no other campaign until the message is reported, and a display
    // error records no impression there.
    group('iOS', () {
      setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);

      test('reports a display error when nobody listens', () async {
        await _sendFlutterApiMessage('onMessageDisplay', [
          _displayMessage('unheard-campaign'),
        ]);

        await Future<void>.delayed(_pastPendingDisplayTimeout);

        expect(hostApi.campaignId, 'unheard-campaign');
        expect(hostApi.errorReason, isNotNull);
        expect(hostApi.dismissType, isNull);
      });

      test('reports a held message that a newer one replaces', () async {
        await _sendFlutterApiMessage('onMessageDisplay', [
          _displayMessage('older-campaign'),
        ]);
        await _sendFlutterApiMessage('onMessageDisplay', [
          _displayMessage('newer-campaign'),
        ]);
        await pumpEventQueue();

        expect(hostApi.campaignId, 'older-campaign');
        expect(hostApi.errorReason, isNotNull);

        final message = await inAppMessaging.onMessageDisplay.first;
        expect(message.campaignMetadata.campaignId, 'newer-campaign');
      });
    });

    // Android counts a display error as an impression, and caps app open
    // campaigns at one a day, so a message nobody saw is not reported.
    group('Android', () {
      setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);

      test('drops the message without reporting it', () async {
        await _sendFlutterApiMessage('onMessageDisplay', [
          _displayMessage('unheard-campaign'),
        ]);

        await Future<void>.delayed(_pastPendingDisplayTimeout);
        expect(hostApi.campaignId, isNull);

        // The message is no longer held either.
        final messages = <InAppMessage>[];
        final subscription = inAppMessaging.onMessageDisplay.listen(
          messages.add,
        );
        addTearDown(subscription.cancel);
        await pumpEventQueue();
        expect(messages, isEmpty);
      });

      test('drops a held message that a newer one replaces', () async {
        await _sendFlutterApiMessage('onMessageDisplay', [
          _displayMessage('older-campaign'),
        ]);
        await _sendFlutterApiMessage('onMessageDisplay', [
          _displayMessage('newer-campaign'),
        ]);
        await pumpEventQueue();

        expect(hostApi.campaignId, isNull);

        final message = await inAppMessaging.onMessageDisplay.first;
        expect(message.campaignMetadata.campaignId, 'newer-campaign');
      });
    });
  });
}

const _pastPendingDisplayTimeout = Duration(milliseconds: 100);

pigeon.FiamDisplayMessage _displayMessage(String campaignId) {
  return pigeon.FiamDisplayMessage(
    campaignMetadata: pigeon.FiamCampaignMetadata(
      campaignId: campaignId,
      campaignName: 'campaign-name',
      isTestMessage: false,
    ),
    messageType: 'BANNER',
  );
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
  bool? customDisplayEnabled;
  String? campaignId;
  String? actionId;
  String? dismissType;
  String? errorReason;

  void reset() {
    appName = null;
    eventName = null;
    messagesSuppressed = null;
    automaticDataCollectionEnabled = null;
    addEventListenersCount = 0;
    customDisplayEnabled = null;
    campaignId = null;
    actionId = null;
    dismissType = null;
    errorReason = null;
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

  @override
  Future<void> setCustomDisplayEnabled(String appName, bool enabled) async {
    this.appName = appName;
    customDisplayEnabled = enabled;
  }

  @override
  Future<void> reportImpression(String campaignId) async {
    this.campaignId = campaignId;
  }

  @override
  Future<void> reportClick(String campaignId, String actionId) async {
    this.campaignId = campaignId;
    this.actionId = actionId;
  }

  @override
  Future<void> reportDismiss(String campaignId, String dismissType) async {
    this.campaignId = campaignId;
    this.dismissType = dismissType;
  }

  @override
  Future<void> reportDisplayError(String campaignId, String reason) async {
    this.campaignId = campaignId;
    errorReason = reason;
  }
}
