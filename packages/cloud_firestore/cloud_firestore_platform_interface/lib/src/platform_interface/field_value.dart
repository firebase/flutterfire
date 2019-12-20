// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// A class to define an interface that's required
/// for building platform-specific implementation
abstract class FieldValueInterface {
  /// Implementation instance
  FieldValueInterface get instance;

  /// type of the FieldValue
  FieldValueType get type;

  /// value of the FieldValue
  dynamic get value;
}

/// Mobile platform implementation for [FieldValueInterface]
class FieldValue implements FieldValueInterface {
  /// Replaces items with type [FieldValueInterface] with implementation type
  /// such as [FieldValue]
  @visibleForTesting
  static Map<String, dynamic> serverDelegates(Map<String, dynamic> data) {
    if(data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) {
      if (value is FieldValueInterface && value.instance is FieldValue) {
        return value.instance;
      } else {
        return value;
      }
    });
    return output;
  }

  FieldValue._(this.type, this.value);

  @override
  FieldValueInterface get instance => this;

  @override
  final FieldValueType type;

  @override
  final dynamic value;
}
