// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics_platform_interface/method_channel_firebase_analytics.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelFirebaseAnalytics analytics =
      MethodChannelFirebaseAnalytics();

  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_analytics');
  MethodCall methodCall;

  setUp(() async {
    channel.setMockMethodCallHandler((MethodCall call) async {
      methodCall = call;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    methodCall = null;
  });

  group('$MethodChannelFirebaseAnalytics', () {
    test('setUserId', () async {
      await analytics.setUserId('test-user-id');
      expect(
        methodCall,
        isMethodCall(
          'setUserId',
          arguments: 'test-user-id',
        ),
      );
    });

    test('setCurrentScreen', () async {
      await analytics.setCurrentScreen(
        screenName: 'test-screen-name',
        screenClassOverride: 'test-class-override',
      );
      expect(
        methodCall,
        isMethodCall(
          'setCurrentScreen',
          arguments: <String, String>{
            'screenName': 'test-screen-name',
            'screenClassOverride': 'test-class-override',
          },
        ),
      );
    });

    test('setUserProperty', () async {
      await analytics.setUserProperty(name: 'test_name', value: 'test-value');
      expect(
        methodCall,
        isMethodCall(
          'setUserProperty',
          arguments: <String, String>{
            'name': 'test_name',
            'value': 'test-value',
          },
        ),
      );
    });

    test('setAnalyticsCollectionEnabled', () async {
      await analytics.setAnalyticsCollectionEnabled(false);
      expect(
        methodCall,
        isMethodCall(
          'setAnalyticsCollectionEnabled',
          arguments: false,
        ),
      );
    });

    test('setSessionTimeoutDuration', () async {
      await analytics.setSessionTimeoutDuration(234);
      expect(
        methodCall,
        isMethodCall(
          'setSessionTimeoutDuration',
          arguments: 234,
        ),
      );
    });

    test('resetAnalyticsData', () async {
      await analytics.resetAnalyticsData();
      expect(
        methodCall,
        isMethodCall(
          'resetAnalyticsData',
          arguments: null,
        ),
      );
    });
  });

  group('FirebaseAnalytics analytics events', () {
    test('logEvent log events', () async {
      await analytics.logEvent(
        name: 'test-event',
        parameters: <String, dynamic>{'a': 'b'},
      );
      expect(
        methodCall,
        isMethodCall(
          'logEvent',
          arguments: <String, dynamic>{
            'name': 'test-event',
            'parameters': <String, dynamic>{'a': 'b'},
          },
        ),
      );
    });
  });
}
