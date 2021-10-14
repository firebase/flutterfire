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
      if (affilitation != null) 'affilitation': affilitation,
      if (coupon != null) 'coupon': coupon,
      if (creative_name != null) 'creative_name': creative_name,
      if (creative_slot != null) 'creative_slot': creative_slot,
      if (discount != null) 'discount': discount,
      if (index != null) 'index': index,
      if (item_brand != null) 'item_brand': item_brand,
      if (item_category != null) 'item_category': item_category,
      if (item_category2 != null) 'item_category2': item_category2,
      if (item_category3 != null) 'item_category3': item_category3,
      if (item_category4 != null) 'item_category4': item_category4,
      if (item_category5 != null) 'item_category5': item_category5,
      if (item_id != null) 'item_id': item_id,
      if (item_list_id != null) 'item_list_id': item_list_id,
      if (item_list_name != null) 'item_list_name': item_list_name,
      if (item_name != null) 'item_name': item_name,
      if (item_variant != null) 'item_variant': item_variant,
      if (location_id != null) 'location_id': location_id,
      if (price != null) 'price': price,
      if (promotion_id != null) 'promotion_id': promotion_id,
      if (promotion_name != null) 'promotion_name': promotion_name,
      if (quantity != null) 'quantity': quantity,
    };
  }

  @override
  String toString() {
    return '$Item($asMap)';
  }
}
