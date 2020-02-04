// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn("chrome")
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/field_value_factory_web.dart';
import 'package:cloud_firestore_web/src/field_value_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("$FieldValueFactoryWeb()", () {
    final factory = FieldValueFactoryWeb();

    test("arrayRemove", () {
      final actual = factory.arrayRemove([]);
      expect(actual, isInstanceOf<FieldValueWeb>());
      expect(actual.type, equals(FieldValueType.arrayRemove));
    });

    test("arrayUnion", () {
      final actual = factory.arrayUnion([]);
      expect(actual, isInstanceOf<FieldValueWeb>());
      expect(actual.type, equals(FieldValueType.arrayUnion));
    });

    test("delete", () {
      final actual = factory.delete();
      expect(actual, isInstanceOf<FieldValueWeb>());
      expect(actual.type, equals(FieldValueType.delete));
    });

    test("increment", () {
      final actualInt = factory.increment(1);
      expect(actualInt, isInstanceOf<FieldValueWeb>());
      expect(actualInt.type, equals(FieldValueType.incrementInteger));

      final actualDouble = factory.increment(1.25);
      expect(actualDouble, isInstanceOf<FieldValueWeb>());
      expect(actualDouble.type, equals(FieldValueType.incrementDouble));
    });

    test("serverTimestamp", () {
      final actual = factory.serverTimestamp();
      expect(actual, isInstanceOf<FieldValueWeb>());
      expect(actual.type, equals(FieldValueType.serverTimestamp));
    });
  });
}
