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
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

import 'utils.dart';

void main() async {
  late GoogleProvider provider = GoogleProvider(
    clientId: 'clientId',
    redirectUri: 'redirectUri',
    scopes: const ['scope1', 'scope2'],
  );

  setUp(() {
    provider.provider = MockGoogleSignIn();
  });

  const labels = DefaultLocalizations();

  group(
    'Sign in with Google button',
    () {
      testWidgets('has a correct button label', (tester) async {
        await render(tester, OAuthProviderButton(provider: provider));
        expect(find.text(labels.signInWithGoogleButtonText), findsOneWidget);
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
          verify(provider.provider.signIn()).called(1);

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

          when(provider.provider.signIn()).thenAnswer(
            (realInvocation) async {
              await Future.delayed(const Duration(milliseconds: 50));
              return MockGoogleSignInAccount();
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

      testWidgets('works standalone', (tester) async {
        await render(
          tester,
          const GoogleSignInButton(
            loadingIndicator: CircularProgressIndicator(),
            clientId: 'test',
          ),
        );

        final button = find.byType(GoogleSignInButton);
        await tester.tap(button);
        await tester.pump();
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

class MockAuthentication extends Mock implements GoogleSignInAuthentication {
  @override
  final String accessToken = _jwt;
}

// ignore: avoid_implementing_value_types, must_be_immutable
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {
  @override
  Future<GoogleSignInAuthentication> get authentication async =>
      MockAuthentication();
}

class MockGoogleSignIn extends Mock implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() async {
    return super.noSuchMethod(
      Invocation.method(#signIn, []),
      returnValue: MockGoogleSignInAccount(),
      returnValueForMissingStub: MockGoogleSignInAccount(),
    );
  }
}
