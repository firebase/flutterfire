// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/src/utils/web_utils.dart';
import 'package:flutter_test/flutter_test.dart';

/// A JS error shaped like the `FirebaseError` the Auth JS SDK throws.
JSObject _firebaseAuthError() {
  final error = globalContext
      .getProperty<JSFunction>('Error'.toJS)
      .callAsConstructor<JSObject>(
        'Firebase: Error (auth/user-disabled).'.toJS,
      );
  error['name'] = 'FirebaseError'.toJS;
  error['code'] = 'auth/user-disabled'.toJS;
  return error;
}

/// Matches the exact JS value [expected], not a wrapper around it.
Matcher _isJsValue(JSAny expected) => predicate<Object>(
  // ignore: invalid_runtime_check_with_js_interop_types
  (e) => e is JSObject && e.strictEquals(expected).toDart,
  'is the original JS error',
);

void main() {
  setUp(() {
    // getFirebaseAuthException always calls OAuthProvider.credentialFromError.
    // Stub it so this test does not need the full Auth JS SDK.
    final oauthProvider = JSObject();
    oauthProvider['credentialFromError'] = ((JSAny _) => null).toJS;
    final firebaseAuth = JSObject();
    firebaseAuth['OAuthProvider'] = oauthProvider;
    globalContext['firebase_auth'] = firebaseAuth;
  });

  group('guardAuthExceptions with a sync callback', () {
    test('maps a Firebase Auth error to FirebaseAuthException', () {
      expect(
        () => guardAuthExceptions<void>(() => throw _firebaseAuthError()),
        throwsA(
          isA<FirebaseAuthException>().having(
            (e) => e.code,
            'code',
            'user-disabled',
          ),
        ),
      );
    });

    test('rethrows a JS error without code or message unchanged', () {
      final error = JSObject();

      expect(
        () => guardAuthExceptions<void>(() => throw error),
        throwsA(_isJsValue(error)),
      );
    });

    test('rethrows a Dart error unchanged', () {
      expect(
        () => guardAuthExceptions<void>(() => throw StateError('boom')),
        throwsA(isA<StateError>().having((e) => e.message, 'message', 'boom')),
      );
    });
  });

  group('guardAuthExceptions with a Future callback', () {
    test('maps a Firebase Auth error to FirebaseAuthException', () async {
      await expectLater(
        guardAuthExceptions(() => Future<void>.error(_firebaseAuthError())),
        throwsA(
          isA<FirebaseAuthException>().having(
            (e) => e.code,
            'code',
            'user-disabled',
          ),
        ),
      );
    });

    test('maps a JS error without code or message to unknown', () async {
      await expectLater(
        guardAuthExceptions(() => Future<void>.error(JSObject())),
        throwsA(
          isA<FirebaseAuthException>().having((e) => e.code, 'code', 'unknown'),
        ),
      );
    });

    test('rethrows a Dart error with its stack trace', () async {
      final error = StateError('boom');
      final stackTrace = StackTrace.current;

      Object? caught;
      StackTrace? caughtStackTrace;
      try {
        await guardAuthExceptions(() => Future<void>.error(error, stackTrace));
      } catch (e, s) {
        caught = e;
        caughtStackTrace = s;
      }

      expect(caught, same(error));
      expect(caughtStackTrace.toString(), stackTrace.toString());
    });
  });
}
