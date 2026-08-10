// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth_example/firebase_options.dart';

import 'firebase_auth_instance_e2e_test.dart' as instance_tests;
import 'firebase_auth_multi_factor_e2e_test.dart' as multi_factor_tests;
import 'firebase_auth_user_e2e_test.dart' as user_tests;
import 'report_test_results.dart';
import 'test_utils.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  reportTestResultsToDriver(binding);

  group('firebase_auth', () {
    setUpAll(() async {
      // The native SDK may already have configured [DEFAULT] from a bundled
      // GoogleService-Info.plist (the plugin registrant does this before any
      // Dart runs). Dart's Firebase.apps cannot see that app until the first
      // platform-channel call, so the only reliable guard is catching the
      // duplicate-app error and keeping the natively configured instance.
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } on FirebaseException catch (e) {
        if (e.code != 'duplicate-app') {
          rethrow;
        }
      }

      await FirebaseAuth.instance
          .useAuthEmulator(testEmulatorHost, testEmulatorPort);
      if (defaultTargetPlatform != TargetPlatform.windows) {
        await FirebaseAuth.instance
            .setSettings(appVerificationDisabledForTesting: true);
      }
    });

    setUp(() async {
      await ensureSignedOut();

      // Reset users on emulator.
      await emulatorClearAllUsers();

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
      } on FirebaseAuthException catch (e) {
        // 'email-already-in-use': web may retain user state after emulator clear
        // 'keychain-error': known macOS issue needing keychain sharing entitlement
        if (e.code != 'email-already-in-use' && e.code != 'keychain-error') {
          rethrow;
        }
      }

      try {
        final disabledUserCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testDisabledEmail,
          password: testPassword,
        );
        await emulatorDisableUser(disabledUserCredential.user!.uid);
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use' && e.code != 'keychain-error') {
          rethrow;
        }
      }
      await ensureSignedOut();
    });

    instance_tests.main();
    user_tests.main();
    multi_factor_tests.main();
  });
}
