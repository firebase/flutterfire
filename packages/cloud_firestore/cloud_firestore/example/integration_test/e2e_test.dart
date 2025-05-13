// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'collection_reference_e2e.dart';
import 'document_change_e2e.dart';
import 'document_reference_e2e.dart';
import 'field_value_e2e.dart';
import 'firebase_options.dart';
import 'geo_point_e2e.dart';
import 'instance_e2e.dart';
import 'load_bundle_e2e.dart';
import 'query_e2e.dart';
import 'second_database.dart';
import 'settings_e2e.dart';
import 'snapshot_metadata_e2e.dart';
import 'timestamp_e2e.dart';
import 'transaction_e2e.dart';
import 'vector_value_e2e.dart';
import 'web_snapshot_listeners.dart';
import 'write_batch_e2e.dart';

bool kUseFirestoreEmulator = true;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('cloud_firestore', () {
    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Web by default doesn't have persistence enabled
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );

      if (kUseFirestoreEmulator) {
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      }
    });

    runInstanceTests();

    runCollectionReferenceTests();
    runDocumentChangeTests();
    runDocumentReferenceTests();
    runFieldValueTests();
    runGeoPointTests();
    runVectorValueTests();
    runQueryTests();
    runSnapshotMetadataTests();
    runTimestampTests();
    runTransactionTests();
    runWriteBatchTests();
    runLoadBundleTests();
    runWebSnapshotListenersTests();
    if (defaultTargetPlatform != TargetPlatform.windows) {
      runSecondDatabaseTests();
    }
    if (kIsWeb) {
      runSettingsTest();
    }
  });
}
