@TestOn('chrome') // Uses web-only Flutter SDK

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics_web/firebase_analytics_web.dart';

void main() {
  group('FirebaseAnalytics for web', () {
    setUp(() {
      FirebaseAnalyticsPlatform.instance = FirebaseAnalyticsPlugin();
    });

    test('it should not fail', () {});
  });
}
