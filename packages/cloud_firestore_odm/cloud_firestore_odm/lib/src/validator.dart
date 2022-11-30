// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A class used to assert that a value respects some rules.
///
/// As opposed to `assert`, this class works in release mode too.
abstract class Validator {
  /// A class used to assert that a value respects some rules.
  ///
  /// As opposed to `assert`, this class works in release mode too.
  const Validator();

  void validate(Object? value, String propertyName);
}

class Min extends Validator {
  const Min(this.minValue);

  final num minValue;

  @override
  void validate(Object? value, String propertyName) {
    if (value is num && value < minValue) {
      throw ArgumentError.value(value, propertyName);
    }
  }
}

class Max extends Validator {
  const Max(this.maxValue);

  final num maxValue;

  @override
  void validate(Object? value, String propertyName) {
    if (value is num && value > maxValue) {
      throw ArgumentError.value(value, propertyName);
    }
  }
}
