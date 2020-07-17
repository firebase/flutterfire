@TestOn('chrome') // Uses web-only Flutter SDK

import 'package:firebase/firebase.dart';
import 'package:firebase_analytics_web/firebase_analytics_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAnalytics extends Mock implements Analytics {}

void main() {
  group('FirebaseAnalyticsWeb', () {
    FirebaseAnalyticsWeb firebaseAnalytics;
    MockAnalytics analytics;

    setUp(() {
      analytics = MockAnalytics();
      firebaseAnalytics = FirebaseAnalyticsWeb(analytics: analytics);
    });

    test('logEvent', () async {
      final name = 'random';
      final parameters = {'a': 'b'};
      await firebaseAnalytics.logEvent(name: name, parameters: parameters);
      verify(analytics.logEvent(name, parameters));
    });

    test('setAnalyticsCollectionEnabled', () async {
      final enabled = true;
      await firebaseAnalytics.setAnalyticsCollectionEnabled(enabled);
      verify(analytics.setAnalyticsCollectionEnabled(enabled));
    });

    test('setUserId', () async {
      final userId = 'userId';
      await firebaseAnalytics.setUserId(userId);
      verify(analytics.setUserId(userId));
    });

    test('setCurrentScreen', () async {
      final screenName = 'screenName';
      // screenClassOverride is discarded in web.
      final screenClassOverride = 'screenClassOverride';
      await firebaseAnalytics.setCurrentScreen(
        screenName: screenName,
        screenClassOverride: screenClassOverride,
      );
      verify(analytics.setCurrentScreen(screenName));
    });

    test('setUserProperty', () async {
      final name = 'name';
      final value = 'value';
      await firebaseAnalytics.setUserProperty(name: name, value: value);
      verify(analytics.setUserProperties({name: value}));
    });
  });
}
