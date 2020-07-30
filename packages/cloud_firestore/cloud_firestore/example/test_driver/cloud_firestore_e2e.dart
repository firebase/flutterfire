// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'collection_reference_e2e.dart';
import 'instance_e2e.dart';
import 'query_e2e.dart';
import 'document_reference_e2e.dart';
import 'document_change_e2e.dart';
import 'field_value_e2e.dart';
import 'geo_point_e2e.dart';
import 'snapshot_metadata_e2e.dart';
import 'timestamp_e2e.dart';
import 'transaction_e2e.dart';
import 'write_batch_e2e.dart';

// TODO(Salakar): Web can't connect to Firestore emulator in CI, unable to reproduce
// connection issue locally (working fine locally and also for Android/iOS on CI).
bool kUseFirestoreEmulator = !kIsWeb;

void testsMain() {
  setUpAll(() async {
    await Firebase.initializeApp();

    if (kUseFirestoreEmulator) {
      String host = defaultTargetPlatform == TargetPlatform.android
          ? '10.0.2.2:8080'
          : 'localhost:8080';
      FirebaseFirestore.instance.settings =
          Settings(host: host, sslEnabled: false, persistenceEnabled: true);
    }
  });

  runInstanceTests();

  runCollectionReferenceTests();
  runDocumentChangeTests();
  runDocumentReferenceTests();
  runFieldValueTests();
  runGeoPointTests();
  runQueryTests();
  runSnapshotMetadataTests();
  runTimestampTests();
  runTransactionTests();
  runWriteBatchTests();
}

void main() => drive.main(testsMain);
