// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void runPipelineWriteTests() {
  group('Pipeline writes', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'firestore-pipeline-test',
      );
    });

    test('literals upsert, update, insert, and delete round-trip', () async {
      final collection =
          'pipeline-writes-${DateTime.now().microsecondsSinceEpoch}';

      Future<Map<String, dynamic>?> read(String id) async {
        final snapshot = await firestore
            .collection(collection)
            .doc(id)
            .get(const GetOptions(source: Source.server));
        return snapshot.data();
      }

      try {
        await firestore
            .pipeline()
            .literals([
              {
                'name': 'ada',
                'score': Expression.constant(1),
                'tags': ['a', 'b'],
              },
            ])
            .upsert(
              collectionPath: collection,
              documentId: Expression.constant('ada'),
            )
            .execute(options: const ExecuteOptions(atomic: true));

        expect(await read('ada'), {
          'name': 'ada',
          'score': 1,
          'tags': ['a', 'b'],
        });

        await firestore.pipeline().collection(collection).update([
          Expression.constant(2).as('score'),
        ]).execute();

        final updated = await read('ada');
        expect(updated?['name'], 'ada');
        expect(updated?['score'], 2);

        await firestore
            .pipeline()
            .literals([
              {'name': 'grace', 'score': Expression.constant(3)},
            ])
            .insert(
              collectionPath: collection,
              documentId: Expression.constant('grace'),
            )
            .execute(options: const ExecuteOptions(atomic: true));

        expect(await read('grace'), {'name': 'grace', 'score': 3});

        await firestore.pipeline().collection(collection).delete().execute();

        expect(await read('ada'), isNull);
        expect(await read('grace'), isNull);
      } finally {
        await firestore.pipeline().collection(collection).delete().execute();
      }
    });
  }, skip: kIsWeb ? false : 'Pipeline writes run on web.');
}
