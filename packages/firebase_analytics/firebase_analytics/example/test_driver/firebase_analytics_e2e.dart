// ignore_for_file: require_trailing_commas

// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// @dart=2.9
import 'package:drive/drive.dart' as drive;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void testsMain() {
  group('$FirebaseAnalytics', () {
    /*late*/ FirebaseAnalytics analytics;

    setUpAll(() async {
      await Firebase.initializeApp();
      analytics = FirebaseAnalytics.instance;
    });

    test('logEvent', () async {
      await expectLater(analytics.logEvent(name: 'testing'), completes);

      Item ITEM = Item(
        affilitation: 'affil',
        coupon: 'coup',
        creative_name: 'creativeName',
        creative_slot: 'creativeSlot',
        discount: 'disc',
        index: 3,
        item_brand: 'itemBrand',
        item_category: 'itemCategory',
        item_category2: 'itemCategory2',
        item_category3: 'itemCategory3',
        item_category4: 'itemCategory4',
        item_category5: 'itemCategory5',
        item_id: 'itemId',
        item_list_id: 'itemListId',
        item_list_name: 'itemListName',
        item_name: 'itemName',
        item_variant: 'itemVariant',
        location_id: 'locationId',
        price: 'pri',
        promotion_id: 'promotionId',
        promotion_name: 'promotionName',
        quantity: 'quantity',
      );
      // test custom event
      await expectLater(
        analytics.logEvent(name: 'testing-parameters', parameters: {
          'foo': 'bar',
          'baz': 500,
          'items': [ITEM],
        }),
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
          // value: 100,
        ),
        completes,
      );

      await expectLater(
        analytics.logPurchase(
          currency: 'foo',
          coupon: 'bar',
          value: 200,
          items: [ITEM],
          tax: 10,
          shipping: 23,
          transactionId: 'bar',
          affiliation: 'baz',
        ),
        completes,
      );
    });

    test('setSessionTimeoutDuration', () async {
      await expectLater(
          analytics
              .setSessionTimeoutDuration(const Duration(milliseconds: 5000)),
          completes);
    });

    test('setAnalyticsCollectionEnabled', () async {
      await expectLater(
          analytics.setAnalyticsCollectionEnabled(true), completes);
    });

    test('setUserId', () async {
      await expectLater(analytics.setUserId(id: 'foo'), completes);
    });

    test('setCurrentScreen', () async {
      await expectLater(
          analytics.setCurrentScreen(screenName: 'screen-name'), completes);
    });

    test('setUserProperty', () async {
      await expectLater(
          analytics.setUserProperty(name: 'foo', value: 'bar'), completes);
    });

    test('resetAnalyticsData', () async {
      await expectLater(analytics.resetAnalyticsData(), completes);
    });

    test('resetAnalyticsData', () async {
      await expectLater(analytics.resetAnalyticsData(), completes);
    });
  });
}

void main() => drive.main(testsMain);
