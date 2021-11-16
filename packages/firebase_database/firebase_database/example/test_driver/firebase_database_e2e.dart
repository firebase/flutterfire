import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'data_snapshot_e2e.dart';
import 'database_e2e.dart';
import 'database_reference_e2e.dart';
import 'firebase_database_configuration_e2e.dart';
import 'query_e2e.dart';

late FirebaseDatabase database;

// The port we've set the Firebase Database emulator to run on via the
// `firebase.json` configuration file.
const emulatorPort = 9299;

// Android device emulators consider localhost of the host machine as 10.0.2.2
// so let's use that if running on Android.
final emulatorHost =
    (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        ? '10.0.2.2'
        : 'localhost';

void testsMain() {
  setUpAll(() async {
    await Firebase.initializeApp();
    database = FirebaseDatabase.instance;
    database.useDatabaseEmulator(emulatorHost, emulatorPort);
  });

  runConfigurationTests();
  runDatabaseTests();
  runDatabaseReferenceTests();
  runQueryTests();
  runDataSnapshotTests();
}

void main() => drive.main(testsMain);
