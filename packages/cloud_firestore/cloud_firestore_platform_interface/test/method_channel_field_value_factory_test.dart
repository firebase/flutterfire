// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_field_value_factory.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_field_value.dart';

void main() {
  group("$MethodChannelFieldValueFactory()", () {
    final MethodChannelFieldValueFactory factory =
        MethodChannelFieldValueFactory();
    test("arrayRemove", () {
      final MethodChannelFieldValue actual = factory.arrayRemove([1]);
      expect(actual.type, equals(FieldValueType.arrayRemove));
    });
    test("arrayUnion", () {
      final MethodChannelFieldValue actual = factory.arrayUnion([1]);
      expect(actual.type, equals(FieldValueType.arrayUnion));
    });
    test("delete", () {
      final MethodChannelFieldValue actual = factory.delete();
      expect(actual.type, equals(FieldValueType.delete));
    });
    test("increment", () {
      final MethodChannelFieldValue actualInt = factory.increment(1);
      expect(actualInt.type, equals(FieldValueType.incrementInteger));
      final MethodChannelFieldValue actualDouble = factory.increment(1.0);
      expect(actualDouble.type, equals(FieldValueType.incrementDouble));
    });
    test("serverTimestamp", () {
      final MethodChannelFieldValue actual = factory.serverTimestamp();
      expect(actual.type, equals(FieldValueType.serverTimestamp));
    });
  });
}
