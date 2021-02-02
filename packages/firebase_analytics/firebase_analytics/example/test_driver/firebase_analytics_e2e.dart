// @dart = 2.9

// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'package:e2e/e2e.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Android-only functionality', (WidgetTester tester) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseAnalytics().android.setSessionTimeoutDuration(1000);
    } else {
      expect(FirebaseAnalytics().android, isNull);
    }
  }, skip: kIsWeb);

  testWidgets('logging', (WidgetTester tester) async {
    expect(FirebaseAnalytics().setAnalyticsCollectionEnabled(true), completes);
    expect(
        FirebaseAnalytics().setCurrentScreen(screenName: 'testing'), completes);
    expect(FirebaseAnalytics().logEvent(name: 'testing'), completes);
  });
}
