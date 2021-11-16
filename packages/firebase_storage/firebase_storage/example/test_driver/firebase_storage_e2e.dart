// ignore_for_file: require_trailing_commas
// @dart = 2.9

// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'instance_e2e.dart';
import 'list_result_e2e.dart';
import 'reference_e2e.dart';
import 'task_e2e.dart';
import 'test_utils.dart';

// Requires that an emulator is running locally
// `melos run firebase:emulator`
bool useEmulator = true;

void testsMain() {
  setUpAll(() async {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
      appId: '1:448618578101:ios:2bc5c1fe2ec336f8ac3efc',
      messagingSenderId: '448618578101',
      projectId: 'react-native-firebase-testing',
    ));
    if (useEmulator) {
      await FirebaseStorage.instance
          .useStorageEmulator(testEmulatorHost, testEmulatorPort);
    }

    // Add a write only file
    await FirebaseStorage.instance.ref('writeOnly.txt').putString('Write Only');

    await FirebaseStorage.instance.ref('flutter-tests/ok.txt').putString('Ok!');

    // Setup list items - Future.wait not working...
    await FirebaseStorage.instance
        .ref('flutter-tests/list/file1.txt')
        .putString('File 1');
    await FirebaseStorage.instance
        .ref('flutter-tests/list/file2.txt')
        .putString('File 2');
    await FirebaseStorage.instance
        .ref('flutter-tests/list/file3.txt')
        .putString('File 3');
    await FirebaseStorage.instance
        .ref('flutter-tests/list/file4.txt')
        .putString('File 5');
    await FirebaseStorage.instance
        .ref('flutter-tests/list/nested/file5.txt')
        .putString('File 5');
  });

  runInstanceTests();
  runListResultTests();
  runReferenceTests();
  runTaskTests();
}

void main() => drive.main(testsMain);
