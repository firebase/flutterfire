// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
// ignore: implementation_imports
import 'package:firebase_messaging_platform_interface/src/method_channel/method_channel_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// iOS test helper implemented in `ios/Runner/RemoteNotificationTestChannel.swift`.
const _remoteNotificationsChannel = MethodChannel('tests/remote_notifications');

/// Delivers a data message through the app delegate the same way iOS does when
/// a push arrives. Returns how many times the fetch completion handler was
/// called (`completionCount`) and with which `UIBackgroundFetchResult`
/// (`fetchResult`).
Future<Map<String, Object?>> deliverRemoteNotification(
  String messageId, {
  required bool inBackground,
}) async {
  final delivery = await _remoteNotificationsChannel
      .invokeMapMethod<String, Object?>('deliver', {
    'inBackground': inBackground,
    'userInfo': {
      'aps': {'content-available': 1},
      'gcm.message_id': messageId,
      'google.c.a.e': '1',
      'from': 'e2e',
      'test': 'remote-notification-delivery',
    },
  });
  return delivery!;
}

const _uiBackgroundFetchResultNewData = 0;

final List<RemoteMessage> _backgroundMessages = <RemoteMessage>[];

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  _backgroundMessages.add(message);
}

String _uniqueMessageId(String prefix) =>
    '$prefix-${DateTime.now().microsecondsSinceEpoch}';

/// Pushes delivered the way iOS delivers them, run by `e2e_test.dart` and on
/// their own by `remote_notification_delivery_test.dart`.
void remoteNotificationDeliveryTests() {
  group(
    'remote notification delivery',
    () {
      test('a data message in the foreground reaches onMessage once', () async {
        final messageId = _uniqueMessageId('foreground');
        final received = <RemoteMessage>[];
        final subscription = FirebaseMessaging.onMessage
            .where((message) => message.messageId == messageId)
            .listen(received.add);
        addTearDown(subscription.cancel);

        final delivery = await deliverRemoteNotification(
          messageId,
          inBackground: false,
        );
        await Future<void>.delayed(const Duration(milliseconds: 500));

        expect(received, hasLength(1));
        expect(
          received.single.data,
          containsPair('test', 'remote-notification-delivery'),
        );
        expect(delivery['completionCount'], 1);
      });

      test(
          'a data message in the background runs onBackgroundMessage once '
          'before the push completes', () async {
        FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
        final messageId = _uniqueMessageId('background');

        final delivery = await deliverRemoteNotification(
          messageId,
          inBackground: true,
        );

        expect(
          _backgroundMessages.where((m) => m.messageId == messageId),
          hasLength(1),
        );
        expect(delivery['completionCount'], 1);
        expect(delivery['fetchResult'], _uiBackgroundFetchResultNewData);
      });

      test(
          'a background message that arrives before onBackgroundMessage is '
          'set runs it once it is', () async {
        // As when iOS launches the app in the background for a push: the
        // message reaches Dart before `main()` has registered the handler.
        // Registering it once first tells the native side the app has one.
        FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
        await Future<void>.delayed(const Duration(milliseconds: 100));
        FirebaseMessagingPlatform.onBackgroundMessage = null;
        // Messages wait for a handler while the app starts using messaging;
        // restart that window, the app has been running for a while.
        MethodChannelFirebaseMessaging.setMethodCallHandlers();
        final messageId = _uniqueMessageId('before-handler');

        final delivery = deliverRemoteNotification(
          messageId,
          inBackground: true,
        );
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(
          _backgroundMessages.where((m) => m.messageId == messageId),
          isEmpty,
        );

        FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
        final result = await delivery;

        expect(
          _backgroundMessages.where((m) => m.messageId == messageId),
          hasLength(1),
        );
        expect(result['completionCount'], 1);
        expect(result['fetchResult'], _uiBackgroundFetchResultNewData);
      });

      test(
          'messages sent before Dart handles the channel are all kept '
          'until it does', () async {
        // As when pushes arrive before the app starts using messaging: Flutter
        // keeps a single message by default.
        final messageIds = [
          for (var i = 0; i < 3; i++) _uniqueMessageId('buffered-$i'),
        ];
        final received = <String?>[];
        final subscription = FirebaseMessaging.onMessage
            .where((message) => messageIds.contains(message.messageId))
            .listen((message) => received.add(message.messageId));
        addTearDown(subscription.cancel);

        MethodChannelFirebaseMessaging.channel.setMethodCallHandler(null);
        addTearDown(MethodChannelFirebaseMessaging.setMethodCallHandlers);
        for (final messageId in messageIds) {
          await deliverRemoteNotification(messageId, inBackground: false);
        }
        expect(received, isEmpty);

        MethodChannelFirebaseMessaging.setMethodCallHandlers();
        await Future<void>.delayed(const Duration(milliseconds: 500));

        expect(received, messageIds);
      });

      test('a later push that reuses a message ID is handled again', () async {
        // Some servers send pushes straight to APNs with a fixed
        // `gcm.message_id`: only the duplicate within one delivery from iOS
        // may be dropped.
        final messageId = _uniqueMessageId('reused-id');
        final received = <RemoteMessage>[];
        final subscription = FirebaseMessaging.onMessage
            .where((message) => message.messageId == messageId)
            .listen(received.add);
        addTearDown(subscription.cancel);

        final first = await deliverRemoteNotification(
          messageId,
          inBackground: false,
        );
        final second = await deliverRemoteNotification(
          messageId,
          inBackground: false,
        );
        await Future<void>.delayed(const Duration(milliseconds: 500));

        expect(received, hasLength(2));
        expect(first['completionCount'], 1);
        expect(second['completionCount'], 1);
      });
    },
    // Pushes are delivered through the iOS app delegate.
    skip: kIsWeb || defaultTargetPlatform != TargetPlatform.iOS,
  );
}
