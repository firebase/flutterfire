// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupCloudFirestoreMocks();

  late FirebaseFirestore firestore;

  setUpAll(() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
  });

  group('PipelineResult', () {
    test('stores and returns data via data()', () {
      final data = <String, dynamic>{'name': 'Alice', 'score': 100};
      final result = PipelineResult(data: data);
      expect(result.data(), data);
    });

    test('data() returns null when data is null', () {
      final result = PipelineResult();
      expect(result.data(), isNull);
    });

    test('stores document reference when provided', () {
      final docRef = firestore.collection('users').doc('123');
      final result = PipelineResult(document: docRef);
      expect(result.document, docRef);
    });

    test('document is null for aggregate-only result', () {
      final result = PipelineResult(
        data: <String, dynamic>{'count': 42},
      );
      expect(result.document, isNull);
    });

    test('stores createTime and updateTime', () {
      final create = DateTime(2026);
      final update = DateTime(2026, 1, 2);
      final result = PipelineResult(
        createTime: create,
        updateTime: update,
      );
      expect(result.createTime, create);
      expect(result.updateTime, update);
    });

    test('stores empty data map', () {
      final result = PipelineResult(data: <String, dynamic>{});
      expect(result.data(), isEmpty);
      expect(result.data(), isNotNull);
    });

    test('stores all fields together', () {
      final docRef = firestore.collection('orders').doc('o1');
      final dateTime1 = DateTime(2026, 2);
      final dateTime2 = DateTime(2026, 2, 2);
      final data = <String, dynamic>{'total': 99.99};
      final result = PipelineResult(
        document: docRef,
        createTime: dateTime1,
        updateTime: dateTime2,
        data: data,
      );
      expect(result.document, docRef);
      expect(result.createTime, dateTime1);
      expect(result.updateTime, dateTime2);
      expect(result.data(), data);
    });
  });
}
