// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

import 'data_snapshot_e2e.dart';
import 'database_e2e.dart';
import 'database_reference_e2e.dart';
import 'firebase_database_configuration_e2e.dart';
import 'query_e2e.dart';

late FirebaseDatabase database;

// The port we've set the Firebase Database emulator to run on via the
// `firebase.json` configuration file.
const emulatorPort = 9000;

// Android device emulators consider localhost of the host machine as 10.0.2.2
// so let's use that if running on Android.
final emulatorHost =
    (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        ? '10.0.2.2'
        : 'localhost';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('firebase_database', () {
    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      database = FirebaseDatabase.instance;
      database.useDatabaseEmulator(emulatorHost, emulatorPort);
      await database.goOnline();
    });

    setupConfigurationTests();
    setupDatabaseTests();
    setupDatabaseReferenceTests();
    setupQueryTests();
    setupDataSnapshotTests();
    // TODO(ehesp): Fix broken tests
    // runOnDisconnectTests();
  });
}
