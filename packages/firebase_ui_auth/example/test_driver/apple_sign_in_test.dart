import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_ui_oauth_apple/src/provider.dart';

import 'utils.dart';

void main() async {
  late AppleProvider provider = AppleProvider();

  setUp(() {
    provider.provider = MockAppleSignIn();
  });

  const labels = DefaultLocalizations();

  group(
    'Sign in with Apple button',
    () {
      testWidgets('has a correct button label', (tester) async {
        await render(tester, OAuthProviderButton(provider: provider));
        expect(find.text(labels.signInWithAppleButtonText), findsOneWidget);
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
              return MockCredential();
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

class MockCredential extends Mock implements OAuthCredential {
  @override
  String get providerId => 'apple.com';
  @override
  String? get accessToken => _jwt;
}

class MockAppleSignIn extends Mock implements AppleProviderBackend {
  @override
  Future<OAuthCredential> signIn() async {
    return super.noSuchMethod(
      Invocation.method(
        #signIn,
        [],
      ),
      returnValue: MockCredential(),
      returnValueForMissingStub: MockCredential(),
    );
  }
}
