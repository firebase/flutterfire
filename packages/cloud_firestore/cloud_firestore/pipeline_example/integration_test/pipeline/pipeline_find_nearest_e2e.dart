// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
      },
    );

    test(
      'findNearest with distance_field returns that field on Apple and web',
      () async {
        final prepared = firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('find-nearest'))
            .findNearest(
              Field('embedding'),
              [0.1, 0.2, 0.3],
              DistanceMeasure.cosine,
              limit: 5,
            );
        final stages = [
          for (final stage in prepared.stages)
            if (stage['stage'] == 'find_nearest')
              {
                'stage': stage['stage'],
                'args': {
                  ...Map<String, dynamic>.from(stage['args'] as Map),
                  'distance_field': 'distance',
                },
              }
            else
              stage,
        ];
        final platform = FirebaseFirestorePlatform.instanceFor(
          app: Firebase.app(),
          databaseId: 'firestore-pipeline-test',
        );
        final snapshot = await platform.pipeline(stages).execute();
        expect(snapshot.results, isA<List<PipelineResultPlatform>>());
        if (!_distanceFieldIsReturned || snapshot.results.isEmpty) {
          return;
        }
        for (final result in snapshot.results) {
          final data = result.data;
          expect(data, isNotNull);
          expect(data!.containsKey('distance'), isTrue);
          expect(data['distance'], isA<num>());
        }
      },
    );
  });
}

bool get _distanceFieldIsReturned {
  if (kIsWeb) {
    return true;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS => true,
    _ => false,
  };
}
