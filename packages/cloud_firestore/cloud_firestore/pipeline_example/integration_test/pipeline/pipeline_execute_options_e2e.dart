// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_test/flutter_test.dart';

import 'pipeline_test_helpers.dart';

void runPipelineExecuteOptionsTests() {
  group('Pipeline execute with options', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'firestore-pipeline-test',
      );
    });

    test(
      'execute with ExecuteOptions returns expected results',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('add-fields'))
            .sort(Expression.field('title').ascending())
            .limit(2)
            .execute(
              options: const ExecuteOptions(
                indexMode: IndexMode.recommended,
              ),
            );
        expectResultCount(snapshot, 2);
        expect(snapshot.result[0].data()!['title'], 'alpha');
        expect(snapshot.result[1].data()!['title'], 'beta');
      },
      skip: true,
    );
  });
}
