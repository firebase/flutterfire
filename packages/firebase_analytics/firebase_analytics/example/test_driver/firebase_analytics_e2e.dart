// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:drive/drive.dart' as drive;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void testsMain() {
  group('$FirebaseAnalytics', () {
    late FirebaseAnalytics analytics;

    setUpAll(() async {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
          appId: '1:448618578101:ios:2bc5c1fe2ec336f8ac3efc',
          storageBucket: 'react-native-firebase-testing.appspot.com',
          databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
          messagingSenderId: '448618578101',
          projectId: 'react-native-firebase-testing',
        ),
      );
      analytics = FirebaseAnalytics.instance;
    });

    test('isSupported', () async {
      final result = await FirebaseAnalytics.instance.isSupported();
      expect(result, isA<bool>());
    });

    test('logEvent', () async {
      await expectLater(analytics.logEvent(name: 'testing'), completes);

      AnalyticsEventItem analyticsEventItem = AnalyticsEventItem(
        affiliation: 'affil',
        coupon: 'coup',
        creativeName: 'creativeName',
        creativeSlot: 'creativeSlot',
        discount: 2.22,
        index: 3,
        itemBrand: 'itemBrand',
        itemCategory: 'itemCategory',
        itemCategory2: 'itemCategory2',
        itemCategory3: 'itemCategory3',
        itemCategory4: 'itemCategory4',
        itemCategory5: 'itemCategory5',
        itemId: 'itemId',
        itemListId: 'itemListId',
        itemListName: 'itemListName',
        itemName: 'itemName',
        itemVariant: 'itemVariant',
        locationId: 'locationId',
        price: 9.99,
        currency: 'USD',
        promotionId: 'promotionId',
        promotionName: 'promotionName',
        quantity: 1,
      );
      // test custom event
      await expectLater(
        analytics.logEvent(
          name: 'testing-parameters',
          parameters: {
            'foo': 'bar',
            'baz': 500,
            'items': [analyticsEventItem],
          },
        ),
        completes,
      );
      // test 2 reserved events
      await expectLater(
        analytics.logAdImpression(
          adPlatform: 'foo',
          adSource: 'bar',
          adFormat: 'baz',
          adUnitName: 'foo',
          currency: 'bar',
          value: 100,
        ),
        completes,
      );

      await expectLater(
        analytics.logPurchase(
          currency: 'foo',
          coupon: 'bar',
          value: 200,
          items: [analyticsEventItem],
          tax: 10,
          shipping: 23,
          transactionId: 'bar',
          affiliation: 'baz',
        ),
        completes,
      );
    });

    test(
      'setSessionTimeoutDuration',
      () async {
        if (kIsWeb) {
          await expectLater(
            analytics
                .setSessionTimeoutDuration(const Duration(milliseconds: 5000)),
            throwsA(isA<UnimplementedError>()),
          );
        } else {
          await expectLater(
            analytics
                .setSessionTimeoutDuration(const Duration(milliseconds: 5000)),
            completes,
          );
        }
      },
    );

    test('setAnalyticsCollectionEnabled', () async {
      await expectLater(
        analytics.setAnalyticsCollectionEnabled(true),
        completes,
      );
    });

    test('setUserId', () async {
      await expectLater(analytics.setUserId(id: 'foo'), completes);
    });

    test('setCurrentScreen', () async {
      await expectLater(
        analytics.setCurrentScreen(screenName: 'screen-name'),
        completes,
      );
    });

    test('setUserProperty', () async {
      await expectLater(
        analytics.setUserProperty(name: 'foo', value: 'bar'),
        completes,
      );
    });

    test(
      'resetAnalyticsData',
      () async {
        if (kIsWeb) {
          await expectLater(
            analytics.resetAnalyticsData(),
            throwsA(isA<UnimplementedError>()),
          );
        } else {
          await expectLater(analytics.resetAnalyticsData(), completes);
        }
      },
    );

    test(
      'setConsent',
      () async {
        if (kIsWeb) {
          await expectLater(
            analytics.setConsent(
              analyticsStorageConsentGranted: false,
              adStorageConsentGranted: true,
            ),
            throwsA(isA<UnimplementedError>()),
          );
        } else {
          await expectLater(
            analytics.setConsent(
              analyticsStorageConsentGranted: false,
              adStorageConsentGranted: true,
            ),
            completes,
          );
        }
      },
    );

    test(
      'setDefaultEventParameters',
      () async {
        if (kIsWeb) {
          await expectLater(
            analytics.setDefaultEventParameters({'default': 'parameters'}),
            throwsA(isA<UnimplementedError>()),
          );
        } else {
          await expectLater(
            analytics.setDefaultEventParameters({'default': 'parameters'}),
            completes,
          );
        }
      },
    );

    test('appInstanceId', () async {
      if (kIsWeb) {
        await expectLater(
          FirebaseAnalytics.instance.appInstanceId,
          throwsA(isA<UnimplementedError>()),
        );
      } else {
        final result = await FirebaseAnalytics.instance.appInstanceId;
        expect(result, isNull);

        await expectLater(
          FirebaseAnalytics.instance.setConsent(
            analyticsStorageConsentGranted: true,
            adStorageConsentGranted: false,
          ),
          completes,
        );

        final result2 = await FirebaseAnalytics.instance.appInstanceId;
        expect(result2, isA<String>());
      }
    });
  });
}

void main() => drive.main(testsMain);
