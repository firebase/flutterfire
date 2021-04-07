// @dart = 2.9

// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'package:e2e/e2e.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(
        FirebaseAnalytics().logEvent(
          name: 'view_item_list',
          parameters: {
            'item_list_id': 'Test',
            'items': [
              {
                'item_id': '1',
                'item_name': 'Item 1',
              },
              {
                'item_id': 2,
                'item_name': 'Item 2',
                'details': {
                  'detail_1': 1,
                  'detail_2': '2',
                },
              },
            ],
          },
        ),
        completes);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      expect(
        FirebaseAnalytics().logEvent(
          name: 'test_event',
          parameters: {
            'ids': [1, 2, 3, 4, 5],
          },
        ),
        throwsA(isA<PlatformException>()),
      );
    }
  });
}
