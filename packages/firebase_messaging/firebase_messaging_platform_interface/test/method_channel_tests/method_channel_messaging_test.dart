// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/src/method_channel/method_channel_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseMessagingMocks();

  late FirebaseApp app;
  late FirebaseMessagingPlatform messaging;
  final List<MethodCall> log = <MethodCall>[];

  group('$MethodChannelFirebaseMessaging', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();

      handleMethodCall((call) async {
        log.add(call);
        switch (call.method) {
          case 'Messaging#deleteToken':
          case 'Messaging#sendMessage':
          case 'Messaging#subscribeToTopic':
          case 'Messaging#unsubscribeFromTopic':
            return null;
          case 'Messaging#getAPNSToken':
          case 'Messaging#getToken':
            return {
              'token': 'test_token',
            };
          case 'Messaging#hasPermission':
          case 'Messaging#requestPermission':
            return {
              'authorizationStatus': 1,
              'alert': 1,
              'announcement': 0,
              'badge': 1,
              'carPlay': 0,
              'criticalAlert': 0,
              'provisional': 0,
              'sound': 1,
            };
          case 'Messaging#setAutoInitEnabled':
            return {
              'isAutoInitEnabled': call.arguments['enabled'],
            };
          case 'Messaging#deleteInstanceID':
            return true;
          default:
            return <String, dynamic>{};
        }
      });
    });

    setUp(() {
      log.clear();
      messaging = MethodChannelFirebaseMessaging(app: app);
    });

    group('$FirebaseMessagingPlatform()', () {
      test('$MethodChannelFirebaseMessaging is the default instance', () {
        expect(FirebaseMessagingPlatform.instance,
            isA<MethodChannelFirebaseMessaging>());
      });

      test('Cannot be implemented with `implements`', () {
        expect(() {
          FirebaseMessagingPlatform.instance =
              ImplementsFirebaseMessagingPlatform();
        }, throwsAssertionError);
      });

      test('Can be extended', () {
        FirebaseMessagingPlatform.instance = ExtendsFirebaseMessagingPlatform();
      });

      test('Can be mocked with `implements`', () {
        final FirebaseMessagingPlatform mock = MocksFirebaseMessagingPlatform();
        FirebaseMessagingPlatform.instance = mock;
      });
    });

    test('delegateFor()', () {
      final testMessaging = TestMethodChannelFirebaseMessaging(Firebase.app());
      final result = testMessaging.delegateFor(app: Firebase.app());

      expect(result, isA<FirebaseMessagingPlatform>());
      expect(result.app, isA<FirebaseApp>());
    });

    group('setInitialValues()', () {
      test('when isAutoInitEnabled is false', () {
        final testMessaging =
            TestMethodChannelFirebaseMessaging(Firebase.app());
        final result = testMessaging.setInitialValues(isAutoInitEnabled: false);
        expect(result, isA<FirebaseMessagingPlatform>());
        expect(result.isAutoInitEnabled, isFalse);
      });

      test('when isAutoInitEnabled is true', () {
        final testMessaging =
            TestMethodChannelFirebaseMessaging(Firebase.app());
        final result = testMessaging.setInitialValues(isAutoInitEnabled: true);
        expect(result, isA<FirebaseMessagingPlatform>());
        expect(result.isAutoInitEnabled, isTrue);
      });
    });

    test('isAutoInitEnabled', () {
      // ignore: invalid_use_of_protected_member
      messaging.setInitialValues(isAutoInitEnabled: true);
      expect(messaging.isAutoInitEnabled, isTrue);
    });

    test('deleteToken', () async {
      await messaging.deleteToken();

      // check native method was called
      expect(log, <Matcher>[
        isMethodCall(
          'Messaging#deleteToken',
          arguments: <String, dynamic>{
            'appName': defaultFirebaseAppName,
          },
        ),
      ]);
    });

    test('getAPNSToken', () async {
      // not applicable to android
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await messaging.getAPNSToken();

      // check native method was called
      expect(log, <Matcher>[
        isMethodCall(
          'Messaging#getAPNSToken',
          arguments: <String, dynamic>{
            'appName': defaultFirebaseAppName,
          },
        ),
      ]);
    });

    test('getToken', () async {
      await messaging.getToken();

      // check native method was called
      expect(log, <Matcher>[
        isMethodCall(
          'Messaging#getToken',
          arguments: <String, dynamic>{
            'appName': defaultFirebaseAppName,
          },
        ),
      ]);
    });

    test('requestPermission', () async {
      // test android response
      final androidPermissions = await messaging.requestPermission();
      expect(androidPermissions.authorizationStatus,
          equals(AuthorizationStatus.authorized));
      // clear log
      log.clear();

      // test other platforms
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final iosStatus = await messaging.requestPermission();
      expect(iosStatus.authorizationStatus, isA<AuthorizationStatus>());
      expect(iosStatus.authorizationStatus,
          equals(AuthorizationStatus.authorized));

      // check native method was called
      expect(log, <Matcher>[
        isMethodCall(
          'Messaging#requestPermission',
          arguments: <String, dynamic>{
            'appName': defaultFirebaseAppName,
            'permissions': <String, bool>{
              'alert': true,
              'announcement': false,
              'badge': true,
              'carPlay': false,
              'criticalAlert': false,
              'provisional': false,
              'sound': true,
            }
          },
        ),
      ]);
    });

    test('setAutoInitEnabled sets to true', () async {
      await messaging.setAutoInitEnabled(true);
      expect(messaging.isAutoInitEnabled, isTrue);

      // check native method was called
      expect(log, <Matcher>[
        isMethodCall(
          'Messaging#setAutoInitEnabled',
          arguments: <String, dynamic>{
            'appName': defaultFirebaseAppName,
            'enabled': true
          },
        ),
      ]);
    });

    test('setAutoInitEnabled sets to false', () async {
      await messaging.setAutoInitEnabled(false);
      expect(messaging.isAutoInitEnabled, isFalse);

      // check native method was called
      expect(log, <Matcher>[
        isMethodCall(
          'Messaging#setAutoInitEnabled',
          arguments: <String, dynamic>{
            'appName': defaultFirebaseAppName,
            'enabled': false
          },
        ),
      ]);
    });

    test('onTokenRefresh', () {
      expect(messaging.onTokenRefresh, isA<Stream<String>>());
    });

    test('subscribeToTopic', () async {
      const topic = 'test-topic';
      await messaging.subscribeToTopic(topic);

      // check native method was called
      expect(log, <Matcher>[
        isMethodCall(
          'Messaging#subscribeToTopic',
          arguments: <String, dynamic>{
            'appName': defaultFirebaseAppName,
            'topic': topic,
          },
        ),
      ]);
    });

    test('unsubscribeFromTopic', () async {
      const topic = 'test-topic';
      await messaging.unsubscribeFromTopic(topic);

      // check native method was called
      expect(log, <Matcher>[
        isMethodCall(
          'Messaging#unsubscribeFromTopic',
          arguments: <String, dynamic>{
            'appName': defaultFirebaseAppName,
            'topic': topic,
          },
        ),
      ]);
    });
  });
}

class ImplementsFirebaseMessagingPlatform extends Mock
    implements FirebaseMessagingPlatform {}

class MocksFirebaseMessagingPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseMessagingPlatform {}

class ExtendsFirebaseMessagingPlatform extends FirebaseMessagingPlatform {}

class TestMethodChannelFirebaseMessaging
    extends MethodChannelFirebaseMessaging {
  TestMethodChannelFirebaseMessaging(FirebaseApp app) : super(app: app);
}
