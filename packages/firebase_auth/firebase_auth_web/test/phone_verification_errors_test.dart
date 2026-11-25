// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_auth_web/src/firebase_auth_web_recaptcha_verifier_factory.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_auth_js_sdk.dart';

void main() {
  setUpAll(() {
    FirebasePlatform.instance = FakeFirebase();
  });

  /// Installs the JS SDK, where `new RecaptchaVerifier()` returns
  /// [recaptchaVerifier] and `PhoneAuthProvider.verifyPhoneNumber()` runs
  /// [verifyPhoneNumber].
  void stubSdk({
    JSObject? recaptchaVerifier,
    JSPromise Function()? verifyPhoneNumber,
  }) {
    final phoneAuthProvider = JSObject();
    if (verifyPhoneNumber != null) {
      phoneAuthProvider['verifyPhoneNumber'] =
          ((JSAny? options, JSAny? verifier) => verifyPhoneNumber()).toJS;
    }

    final auth = stubFirebaseAuthJsSdk();
    auth['PhoneAuthProvider'] = jsConstructor(phoneAuthProvider);
    auth['RecaptchaVerifier'] = jsConstructor(recaptchaVerifier ?? JSObject());
  }

  group('verifyPhoneNumber', () {
    final failures = <FirebaseAuthException>[];

    setUp(failures.clear);

    Future<void> verifyPhoneNumber({
      PhoneCodeSent? codeSent,
      MultiFactorSession? multiFactorSession,
    }) {
      return FirebaseAuthWeb.instance.verifyPhoneNumber(
        phoneNumber: '+15555550100',
        multiFactorSession: multiFactorSession,
        verificationCompleted: (_) {},
        verificationFailed: failures.add,
        codeSent: codeSent ?? (_, __) {},
        codeAutoRetrievalTimeout: (_) {},
      );
    }

    test('reports a Firebase Auth error to verificationFailed', () async {
      stubSdk(
        verifyPhoneNumber: () => rejectWith(
          jsError(
            'Firebase: Error (auth/invalid-phone-number).',
            code: 'auth/invalid-phone-number',
          ),
        ),
      );

      await verifyPhoneNumber();

      expect(failures.single.code, 'invalid-phone-number');
    });

    test('rethrows a Dart error thrown by codeSent', () async {
      stubSdk(verifyPhoneNumber: () => resolveWith('verification-id'.toJS));

      await expectLater(
        verifyPhoneNumber(codeSent: (_, __) => throw StateError('boom')),
        throwsA(isA<StateError>()),
      );
      expect(failures, isEmpty);
    });

    test(
      'rethrows the cast error for a multiFactorSession from another platform',
      () async {
        stubSdk();

        await expectLater(
          verifyPhoneNumber(multiFactorSession: MultiFactorSession('id')),
          throwsA(isA<TypeError>()),
        );
        expect(failures, isEmpty);
      },
    );
  });

  group('RecaptchaVerifierFactoryWeb', () {
    RecaptchaVerifierFactoryWeb verifierWith(JSObject recaptchaVerifier) {
      stubSdk(recaptchaVerifier: recaptchaVerifier);
      return RecaptchaVerifierFactoryWeb(auth: FirebaseAuthWeb.instance);
    }

    test(
      'render maps a Firebase Auth error to FirebaseAuthException',
      () async {
        final recaptchaVerifier = JSObject();
        recaptchaVerifier['render'] = (() => rejectWith(
          jsError(
            'Firebase: Error (auth/captcha-check-failed).',
            code: 'auth/captcha-check-failed',
          ),
        )).toJS;

        await expectLater(
          verifierWith(recaptchaVerifier).render(),
          throwsA(
            isA<FirebaseAuthException>().having(
              (e) => e.code,
              'code',
              'captcha-check-failed',
            ),
          ),
        );
      },
    );

    test('render rethrows a Dart error unchanged', () async {
      JSPromise render() => throw StateError('boom');
      final recaptchaVerifier = JSObject();
      recaptchaVerifier['render'] = render.toJS;

      await expectLater(
        verifierWith(recaptchaVerifier).render(),
        throwsA(isA<StateError>()),
      );
    });

    test('verify rethrows a Dart error unchanged', () {
      JSPromise verify() => throw StateError('boom');
      final recaptchaVerifier = JSObject();
      recaptchaVerifier['verify'] = verify.toJS;

      expect(
        () => verifierWith(recaptchaVerifier).verify(),
        throwsA(isA<StateError>()),
      );
    });
  });
}
