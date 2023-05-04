// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('chrome')

import 'package:firebase_analytics_web/firebase_analytics_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<FirebaseAnalyticsWeb>()])
import 'firebase_analytics_web_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('$FirebaseAnalyticsWeb', () {
    late MockFirebaseAnalyticsWeb analytics;

    setUp(() {
      analytics = MockFirebaseAnalyticsWeb();
    });

    test('logEvent', () {
      const name = 'random';
      final parameters = {'a': 'b'};
      analytics.logEvent(name: name, parameters: parameters);
      verify(analytics.logEvent(name: name, parameters: parameters));
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
      analytics.setUserId(id: userId);
      verify(analytics.setUserId(id: userId));
      verifyNoMoreInteractions(analytics);
    });

    test('setCurrentScreen', () {
      const screenName = 'screenName';
      // screenClassOverride is discarded in web.
      analytics.setCurrentScreen(
        screenName: screenName,
      );
      verify(analytics.setCurrentScreen(screenName: screenName));
      verifyNoMoreInteractions(analytics);
    });

    test('setAnalyticsCollectionEnabled', () {
      analytics.setAnalyticsCollectionEnabled(true);
      verify(analytics.setAnalyticsCollectionEnabled(true));
      verifyNoMoreInteractions(analytics);
    });
  });
}
