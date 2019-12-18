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
  FieldValue._(this.type, this.value);

  @override
  FieldValueInterface get instance => this;

  final FieldValueType type;

  final dynamic value;
}
