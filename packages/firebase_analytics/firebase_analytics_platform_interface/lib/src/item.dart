// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Interface that defines the required attributes of an analytics Item.
/// https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Param
class Item {
  Item({
    this.affiliation,
    this.coupon,
    this.creativeName,
    this.creativeSlot,
    this.discount,
    this.index,
    this.itemBrand,
    this.itemCategory,
    this.itemCategory2,
    this.itemCategory3,
    this.itemCategory4,
    this.itemCategory5,
    this.itemId,
    this.itemListId,
    this.itemListName,
    this.itemName,
    this.itemVariant,
    this.locationId,
    this.price,
    this.promotionId,
    this.promotionName,
    this.quantity,
  });

  /// Affiliation.
  final String? affiliation;

  final String? coupon;

  final String? creativeName;

  final String? creativeSlot;

  final String? discount;

  final int? index;

  final String? itemBrand;

  final String? itemCategory;

  final String? itemCategory2;

  final String? itemCategory3;

  final String? itemCategory4;

  final String? itemCategory5;

  final String? itemId;

  final String? itemListId;

  final String? itemListName;

  final String? itemName;

  final String? itemVariant;

  final String? locationId;

  final String? price;

  final String? promotionId;

  final String? promotionName;

  final String? quantity;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      if (affiliation != null) 'affiliation': affiliation,
      if (coupon != null) 'coupon': coupon,
      if (creativeName != null) 'creative_name': creativeName,
      if (creativeSlot != null) 'creative_slot': creativeSlot,
      if (discount != null) 'discount': discount,
      if (index != null) 'index': index,
      if (itemBrand != null) 'item_brand': itemBrand,
      if (itemCategory != null) 'item_category': itemCategory,
      if (itemCategory2 != null) 'item_category2': itemCategory2,
      if (itemCategory3 != null) 'item_category3': itemCategory3,
      if (itemCategory4 != null) 'item_category4': itemCategory4,
      if (itemCategory5 != null) 'item_category5': itemCategory5,
      if (itemId != null) 'item_id': itemId,
      if (itemListId != null) 'item_list_id': itemListId,
      if (itemListName != null) 'item_list_name': itemListName,
      if (itemName != null) 'item_name': itemName,
      if (itemVariant != null) 'item_variant': itemVariant,
      if (locationId != null) 'location_id': locationId,
      if (price != null) 'price': price,
      if (promotionId != null) 'promotion_id': promotionId,
      if (promotionName != null) 'promotion_name': promotionName,
      if (quantity != null) 'quantity': quantity,
    };
  }

  @override
  String toString() {
    return '$Item($asMap)';
  }
}
