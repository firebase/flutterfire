// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'pipeline_test_helpers.dart';

void runPipelineFilterSortTests() {
  group('Pipeline where, sort, limit, offset, distinct', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'firestore-pipeline-test');
    });

    test('where + limit returns expected count and data', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('filter-sort'))
          .where(Expression.field('active').equalValue(true))
          .sort(Expression.field('score').ascending())
          .limit(5)
          .execute();
      expectResultCount(snapshot, 4);
      expectResultsData(snapshot, [
        {'active': true, 'score': 10, 'category': 'a'},
        {'active': true, 'score': 15, 'category': 'b'},
        {'active': true, 'score': 20, 'category': 'b'},
        {'active': true, 'score': 30, 'category': 'c'},
      ]);
    });

    test('sort + limit returns expected order', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('filter-sort'))
          .sort(Expression.field('score').descending())
          .limit(3)
          .execute();
      expectResultCount(snapshot, 3);
      expectResultsData(snapshot, [
        {'score': 30, 'category': 'c'},
        {'score': 20, 'category': 'b'},
        {'score': 15, 'category': 'b'},
      ]);
    });

    test('offset + limit returns expected slice', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('filter-sort'))
          .sort(Expression.field('score').ascending())
          .offset(2)
          .limit(5)
          .execute();
      expectResultCount(snapshot, 3);
      expectResultsData(snapshot, [
        {'score': 15, 'category': 'b'},
        {'score': 20, 'category': 'b'},
        {'score': 30, 'category': 'c'},
      ]);
    });

    test('distinct returns unique category values', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('filter-sort'))
          .distinct(Expression.field('category').as('category'))
          .sort(Expression.field('category').ascending())
          .limit(10)
          .execute();
      expectResultCount(snapshot, 3);
      final categories = snapshot.result.map((r) => r.data()!['category']).toList();
      expect(categories..sort(), ['a', 'b', 'c']);
    });
  });
}
