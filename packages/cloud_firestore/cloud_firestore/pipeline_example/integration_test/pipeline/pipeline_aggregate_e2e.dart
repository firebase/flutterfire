// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';

import 'pipeline_test_helpers.dart';

void runPipelineAggregateTests() {
  group('Pipeline aggregate', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'firestore-pipeline-test',
      );
    });

    test('aggregate count and sum returns expected single result', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('aggregate'))
          .aggregate(
            CountAll().as('total'),
            Expression.field('score').sum().as('total_score'),
          )
          .execute();
      expectResultCount(snapshot, 1);
      expectResultsData(snapshot, [
        {'total': 4, 'total_score': 100},
      ]);
    });

    test(
      'aggregateWithOptions with groups returns one row per group',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('aggregate'))
            .aggregateWithOptions(
              AggregateStageOptions(
                accumulators: [
                  Expression.field('score').sum().as('total_score'),
                  CountAll().as('count'),
                ],
                groups: [Expression.field('category')],
              ),
            )
            .execute();
        expectResultCount(snapshot, 2);
        final results = snapshot.result.map((r) => r.data()!).toList();
        results.sort(
          (a, b) =>
              (a['category'] as String).compareTo(b['category'] as String),
        );
        expect(results[0]['category'], 'x');
        expect(results[0]['total_score'], 30);
        expect(results[0]['count'], 2);
        expect(results[1]['category'], 'y');
        expect(results[1]['total_score'], 70);
        expect(results[1]['count'], 2);
      },
    );

    test('aggregate first and last score with sort', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('aggregate'))
          .sort(Expression.field('score').ascending())
          .aggregate(
            Expression.field('score').first().as('first_s'),
            Expression.field('score').last().as('last_s'),
          )
          .execute();
      expectResultCount(snapshot, 1);
      expectResultsData(snapshot, [
        {'first_s': 10, 'last_s': 40},
      ]);
    }, skip: !kIsWeb);

    test('aggregate array_agg and array_agg_distinct on category', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('aggregate'))
          .sort(Expression.field('score').ascending())
          .aggregate(
            Expression.field('category').arrayAgg().as('cats'),
            Expression.field('category').arrayAggDistinct().as('cats_d'),
          )
          .execute();
      expectResultCount(snapshot, 1);
      final data = snapshot.result[0].data()!;
      final cats = data['cats'] as List<dynamic>;
      expect(cats.length, 4);
      expect(cats.map((e) => e as String).toSet(), {'x', 'y'});
      final catsD = data['cats_d'] as List<dynamic>;
      expect(catsD.length, 2);
      expect(catsD.map((e) => e as String).toSet(), {'x', 'y'});
    }, skip: !kIsWeb);
  });
}
