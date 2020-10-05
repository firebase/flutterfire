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

  FirebaseApp app;
  FirebaseMessagingPlatform messaging;
  final List<MethodCall> log = <MethodCall>[];

  Map<String, dynamic> kMockNotification = {
    'android': {
      'channelId': 'foo',
      'count': 1,
      'priority': 1,
    },
    'ios': {
      'subtitle': 'bar',
    },
    'title': 'test notification',
    'body': 'this is a test notification'
  };

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
            return 'test_token';
          case 'Messaging#hasPermission':
          case 'Messaging#requestPermission':
            return 1;
          case 'Messaging#setAutoInitEnabled':
            return {
              'isAutoInitEnabled': true,
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
      test('when initialNotification arg is not null', () {
        final testMessaging =
            TestMethodChannelFirebaseMessaging(Firebase.app());
        final result = testMessaging.setInitialValues(
            isAutoInitEnabled: false, initialNotification: kMockNotification);
        expect(result, isA<FirebaseMessagingPlatform>());
        expect(result.isAutoInitEnabled, isFalse);
        expect(result.initialNotification, isA<Notification>());
      });

      test('when initialNotification arg is null', () {
        final testMessaging =
            TestMethodChannelFirebaseMessaging(Firebase.app());
        final result = testMessaging.setInitialValues(isAutoInitEnabled: false);
        expect(result, isA<FirebaseMessagingPlatform>());
        expect(result.isAutoInitEnabled, isFalse);
        expect(result.initialNotification, isNull);
      });
    });

    test('isAutoInitEnabled', () {
      messaging.setInitialValues(isAutoInitEnabled: true);
      expect(messaging.isAutoInitEnabled, isTrue);
    });

    test('initialNotification', () {
      messaging.setInitialValues(initialNotification: kMockNotification);
      final initialNotication = messaging.initialNotification;
      expect(initialNotication, isA<Notification>());
      // should now be null, since notification has been read
      expect(messaging.initialNotification, isNull);
    });

    test('deleteToken', () async {
      await messaging.deleteToken();

      // check native method was called
      expect(log, <Matcher>[
        isMethodCall(
          'Messaging#deleteToken',
          arguments: <String, dynamic>{
            'appName': defaultFirebaseAppName,
            'authorizedEntity': null,
            'scope': null,
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
            'authorizedEntity': null,
            'scope': null
          },
        ),
      ]);
    });

    // hasPermission
    test('hasPermission', () async {
      // test android response
      final androidStatus = await messaging.hasPermission();
      expect(androidStatus, equals(AuthorizationStatus.authorized));
      // clear log
      log.clear();

      // test other platforms
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final iosStatus = await messaging.hasPermission();
      expect(iosStatus, isA<AuthorizationStatus>());

      // check native method was called
      expect(log, <Matcher>[
        isMethodCall(
          'Messaging#hasPermission',
          arguments: <String, dynamic>{
            'appName': defaultFirebaseAppName,
          },
        ),
      ]);
    });

    test('requestPermission', () async {
      // test android response
      final androidStatus = await messaging.requestPermission();
      expect(androidStatus, equals(AuthorizationStatus.authorized));
      // clear log
      log.clear();

      // test other platforms
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final iosStatus = await messaging.requestPermission();
      expect(iosStatus, isA<AuthorizationStatus>());

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

    test('sendMessage', () async {
      await messaging.sendMessage();

      // check native method was called
      expect(log, <Matcher>[
        isMethodCall(
          'Messaging#sendMessage',
          arguments: <String, dynamic>{
            'appName': defaultFirebaseAppName,
            'message': <String, dynamic>{
              'senderId': null,
              'data': null,
              'collapseKey': null,
              'messageId': null,
              'messageType': null,
              'ttl': null,
            }
          },
        ),
      ]);
    });

    test('setAutoInitEnabled', () async {
      expect(messaging.isAutoInitEnabled, isNull);
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

    test('onIosSettingsRegistered', () {
      expect(messaging.onIosSettingsRegistered,
          isA<Stream<IosNotificationSettings>>());
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

    test('deleteInstanceID', () async {
      await messaging.deleteInstanceID();

      // check native method was called
      expect(log, <Matcher>[
        isMethodCall(
          'Messaging#deleteInstanceID',
          arguments: <String, dynamic>{
            'appName': defaultFirebaseAppName,
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
