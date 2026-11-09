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

class _FakeFirebase extends FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return FirebaseAppPlatform(
      name,
      const FirebaseOptions(
        apiKey: 'api-key',
        appId: 'app-id',
        messagingSenderId: 'sender-id',
        projectId: 'project-id',
      ),
    );
  }
}

JSObject _jsError(String message, {String? code}) {
  final error = globalContext
      .getProperty<JSFunction>('Error'.toJS)
      .callAsConstructor<JSObject>(message.toJS);
  if (code != null) {
    error['name'] = 'FirebaseError'.toJS;
    error['code'] = code.toJS;
  }
  return error;
}

void main() {
  setUpAll(() {
    FirebasePlatform.instance = _FakeFirebase();
  });

  /// Stubs the JS SDK so that `connectAuthEmulator()` throws [error].
  void connectAuthEmulatorThrows(Object error) {
    final core = JSObject();
    core['getApp'] = (([JSAny? name]) => JSObject()).toJS;
    globalContext['firebase_core'] = core;

    final oauthProvider = JSObject();
    oauthProvider['credentialFromError'] = ((JSAny _) => null).toJS;

    final auth = JSObject();
    for (final name in [
      'indexedDBLocalPersistence',
      'browserLocalPersistence',
      'browserSessionPersistence',
      'debugErrorMap',
      'browserPopupRedirectResolver',
    ]) {
      auth[name] = JSObject();
    }
    auth['OAuthProvider'] = oauthProvider;
    auth['initializeAuth'] = ((JSAny? app, JSAny? options) => JSObject()).toJS;
    void connectAuthEmulator(JSAny? auth, JSAny? origin) => throw error;
    auth['connectAuthEmulator'] = connectAuthEmulator.toJS;
    globalContext['firebase_auth'] = auth;
  }

  test('ignores auth/emulator-config-failed after a hot restart', () async {
    connectAuthEmulatorThrows(
      _jsError(
        'Firebase: Error (auth/emulator-config-failed).',
        code: 'auth/emulator-config-failed',
      ),
    );

    await FirebaseAuthWeb.instance.useAuthEmulator('localhost', 9099);
  });

  test('maps a Firebase Auth error to FirebaseAuthException', () async {
    connectAuthEmulatorThrows(
      _jsError(
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
    connectAuthEmulatorThrows(_jsError('storage is disabled'));

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
