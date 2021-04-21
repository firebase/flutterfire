// @dart = 2.9

// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore: do_not_use_environment
const bool SKIP_MANUAL_TESTS = bool.fromEnvironment('CI');

void runInstanceTests() {
  group('$FirebaseMessaging.instance', () {
    FirebaseApp app;
    FirebaseMessaging messaging;

    setUpAll(() async {
      app = await Firebase.initializeApp();
      messaging = FirebaseMessaging.instance;
    });

    tearDownAll(() {});

    test('instance', () {
      expect(messaging, isA<FirebaseMessaging>());
      expect(messaging.app, isA<FirebaseApp>());
      expect(messaging.app.name, defaultFirebaseAppName);
    });

    group('app', () {
      test('accessible from messaging.app', () {
        expect(messaging.app, isA<FirebaseApp>());
        expect(messaging.app.name, app.name);
      });
    });

    group('setAutoInitEnabled()', () {
      test('sets the value', () async {
        expect(messaging.isAutoInitEnabled, isTrue);
        await messaging.setAutoInitEnabled(false);
        expect(messaging.isAutoInitEnabled, isFalse);
      }, skip: kIsWeb);
    });

    group('requestPermission', () {
      test(
          'authorizationStatus returns AuthorizationStatus.authorized on Android',
          () async {
        final result = await messaging.requestPermission();
        expect(result, isA<NotificationSettings>());
        expect(result.authorizationStatus, AuthorizationStatus.authorized);
      }, skip: defaultTargetPlatform != TargetPlatform.android || kIsWeb);
    });

    group('requestPermission', () {
      test(
          'authorizationStatus returns AuthorizationStatus.notDetermined on Web',
          () async {
        final result = await messaging.requestPermission();
        expect(result, isA<NotificationSettings>());
        expect(result.authorizationStatus, AuthorizationStatus.notDetermined);
      }, skip: !kIsWeb);
    });

    group('getAPNSToken', () {
      test('resolves null on android', () async {
        expect(await messaging.getAPNSToken(), null);
      }, skip: defaultTargetPlatform != TargetPlatform.android);

      test('resolves null on ios if using simulator', () async {
        expect(await messaging.getAPNSToken(), null);
      },
          skip: !(defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform != TargetPlatform.macOS));
    });

    group('getInitialMessage', () {
      test('returns null when no initial message', () async {
        expect(await messaging.getInitialMessage(), null);
      });
    });

    group('getToken()', () {
      test('returns a token', () async {
        final result = await messaging.getToken();
        expect(result, isA<String>());
      });
    }, skip: SKIP_MANUAL_TESTS); // only run for manual testing

    group('deleteToken()', () {
      test('generate a new token after deleting', () async {
        final token1 = await messaging.getToken();
        await messaging.deleteToken();
        final token2 = await messaging.getToken();
        expect(token1, isA<String>());
        expect(token2, isA<String>());
        expect(token1, isNot(token2));
      }, skip: SKIP_MANUAL_TESTS); // only run for manual testing
    });

    group('subscribeToTopic()', () {
      test('successfully subscribes from topic', () async {
        const topic = 'test-topic';
        await messaging.subscribeToTopic(topic);
      }, skip: kIsWeb);
    });

    group('unsubscribeFromTopic()', () {
      test('successfully unsubscribes from topic', () async {
        const topic = 'test-topic';
        await messaging.unsubscribeFromTopic(topic);
      }, skip: kIsWeb);
    });
  });
}
