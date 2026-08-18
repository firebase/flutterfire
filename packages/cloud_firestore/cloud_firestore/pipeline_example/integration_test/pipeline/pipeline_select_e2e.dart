// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pipeline_test_helpers.dart';

void runPipelineSelectTests() {
  group('Pipeline select', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'firestore-pipeline-test',
      );
    });

    test('select returns only selected fields in expected order', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('select'))
          .sort(Expression.field('score').ascending())
          .select(
            Expression.field('name').as('name'),
            Expression.field('score').as('score'),
          )
          .limit(3)
          .execute();
      expectResultCount(snapshot, 3);
      expectResultsData(snapshot, [
        {'name': 'doc1', 'score': 1},
        {'name': 'doc2', 'score': 2},
        {'name': 'doc3', 'score': 3},
      ]);
    });
  });
}
