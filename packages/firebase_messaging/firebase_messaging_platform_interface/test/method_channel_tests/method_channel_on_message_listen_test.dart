// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:firebase_messaging_platform_interface/src/method_channel/method_channel_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

// Kept in its own file: it needs an isolate where nothing has used
// `FirebaseMessagingPlatform.instance` yet, like an app that only listens to
// `FirebaseMessaging.onMessage`.
void main() {
  setupFirebaseMessagingMocks();

  test('onMessage receives native messages without any other messaging call',
      () async {
    final received = <RemoteMessage>[];
    final subscription =
        FirebaseMessagingPlatform.onMessage.stream.listen(received.add);
    addTearDown(subscription.cancel);

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      MethodChannelFirebaseMessaging.channel.name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('Messaging#onMessage', <String, dynamic>{
          'messageId': 'foreground-message',
        }),
      ),
      (_) {},
    );
    await pumpEventQueue();

    expect(received.map((m) => m.messageId), <String>['foreground-message']);
  });
}
