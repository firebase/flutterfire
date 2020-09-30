// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import './mock.dart';

void main() {
  setupFirebaseMessagingMocks();
  FirebaseMessaging messaging;
  FirebaseMessaging secondaryMessaging;
  FirebaseApp app;
  FirebaseApp secondaryApp;

  group('$FirebaseMessaging', () {
    setUpAll(() async {
      FirebaseMessagingPlatform.instance = kMockMessagingPlatform;

      app = await Firebase.initializeApp();
      secondaryApp = await Firebase.initializeApp(
          name: 'foo',
          options: FirebaseOptions(
            apiKey: '123',
            appId: '123',
            messagingSenderId: '123',
            projectId: '123',
          ));

      messaging = FirebaseMessaging.instance;
      secondaryMessaging = FirebaseMessaging.instanceFor(app: secondaryApp);
    });
    group('instance', () {
      test('returns an instance', () async {
        expect(messaging, isA<FirebaseMessaging>());
      });

      test('returns the correct $FirebaseApp', () {
        expect(messaging.app, isA<FirebaseApp>());
        expect(messaging.app.name, defaultFirebaseAppName);
      });
    });

    group('instanceFor()', () {
      test('returns an instance', () async {
        expect(secondaryMessaging, isA<FirebaseMessaging>());
      });

      test('returns the correct $FirebaseApp', () {
        expect(secondaryMessaging.app, isA<FirebaseApp>());
        expect(secondaryMessaging.app.name, secondaryApp.name);
      });
    });

    group('configure', () {});

    group('get.isAutoInitEnabled', () {
      test('verify delegate method is called', () {
        // verify isAutoInitEnabled returns true
        when(kMockMessagingPlatform.isAutoInitEnabled).thenReturn(true);
        var result = messaging.isAutoInitEnabled;

        expect(result, isA<bool>());
        expect(result, isTrue);
        verify(kMockMessagingPlatform.isAutoInitEnabled);

        // verify isAutoInitEnabled returns false
        when(kMockMessagingPlatform.isAutoInitEnabled).thenReturn(false);
        result = messaging.isAutoInitEnabled;

        expect(result, isA<bool>());
        expect(result, isFalse);
        verify(kMockMessagingPlatform.isAutoInitEnabled);
      });
    });

    group('initialNotification', () {
      test('verify delegate method is called', () {
        const notificationTitle = 'test-notification';
        Notification notification = Notification(title: notificationTitle);
        when(kMockMessagingPlatform.initialNotification)
            .thenReturn(notification);

        // verify isAutoInitEnabled returns true
        final result = messaging.initialNotification;

        expect(result, isA<Notification>());
        expect(result.title, notificationTitle);

        verify(kMockMessagingPlatform.initialNotification);
      });
    });

    group('deleteToken', () {
      test('verify delegate method is called with correct args', () async {
        const authorizedEntity = 'test-authorizedEntity';
        const scope = 'test-scope';
        when(kMockMessagingPlatform.deleteToken()).thenReturn(null);

        await messaging.deleteToken(
            authorizedEntity: authorizedEntity, scope: scope);

        verify(kMockMessagingPlatform.deleteToken(
            authorizedEntity: authorizedEntity, scope: scope));
      });
    });

    group('getAPNSToken', () {
      test('verify delegate method is called', () async {
        const apnsToken = 'test-apns';
        when(kMockMessagingPlatform.getAPNSToken())
            .thenAnswer((_) => Future.value(apnsToken));

        await messaging.getAPNSToken();

        verify(kMockMessagingPlatform.getAPNSToken());
      });
    });
    group('getToken', () {
      test('verify delegate method is called with correct args', () async {
        const authorizedEntity = 'test-authorizedEntity';
        const scope = 'test-scope';
        const vapidKey = 'test-vapid-key';
        when(kMockMessagingPlatform.getToken(
                authorizedEntity: anyNamed('authorizedEntity'),
                scope: anyNamed('scope'),
                vapidKey: anyNamed('vapidKey')))
            .thenReturn(null);

        await messaging.getToken(
            authorizedEntity: authorizedEntity,
            scope: scope,
            vapidKey: vapidKey);

        verify(kMockMessagingPlatform.getToken(
            authorizedEntity: authorizedEntity,
            scope: scope,
            vapidKey: vapidKey));
      });
    });
    group('hasPermission', () {
      test('verify delegate method is called', () async {
        when(kMockMessagingPlatform.hasPermission())
            .thenAnswer((_) => Future.value(AuthorizationStatus.authorized));

        final result = await messaging.hasPermission();

        expect(result, isA<AuthorizationStatus>());
        expect(result, AuthorizationStatus.authorized);

        verify(kMockMessagingPlatform.hasPermission());
      });
    });
    group('onTokenRefresh', () {
      test('verify delegate method is called', () async {
        const token = 'test-token';

        when(kMockMessagingPlatform.onTokenRefresh)
            .thenAnswer((_) => Stream<String>.fromIterable(<String>[token]));

        final StreamQueue<String> changes =
            StreamQueue<String>(messaging.onTokenRefresh);
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
        )).thenAnswer((_) => Future.value(AuthorizationStatus.authorized));

        // true values
        await messaging.requestPermission(
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
        await messaging.requestPermission(
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
        await messaging.requestPermission();

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
    group('sendMessage', () {
      var senderId = 'custom-sender@fcm.googleapis.com';
      var data = <String, String>{'foo': 'bar'};
      var collapseKey = 'collapse-key';
      var messageId = 'message-id';
      var messageType = 'message-type';
      var ttl = 1;

      setUpAll(() {
        when(kMockMessagingPlatform.sendMessage(
          senderId: anyNamed('senderId'),
          data: anyNamed('data'),
          collapseKey: anyNamed('collapseKey'),
          messageId: anyNamed('messageId'),
          messageType: anyNamed('messageType'),
          ttl: anyNamed('ttl'),
        )).thenAnswer((_) => null);
      });
      test('verify delegate method is called with correct args', () async {
        await messaging.sendMessage(
            senderId: senderId,
            data: data,
            collapseKey: collapseKey,
            messageId: messageId,
            messageType: messageType,
            ttl: ttl);

        verify(kMockMessagingPlatform.sendMessage(
            senderId: senderId,
            data: data,
            collapseKey: collapseKey,
            messageId: messageId,
            messageType: messageType,
            ttl: ttl));
      });

      test('senderId defaults to the correct value if not set', () async {
        var defaultSenderId =
            '${app.options.messagingSenderId}@fcm.googleapis.com';

        await messaging.sendMessage(
            senderId: null,
            data: data,
            collapseKey: collapseKey,
            messageId: messageId,
            messageType: messageType,
            ttl: null);

        verify(kMockMessagingPlatform.sendMessage(
            senderId: defaultSenderId,
            data: data,
            collapseKey: collapseKey,
            messageId: messageId,
            messageType: messageType,
            ttl: null));
      });

      test('asserts [ttl] is more than 0 if not null', () {
        expect(() => messaging.sendMessage(ttl: -1), throwsAssertionError);
      });
    });
    group('setAutoInitEnabled', () {
      test('verify delegate method is called with correct args', () async {
        when(kMockMessagingPlatform.setAutoInitEnabled(any))
            .thenAnswer((_) => null);

        await messaging.setAutoInitEnabled(false);
        verify(kMockMessagingPlatform.setAutoInitEnabled(false));

        await messaging.setAutoInitEnabled(true);
        verify(kMockMessagingPlatform.setAutoInitEnabled(true));
      });

      test('asserts [ttl] is more than 0 if not null', () {
        expect(() => messaging.setAutoInitEnabled(null), throwsAssertionError);
      });
    });
    // group('onIosSettingsRegistered', () {});
    group('subscribeToTopic', () {
      setUpAll(() {
        when(kMockMessagingPlatform.subscribeToTopic(any))
            .thenAnswer((_) => null);
      });

      test('throws AssertionError if topic is invalid', () async {
        final invalidTopic = 'test invalid = topic';

        expect(() => messaging.subscribeToTopic(invalidTopic),
            throwsAssertionError);
      });

      test('verify delegate method is called with correct args', () async {
        final topic = 'test-topic';

        await messaging.subscribeToTopic(topic);
        verify(kMockMessagingPlatform.subscribeToTopic(topic));
      });

      test('throws AssertionError for invalid topic name', () {
        expect(
            () => messaging.unsubscribeFromTopic(null), throwsAssertionError);
        verifyNever(kMockMessagingPlatform.unsubscribeFromTopic(any));
      });
    });
    group('unsubscribeFromTopic', () {
      when(kMockMessagingPlatform.unsubscribeFromTopic(any))
          .thenAnswer((_) => null);
      test('verify delegate method is called with correct args', () async {
        final topic = 'test-topic';

        await messaging.unsubscribeFromTopic(topic);
        verify(kMockMessagingPlatform.unsubscribeFromTopic(topic));
      });

      test('throws AssertionError for invalid topic name', () {
        expect(
            () => messaging.unsubscribeFromTopic(null), throwsAssertionError);
        verifyNever(kMockMessagingPlatform.unsubscribeFromTopic(any));
      });
    });

    group('deleteInstanceID', () {
      test('verify delegate method', () async {
        bool mockResult = true;
        when(kMockMessagingPlatform.deleteInstanceID())
            .thenAnswer((_) => Future.value(mockResult));

        var result = await messaging.deleteInstanceID();
        expect(result, isTrue);

        verify(kMockMessagingPlatform.deleteInstanceID());

        mockResult = false;
        result = await messaging.deleteInstanceID();
        expect(result, isFalse);
      });
    });
  });
}
