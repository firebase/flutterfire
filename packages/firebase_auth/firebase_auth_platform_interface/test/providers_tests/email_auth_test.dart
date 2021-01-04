// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

void main() {
  /*late*/ TestEmailAuthProvider emailAuthProvider;
  final String kMockEmail = 'test-email';
  final String kMockPassword = 'test-password';
  final String kMockEmailLink = 'https://www.emaillink.com';

  setUpAll(() {
    emailAuthProvider = TestEmailAuthProvider();
  });

  group('$EmailAuthProvider', () {
    test('Constructor', () {
      expect(emailAuthProvider, isA<EmailAuthProvider>());
    });

    test('EmailAuthProvider.EMAIL_LINK_SIGN_IN_METHOD', () {
      expect(EmailAuthProvider.EMAIL_LINK_SIGN_IN_METHOD, isA<String>());
      expect(EmailAuthProvider.EMAIL_LINK_SIGN_IN_METHOD, equals('emailLink'));
    });

    test('EmailAuthProvider.EMAIL_PASSWORD_SIGN_IN_METHOD', () {
      expect(EmailAuthProvider.EMAIL_PASSWORD_SIGN_IN_METHOD, isA<String>());
      expect(
          EmailAuthProvider.EMAIL_PASSWORD_SIGN_IN_METHOD, equals('password'));
    });

    test('EmailAuthProvider.PROVIDER_ID', () {
      expect(EmailAuthProvider.PROVIDER_ID, isA<String>());
      expect(EmailAuthProvider.PROVIDER_ID, equals('password'));
    });

    group('EmailAuthProvider.credential()', () {
      test('creates a new [EmailAuthCredential]', () {
        final result = EmailAuthProvider.credential(
            email: kMockEmail, password: kMockPassword);
        expect(result, isA<AuthCredential>());
        expect(result.token, isNull);
        expect(result.signInMethod, equals('password'));
      });

      test('throws [AssertionError] when email is null', () {
        expect(
            () => EmailAuthProvider.credential(
                email: null, password: kMockPassword),
            throwsAssertionError);
      });
      test('throws [AssertionError] when password is null', () {
        expect(
            () =>
                EmailAuthProvider.credential(email: kMockEmail, password: null),
            throwsAssertionError);
      });
    });

    group('EmailAuthProvider.credentialWithLink()', () {
      test('creates a new [EmailAuthCredential]', () {
        final result = EmailAuthProvider.credentialWithLink(
            email: kMockEmail, emailLink: kMockEmailLink);
        expect(result, isA<AuthCredential>());
        expect(result.token, isNull);
        expect(result.signInMethod, equals('emailLink'));
      });

      test('throws [AssertionError] when email is null', () {
        expect(
            () => EmailAuthProvider.credentialWithLink(
                email: null, emailLink: kMockEmailLink),
            throwsAssertionError);
      });
      test('throws [AssertionError] when emailLink is null', () {
        expect(
            () => EmailAuthProvider.credentialWithLink(
                email: kMockEmail, emailLink: null),
            throwsAssertionError);
      });
    });
  });
}

class TestEmailAuthProvider extends EmailAuthProvider {
  TestEmailAuthProvider() : super();
}
