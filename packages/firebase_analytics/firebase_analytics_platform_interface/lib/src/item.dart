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
    this.brand,
    this.category,
    this.category2,
    this.category3,
    this.category4,
    this.category5,
    this.id,
    this.listName,
    this.listId,
    this.name,
    this.variant,
  });

  /// Item brand.
  final String? brand;

  /// Item category
  final String? category;

  /// Item category
  final String? category2;

  /// Item category
  final String? category3;

  /// Item category
  final String? category4;

  /// Item category
  final String? category5;

  /// The ID of the list in which the item was presented to the user
  final String? listId;

  /// The name of the list in which the item was presented to the user
  final String? listName;

  /// Item ID
  final String? id;

  /// Item name
  final String? name;

  /// Item variant
  final String? variant;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'brand': brand,
      'category': category,
      'category2': category2,
      'category3': category3,
      'category4': category4,
      'category5': category5,
      'listId': listId,
      'listName': listName,
      'id': id,
      'name': name,
      'variant': variant,
    };
  }

  @override
  String toString() {
    return '$Item($asMap)';
  }
}
