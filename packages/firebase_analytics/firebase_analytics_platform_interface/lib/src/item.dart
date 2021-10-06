// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Interface that defines the required attributes of an analytics Item.
/// https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Param
class Item {
  // ignore: public_member_api_docs
  @protected
  Item({
    this.affilitation,
    this.coupon,
    this.creative_name,
    this.creative_slot,
    this.discount,
    this.index,
    this.item_brand,
    this.item_category,
    this.item_category2,
    this.item_category3,
    this.item_category4,
    this.item_category5,
    this.item_id,
    this.item_list_id,
    this.item_list_name,
    this.item_name,
    this.item_variant,
    this.location_id,
    this.price,
    this.promotion_id,
    this.promotion_name,
    this.quantity,
  });

  /// Affiliation.
  final String? affilitation;

  final String? coupon;

  final String? creative_name;

  final String? creative_slot;

  final String? discount;

  final int? index;

  final String? item_brand;

  final String? item_category;

  final String? item_category2;

  final String? item_category3;

  final String? item_category4;

  final String? item_category5;

  final String? item_id;

  final String? item_list_id;

  final String? item_list_name;

  final String? item_name;

  final String? item_variant;

  final String? location_id;

  final String? price;

  final String? promotion_id;

  final String? promotion_name;

  final String? quantity;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'affilitation': affilitation,
      'coupon': coupon,
      'creative_name': creative_name,
      'creative_slot': creative_slot,
      'discount': discount,
      'index': index,
      'item_brand': item_brand,
      'item_category': item_category,
      'item_category2': item_category2,
      'item_category3': item_category3,
      'item_category4': item_category4,
      'item_category5': item_category5,
      'item_id': item_id,
      'item_list_id': item_list_id,
      'item_list_name': item_list_name,
      'item_name': item_name,
      'item_variant': item_variant,
      'location_id': location_id,
      'price': price,
      'promotion_id': promotion_id,
      'promotion_name': promotion_name,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return '$Item($asMap)';
  }
}
