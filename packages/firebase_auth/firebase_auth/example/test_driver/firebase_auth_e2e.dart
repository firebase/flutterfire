// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_config.dart';
import 'instance_e2e.dart';
import 'test_utils.dart';
import 'user_e2e.dart';

// Requires that an emulator is running locally
// `melos run firebase:emulator`
bool useEmulator = true;

void testsMain() {
  setUpAll(() async {
    // TODO(pr_Mais): macos isn't compiling without the GoogleService.plist file
    await Firebase.initializeApp(options: TestFirebaseConfig.platformOptions);

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
