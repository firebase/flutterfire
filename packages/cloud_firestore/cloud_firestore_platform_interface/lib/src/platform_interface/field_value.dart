// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// Sentinel values that can be used when writing document fields with set() or
/// update().

abstract class FieldValueInterface {

  FieldValueInterface get instance;

  FieldValueType get type;

  dynamic get value;
}

class FieldValue implements FieldValueInterface {
  static Map<String, dynamic> _serverDelegates(Map<String, dynamic> data) {
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) {
      if(value is FieldValueInterface && value.instance is FieldValue) {
        return value.instance;
      } else{
        return value;
      }
    });
    return output;
  }
  FieldValue._(this.type, this.value);

  @override
  FieldValueInterface get instance => this;

  final FieldValueType type;

  final dynamic value;
}
