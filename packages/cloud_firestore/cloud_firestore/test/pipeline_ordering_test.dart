// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupCloudFirestoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('OrderDirection', () {
    test('asc has expected name', () {
      expect(OrderDirection.asc.name, 'asc');
    });

    test('desc has expected name', () {
      expect(OrderDirection.desc.name, 'desc');
    });
  });

  group('Ordering', () {
    test('toMap() serializes ascending order', () {
      final ordering = Ordering(Field('name'), OrderDirection.asc);
      expect(ordering.toMap(), {
        'expression': {'name': 'field', 'args': {'field': 'name'}},
        'order_direction': 'asc',
      });
    });

    test('toMap() serializes descending order', () {
      final ordering = Ordering(Field('score'), OrderDirection.desc);
      expect(ordering.toMap(), {
        'expression': {'name': 'field', 'args': {'field': 'score'}},
        'order_direction': 'desc',
      });
    });

    test('toMap() includes expression toMap() result', () {
      final ordering = Ordering(Constant(42), OrderDirection.asc);
      expect(ordering.toMap(), {
        'expression': {'name': 'constant', 'args': {'value': 42}},
        'order_direction': 'asc',
      });
    });
  });
}
