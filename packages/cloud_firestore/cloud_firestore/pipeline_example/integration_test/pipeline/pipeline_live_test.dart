// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Pipeline E2E runs against live Firebase (do not use emulator).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pipeline_example/firebase_options.dart';

import 'pipeline_add_fields_e2e.dart';
import 'pipeline_aggregate_e2e.dart';
import 'pipeline_expressions_e2e.dart';
import 'pipeline_filter_sort_e2e.dart';
import 'pipeline_find_nearest_e2e.dart';
import 'pipeline_remove_fields_e2e.dart';
import 'pipeline_replace_with_e2e.dart';
import 'pipeline_sample_e2e.dart';
import 'pipeline_seed.dart';
import 'pipeline_select_e2e.dart';
import 'pipeline_unnest_union_e2e.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('pipeline (live)', () {
    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'firestore-pipeline-test',
      );
      firestore.settings = const Settings(persistenceEnabled: true);
      await seedPipelineE2ECollections(firestore);
    });

    // runPipelineFilterSortTests();
    // runPipelineAddFieldsTests();
    // runPipelineSelectTests();
    // runPipelineRemoveFieldsTests();
    // runPipelineReplaceWithTests();
    // runPipelineAggregateTests();
    // runPipelineUnnestUnionTests();
    // runPipelineSampleTests();
    // runPipelineFindNearestTests();
    runPipelineExpressionsTests();
  });
}
