// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

void main() {
  /*late*/ TestTwitterAuthProvider twitterAuthProvider;
  final String kMockProviderId = 'twitter.com';
  setUpAll(() {
    twitterAuthProvider = TestTwitterAuthProvider();
  });

  group('$TwitterAuthProvider', () {
    test('Constructor', () {
      expect(twitterAuthProvider, isA<TwitterAuthProvider>());
    });

    test('TwitterAuthProvider.TWITTER_SIGN_IN_METHOD', () {
      expect(TwitterAuthProvider.TWITTER_SIGN_IN_METHOD, isA<String>());
      expect(
          TwitterAuthProvider.TWITTER_SIGN_IN_METHOD, equals(kMockProviderId));
    });

    test('TwitterAuthProvider.PROVIDER_ID', () {
      expect(TwitterAuthProvider.PROVIDER_ID, isA<String>());
      expect(TwitterAuthProvider.PROVIDER_ID, equals(kMockProviderId));
    });

    test('parameters', () {
      expect(twitterAuthProvider.parameters, isA<Object>());
    });

    group('setCustomParameters()', () {
      test('sets custom parameters', () {
        final Map<dynamic, dynamic> kCustomOAuthParameters = <dynamic, dynamic>{
          'lang': 'es'
        };
        final result =
            twitterAuthProvider.setCustomParameters(kCustomOAuthParameters);
        expect(result, isA<TwitterAuthProvider>());
        expect(result.parameters['lang'], isA<String>());
        expect(result.parameters['lang'], equals('es'));
      });

      test('throws [AssertionError] when customOAuthParameters is null', () {
        expect(() => twitterAuthProvider.setCustomParameters(null),
            throwsAssertionError);
      });
    });

    group('TwitterAuthProvider.credential()', () {
      final String kMockAccessToken = 'test-token';
      final String kMockSecret = 'test-secret';
      test('creates a new [TwitterAuthCredential]', () {
        final result = TwitterAuthProvider.credential(
            accessToken: kMockAccessToken, secret: kMockSecret);
        expect(result, isA<OAuthCredential>());
        expect(result.token, isNull);
        expect(result.idToken, isNull);
        expect(result.accessToken, kMockAccessToken);
        expect(result.providerId, equals(kMockProviderId));
        expect(result.signInMethod, equals(kMockProviderId));
      });

      test('throws [AssertionError] when accessToken is null', () {
        expect(
            () => TwitterAuthProvider.credential(
                accessToken: null, secret: kMockSecret),
            throwsAssertionError);
      });

      test('throws [AssertionError] when secret is null', () {
        expect(
            () => TwitterAuthProvider.credential(
                accessToken: kMockAccessToken, secret: null),
            throwsAssertionError);
      });
    });
  });
}

class TestTwitterAuthProvider extends TwitterAuthProvider {
  TestTwitterAuthProvider() : super();
}
