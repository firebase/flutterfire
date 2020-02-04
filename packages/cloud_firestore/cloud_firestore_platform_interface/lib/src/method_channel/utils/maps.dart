// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/src/platform_interface/field_value.dart';

/// Casts a Map<dynamic, dynamic> to Map<String, dynamic>
Map<String, dynamic> asStringKeyedMap(Map<dynamic, dynamic> map) =>
    map?.cast<String, dynamic>();

/// Replaces items with type [FieldValueInterface] with implementation type
/// such as [FieldValuePlatform]
Map<String, dynamic> unwrapFieldValueInterfaceToPlatformType(Map<String, dynamic> data) {
  if (data == null) {
    return null;
  }
  Map<String, dynamic> output = Map.from(data);
  output.updateAll((key, value) {
    if (value is FieldValueInterface &&
        value.instance is FieldValuePlatform) {
      return value.instance;
    } else {
      return value;
    }
  });
  return output;
}
