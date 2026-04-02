// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pipeline_test_helpers.dart';

void runPipelineReplaceWithTests() {
  group('Pipeline replaceWith', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'firestore-pipeline-test',
      );
    });

    test('replaceWith emits nested map as document', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('replace-with'))
          .sort(Expression.field('name').ascending())
          .replaceWith(Expression.field('nested'))
          .limit(1)
          .execute();
      expectResultCount(snapshot, 1);
      expectResultsData(snapshot, [
        {'father': 'John Doe Sr.', 'mother': 'Jane Doe'},
      ]);
    });

    test('replaceWith emits each nested map as a result document', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('replace-with'))
          .sort(Expression.field('name').ascending())
          .replaceWith(Expression.field('nested'))
          .execute();
      expectResultCount(snapshot, 3);
      expectResultsData(snapshot, [
        {'father': 'John Doe Sr.', 'mother': 'Jane Doe'},
        {'a': 1, 'b': 2},
        {'x': 'foo', 'y': 'bar'},
      ]);
    });
  });
}
