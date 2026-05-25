// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void runPipelineSearchTests() {
  group('Pipeline search', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'firestore-pipeline-test',
      );
    });

    test('withQuery returns matching search results', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .search(SearchStage.withQuery('pancakes', limit: 10))
          .where(Expression.field('test').equalValue('search'))
          .execute();

      expect(_resultNames(snapshot), contains('Pancake House'));
    });

    test('withQueryExpression returns matching search results', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .search(
            SearchStage.withQueryExpression(
              Expression.documentMatches('pancakes'),
              limit: 10,
            ),
          )
          .where(Expression.field('test').equalValue('search'))
          .execute();

      expect(_resultNames(snapshot), contains('Pancake House'));
    });

    test('withQueryExpression supports combined document match queries',
        () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .search(
            SearchStage.withQueryExpression(
              Expression.and(
                Expression.documentMatches('pancakes'),
                Expression.documentMatches('breakfast'),
              ),
              limit: 10,
            ),
          )
          .where(Expression.field('test').equalValue('search'))
          .execute();

      expect(_resultNames(snapshot), contains('Pancake House'));
    });
  });
}

List<Object?> _resultNames(PipelineSnapshot snapshot) {
  return snapshot.result.map((result) => result.data()?['name']).toList();
}
