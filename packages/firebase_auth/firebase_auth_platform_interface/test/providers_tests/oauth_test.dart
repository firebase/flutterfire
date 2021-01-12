// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

final String kMockProviderId = 'test.com';

void main() {
  /*late*/ TestOAuthProvider oAuthProvider;

  setUpAll(() {
    oAuthProvider = TestOAuthProvider(kMockProviderId);
  });

  group('$OAuthProvider', () {
    group('Constructor', () {
      test('returns an instance of [OAuthProvider]', () {
        expect(oAuthProvider, isA<OAuthProvider>());
      });

      test('throws [AssertionError] when providerId is null', () {
        expect(() => TestOAuthProvider(null), throwsAssertionError);
      });
    });

    test('providerId', () {
      expect(oAuthProvider.providerId, isA<String>());
      expect(oAuthProvider.providerId, equals(kMockProviderId));
    });

    test('scopes', () {
      expect(oAuthProvider.scopes, isA<List<String>>());
      expect(oAuthProvider.scopes.length, 0);
    });

    test('parameters', () {
      expect(oAuthProvider.parameters, isA<Object>());
    });

    group('addScope()', () {
      test('adds a new scope', () {
        String kMockScope = 'repo';
        final result = oAuthProvider.addScope(kMockScope);

        expect(result, isA<OAuthProvider>());
        expect(result.scopes, isA<List<String>>());
        expect(result.scopes.length, 1);
        expect(result.scopes[0], equals(kMockScope));
      });

      test('throws [AssertionError] when scope is null', () {
        expect(() => oAuthProvider.addScope(null), throwsAssertionError);
      });
    });

    group('setCustomParameters()', () {
      test('sets custom parameters', () {
        final Map<dynamic, dynamic> kCustomOAuthParameters = <dynamic, dynamic>{
          'allow_signup': 'false',
        };
        final result =
            oAuthProvider.setCustomParameters(kCustomOAuthParameters);
        expect(result, isA<OAuthProvider>());
        expect(result.parameters['allow_signup'], isA<String>());
        expect(result.parameters['allow_signup'], equals('false'));
      });

      test('throws [AssertionError] when customOAuthParameters is null', () {
        expect(() => oAuthProvider.setCustomParameters(null),
            throwsAssertionError);
      });
    });

    group('credential()', () {
      final String kMockAccessToken = 'test-token';
      final String kMockIdToken = 'id';
      final String kMockRawNonce = 'test-raw-nonce';
      test('creates a new [OAuthCredential]', () {
        final result = oAuthProvider.credential(
            accessToken: kMockAccessToken,
            idToken: kMockIdToken,
            rawNonce: kMockRawNonce);

        expect(result, isA<AuthCredential>());
        expect(result.token, isNull);
        expect(result.idToken, equals(kMockIdToken));
        expect(result.rawNonce, equals(kMockRawNonce));
        expect(result.accessToken, equals(kMockAccessToken));
        expect(result.providerId, equals(kMockProviderId));
        expect(result.signInMethod, equals('oauth'));
      });
    });
  });
}

class TestOAuthProvider extends OAuthProvider {
  TestOAuthProvider(providerId) : super(providerId);
}
