// ignore_for_file: require_trailing_commas

// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'instance_e2e.dart';
import 'test_utils.dart';
import 'user_e2e.dart';

// Requires that an emulator is running locally
// `melos run firebase:emulator`
bool useEmulator = true;

void testsMain() {
  setUpAll(() async {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
      appId: '1:448618578101:ios:4cd06f56e36384acac3efc',
      messagingSenderId: '448618578101',
      projectId: 'react-native-firebase-testing',
      authDomain: 'react-native-firebase-testing.firebaseapp.com',
      iosClientId:
          '448618578101-m53gtqfnqipj12pts10590l37npccd2r.apps.googleusercontent.com',
    ));

    if (useEmulator) {
      await FirebaseAuth.instance
          .useAuthEmulator(testEmulatorHost, testEmulatorPort);
    }
  });

  setUp(() async {
    // Reset users on emulator.
    await emulatorClearAllUsers();

    // Create a generic testing user account.
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: testEmail,
      password: testPassword,
    );

    // Create a disabled user account.
    final disabledUserCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: testDisabledEmail,
      password: testPassword,
    );
    await emulatorDisableUser(disabledUserCredential.user!.uid);

    await ensureSignedOut();
  });

  runInstanceTests();
  runUserTests();
}

void main() => drive.main(testsMain);
