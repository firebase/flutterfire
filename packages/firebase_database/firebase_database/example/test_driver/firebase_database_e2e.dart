import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'data_snapshot_e2e.dart';
import 'database_e2e.dart';
import 'database_reference_e2e.dart';
import 'firebase_database_configuration_e2e.dart';
import 'query_e2e.dart';

late FirebaseDatabase database;

void testsMain() {
  setUpAll(() async {
    database = FirebaseDatabase.instance;
    await Firebase.initializeApp();
  });

  runConfigurationTests();
  runDatabaseTests();
  runDatabaseReferenceTests();
  runQueryTests();
  runDataSnapshotTests();
}

void main() => drive.main(testsMain);
