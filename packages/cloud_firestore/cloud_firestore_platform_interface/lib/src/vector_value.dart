// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Represents a vector value by an array of doubles.
@immutable
class VectorValue {
  /// Create [VectorValue] instance.
  const VectorValue(this._value);

  final List<double> _value; // ignore: public_member_api_docs

  @override
  bool operator ==(Object other) =>
      other is VectorValue && listEquals(other._value, _value);

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'VectorValue(value: $_value)';

  /// Converts a [VectorValue] to a [List] of [double].
  List<double> toArray() => _value;
}
