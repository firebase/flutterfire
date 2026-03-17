// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'pipeline_test_helpers.dart';

void runPipelineAddFieldsTests() {
  group('Pipeline addFields', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'firestore-pipeline-test');
    });

    test('addFields with expression returns expected transformed data', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('add-fields'))
          .sort(Expression.field('title').ascending())
          .addFields(
            Expression.field('score').abs().as('abs_score'),
          )
          .limit(3)
          .execute();
      expectResultCount(snapshot, 3);
      expectResultsData(snapshot, [
        {'title': 'alpha', 'score': -7,  'abs_score': 7},
        {'title': 'beta', 'score': 42,  'abs_score': 42},
        {'title': 'gamma', 'score': 0,  'abs_score': 0},
      ]);
    });
  });
}
