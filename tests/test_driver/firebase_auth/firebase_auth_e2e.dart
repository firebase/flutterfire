// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_default_options.dart';
import 'firebase_auth_instance_e2e.dart' as instance_tests;
import 'firebase_auth_multi_factor_e2e.dart' as multi_factor_tests;
import 'firebase_auth_user_e2e.dart' as user_tests;
import 'test_utils.dart';

void setupTests() {
  group('firebase_auth', () {
    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseAuth.instance
          .useAuthEmulator(testEmulatorHost, testEmulatorPort);
    });

    setUp(() async {
      // Reset users on emulator.
      await emulatorClearAllUsers();

      try {
        // Create a generic testing user account. Wrapped around try/catch because web still seems to have knowledge of user.
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
      } catch (e) {
        // ignore: avoid_print
        print('Already existing user: $e');
      }

      try {
        // Create a disabled user account. Wrapped around try/catch because web still seems to have knowledge of user.
        final disabledUserCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testDisabledEmail,
          password: testPassword,
        );
        await emulatorDisableUser(disabledUserCredential.user!.uid);
      } catch (e) {
        // ignore: avoid_print
        print('Already existing disabled user: $e');
      }
      await ensureSignedOut();
    });

    instance_tests.setupTests();
    user_tests.setupTests();
    multi_factor_tests.setupTests();
  });
}
