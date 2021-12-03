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
const emulatorPort = 9000;

// Android device emulators consider localhost of the host machine as 10.0.2.2
// so let's use that if running on Android.
final emulatorHost =
    (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        ? '10.0.2.2'
        : 'localhost';

void testsMain() {
  setUpAll(() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
        appId: '1:448618578101:ios:2bc5c1fe2ec336f8ac3efc',
        messagingSenderId: '448618578101',
        projectId: 'react-native-firebase-testing',
        databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
        storageBucket: 'react-native-firebase-testing.appspot.com',
      ),
    );
    database = FirebaseDatabase.instance;
    database.useDatabaseEmulator(emulatorHost, emulatorPort);
  });

  runConfigurationTests();
  runDatabaseTests();
  runDatabaseReferenceTests();
  runQueryTests();
  runDataSnapshotTests();
  // TODO(ehesp): Fix broken tests
  // runOnDisconnectTests();
}

void main() => drive.main(testsMain);
