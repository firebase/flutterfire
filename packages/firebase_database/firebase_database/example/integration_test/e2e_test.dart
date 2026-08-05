// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_database_example/firebase_options.dart';

import 'data_snapshot_e2e.dart';
import 'database_e2e.dart';
import 'database_reference_e2e.dart';
import 'report_test_results.dart';
import 'web_only_stub.dart' if (dart.library.js_interop) 'web_only.dart';
import 'firebase_database_configuration_e2e.dart';
import 'query_e2e.dart';

late FirebaseDatabase database;

// The port we've set the Firebase Database emulator to run on via the
// `firebase.json` configuration file.
const emulatorPort = 9000;

// Android device emulators consider localhost of the host machine as 10.0.2.2
// but should be automatically mapped by the useDatabaseEmulator function.
const emulatorHost = 'localhost';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  reportTestResultsToDriver(binding);

  group('firebase_database', () {
    setUpAll(() async {
      // The native SDK may already have configured [DEFAULT] from a bundled      // GoogleService-Info.plist (the plugin registrant does this before any      // Dart runs). Dart's Firebase.apps cannot see that app until the first      // platform-channel call, so the only reliable guard is catching the      // duplicate-app error and keeping the natively configured instance.      try {        await Firebase.initializeApp(          options: DefaultFirebaseOptions.currentPlatform,        );      } on FirebaseException catch (e) {        if (e.code != 'duplicate-app') {          rethrow;        }      }
      database = FirebaseDatabase.instance;
      database.useDatabaseEmulator(emulatorHost, emulatorPort);
      await database.goOnline();
    });

    setupConfigurationTests();
    setupDatabaseTests();
    setupDatabaseReferenceTests();
    setupQueryTests();
    setupDataSnapshotTests();
    setupWebOnlyTests();
  });
}
