// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:async/async.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:firebase_messaging_platform_interface/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import './mock.dart';

void main() {
  setupFirebaseMessagingMocks();
  FirebaseMessaging? messaging;

  group('$FirebaseMessaging', () {
    setUpAll(() async {
      await Firebase.initializeApp();
      FirebaseMessagingPlatform.instance = kMockMessagingPlatform;
      messaging = FirebaseMessaging.instance;
    });
    group('instance', () {
      test('returns an instance', () async {
        expect(messaging, isA<FirebaseMessaging>());
      });

      test('returns the correct $FirebaseApp', () {
        expect(messaging!.app, isA<FirebaseApp>());
        expect(messaging!.app.name, defaultFirebaseAppName);
      });
    });

    group('get.isAutoInitEnabled', () {
      test('verify delegate method is called', () {
        // verify isAutoInitEnabled returns true
        when(kMockMessagingPlatform.isAutoInitEnabled).thenReturn(true);
        var result = messaging!.isAutoInitEnabled;

        expect(result, isA<bool>());
        expect(result, isTrue);
        verify(kMockMessagingPlatform.isAutoInitEnabled);

        // verify isAutoInitEnabled returns false
        when(kMockMessagingPlatform.isAutoInitEnabled).thenReturn(false);
        result = messaging!.isAutoInitEnabled;

        expect(result, isA<bool>());
        expect(result, isFalse);
        verify(kMockMessagingPlatform.isAutoInitEnabled);
      });
    });

    group('getInitialMessage', () {
      test('verify delegate method is called', () async {
        const senderId = 'test-notification';
        RemoteMessage message = const RemoteMessage(senderId: senderId);
        when(kMockMessagingPlatform.getInitialMessage())
            .thenAnswer((_) => Future.value(message));

        final result = await messaging!.getInitialMessage();

        expect(result, isA<RemoteMessage>());
        expect(result!.senderId, senderId);

        verify(kMockMessagingPlatform.getInitialMessage());
      });
    });

    group('deleteToken', () {
      test('verify delegate method is called with correct args', () async {
        when(kMockMessagingPlatform.deleteToken())
            .thenAnswer((_) => Future.value());

        await messaging!.deleteToken();

        verify(kMockMessagingPlatform.deleteToken());
      });
    });

    group('getAPNSToken', () {
      test('verify delegate method is called', () async {
        const apnsToken = 'test-apns';
        when(kMockMessagingPlatform.getAPNSToken())
            .thenAnswer((_) => Future.value(apnsToken));

        await messaging!.getAPNSToken();

        verify(kMockMessagingPlatform.getAPNSToken());
      });
    });
    group('getToken', () {
      test('verify delegate method is called with correct args', () async {
        const vapidKey = 'test-vapid-key';
        when(kMockMessagingPlatform.getToken(vapidKey: anyNamed('vapidKey')))
            .thenAnswer((_) => Future.value(''));

        await messaging!.getToken(vapidKey: vapidKey);

        verify(kMockMessagingPlatform.getToken(vapidKey: vapidKey));
      });
    });

    group('onTokenRefresh', () {
      test('verify delegate method is called', () async {
        const token = 'test-token';

        when(kMockMessagingPlatform.onTokenRefresh)
            .thenAnswer((_) => Stream<String>.fromIterable(<String>[token]));

        final StreamQueue<String> changes =
            StreamQueue<String>(messaging!.onTokenRefresh);
        expect(await changes.next, isA<String>());

        verify(kMockMessagingPlatform.onTokenRefresh);
      });
    });
    group('requestPermission', () {
      test('verify delegate method is called with correct args', () async {
        when(kMockMessagingPlatform.requestPermission(
          alert: anyNamed('alert'),
          announcement: anyNamed('announcement'),
          badge: anyNamed('badge'),
          carPlay: anyNamed('carPlay'),
          criticalAlert: anyNamed('criticalAlert'),
          provisional: anyNamed('provisional'),
          sound: anyNamed('sound'),
        )).thenAnswer((_) => Future.value(defaultNotificationSettings));

        // true values
        await messaging!.requestPermission(
            alert: true,
            announcement: true,
            badge: true,
            carPlay: true,
            criticalAlert: true,
            provisional: true,
            sound: true);

        verify(kMockMessagingPlatform.requestPermission(
            alert: true,
            announcement: true,
            badge: true,
            carPlay: true,
            criticalAlert: true,
            provisional: true,
            sound: true));

        // false values
        await messaging!.requestPermission(
            alert: false,
            announcement: false,
            badge: false,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: false);

        verify(kMockMessagingPlatform.requestPermission(
            alert: false,
            announcement: false,
            badge: false,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: false));

        // default values
        await messaging!.requestPermission();

        verify(kMockMessagingPlatform.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true));
      });
    });

    group('setAutoInitEnabled', () {
      test('verify delegate method is called with correct args', () async {
        when(kMockMessagingPlatform.setAutoInitEnabled(any))
            .thenAnswer((_) => Future<void>.value());

        await messaging!.setAutoInitEnabled(false);
        verify(kMockMessagingPlatform.setAutoInitEnabled(false));

        await messaging!.setAutoInitEnabled(true);
        verify(kMockMessagingPlatform.setAutoInitEnabled(true));
      });
    });
    group('subscribeToTopic', () {
      // setUp(() {
      //   when(kMockMessagingPlatform.subscribeToTopic(''))
      //       .thenAnswer((_) => Future<void>.value());
      // });

      test('throws AssertionError if topic is invalid', () async {
        const invalidTopic = 'test invalid = topic';

        expect(() => messaging!.subscribeToTopic(invalidTopic),
            throwsAssertionError);
      });

      test('verify delegate method is called with correct args', () async {
        when(kMockMessagingPlatform.subscribeToTopic(any))
            .thenAnswer((_) => Future<void>.value());

        const topic = 'test-topic';

        await messaging!.subscribeToTopic(topic);
        verify(kMockMessagingPlatform.subscribeToTopic(topic));
      });
    });
    group('unsubscribeFromTopic', () {
      when(kMockMessagingPlatform.unsubscribeFromTopic(any))
          .thenAnswer((_) => Future<void>.value());
      test('verify delegate method is called with correct args', () async {
        const topic = 'test-topic';

        await messaging!.unsubscribeFromTopic(topic);
        verify(kMockMessagingPlatform.unsubscribeFromTopic(topic));
      });
    });
  });
}
