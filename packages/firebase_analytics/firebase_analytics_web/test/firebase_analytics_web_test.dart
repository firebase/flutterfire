// ignore_for_file: require_trailing_commas
// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('chrome')

import 'package:firebase/firebase.dart';
import 'package:firebase_analytics_web/firebase_analytics_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAnalytics extends Mock implements Analytics {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('$FirebaseAnalyticsWeb', () {
    late MockAnalytics analytics;

    setUp(() {
      analytics = MockAnalytics();
    });

    test('logEvent', () {
      const name = 'random';
      final parameters = {'a': 'b'};
      analytics.logEvent(name, parameters);
      verify(analytics.logEvent(name, parameters));
      verifyNoMoreInteractions(analytics);
    });

    test('setAnalyticsCollectionEnabled', () {
      const enabled = true;
      analytics.setAnalyticsCollectionEnabled(enabled);
      verify(analytics.setAnalyticsCollectionEnabled(enabled));
      verifyNoMoreInteractions(analytics);
    });

    test('setUserId', () {
      const userId = 'userId';
      analytics.setUserId(userId);
      verify(analytics.setUserId(userId));
      verifyNoMoreInteractions(analytics);
    });

    test('setCurrentScreen', () {
      const screenName = 'screenName';
      // screenClassOverride is discarded in web.
      analytics.setCurrentScreen(
       screenName,
      );
      verify(analytics.setCurrentScreen(screenName));
      verifyNoMoreInteractions(analytics);
    });

    test('setAnalyticsCollectionEnabled', () {
      analytics.setAnalyticsCollectionEnabled(true);
      verify(analytics.setAnalyticsCollectionEnabled(true));
      verifyNoMoreInteractions(analytics);
    });

    test('setUserProperties', () {
      final parameters = {'a': 'b'};
      analytics.setUserProperties(parameters);
      verify(analytics.setUserProperties(parameters));
      verifyNoMoreInteractions(analytics);
    });
  });
}
