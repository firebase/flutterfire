// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import '../mock.dart';

void main() {
  setupFirebaseAnalyticsMocks();
  late FirebaseAnalyticsPlatform analytics;
  final List<MethodCall> methodCallLogger = <MethodCall>[];

  group('$MethodChannelFirebaseAnalytics', () {
    setUpAll(() async {
      FirebaseApp app = await Firebase.initializeApp();

      handleMethodCall((call) async {
        methodCallLogger.add(call);

        switch (call.method) {
          case 'Analytics#getAppInstanceId':
            return 'ABCD1234';

          default:
            return true;
        }
      });

      analytics = MethodChannelFirebaseAnalytics(app: app);
    });

    setUp(() async {
      methodCallLogger.clear();
    });

    test('setUserId', () async {
      await analytics.setUserId(id: 'test-user-id');
      expect(
        methodCallLogger,
        <Matcher>[
          isMethodCall(
            'Analytics#setUserId',
            arguments: {'userId': 'test-user-id'},
          ),
        ],
      );
    });

    test('setCurrentScreen', () async {
      await analytics.setCurrentScreen(
        screenName: 'test-screen-name',
        screenClassOverride: 'test-class-override',
      );
      expect(
        methodCallLogger,
        <Matcher>[
          isMethodCall(
            'Analytics#logEvent',
            arguments: {
              'eventName': 'screen_view',
              'parameters': {
                'screen_name': 'test-screen-name',
                'screen_class': 'test-class-override',
              },
            },
          ),
        ],
      );
    });

    test('setUserProperty', () async {
      await analytics.setUserProperty(name: 'test_name', value: 'test-value');
      expect(
        methodCallLogger,
        <Matcher>[
          isMethodCall(
            'Analytics#setUserProperty',
            arguments: {
              'name': 'test_name',
              'value': 'test-value',
            },
          ),
        ],
      );
    });

    test('setAnalyticsCollectionEnabled', () async {
      await analytics.setAnalyticsCollectionEnabled(false);
      expect(
        methodCallLogger,
        <Matcher>[
          isMethodCall(
            'Analytics#setAnalyticsCollectionEnabled',
            arguments: {'enabled': false},
          ),
        ],
      );
    });

    test('setSessionTimeoutDuration', () async {
      Duration timeout = const Duration(milliseconds: 1000);
      // android platform specific
      await analytics.setSessionTimeoutDuration(timeout);
    });

    test('resetAnalyticsData', () async {
      await analytics.resetAnalyticsData();
      expect(
        methodCallLogger,
        <Matcher>[
          isMethodCall(
            'Analytics#resetAnalyticsData',
            arguments: null,
          ),
        ],
      );
    });

    test('getAppInstanceId', () async {
      await analytics.getAppInstanceId();
      expect(
        methodCallLogger,
        <Matcher>[
          isMethodCall(
            'Analytics#getAppInstanceId',
            arguments: null,
          ),
        ],
      );
    });

    test('logEvent', () async {
      await analytics.logEvent(
        name: 'test-event',
        parameters: <String, Object>{'a': 'b'},
      );
      expect(
        methodCallLogger,
        <Matcher>[
          isMethodCall(
            'Analytics#logEvent',
            arguments: <String, Object>{
              'eventName': 'test-event',
              'parameters': <String, Object>{'a': 'b'},
            },
          ),
        ],
      );
    });
  });
}

class TestMethodChannelFirebaseAnalytics
    extends MethodChannelFirebaseAnalytics {
  TestMethodChannelFirebaseAnalytics(FirebaseApp app) : super(app: app);
}
