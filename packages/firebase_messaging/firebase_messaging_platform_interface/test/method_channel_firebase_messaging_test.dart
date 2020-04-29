// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MockMethodChannel mockChannel;
  MethodChannelFirebaseMessaging channelPlatform;

  setUp(() {
    mockChannel = MockMethodChannel();
    channelPlatform = MethodChannelFirebaseMessaging.private(mockChannel);
  });

  test('requestNotificationPermissions on ios with default permissions', () {
    channelPlatform.requestNotificationPermissions();
    verify(mockChannel.invokeMethod<void>('requestNotificationPermissions',
        <String, bool>{'sound': true, 'badge': true, 'alert': true, 'provisional': false}));
  });

  test('requestNotificationPermissions on ios with custom permissions', () {
    channelPlatform.requestNotificationPermissions(const IosNotificationSettings(sound: false, provisional: true));
    verify(mockChannel.invokeMethod<void>('requestNotificationPermissions',
        <String, bool>{'sound': false, 'badge': true, 'alert': true, 'provisional': true}));
  });

  test('configure', () {
    channelPlatform.configure();
    verify(mockChannel.setMethodCallHandler(any));
    verify(mockChannel.invokeMethod<void>('configure'));
  });

  test('incoming token', () async {
    channelPlatform.configure();
    final dynamic handler = verify(mockChannel.setMethodCallHandler(captureAny)).captured.single;
    final String token1 = 'I am a super secret token';
    final String token2 = 'I am the new token in town';
    Future<String> tokenFromStream = channelPlatform.onTokenRefresh.first;
    await handler(MethodCall('onToken', token1));

    expect(await tokenFromStream, token1);

    tokenFromStream = channelPlatform.onTokenRefresh.first;
    await handler(MethodCall('onToken', token2));

    expect(await tokenFromStream, token2);
  });

  test('incoming iOS settings', () async {
    channelPlatform.configure();
    final dynamic handler = verify(mockChannel.setMethodCallHandler(captureAny)).captured.single;
    IosNotificationSettings iosSettings = const IosNotificationSettings();

    Future<IosNotificationSettings> iosSettingsFromStream = channelPlatform.onIosSettingsRegistered.first;
    await handler(MethodCall('onIosSettingsRegistered', iosSettings.toMap()));
    expect((await iosSettingsFromStream).toMap(), iosSettings.toMap());

    iosSettings = const IosNotificationSettings(sound: false);
    iosSettingsFromStream = channelPlatform.onIosSettingsRegistered.first;
    await handler(MethodCall('onIosSettingsRegistered', iosSettings.toMap()));
    expect((await iosSettingsFromStream).toMap(), iosSettings.toMap());
  });

  test('incoming messages', () async {
    final Completer<dynamic> onMessage = Completer<dynamic>();
    final Completer<dynamic> onLaunch = Completer<dynamic>();
    final Completer<dynamic> onResume = Completer<dynamic>();

    channelPlatform.configure(
      onMessage: (dynamic m) async {
        onMessage.complete(m);
      },
      onLaunch: (dynamic m) async {
        onLaunch.complete(m);
      },
      onResume: (dynamic m) async {
        onResume.complete(m);
      },
      onBackgroundMessage: validOnBackgroundMessage,
    );
    final dynamic handler = verify(mockChannel.setMethodCallHandler(captureAny)).captured.single;

    final Map<String, dynamic> onMessageMessage = <String, dynamic>{};
    final Map<String, dynamic> onLaunchMessage = <String, dynamic>{};
    final Map<String, dynamic> onResumeMessage = <String, dynamic>{};

    await handler(MethodCall('onMessage', onMessageMessage));
    expect(await onMessage.future, onMessageMessage);
    expect(onLaunch.isCompleted, isFalse);
    expect(onResume.isCompleted, isFalse);

    await handler(MethodCall('onLaunch', onLaunchMessage));
    expect(await onLaunch.future, onLaunchMessage);
    expect(onResume.isCompleted, isFalse);

    await handler(MethodCall('onResume', onResumeMessage));
    expect(await onResume.future, onResumeMessage);
  });

  const String myTopic = 'Flutter';

  test('subscribe to topic', () async {
    await channelPlatform.subscribeToTopic(myTopic);
    verify(mockChannel.invokeMethod<void>('subscribeToTopic', myTopic));
  });

  test('unsubscribe from topic', () async {
    await channelPlatform.unsubscribeFromTopic(myTopic);
    verify(mockChannel.invokeMethod<void>('unsubscribeFromTopic', myTopic));
  });

  test('getToken', () {
    channelPlatform.getToken();
    verify(mockChannel.invokeMethod<String>('getToken'));
  });

  test('deleteInstanceID', () {
    channelPlatform.deleteInstanceID();
    verify(mockChannel.invokeMethod<bool>('deleteInstanceID'));
  });

  test('autoInitEnabled', () {
    channelPlatform.autoInitEnabled();
    verify(mockChannel.invokeMethod<bool>('autoInitEnabled'));
  });

  test('setAutoInitEnabled', () {
    // assert that we haven't called the method yet
    verifyNever(channelPlatform.setAutoInitEnabled(true));

    channelPlatform.setAutoInitEnabled(true);

    verify(mockChannel.invokeMethod<void>('setAutoInitEnabled', true));

    // assert that enabled = false was not yet called
    verifyNever(channelPlatform.setAutoInitEnabled(false));

    channelPlatform.setAutoInitEnabled(false);

    verify(mockChannel.invokeMethod<void>('setAutoInitEnabled', false));
  });

  test('configure bad onBackgroundMessage', () {
    expect(
      () => channelPlatform.configure(
        onBackgroundMessage: (dynamic message) => Future<dynamic>.value(),
      ),
      throwsArgumentError,
    );
  });
}

Future<dynamic> validOnBackgroundMessage(Map<String, dynamic> message) async {}

class MockMethodChannel extends Mock implements MethodChannel {}
