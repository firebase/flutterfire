// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'auth_emulator_web_session_storage_stub.dart'
    if (dart.library.js_interop) 'auth_emulator_web_session_storage_web.dart';
import 'test_utils.dart';

void main() {
  group(
    'useAuthEmulator sessionStorage (web)',
    () {
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
    },
    skip: !kIsWeb,
  );
}
