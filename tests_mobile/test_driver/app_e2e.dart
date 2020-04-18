library test_suites;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

part 'cloud_firestore/cloud_firestore_e2e.dart';

FirebaseApp sharedFirebaseAppInstance;

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();
  
  group('FlutterFire', () {    
    setUp(() async {
      sharedFirebaseAppInstance = await FirebaseApp.configure(
        name: "test",
        options: const FirebaseOptions(
          googleAppID: '1:448618578101:web:0b650370bb29e29cac3efc',
          gcmSenderID: '448618578101',
          apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
          projectID: 'react-native-firebase-testing',
        ),
      );
    });

    setupCloudFirestoreTests();
  });
}