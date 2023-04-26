// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';
import 'package:firebase_ui_oauth_facebook/firebase_ui_oauth_facebook.dart';
import 'package:mockito/mockito.dart';

import 'utils.dart';

void main() async {
  late FacebookProvider provider = FacebookProvider(clientId: 'clientId');

  setUp(() {
    provider.provider = MockFacebookAuth();
  });

  const labels = DefaultLocalizations();

  group(
    'Sign in with Facebook button',
    () {
      testWidgets('has a correct button label', (tester) async {
        await render(tester, OAuthProviderButton(provider: provider));
        expect(find.text(labels.signInWithFacebookButtonText), findsOneWidget);
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
              return MockLoginResult();
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

class MockAccessToken extends Mock implements AccessToken {
  @override
  String get token => _jwt;
}

class MockLoginResult extends Mock implements LoginResult {
  @override
  LoginStatus get status => LoginStatus.success;
  @override
  AccessToken? get accessToken => MockAccessToken();
}

class MockFacebookAuth extends Mock implements FacebookAuth {
  @override
  Future<LoginResult> login({
    List<String>? permissions = const ['email', 'public_profile'],
    LoginBehavior? loginBehavior = LoginBehavior.dialogOnly,
  }) async {
    return super.noSuchMethod(
      Invocation.method(#signIn, [], {
        #permissions: permissions,
        #behavior: loginBehavior,
      }),
      returnValue: MockLoginResult(),
      returnValueForMissingStub: MockLoginResult(),
    );
  }
}
