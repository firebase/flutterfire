// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupCloudFirestoreMocks();

  late FirebaseFirestore firestore;

  setUpAll(() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
  });

  group('PipelineSample', () {
    group('withSize()', () {
      test('serializes as type size with value', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .sample(PipelineSample.withSize(100));
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'sample');
        expect(stage['args']['type'], 'size');
        expect(stage['args']['value'], 100);
      });

      test('accepts zero size', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .sample(PipelineSample.withSize(0));
        expect(pipeline.stages.last['args']['value'], 0);
      });
    });

    group('withPercentage()', () {
      test('serializes as type percentage with value', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .sample(PipelineSample.withPercentage(0.6));
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'sample');
        expect(stage['args']['type'], 'percentage');
        expect(stage['args']['value'], 0.6);
      });
    });
  });
}
