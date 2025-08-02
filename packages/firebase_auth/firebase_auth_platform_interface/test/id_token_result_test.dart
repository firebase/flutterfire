// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/src/id_token_result.dart';
import 'package:firebase_auth_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String kMockSignInProvider = 'password';
  const String kMockSignInSecondFactor = 'phone';
  const String kMockToken = 'test-token';
  const int kMockExpirationTimestamp = 1234566;
  const int kMockAuthTimestamp = 1234567;
  const int kMockIssuedAtTimestamp = 12345678;
  final Map<String, String> kMockClaims = {
    'claim1': 'value1',
  };

  final kMockData = PigeonIdTokenResult(
      claims: kMockClaims,
      issuedAtTimestamp: kMockIssuedAtTimestamp,
      authTimestamp: kMockAuthTimestamp,
      expirationTimestamp: kMockExpirationTimestamp,
      signInProvider: kMockSignInProvider,
      signInSecondFactor: kMockSignInSecondFactor,
      token: kMockToken);

  group('$IdTokenResult', () {
    final idTokenResult = IdTokenResult(kMockData);
    group('Constructor', () {
      test('returns an instance of [IdTokenResult]', () {
        expect(idTokenResult, isA<IdTokenResult>());
        expect(idTokenResult.authTime!.millisecondsSinceEpoch,
            equals(kMockAuthTimestamp));
        expect(idTokenResult.claims, equals(kMockClaims));
        expect(idTokenResult.expirationTime!.millisecondsSinceEpoch,
            equals(kMockExpirationTimestamp));
        expect(idTokenResult.issuedAtTime!.millisecondsSinceEpoch,
            equals(kMockIssuedAtTimestamp));
        expect(idTokenResult.signInProvider, equals(kMockSignInProvider));
        expect(
            idTokenResult.signInSecondFactor, equals(kMockSignInSecondFactor));
        expect(idTokenResult.token, equals(kMockToken));
      });
    });

    group('claims', () {
      test('returns [Map] of data[claims] ', () {
        expect(idTokenResult.claims, isA<Map<String, dynamic>>());
      });

      test('returns null when data[claims] is null', () {
        final kMockData = PigeonIdTokenResult(
            issuedAtTimestamp: kMockIssuedAtTimestamp,
            authTimestamp: kMockAuthTimestamp,
            expirationTimestamp: kMockExpirationTimestamp,
            signInProvider: kMockSignInProvider,
            signInSecondFactor: kMockSignInSecondFactor,
            token: kMockToken);

        final testIdTokenResult = IdTokenResult(kMockData);
        expect(testIdTokenResult.claims, isNull);
      });
    });

    test('toString()', () {
      expect(idTokenResult.toString(),
          '$IdTokenResult(authTime: ${idTokenResult.authTime}, claims: $kMockClaims, expirationTime: ${idTokenResult.expirationTime}, issuedAtTime: ${idTokenResult.issuedAtTime}, signInProvider: $kMockSignInProvider, signInSecondFactor: $kMockSignInSecondFactor, token: $kMockToken)');
    });
  });
}
