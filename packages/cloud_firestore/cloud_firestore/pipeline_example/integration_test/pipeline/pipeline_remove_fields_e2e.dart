// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pipeline_test_helpers.dart';

void runPipelineRemoveFieldsTests() {
  group('Pipeline removeFields', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'firestore-pipeline-test',
      );
    });

    test('removeFields drops specified fields only', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('remove-fields'))
          .sort(Expression.field('keep').ascending())
          .removeFields('internal_id', 'debug_flag')
          .limit(3)
          .execute();
      expectResultCount(snapshot, 3);
      expectResultsData(snapshot, [
        {'keep': 'x'},
        {'keep': 'y'},
        {'keep': 'z'},
      ]);
      for (final r in snapshot.result) {
        final data = r.data()!;
        expect(data.containsKey('internal_id'), false);
        expect(data.containsKey('debug_flag'), false);
      }
    });
  });
}
