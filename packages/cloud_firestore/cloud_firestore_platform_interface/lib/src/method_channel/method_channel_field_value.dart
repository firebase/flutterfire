// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:collection/collection.dart';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter/material.dart';

/// Sentinel values that can be used when writing document fields with set() or
/// update().
enum FieldValueType {
  /// adds elements to an array but only elements not already present
  arrayUnion,

  /// removes all instances of each given element
  arrayRemove,

  /// deletes field
  delete,

  /// sets field value to server timestamp
  serverTimestamp,

  ///  increment or decrement a numeric field value using a double value
  incrementDouble,

  ///  increment or decrement a numeric field value using an integer value
  incrementInteger,
}

/// Default, `MethodChannel`-based delegate for a [FieldValuePlatform].
@immutable
class MethodChannelFieldValue {
  /// Constructor.
  MethodChannelFieldValue(this.type, this.value);

  /// The type of the field value.
  final FieldValueType type;

  /// The data associated with the [FieldValueType] above, if any.
  final dynamic value;

  @override
  bool operator ==(dynamic other) =>
      other is MethodChannelFieldValue &&
      other.type == type &&
      const DeepCollectionEquality().equals(other.value, value);

  @override
  int get hashCode => hashValues(type, value);
}
