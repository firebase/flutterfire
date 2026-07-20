// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DistanceMeasure', () {
    test('cosine has expected name', () {
      expect(DistanceMeasure.cosine.name, 'cosine');
    });

    test('euclidean has expected name', () {
      expect(DistanceMeasure.euclidean.name, 'euclidean');
    });

    test('dotProduct has expected name', () {
      expect(DistanceMeasure.dotProduct.name, 'dotProduct');
    });

    test('has exactly three values', () {
      expect(DistanceMeasure.values, hasLength(3));
      expect(DistanceMeasure.values, contains(DistanceMeasure.cosine));
      expect(DistanceMeasure.values, contains(DistanceMeasure.euclidean));
      expect(DistanceMeasure.values, contains(DistanceMeasure.dotProduct));
    });
  });
}
