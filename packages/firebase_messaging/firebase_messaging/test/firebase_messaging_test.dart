// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart' show TestWidgetsFlutterBinding;
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:test/test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseMessaging', () {
    MockFirebaseMessaging mock;
    FirebaseMessaging firebaseMessaging;

    setUp(() {
      firebaseMessaging = FirebaseMessaging.private(FakePlatform(operatingSystem: 'ios'));
      mock = MockFirebaseMessaging();
      FirebaseMessagingPlatform.instance = mock;
    });

    test('requestNotificationPermissions on ios with default permissions', () {
      firebaseMessaging.requestNotificationPermissions();
      verify(mock.requestNotificationPermissions());
    });

    test('requestNotificationPermissions on ios with custom permissions', () {
      firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: false, provisional: true));
      verify(mock.requestNotificationPermissions(const IosNotificationSettings(sound: false, provisional: true)));
    });

    test('requestNotificationPermissions on android', () {
      firebaseMessaging = FirebaseMessaging.private(FakePlatform(operatingSystem: 'android'));

      firebaseMessaging.requestNotificationPermissions();
      verifyZeroInteractions(mock);
    });

    test('configure', () {
      firebaseMessaging.configure();
      verify(mock.configure());
    });

    test('incoming token', () async {
      firebaseMessaging.configure();
      final String token1 = 'I am a super secret token';
      final String token2 = 'I am the new token in town';
      when(mock.onTokenRefresh).thenAnswer((_) => Stream<String>.fromIterable([token1, token2]));

      final changes = StreamQueue<String>(firebaseMessaging.onTokenRefresh);
      expect(await changes.next, token1);
      expect(await changes.next, token2);

      changes.cancel();
    });

    test('incoming iOS settings', () async {
      firebaseMessaging.configure();
      final iosSettings1 = const IosNotificationSettings();
      final iosSettings2 = const IosNotificationSettings(sound: false);

      when(mock.onIosSettingsRegistered)
          .thenAnswer((_) => Stream<IosNotificationSettings>.fromIterable([iosSettings1, iosSettings2]));

      final changes = StreamQueue<IosNotificationSettings>(firebaseMessaging.onIosSettingsRegistered);
      expect((await changes.next).toMap(), iosSettings1.toMap());
      expect((await changes.next).toMap(), iosSettings2.toMap());

      changes.cancel();
    });

//    TODO: write incoming messages test
//    test('incoming messages', () async {
//      final Completer<dynamic> onMessage = Completer<dynamic>();
//      final Completer<dynamic> onLaunch = Completer<dynamic>();
//      final Completer<dynamic> onResume = Completer<dynamic>();
//
//      firebaseMessaging.configure(
//        onMessage: (dynamic m) async {
//          onMessage.complete(m);
//        },
//        onLaunch: (dynamic m) async {
//          onLaunch.complete(m);
//        },
//        onResume: (dynamic m) async {
//          onResume.complete(m);
//        },
//        onBackgroundMessage: validOnBackgroundMessage,
//      );
//
//      final dynamic handler = verify(mockChannel.setMethodCallHandler(captureAny)).captured.single;
//
//      final Map<String, dynamic> onMessageMessage = <String, dynamic>{};
//      final Map<String, dynamic> onLaunchMessage = <String, dynamic>{};
//      final Map<String, dynamic> onResumeMessage = <String, dynamic>{};
//
//      await handler(MethodCall('onMessage', onMessageMessage));
//      expect(await onMessage.future, onMessageMessage);
//      expect(onLaunch.isCompleted, isFalse);
//      expect(onResume.isCompleted, isFalse);
//
//      await handler(MethodCall('onLaunch', onLaunchMessage));
//      expect(await onLaunch.future, onLaunchMessage);
//      expect(onResume.isCompleted, isFalse);
//
//      await handler(MethodCall('onResume', onResumeMessage));
//      expect(await onResume.future, onResumeMessage);
//    });

    const String myTopic = 'Flutter';

    test('subscribe to topic', () async {
      await firebaseMessaging.subscribeToTopic(myTopic);
      verify(mock.subscribeToTopic(myTopic));
    });

    test('unsubscribe from topic', () async {
      await firebaseMessaging.unsubscribeFromTopic(myTopic);
      verify(mock.unsubscribeFromTopic(myTopic));
    });

    test('getToken', () {
      firebaseMessaging.getToken();
      verify(mock.getToken());
    });

    test('deleteInstanceID', () {
      firebaseMessaging.deleteInstanceID();
      verify(mock.deleteInstanceID());
    });

    test('autoInitEnabled', () {
      firebaseMessaging.autoInitEnabled();
      verify(mock.autoInitEnabled());
    });

    test('setAutoInitEnabled', () {
      // assert that we haven't called the method yet
      verifyNever(firebaseMessaging.setAutoInitEnabled(true));

      firebaseMessaging.setAutoInitEnabled(true);

      verify(mock.setAutoInitEnabled(true));

      // assert that enabled = false was not yet called
      verifyNever(firebaseMessaging.setAutoInitEnabled(false));

      firebaseMessaging.setAutoInitEnabled(false);

      verify(mock.setAutoInitEnabled(false));
    });

    test('configure bad onBackgroundMessage', () {
      expect(
        () => firebaseMessaging.configure(
          onBackgroundMessage: (dynamic message) => Future<dynamic>.value(),
        ),
        throwsArgumentError,
      );
    });
  });
}

Future<dynamic> validOnBackgroundMessage(Map<String, dynamic> message) async {}

class MockFirebaseMessaging extends Mock with MockPlatformInterfaceMixin implements FirebaseMessagingPlatform {}
