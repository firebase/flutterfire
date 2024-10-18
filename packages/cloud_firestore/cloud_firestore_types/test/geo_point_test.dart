// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_types/cloud_firestore_types.dart';
import 'package:test/test.dart';

void main() {
  group('$GeoPoint', () {
    test('equality', () {
      expect(const GeoPoint(-80, 0), equals(const GeoPoint(-80, 0)));
      expect(const GeoPoint(0, 0), equals(const GeoPoint(0, 0)));
      expect(const GeoPoint(0, 100), equals(const GeoPoint(0, 100)));
    });

    test('throws if invalid values', () {
      expect(() => GeoPoint(-100, 0), throwsA(isA<AssertionError>));
      expect(() => GeoPoint(100, 0), throwsA(isA<AssertionError>));
      expect(() => GeoPoint(0, -190), throwsA(isA<AssertionError>));
      expect(() => GeoPoint(0, 190), throwsA(isA<AssertionError>));
    });
  });
}
