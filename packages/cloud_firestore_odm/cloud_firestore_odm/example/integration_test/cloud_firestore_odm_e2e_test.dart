// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'collection_reference_test.dart' as collection_reference_test;
import 'document_reference_test.dart' as document_reference_test;
import 'path_test.dart' as path_test;
import 'query_reference_test.dart' as query_reference_test;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('cloud_firestore_odm', () {
    setUpAll(() async {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
          appId: '1:448618578101:ios:3a3c8ae9cb0b6408ac3efc',
          messagingSenderId: '448618578101',
          projectId: 'react-native-firebase-testing',
          authDomain: 'react-native-firebase-testing.firebaseapp.com',
          iosClientId:
              '448618578101-m53gtqfnqipj12pts10590l37npccd2r.apps.googleusercontent.com',
        ),
      );
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    });

    collection_reference_test.main();
    document_reference_test.main();
    // TODO CI tests configuration currently not compatible with widget testing
    // firestore_builder_test.main();
    query_reference_test.main();
    path_test.main();
  });
}
