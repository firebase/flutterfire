// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_auth_js_sdk.dart';

void main() {
  setUpAll(() {
    FirebasePlatform.instance = FakeFirebase();
  });

  /// Stubs the JS SDK so that `connectAuthEmulator()` throws [error].
  void connectAuthEmulatorThrows(Object error) {
    void connectAuthEmulator(JSAny? auth, JSAny? origin) => throw error;
    stubFirebaseAuthJsSdk()['connectAuthEmulator'] = connectAuthEmulator.toJS;
  }

  test('ignores auth/emulator-config-failed after a hot restart', () async {
    connectAuthEmulatorThrows(
      jsError(
        'Firebase: Error (auth/emulator-config-failed).',
        code: 'auth/emulator-config-failed',
      ),
    );

    await FirebaseAuthWeb.instance.useAuthEmulator('localhost', 9099);
  });

  test('maps a Firebase Auth error to FirebaseAuthException', () async {
    connectAuthEmulatorThrows(
      jsError(
        'Firebase: Error (auth/invalid-emulator-scheme).',
        code: 'auth/invalid-emulator-scheme',
      ),
    );

    await expectLater(
      FirebaseAuthWeb.instance.useAuthEmulator('localhost', 9099),
      throwsA(
        isA<FirebaseAuthException>().having(
          (e) => e.code,
          'code',
          'invalid-emulator-scheme',
        ),
      ),
    );
  });

  test('maps a JS error without code to an unknown error', () async {
    connectAuthEmulatorThrows(jsError('storage is disabled'));

    await expectLater(
      FirebaseAuthWeb.instance.useAuthEmulator('localhost', 9099),
      throwsA(
        isA<FirebaseAuthException>().having((e) => e.code, 'code', 'unknown'),
      ),
    );
  });

  test('rethrows a Dart error unchanged', () async {
    connectAuthEmulatorThrows(StateError('boom'));

    await expectLater(
      FirebaseAuthWeb.instance.useAuthEmulator('localhost', 9099),
      throwsA(isA<StateError>()),
    );
  });
}
