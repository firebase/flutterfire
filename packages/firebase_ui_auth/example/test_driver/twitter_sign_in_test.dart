// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';
import 'package:firebase_ui_oauth_twitter/firebase_ui_oauth_twitter.dart';
import 'package:mockito/mockito.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:twitter_login/entity/auth_result.dart' as twe;

import 'utils.dart';

void main() async {
  late TwitterProvider provider = TwitterProvider(
    apiKey: 'apiKey',
    apiSecretKey: 'apiSecretKey',
  );

  setUp(() {
    provider.provider = MockTwitterLogin();
  });

  const labels = DefaultLocalizations();

  group(
    'Sign in with Twitter button',
    () {
      testWidgets('has a correct button label', (tester) async {
        await render(tester, OAuthProviderButton(provider: provider));
        expect(find.text(labels.signInWithTwitterButtonText), findsOneWidget);
      });

      testWidgets(
        'calls sign in when tapped',
        (tester) async {
          await render(
            tester,
            OAuthProviderButton(provider: provider),
          );

          final button = find.byType(OAuthProviderButtonBase);
          await tester.tap(button);

          await tester.pumpAndSettle();
          verify(provider.provider.login()).called(1);

          expect(true, isTrue);
        },
      );

      testWidgets(
        'shows loading indicator when sign in is in progress',
        (tester) async {
          await render(
            tester,
            OAuthProviderButton(provider: provider),
          );

          when(provider.provider.login()).thenAnswer(
            (realInvocation) async {
              await Future.delayed(const Duration(milliseconds: 50));
              return MockAuthResult();
            },
          );

          final button = find.byType(OAuthProviderButtonBase);
          await tester.tap(button);
          await tester.pump();

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        },
      );

      testWidgets('signs the user in', (tester) async {
        await render(
          tester,
          OAuthProviderButton(provider: provider),
        );

        final button = find.byType(OAuthProviderButtonBase);
        await tester.tap(button);
        await tester.pumpAndSettle();

        final user = FirebaseAuth.instance.currentUser!;

        expect(user.displayName, 'Test User');
        expect(user.email, 'test@test.com');
      });
    },
    skip: !provider.supportsPlatform(defaultTargetPlatform),
  );
}

// Mock JWT with the following payload:
// {
//   "sub": "1234567890",
//   "name": "Test User",
//   "email": "test@test.com",
//   "iat": 1516239022
// }
const _jwt =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IlRlc3QgVXNlciIsImVtYWlsIjoidGVzdEB0ZXN0LmNvbSIsImlhdCI6MTUxNjIzOTAyMn0.m5qYto_Vs5ELTURC8rkD-JAJuoosdQZeuUZ_qFrEiaE';

class MockAuthResult extends Mock implements twe.AuthResult {
  @override
  TwitterLoginStatus? get status => TwitterLoginStatus.loggedIn;
  @override
  String? get authToken => _jwt;
  @override
  String? get authTokenSecret => 'secret';
}

class MockTwitterLogin extends Mock implements TwitterLogin {
  @override
  Future<twe.AuthResult> login({bool? forceLogin}) async {
    return super.noSuchMethod(
      Invocation.method(
        #signIn,
        [],
      ),
      returnValue: MockAuthResult(),
      returnValueForMissingStub: MockAuthResult(),
    );
  }
}
