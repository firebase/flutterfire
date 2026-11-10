// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'auth_emulator_web_session_storage_stub.dart'
    if (dart.library.js_interop) 'auth_emulator_web_session_storage_web.dart';
import 'report_test_results.dart';
import 'test_utils.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  reportTestResultsToDriver(binding);

  group('useAuthEmulator sessionStorage (web)', () {
    test(
      'connects even when sessionStorage already has the emulator origin',
      () async {
        const appName = 'auth-emulator-session-storage';
        final origin = 'http://$testEmulatorHost:$testEmulatorPort';

        final app = await Firebase.initializeApp(
          name: appName,
          options: DefaultFirebaseOptions.currentPlatform,
        );
        addTearDown(() async {
          try {
            await FirebaseAuth.instanceFor(app: app).signOut();
          } catch (_) {}
          clearAuthEmulatorOrigin(appName);
          clearAuthEmulatorOriginLocal(appName);
          await app.delete();
        });

        // Simulate a previous page load: the sticky note is present, but this
        // JS Auth instance has not called connectAuthEmulator yet.
        setAuthEmulatorOrigin(appName, origin);

        final auth = FirebaseAuth.instanceFor(app: app);
        await auth.useAuthEmulator(testEmulatorHost, testEmulatorPort);

        final credential = await auth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
        expect(credential.user, isNotNull);
        expect(credential.user!.email, testEmail);
      },
    );

    test(
      'stays on the emulator after sessionStorage is cleared when the user persisted',
      () async {
        final appName =
            'auth-emulator-persist-${DateTime.now().microsecondsSinceEpoch}';
        final email =
            'persist-${DateTime.now().microsecondsSinceEpoch}@example.com';
        final origin = 'http://$testEmulatorHost:$testEmulatorPort';
        FirebaseApp? app;

        addTearDown(() async {
          final existing = app;
          if (existing != null) {
            try {
              await FirebaseAuth.instanceFor(app: existing).signOut();
            } catch (_) {}
            try {
              await existing.delete();
            } catch (_) {}
          }
          clearAuthEmulatorOrigin(appName);
          clearAuthEmulatorOriginLocal(appName);
        });

        clearAuthEmulatorOrigin(appName);
        clearAuthEmulatorOriginLocal(appName);

        app = await Firebase.initializeApp(
          name: appName,
          options: DefaultFirebaseOptions.currentPlatform,
        );
        final auth = FirebaseAuth.instanceFor(app: app);
        await auth.useAuthEmulator(testEmulatorHost, testEmulatorPort);
        expect(getAuthEmulatorOriginLocal(appName), origin);

        final created = await auth.createUserWithEmailAndPassword(
          email: email,
          password: testPassword,
        );
        expect(created.user, isNotNull);

        clearAuthEmulatorOrigin(appName);
        await app.delete();

        app = await Firebase.initializeApp(
          name: appName,
          options: DefaultFirebaseOptions.currentPlatform,
        );
        final restored = FirebaseAuth.instanceFor(app: app);
        expect(restored.currentUser?.email, email);
        expect(await restored.currentUser!.getIdToken(true), isNotEmpty);
      },
    );

    test(
      'throws in debug when this instance already talked to production',
      () async {
        final appName =
            'auth-emulator-too-late-${DateTime.now().microsecondsSinceEpoch}';
        final origin = 'http://$testEmulatorHost:$testEmulatorPort';
        FirebaseApp? app;

        addTearDown(() async {
          final existing = app;
          if (existing != null) {
            try {
              await existing.delete();
            } catch (_) {}
          }
          clearAuthEmulatorOrigin(appName);
          clearAuthEmulatorOriginLocal(appName);
        });

        clearAuthEmulatorOrigin(appName);
        clearAuthEmulatorOriginLocal(appName);

        app = await Firebase.initializeApp(
          name: appName,
          options: DefaultFirebaseOptions.currentPlatform,
        );
        final auth = FirebaseAuth.instanceFor(app: app);
        try {
          await auth
              .signInWithEmailAndPassword(
                email: testEmail,
                password: testPassword,
              )
              .timeout(const Duration(seconds: 20));
        } on FirebaseAuthException {
          // The request locks this instance before the response arrives.
        } on TimeoutException {
          // Same lock. The call was already sent.
        }

        await expectLater(
          auth.useAuthEmulator(testEmulatorHost, testEmulatorPort),
          throwsA(
            isA<FirebaseAuthException>()
                .having((e) => e.code, 'code', 'emulator-config-failed')
                .having((e) => e.message, 'message', contains('production'))
                .having(
                  (e) => e.message,
                  'message',
                  contains('full page reload'),
                ),
          ),
        );
        expect(getAuthEmulatorOriginLocal(appName), origin);
      },
    );

    test(
      'keeps a different emulator connection when connect is too late',
      () async {
        final appName =
            'auth-emulator-other-origin-${DateTime.now().microsecondsSinceEpoch}';
        const otherHost = '127.0.0.1';
        const otherOrigin = 'http://$otherHost:$testEmulatorPort';
        FirebaseApp? app;

        addTearDown(() async {
          final existing = app;
          if (existing != null) {
            try {
              await FirebaseAuth.instanceFor(app: existing).signOut();
            } catch (_) {}
            try {
              await existing.delete();
            } catch (_) {}
          }
          clearAuthEmulatorOrigin(appName);
          clearAuthEmulatorOriginLocal(appName);
        });

        clearAuthEmulatorOrigin(appName);
        clearAuthEmulatorOriginLocal(appName);

        app = await Firebase.initializeApp(
          name: appName,
          options: DefaultFirebaseOptions.currentPlatform,
        );
        final auth = FirebaseAuth.instanceFor(app: app);
        await auth.useAuthEmulator(testEmulatorHost, testEmulatorPort);
        final credential = await auth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
        expect(credential.user, isNotNull);

        await auth.useAuthEmulator(otherHost, testEmulatorPort);

        expect(getAuthEmulatorOriginLocal(appName), otherOrigin);
        expect(await credential.user!.getIdToken(true), isNotEmpty);
      },
    );
  }, skip: !kIsWeb);
}
