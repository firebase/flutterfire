// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// The Android plugin only sends foreground messages to the engines whose Dart
// listens to `onMessage`, and keeps them while none does.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/firebase_messaging');
  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          return null;
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'tells the Android plugin when the app starts and stops listening',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final first = FirebaseMessaging.onMessage.listen((_) {});
      final second = FirebaseMessaging.onMessage.listen((_) {});
      await pumpEventQueue();
      expect(calls, <String>['Messaging#startForegroundMessages']);

      await first.cancel();
      await pumpEventQueue();
      expect(calls, <String>['Messaging#startForegroundMessages']);

      await second.cancel();
      await pumpEventQueue();
      expect(calls, <String>[
        'Messaging#startForegroundMessages',
        'Messaging#stopForegroundMessages',
      ]);
    },
  );

  test('delivers the messages of the platform stream', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final received = <String?>[];
    final subscription = FirebaseMessaging.onMessage.listen(
      (message) => received.add(message.messageId),
    );
    addTearDown(subscription.cancel);

    FirebaseMessagingPlatform.onMessage.add(
      const RemoteMessage(messageId: 'from-platform'),
    );
    await pumpEventQueue();

    expect(received, <String>['from-platform']);
  });

  test('sends nothing on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final subscription = FirebaseMessaging.onMessage.listen((_) {});
    await pumpEventQueue();
    await subscription.cancel();
    await pumpEventQueue();

    expect(calls, isEmpty);
  });
}
