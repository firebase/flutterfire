// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

const String COUPON = 'coupon';
const String CURRENCY = 'currency';
const String PAYMENT_TYPE = 'payment_type';
const String VALUE = 'value';
const double VALUE_DOUBLE = 434;
const String ITEMS = 'items';
const String SHIPPING_TIER = 'shipping_tier';
const String AD_PLATFORM = 'ad_platform';
const String AD_SOURCE = 'ad_source';
const String AD_FORMAT = 'ad_format';
const String AD_UNIT_NAME = 'ad_unit_name';
const String SOURCE = 'source';
const String MEDIUM = 'medium';
const String CAMPAIGN = 'campaign';
const String TERM = 'term';
const String CONTENT = 'content';
const String CP1 = 'cp1';
const String ACLID = 'aclid';
const String VIRTUAL_CURRENCY_NAME = 'virtual_currency_name';
const String GROUP_ID = 'group_id';
const String LEVEL = 'level';
const String LEVEL_NAME = 'level_name';
const String SUCCESS = 'success';
const int SUCCESS_INT = 8;
const int LEVEL_INT = 6;
const String CHARACTER = 'character';
const String SCORE = 'score';
const int SCORE_INT = 9;
const String METHOD = 'method';
const String TAX = 'tax';
const double TAX_DOUBLE = 45;
const String SHIPPING = 'shipping';
const double SHIPPING_DOUBLE = 68;
const String TRANSACTION_ID = 'transaction_id';
const String AFFILIATION = 'affiliation';
const String SCREEN_CLASS = 'screen_class';
const String SCREEN_NAME = 'screen_name';
const String ITEM_LIST_ID = 'item_list_id';
const String ITEM_LIST_NAME = 'item_list_name';
const String ITEM_ID = 'item_id';
const String CREATIVE_NAME = 'creative_name';
const String CREATIVE_SLOT = 'creative_slot';
const String PROMOTION_ID = 'promotion_id';
const String PROMOTION_NAME = 'promotion_name';
const String LOCATION_ID = 'location_id';
const String SEARCH_TERM = 'search_term';
const String NUMBER_OF_NIGHTS = 'number_of_nights';
const int NUMBER_OF_NIGHTS_INT = 7;
const String NUMBER_OF_PASSENGERS = 'number_of_passengers';
const int NUMBER_OF_PASSENGERS_INT = 2;
const String NUMBER_OF_ROOMS = 'number_of_rooms';
const int NUMBER_OF_ROOMS_INT = 12;
const String ORIGIN = 'origin';
const String DESTINATION = 'destination';
const String START_DATE = 'start_date';
const String END_DATE = 'end_date';
const String TRAVEL_CLASS = 'travel_class';
const String CONTENT_TYPE = 'content_type';
const String ITEM_NAME = 'item_name';
const String ACHIEVEMENT_ID = 'achievement_id';

final ITEM = AnalyticsEventItem(
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
  parameters: {'a': 'b'},
);

void main() {
  setupFirebaseAnalyticsMocks();

  FirebaseAnalytics? analytics;

  group('$FirebaseAnalytics', () {
    setUpAll(() async {
      await Firebase.initializeApp();
      analytics = FirebaseAnalytics.instance;
    });

    setUp(() async {
      methodCallLog.clear();
    });

    tearDown(methodCallLog.clear);

    group('AnalyticsEventItem', () {
      test('Should properly toString', () {
        expect(
          ITEM.toString(),
          equals(
            'AnalyticsEventItem({a: b, affiliation: affil, currency: USD, coupon: coup, creative_name: creativeName, creative_slot: creativeSlot, discount: 2.22, index: 3, item_brand: itemBrand, item_category: itemCategory, item_category2: itemCategory2, item_category3: itemCategory3, item_category4: itemCategory4, item_category5: itemCategory5, item_id: itemId, item_list_id: itemListId, item_list_name: itemListName, item_name: itemName, item_variant: itemVariant, location_id: locationId, price: 9.99, promotion_id: promotionId, promotion_name: promotionName, quantity: 1})',
          ),
        );
      });
    });

    group('logEvent', () {
      test('reject events with reserved names', () async {
        expect(
          analytics!.logEvent(name: 'app_clear_data'),
          throwsArgumentError,
        );
      });

      test('reject events with reserved prefix', () async {
        expect(analytics!.logEvent(name: 'firebase_foo'), throwsArgumentError);
      });

      void testRequiresValueAndCurrencyTogether(
        String methodName,
        Future<void> Function() testFn,
      ) {
        test('$methodName requires value and currency together', () async {
          expect(
            testFn,
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                valueAndCurrencyMustBeTogetherError,
              ),
            ),
          );
        });
      }

      testRequiresValueAndCurrencyTogether('logAddToCart', () {
        return analytics!.logAddToCart(
          value: 123.90,
        );
      });

      testRequiresValueAndCurrencyTogether('logRemoveFromCart', () {
        return analytics!.logRemoveFromCart(
          value: 123.90,
        );
      });

      testRequiresValueAndCurrencyTogether('logAddToWishlist', () {
        return analytics!.logAddToWishlist(
          value: 123.90,
        );
      });

      testRequiresValueAndCurrencyTogether('logBeginCheckout', () {
        return analytics!.logBeginCheckout(
          value: 123.90,
        );
      });

      testRequiresValueAndCurrencyTogether('logGenerateLead', () {
        return analytics!.logGenerateLead(
          value: 123.90,
        );
      });

      testRequiresValueAndCurrencyTogether('logViewItem', () {
        return analytics!.logViewItem(
          value: 123.90,
        );
      });
    });

    group('filter out nulls', () {
      test('filters out null values', () {
        final Map<String, dynamic> original = <String, dynamic>{
          'a': 1,
          'b': null,
          'c': 'd',
        };
        final Map<String, dynamic> filtered = filterOutNulls(original);

        expect(filtered, isNot(same(original)));
        expect(original, <String, dynamic>{'a': 1, 'b': null, 'c': 'd'});
        expect(filtered, <String, dynamic>{'a': 1, 'c': 'd'});
      });
    });

    group('Non logEvent type API', () {
      test('setUserProperty rejects invalid names', () async {
        // invalid character
        expect(
          analytics!.setUserProperty(name: 'test-name', value: 'test-value'),
          throwsArgumentError,
        );
        // non-alpha first character
        expect(
          analytics!.setUserProperty(name: '0test', value: 'test-value'),
          throwsArgumentError,
        );
        // blank
        expect(
          analytics!.setUserProperty(name: '', value: 'test-value'),
          throwsArgumentError,
        );
        // reserved prefix
        expect(
          analytics!
              .setUserProperty(name: 'firebase_test', value: 'test-value'),
          throwsArgumentError,
        );
      });
    });
  });
}
