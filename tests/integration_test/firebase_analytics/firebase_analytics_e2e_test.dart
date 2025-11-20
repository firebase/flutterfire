// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

// ignore: do_not_use_environment
const bool skipTestsOnCI = bool.fromEnvironment('CI');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('firebase_analytics', () {
    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    // getSessionId has to be first, else Android returns null
    test(
      'getSessionId',
      () async {
        if (kIsWeb) {
          await expectLater(
            FirebaseAnalytics.instance.getSessionId(),
            throwsA(isA<UnimplementedError>()),
          );
        } else {
          await expectLater(
            FirebaseAnalytics.instance.setConsent(
              analyticsStorageConsentGranted: true,
            ),
            completes,
          );

          final result = await FirebaseAnalytics.instance.getSessionId();
          expect(result, isA<int?>());
        }
      },
      skip: skipTestsOnCI && defaultTargetPlatform == TargetPlatform.iOS,
    );

    test('isSupported', () async {
      final result = await FirebaseAnalytics.instance.isSupported();
      expect(result, isA<bool>());
    });

    test('logEvent', () async {
      await expectLater(
        FirebaseAnalytics.instance.logEvent(name: 'testing'),
        completes,
      );

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
        FirebaseAnalytics.instance.logEvent(
          name: 'testing-parameters',
          parameters: {
            'foo': 'bar',
            'baz': 500,
          },
        ),
        completes,
      );

      // test custom event assert exception
      await expectLater(
        FirebaseAnalytics.instance.logEvent(
          name: 'testing-parameters',
          parameters: {
            'foo': 'bar',
            'baz': 500,
            // Lists are not supported
            'items': [analyticsEventItem],
          },
        ),
        throwsA(isA<AssertionError>()),
      );

      // test 3 reserved events
      await expectLater(
        FirebaseAnalytics.instance.logAdImpression(
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
        FirebaseAnalytics.instance.logPurchase(
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

      await expectLater(
        FirebaseAnalytics.instance.logScreenView(
          screenClass: 'FooActivity',
          screenName: 'bar',
        ),
        completes,
      );
    });

    test(
      'setSessionTimeoutDuration',
      () async {
        if (kIsWeb) {
          await expectLater(
            FirebaseAnalytics.instance
                .setSessionTimeoutDuration(const Duration(milliseconds: 5000)),
            throwsA(isA<UnimplementedError>()),
          );
        } else {
          await expectLater(
            FirebaseAnalytics.instance
                .setSessionTimeoutDuration(const Duration(milliseconds: 5000)),
            completes,
          );
        }
      },
    );

    test('setAnalyticsCollectionEnabled', () async {
      await expectLater(
        FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true),
        completes,
      );
    });

    test(
      'logInAppPurchase',
      () async {
        await expectLater(
          FirebaseAnalytics.instance.logInAppPurchase(
            currency: 'USD',
            freeTrial: false,
            price: 4.99,
            priceIsDiscounted: false,
            productID: 'com.example.product',
            productName: 'Example Product',
            quantity: 1,
            subscription: true,
            value: 4.99,
          ),
          completes,
        );
      },
      skip: defaultTargetPlatform != TargetPlatform.iOS,
    );

    test('setUserId', () async {
      await expectLater(
        FirebaseAnalytics.instance.setUserId(id: 'foo'),
        completes,
      );
    });

    test('logScreenView', () async {
      await expectLater(
        FirebaseAnalytics.instance.logScreenView(
          screenName: 'screen-name',
          screenClass: 'TestScreen',
        ),
        completes,
      );
    });

    test('setUserProperty', () async {
      await expectLater(
        FirebaseAnalytics.instance.setUserProperty(name: 'foo', value: 'bar'),
        completes,
      );
    });

    test(
      'resetAnalyticsData',
      () async {
        if (kIsWeb) {
          await expectLater(
            FirebaseAnalytics.instance.resetAnalyticsData(),
            throwsA(isA<UnimplementedError>()),
          );
        } else {
          await expectLater(
            FirebaseAnalytics.instance.resetAnalyticsData(),
            completes,
          );
        }
      },
    );

    test(
      'setConsent',
      () async {
        await expectLater(
          FirebaseAnalytics.instance.setConsent(
            analyticsStorageConsentGranted: true,
            adStorageConsentGranted: true,
            adPersonalizationSignalsConsentGranted: true,
            adUserDataConsentGranted: true,
            functionalityStorageConsentGranted: true,
            personalizationStorageConsentGranted: true,
            securityStorageConsentGranted: true,
          ),
          completes,
        );
      },
    );

    test(
      'setDefaultEventParameters',
      () async {
        if (kIsWeb) {
          await expectLater(
            FirebaseAnalytics.instance
                .setDefaultEventParameters({'default': 'parameters'}),
            throwsA(isA<UnimplementedError>()),
          );
          // reset a single default parameter
          await expectLater(
            FirebaseAnalytics.instance
                .setDefaultEventParameters({'default': null}),
            throwsA(isA<UnimplementedError>()),
          );
          // reset all default parameters
          await expectLater(
            FirebaseAnalytics.instance.setDefaultEventParameters(null),
            throwsA(isA<UnimplementedError>()),
          );
        } else {
          await expectLater(
            FirebaseAnalytics.instance
                .setDefaultEventParameters({'default': 'parameters'}),
            completes,
          );
          // reset a single default parameter
          await expectLater(
            FirebaseAnalytics.instance
                .setDefaultEventParameters({'default': null}),
            completes,
          );
          // reset all default parameters
          await expectLater(
            FirebaseAnalytics.instance.setDefaultEventParameters(null),
            completes,
          );

          // test custom event assert exception
          await expectLater(
            FirebaseAnalytics.instance.setDefaultEventParameters(
              {
                'foo': 'bar',
                'baz': 500,
                // Lists are not supported
                'items': ['some', 'items'],
              },
            ),
            throwsA(isA<AssertionError>()),
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
        await expectLater(
          FirebaseAnalytics.instance.setConsent(
            analyticsStorageConsentGranted: false,
            adStorageConsentGranted: false,
          ),
          completes,
        );

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

    test(
      'initiateOnDeviceConversionMeasurement',
      () async {
        await expectLater(
          FirebaseAnalytics.instance
              .initiateOnDeviceConversionMeasurementWithEmailAddress(
            'test@mail.com',
          ),
          completes,
        );

        await expectLater(
          FirebaseAnalytics.instance
              .initiateOnDeviceConversionMeasurementWithPhoneNumber(
            '+15555555555',
          ),
          completes,
        );
      },
      skip: kIsWeb || defaultTargetPlatform != TargetPlatform.iOS,
    );
  });
}
