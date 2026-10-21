// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:firebase_messaging_platform_interface/src/method_channel/method_channel_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

// Apple platforms deliver background messages to the main isolate through
// `Messaging#onBackgroundMessage` on the main channel. iOS can deliver one
// before `main()` has registered a handler (background launch for a push), so
// the message must wait for the handler instead of being dropped.
void main() {
  setupFirebaseMessagingMocks();

  late FirebaseApp app;
  final List<RemoteMessage> handled = <RemoteMessage>[];

  Future<void> handler(RemoteMessage message) async {
    handled.add(message);
  }

  // Simulates the native side invoking `Messaging#onBackgroundMessage`, and
  // returns the reply the native side receives.
  Future<Object?> deliverFromNative(String messageId) {
    final reply = Completer<Object?>();
    const codec = StandardMethodCodec();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      MethodChannelFirebaseMessaging.channel.name,
      codec.encodeMethodCall(
        MethodCall('Messaging#onBackgroundMessage', <String, dynamic>{
          'messageId': messageId,
          'data': const <String, dynamic>{'foo': 'bar'},
        }),
      ),
      (ByteData? data) => reply.complete(
        data == null ? null : codec.decodeEnvelope(data),
      ),
    );
    return reply.future;
  }

  setUpAll(() async {
    app = await Firebase.initializeApp();
  });

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    handled.clear();
    FirebaseMessagingPlatform.instance = MethodChannelFirebaseMessaging(
      app: app,
    );
    FirebaseMessagingPlatform.onBackgroundMessage = null;
    MethodChannelFirebaseMessaging.setMethodCallHandlers();
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    FirebaseMessagingPlatform.onBackgroundMessage = null;
    MethodChannelFirebaseMessaging.backgroundMessageHandlerRegistrationTimeout =
        const Duration(seconds: 10);
  });

  test('is handled straight away when a handler is registered', () async {
    FirebaseMessagingPlatform.onBackgroundMessage = handler;

    await deliverFromNative('registered-first');

    expect(handled.map((m) => m.messageId), <String>['registered-first']);
  });

  test('waits for a handler registered after the message arrived', () async {
    var replied = false;
    final reply =
        deliverFromNative('arrived-first').whenComplete(() => replied = true);

    await pumpEventQueue();
    expect(replied, isFalse, reason: 'native must keep waiting');
    expect(handled, isEmpty);

    FirebaseMessagingPlatform.onBackgroundMessage = handler;
    await reply;

    expect(handled.map((m) => m.messageId), <String>['arrived-first']);
    expect(handled.single.data, <String, dynamic>{'foo': 'bar'});
  });

  test('handles every message that arrived before the handler', () async {
    final replies = <Future<Object?>>[
      deliverFromNative('first'),
      deliverFromNative('second'),
    ];
    await pumpEventQueue();

    FirebaseMessagingPlatform.onBackgroundMessage = handler;
    await Future.wait(replies);

    expect(
      handled.map((m) => m.messageId),
      unorderedEquals(<String>['first', 'second']),
    );
  });

  test('replies to native when no handler is ever registered', () async {
    MethodChannelFirebaseMessaging.backgroundMessageHandlerRegistrationTimeout =
        const Duration(milliseconds: 50);

    final reply = await deliverFromNative('never-handled')
        .timeout(const Duration(seconds: 5));

    expect(reply, isNull);
    expect(handled, isEmpty);
  });

  test('a later registration still handles new messages after a timeout',
      () async {
    MethodChannelFirebaseMessaging.backgroundMessageHandlerRegistrationTimeout =
        const Duration(milliseconds: 50);
    await deliverFromNative('timed-out');

    FirebaseMessagingPlatform.onBackgroundMessage = handler;
    await deliverFromNative('after-registration');

    expect(handled.map((m) => m.messageId), <String>['after-registration']);
  });
}
