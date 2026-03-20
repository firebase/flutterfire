// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pipeline_test_helpers.dart';

void runPipelineSampleTests() {
  group('Pipeline sample', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'firestore-pipeline-test',
      );
    });

    test('sample withSize returns exactly requested count', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('sample'))
          .sample(PipelineSample.withSize(5))
          .execute();
      expectResultCount(snapshot, 5);
      for (final r in snapshot.result) {
        expect(r.data(), isNotNull);
        expect(r.data()!.containsKey('n'), true);
      }
    });

    test('sample withPercentage returns results in expected range', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('sample'))
          .sample(PipelineSample.withPercentage(0.2))
          .execute();
      expect(snapshot.result.length, greaterThanOrEqualTo(0));
      expect(snapshot.result.length, lessThanOrEqualTo(10));
    });
  });
}
