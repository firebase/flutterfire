// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pipeline_test_helpers.dart';

void runPipelineUnnestUnionTests() {
  group('Pipeline unnest and union', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'firestore-pipeline-test',
      );
    });

    test('unnest produces one row per array element with tag field', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('unnest'))
          .unnest(Expression.field('tags').as('tag'))
          .sort(Expression.field('tag').ascending())
          .limit(10)
          .execute();
      expectResultCount(snapshot, 5);
      final tags =
          snapshot.result.map((r) => r.data()!['tag'] as String).toList();
      expect(tags..sort(), [
        'dart',
        'dart',
        'firestore',
        'firestore',
        'flutter',
      ]);
    });

    test(
      'union concatenates both pipelines with deterministic total count',
      () async {
        final other = firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('union-b'))
            .limit(5);
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('union-a'))
            .limit(5)
            .union(other)
            .execute();
        expectResultCount(snapshot, 6);
      },
    );
  });
}
