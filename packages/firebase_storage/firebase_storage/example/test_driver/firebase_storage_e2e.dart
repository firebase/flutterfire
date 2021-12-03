// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          projectId: 'react-native-firebase-testing',
          apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
          authDomain: 'react-native-firebase-testing.firebaseapp.com',
          storageBucket: 'react-native-firebase-testing.appspot.com',
          messagingSenderId: '448618578101',
          appId: '1:448618578101:web:772d484dc9eb15e9ac3efc',
        ),
      );
    } else {
      if (Platform.isMacOS) {
        //TODO(pr_Mais): macos doesn't build without GoogleService.plist, not possible to initialize from dart only??
        await Firebase.initializeApp();
      } else {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            projectId: 'react-native-firebase-testing',
            apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
            messagingSenderId: '448618578101',
            appId: '1:448618578101:ios:6640d5c29008c2a8ac3efc',
            iosBundleId: 'io.flutter.plugins.firebase.storage.example',
            storageBucket: 'react-native-firebase-testing.appspot.com',
          ),
        );
      }
    }

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
