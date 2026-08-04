// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

const String _searchCollection = 'pipeline-search-e2e';

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
          .collection(_searchCollection)
          .search(SearchStage.withQuery('pancakes', limit: 10))
          .execute();

      expect(_resultNames(snapshot), contains('Pancake House'));
    });

    test('withQuery passes options and returns expected result list', () async {
      final snapshot = await firestore
          .pipeline()
          .collection(_searchCollection)
          .search(
            SearchStage.withQuery(
              'breakfast',
              languageCode: 'en',
              retrievalDepth: 10,
              offset: 0,
              limit: 10,
            ),
          )
          .execute();

      expect(_sortedResultValues(snapshot, 'name'), [
        'Coffee Bar',
        'Pancake House',
      ]);
      expect(_resultNames(snapshot), isNot(contains('Burger Diner')));
    });

    test('withQueryExpression returns matching search results', () async {
      final snapshot = await firestore
          .pipeline()
          .collection(_searchCollection)
          .search(
            SearchStage.withQueryExpression(
              Expression.documentMatches('pancakes'),
              limit: 10,
            ),
          )
          .execute();

      expect(_resultNames(snapshot), contains('Pancake House'));
    });

    test(
      'withQueryExpression supports combined document match queries',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection(_searchCollection)
            .search(
              SearchStage.withQueryExpression(
                Expression.and(
                  Expression.documentMatches('pancakes'),
                  Expression.documentMatches('breakfast'),
                ),
                limit: 10,
              ),
            )
            .execute();

        expect(_resultNames(snapshot), contains('Pancake House'));
      },
      skip:
          true, // 'Native search does not support AND in query expressions yet.'
    );

    test('withQuery returns empty results when nothing matches', () async {
      final snapshot = await firestore
          .pipeline()
          .collection(_searchCollection)
          .search(SearchStage.withQuery('No match', limit: 10))
          .execute();

      expect(snapshot.result, isEmpty);
    });
  });
}

List<Object?> _resultNames(PipelineSnapshot snapshot) {
  return snapshot.result.map((result) => result.data()?['name']).toList();
}

List<String> _sortedResultValues(PipelineSnapshot snapshot, String field) {
  return snapshot.result
      .map((result) => result.data()?[field])
      .whereType<String>()
      .toList()
    ..sort();
}
