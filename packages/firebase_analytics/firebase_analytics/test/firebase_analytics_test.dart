// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
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

AnalyticsEventItem ITEM = AnalyticsEventItem(
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

      test('custom event with correct parameters', () async {
        await analytics!.logEvent(
          name: 'test-event',
          parameters: {'a': 'b'},
        );
        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: {
                'eventName': 'test-event',
                'parameters': {'a': 'b'},
              },
            )
          ],
        );
      });

      test('logAddPaymentInfo', () async {
        await analytics!.logAddPaymentInfo(
          coupon: COUPON,
          currency: CURRENCY,
          value: VALUE_DOUBLE,
          items: [ITEM],
          paymentType: PAYMENT_TYPE,
        );
        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'add_payment_info',
                'parameters': {
                  COUPON: COUPON,
                  CURRENCY: CURRENCY,
                  PAYMENT_TYPE: PAYMENT_TYPE,
                  VALUE: VALUE_DOUBLE,
                  ITEMS: [ITEM.asMap()],
                },
              },
            )
          ],
        );
      });

      test('logAddShippingInfo', () async {
        await analytics!.logAddShippingInfo(
          coupon: COUPON,
          currency: CURRENCY,
          shippingTier: SHIPPING_TIER,
          value: VALUE_DOUBLE,
          items: [ITEM],
        );
        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'add_shipping_info',
                'parameters': {
                  COUPON: COUPON,
                  CURRENCY: CURRENCY,
                  SHIPPING_TIER: SHIPPING_TIER,
                  VALUE: VALUE_DOUBLE,
                  ITEMS: [ITEM.asMap()],
                },
              },
            )
          ],
        );
      });

      test('logAddToCart', () async {
        await analytics!.logAddToCart(
          currency: CURRENCY,
          value: VALUE_DOUBLE,
          items: [ITEM],
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'add_to_cart',
                'parameters': {
                  CURRENCY: CURRENCY,
                  VALUE: VALUE_DOUBLE,
                  ITEMS: [ITEM.asMap()],
                },
              },
            )
          ],
        );
      });

      test('logAddToWishlist', () async {
        await analytics!.logAddToWishlist(
          currency: CURRENCY,
          value: VALUE_DOUBLE,
          items: [ITEM],
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'add_to_wishlist',
                'parameters': {
                  CURRENCY: CURRENCY,
                  VALUE: VALUE_DOUBLE,
                  ITEMS: [ITEM.asMap()],
                },
              },
            )
          ],
        );
      });

      test('logAdImpression', () async {
        await analytics!.logAdImpression(
          adPlatform: AD_PLATFORM,
          adSource: AD_SOURCE,
          adFormat: AD_FORMAT,
          adUnitName: AD_UNIT_NAME,
          currency: CURRENCY,
          value: VALUE_DOUBLE,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'ad_impression',
                'parameters': {
                  CURRENCY: CURRENCY,
                  VALUE: VALUE_DOUBLE,
                  AD_PLATFORM: AD_PLATFORM,
                  AD_SOURCE: AD_SOURCE,
                  AD_FORMAT: AD_FORMAT,
                  AD_UNIT_NAME: AD_UNIT_NAME,
                },
              },
            )
          ],
        );
      });

      test('logAppOpen', () async {
        await analytics!.logAppOpen();

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'app_open',
                'parameters': null
              },
            )
          ],
        );
      });

      test('logBeginCheckout', () async {
        await analytics!.logBeginCheckout(
          value: VALUE_DOUBLE,
          currency: CURRENCY,
          items: [ITEM],
          coupon: COUPON,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'begin_checkout',
                'parameters': {
                  CURRENCY: CURRENCY,
                  VALUE: VALUE_DOUBLE,
                  ITEMS: [ITEM.asMap()],
                  COUPON: COUPON,
                },
              },
            )
          ],
        );
      });

      test('logCampaignDetails', () async {
        await analytics!.logCampaignDetails(
          source: SOURCE,
          medium: MEDIUM,
          campaign: CAMPAIGN,
          term: TERM,
          content: CONTENT,
          aclid: ACLID,
          cp1: CP1,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'campaign_details',
                'parameters': {
                  SOURCE: SOURCE,
                  MEDIUM: MEDIUM,
                  CAMPAIGN: CAMPAIGN,
                  TERM: TERM,
                  CONTENT: CONTENT,
                  ACLID: ACLID,
                  CP1: CP1,
                },
              },
            )
          ],
        );
      });

      test('logEarnVirtualCurrency', () async {
        await analytics!.logEarnVirtualCurrency(
          virtualCurrencyName: VIRTUAL_CURRENCY_NAME,
          value: VALUE_DOUBLE,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'earn_virtual_currency',
                'parameters': {
                  VALUE: VALUE_DOUBLE,
                  VIRTUAL_CURRENCY_NAME: VIRTUAL_CURRENCY_NAME,
                },
              },
            )
          ],
        );
      });

      test('logGenerateLead', () async {
        await analytics!.logGenerateLead(
          value: VALUE_DOUBLE,
          currency: CURRENCY,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'generate_lead',
                'parameters': {
                  VALUE: VALUE_DOUBLE,
                  CURRENCY: CURRENCY,
                },
              },
            )
          ],
        );
      });

      test('logJoinGroup', () async {
        await analytics!.logJoinGroup(
          groupId: GROUP_ID,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'join_group',
                'parameters': {
                  GROUP_ID: GROUP_ID,
                },
              },
            )
          ],
        );
      });

      test('logLevelUp', () async {
        await analytics!.logLevelUp(level: LEVEL_INT, character: CHARACTER);

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'level_up',
                'parameters': {LEVEL: LEVEL_INT, CHARACTER: CHARACTER},
              },
            )
          ],
        );
      });

      test('logLevelStart', () async {
        await analytics!.logLevelStart(
          levelName: LEVEL_NAME,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'level_start',
                'parameters': {
                  LEVEL_NAME: LEVEL_NAME,
                },
              },
            )
          ],
        );
      });

      test('logLevelEnd', () async {
        await analytics!
            .logLevelEnd(levelName: LEVEL_NAME, success: SUCCESS_INT);

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'level_end',
                'parameters': {
                  LEVEL_NAME: LEVEL_NAME,
                  SUCCESS: SUCCESS_INT,
                },
              },
            )
          ],
        );
      });

      test('logLogin', () async {
        await analytics!.logLogin(loginMethod: METHOD);

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'login',
                'parameters': {
                  METHOD: METHOD,
                },
              },
            )
          ],
        );
      });

      test('logPostScore', () async {
        await analytics!.logPostScore(
          score: SCORE_INT,
          level: LEVEL_INT,
          character: CHARACTER,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'post_score',
                'parameters': {
                  LEVEL: LEVEL_INT,
                  SCORE: SCORE_INT,
                  CHARACTER: CHARACTER,
                },
              },
            )
          ],
        );
      });

      test('logPurchase', () async {
        await analytics!.logPurchase(
          currency: CURRENCY,
          coupon: COUPON,
          value: VALUE_DOUBLE,
          items: [ITEM],
          tax: TAX_DOUBLE,
          shipping: SHIPPING_DOUBLE,
          transactionId: TRANSACTION_ID,
          affiliation: AFFILIATION,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'purchase',
                'parameters': {
                  CURRENCY: CURRENCY,
                  COUPON: COUPON,
                  VALUE: VALUE_DOUBLE,
                  ITEMS: [ITEM.asMap()],
                  TAX: TAX_DOUBLE,
                  SHIPPING: SHIPPING_DOUBLE,
                  TRANSACTION_ID: TRANSACTION_ID,
                  AFFILIATION: AFFILIATION,
                },
              },
            )
          ],
        );
      });

      test('logRemoveFromCart', () async {
        await analytics!.logRemoveFromCart(
          currency: CURRENCY,
          value: VALUE_DOUBLE,
          items: [ITEM],
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'remove_from_cart',
                'parameters': {
                  CURRENCY: CURRENCY,
                  VALUE: VALUE_DOUBLE,
                  ITEMS: [ITEM.asMap()],
                },
              },
            )
          ],
        );
      });

      test('logScreenView', () async {
        await analytics!.logScreenView(
          screenClass: SCREEN_CLASS,
          screenName: SCREEN_NAME,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'screen_view',
                'parameters': {
                  SCREEN_CLASS: SCREEN_CLASS,
                  SCREEN_NAME: SCREEN_NAME,
                },
              },
            )
          ],
        );
      });

      test('logSelectItem', () async {
        await analytics!.logSelectItem(
          items: [ITEM],
          itemListId: ITEM_LIST_ID,
          itemListName: ITEM_LIST_NAME,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'select_item',
                'parameters': {
                  ITEM_LIST_ID: ITEM_LIST_ID,
                  ITEM_LIST_NAME: ITEM_LIST_NAME,
                  ITEMS: [ITEM.asMap()],
                },
              },
            )
          ],
        );
      });

      test('logSelectPromotion', () async {
        await analytics!.logSelectPromotion(
          items: [ITEM],
          creativeName: CREATIVE_NAME,
          creativeSlot: CREATIVE_SLOT,
          locationId: LOCATION_ID,
          promotionId: PROMOTION_ID,
          promotionName: PROMOTION_NAME,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'select_promotion',
                'parameters': {
                  CREATIVE_NAME: CREATIVE_NAME,
                  CREATIVE_SLOT: CREATIVE_SLOT,
                  LOCATION_ID: LOCATION_ID,
                  PROMOTION_ID: PROMOTION_ID,
                  PROMOTION_NAME: PROMOTION_NAME,
                  ITEMS: [ITEM.asMap()],
                },
              },
            )
          ],
        );
      });

      test('logViewCart', () async {
        await analytics!.logViewCart(
          currency: CURRENCY,
          value: VALUE_DOUBLE,
          items: [ITEM],
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'view_cart',
                'parameters': {
                  CURRENCY: CURRENCY,
                  VALUE: VALUE_DOUBLE,
                  ITEMS: [ITEM.asMap()],
                },
              },
            )
          ],
        );
      });

      test('logSearch', () async {
        await analytics!.logSearch(
          searchTerm: SEARCH_TERM,
          numberOfNights: NUMBER_OF_NIGHTS_INT,
          numberOfPassengers: NUMBER_OF_PASSENGERS_INT,
          numberOfRooms: NUMBER_OF_ROOMS_INT,
          origin: ORIGIN,
          destination: DESTINATION,
          startDate: START_DATE,
          endDate: END_DATE,
          travelClass: TRAVEL_CLASS,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'search',
                'parameters': {
                  SEARCH_TERM: SEARCH_TERM,
                  NUMBER_OF_NIGHTS: NUMBER_OF_NIGHTS_INT,
                  NUMBER_OF_PASSENGERS: NUMBER_OF_PASSENGERS_INT,
                  NUMBER_OF_ROOMS: NUMBER_OF_ROOMS_INT,
                  ORIGIN: ORIGIN,
                  DESTINATION: DESTINATION,
                  START_DATE: START_DATE,
                  END_DATE: END_DATE,
                  TRAVEL_CLASS: TRAVEL_CLASS,
                },
              },
            )
          ],
        );
      });

      test('logSelectContent', () async {
        await analytics!.logSelectContent(
          contentType: CONTENT_TYPE,
          itemId: ITEM_ID,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'select_content',
                'parameters': {
                  CONTENT_TYPE: CONTENT_TYPE,
                  ITEM_ID: ITEM_ID,
                },
              },
            )
          ],
        );
      });

      test('logShare', () async {
        await analytics!.logShare(
          contentType: CONTENT_TYPE,
          itemId: ITEM_ID,
          method: METHOD,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'share',
                'parameters': {
                  CONTENT_TYPE: CONTENT_TYPE,
                  ITEM_ID: ITEM_ID,
                  METHOD: METHOD,
                },
              },
            )
          ],
        );
      });

      test('logSignUp', () async {
        await analytics!.logSignUp(signUpMethod: METHOD);

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'sign_up',
                'parameters': {
                  METHOD: METHOD,
                },
              },
            )
          ],
        );
      });

      test('logSpendVirtualCurrency', () async {
        await analytics!.logSpendVirtualCurrency(
          itemName: ITEM_NAME,
          virtualCurrencyName: VIRTUAL_CURRENCY_NAME,
          value: VALUE_DOUBLE,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'spend_virtual_currency',
                'parameters': {
                  ITEM_NAME: ITEM_NAME,
                  VIRTUAL_CURRENCY_NAME: VIRTUAL_CURRENCY_NAME,
                  VALUE: VALUE_DOUBLE,
                },
              },
            )
          ],
        );
      });

      test('logTutorialBegin', () async {
        await analytics!.logTutorialBegin();

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'tutorial_begin',
                'parameters': null,
              },
            )
          ],
        );
      });

      test('logTutorialComplete', () async {
        await analytics!.logTutorialComplete();

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'tutorial_complete',
                'parameters': null
              },
            )
          ],
        );
      });

      test('logUnlockAchievement', () async {
        await analytics!.logUnlockAchievement(id: ACHIEVEMENT_ID);

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'unlock_achievement',
                'parameters': {ACHIEVEMENT_ID: ACHIEVEMENT_ID},
              },
            )
          ],
        );
      });

      test('logViewItem', () async {
        await analytics!.logViewItem(
          currency: CURRENCY,
          value: VALUE_DOUBLE,
          items: [ITEM],
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'view_item',
                'parameters': {
                  CURRENCY: CURRENCY,
                  VALUE: VALUE_DOUBLE,
                  ITEMS: [ITEM.asMap()]
                },
              },
            )
          ],
        );
      });

      test('logViewItemList', () async {
        await analytics!.logViewItemList(
          itemListId: ITEM_LIST_ID,
          itemListName: ITEM_LIST_NAME,
          items: [ITEM],
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'view_item_list',
                'parameters': {
                  ITEM_LIST_ID: ITEM_LIST_ID,
                  ITEM_LIST_NAME: ITEM_LIST_NAME,
                  ITEMS: [ITEM.asMap()],
                },
              },
            )
          ],
        );
      });

      test('logViewPromotion', () async {
        await analytics!.logViewPromotion(
          creativeName: CREATIVE_NAME,
          creativeSlot: CREATIVE_SLOT,
          items: [ITEM],
          locationId: LOCATION_ID,
          promotionName: PROMOTION_NAME,
          promotionId: PROMOTION_ID,
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'view_promotion',
                'parameters': {
                  CREATIVE_NAME: CREATIVE_NAME,
                  CREATIVE_SLOT: CREATIVE_SLOT,
                  LOCATION_ID: LOCATION_ID,
                  PROMOTION_NAME: PROMOTION_NAME,
                  PROMOTION_ID: PROMOTION_ID,
                  ITEMS: [ITEM.asMap()],
                },
              },
            )
          ],
        );
      });

      test('logViewSearchResults', () async {
        await analytics!.logViewSearchResults(searchTerm: SEARCH_TERM);

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'view_search_results',
                'parameters': {
                  SEARCH_TERM: SEARCH_TERM,
                },
              },
            )
          ],
        );
      });

      test('logRefund', () async {
        await analytics!.logRefund(
          currency: CURRENCY,
          coupon: COUPON,
          value: VALUE_DOUBLE,
          tax: TAX_DOUBLE,
          transactionId: TRANSACTION_ID,
          shipping: SHIPPING_DOUBLE,
          affiliation: AFFILIATION,
          items: [ITEM],
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, dynamic>{
                'eventName': 'refund',
                'parameters': {
                  CURRENCY: CURRENCY,
                  COUPON: COUPON,
                  VALUE: VALUE_DOUBLE,
                  TAX: TAX_DOUBLE,
                  TRANSACTION_ID: TRANSACTION_ID,
                  SHIPPING: SHIPPING_DOUBLE,
                  AFFILIATION: AFFILIATION,
                  ITEMS: [ITEM.asMap()],
                },
              },
            )
          ],
        );
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
          'c': 'd'
        };
        final Map<String, dynamic> filtered = filterOutNulls(original);

        expect(filtered, isNot(same(original)));
        expect(original, <String, dynamic>{'a': 1, 'b': null, 'c': 'd'});
        expect(filtered, <String, dynamic>{'a': 1, 'c': 'd'});
      });
    });

    group('Non logEvent type API', () {
      test('setUserId', () async {
        await analytics!.setUserId(id: 'test-user-id');
        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#setUserId',
              arguments: {'userId': 'test-user-id'},
            )
          ],
        );
      });

      test('setCurrentScreen', () async {
        await analytics!.setCurrentScreen(
          screenName: 'test-screen-name',
          screenClassOverride: 'test-class-override',
        );
        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#logEvent',
              arguments: <String, Object>{
                'eventName': 'screen_view',
                'parameters': {
                  'screen_name': 'test-screen-name',
                  'screen_class': 'test-class-override',
                },
              },
            )
          ],
        );
      });

      test('setUserProperty', () async {
        await analytics!
            .setUserProperty(name: 'test_name', value: 'test-value');
        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#setUserProperty',
              arguments: <String, String>{
                'name': 'test_name',
                'value': 'test-value',
              },
            )
          ],
        );
      });

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

      test('setAnalyticsCollectionEnabled', () async {
        await analytics!.setAnalyticsCollectionEnabled(false);
        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#setAnalyticsCollectionEnabled',
              arguments: {'enabled': false},
            )
          ],
        );
      });

      test(
        'setSessionTimeoutDuration',
        () async {
          await analytics!
              .setSessionTimeoutDuration(const Duration(milliseconds: 234));
          expect(
            methodCallLog,
            <Matcher>[
              isMethodCall(
                'Analytics#setSessionTimeoutDuration',
                arguments: 234,
              )
            ],
          );
        },
        testOn: 'android',
      );

      test('resetAnalyticsData', () async {
        await analytics!.resetAnalyticsData();
        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#resetAnalyticsData',
              arguments: null,
            )
          ],
        );
      });

      test('appInstanceId', () async {
        var _ = await analytics!.appInstanceId;
        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'Analytics#getAppInstanceId',
              arguments: null,
            )
          ],
        );
      });
    });
  });
}
