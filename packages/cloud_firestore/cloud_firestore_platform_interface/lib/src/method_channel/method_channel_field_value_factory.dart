// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/services.dart';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'method_channel_field_value.dart';

/// An implementation of [FieldValueFactoryPlatform] that is suitable to be used
/// on mobile where communication relies on [MethodChannel]
class MethodChannelFieldValueFactory extends FieldValueFactoryPlatform {
  @override
  MethodChannelFieldValue arrayRemove(List elements) =>
      MethodChannelFieldValue(FieldValueType.arrayRemove, elements);

  @override
  MethodChannelFieldValue arrayUnion(List elements) =>
      MethodChannelFieldValue(FieldValueType.arrayUnion, elements);

  @override
  MethodChannelFieldValue delete() =>
      MethodChannelFieldValue(FieldValueType.delete, null);

  @override
  MethodChannelFieldValue increment(num value) => _fromNum(
        value,
        FieldValueType.incrementDouble,
        FieldValueType.incrementInteger,
      );

  @override
  MethodChannelFieldValue minimum(num value) => _fromNum(
        value,
        FieldValueType.minimumDouble,
        FieldValueType.minimumInteger,
      );

  @override
  MethodChannelFieldValue maximum(num value) => _fromNum(
        value,
        FieldValueType.maximumDouble,
        FieldValueType.maximumInteger,
      );

  MethodChannelFieldValue _fromNum(
    num value,
    FieldValueType doubleType,
    FieldValueType integerType,
  ) {
    // It is a compile-time error for any type other than `int` or `double` to
    // attempt to extend or implement `num`.
    assert(value is int || value is double);
    if (value is double) {
      return MethodChannelFieldValue(doubleType, value);
      // ignore: avoid_double_and_int_checks
    } else if (value is int) {
      return MethodChannelFieldValue(integerType, value);
    }

    throw StateError(
        'MethodChannelFieldValue() numeric factories expect a "num" value');
  }

  @override
  MethodChannelFieldValue serverTimestamp() =>
      MethodChannelFieldValue(FieldValueType.serverTimestamp, null);
}
