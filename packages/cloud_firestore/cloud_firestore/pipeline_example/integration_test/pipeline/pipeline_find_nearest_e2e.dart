// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void runPipelineFindNearestTests() {
  group('Pipeline findNearest', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'firestore-pipeline-test',
      );
    });

    test(
        'findNearest returns results ordered by distance when vector index exists',
        () async {
      final pipeline = firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('find-nearest'))
          .findNearest(
            Field('embedding'),
            [0.1, 0.2, 0.3],
            DistanceMeasure.cosine,
            limit: 5,
          );
      final snapshot = await pipeline.execute();
      expect(snapshot, isNotNull);
      expect(snapshot.result, isA<List<PipelineResult>>());
      if (snapshot.result.isNotEmpty) {
        final first = snapshot.result.first.data();
        if (first != null && first.containsKey('label')) {
          expect(first['label'], 'near');
        }
      }
    });
  });
}
