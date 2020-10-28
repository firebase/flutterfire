// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

// import 'firebase_storage_web_e2e.dart';
// import 'list_result_web_e2e.dart';
// import 'reference_web_e2e.dart';
// import 'task_web_e2e.dart';
import 'task_snapshot_web_e2e.dart';

// Requires that an emulator is running locally
bool USE_EMULATOR = false;

void testsMain() {
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  // runFirebaseStorageWebTests();
  // runListResultTests();
  // runReferenceTests();
  // runTaskTests();
  runTaskSnapshotTests();
}

void main() => drive.main(testsMain);
