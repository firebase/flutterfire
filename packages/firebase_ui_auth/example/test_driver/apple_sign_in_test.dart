import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
  final provider = AppleProvider();
  late FirebaseAuth auth;
  late MockProvider fbProvider;

  const labels = DefaultLocalizations();

  group(
    'Sign in with Apple button',
    () {
      setUp(() {
        auth = MockAuth();
        fbProvider = MockProvider();
        provider.firebaseAuthProvider = fbProvider;
      });

      testWidgets('has a correct button label', (tester) async {
        await render(
          tester,
          OAuthProviderButton(
            provider: provider,
            auth: auth,
          ),
        );
        expect(find.text(labels.signInWithAppleButtonText), findsOneWidget);
      });

      testWidgets(
        'calls sign in when tapped',
        (tester) async {
          await render(
            tester,
            OAuthProviderButton(
              provider: provider,
              auth: auth,
            ),
          );

          final button = find.byType(OAuthProviderButtonBase);
          await tester.tap(button);

          await tester.pumpAndSettle();
          verify(auth.signInWithProvider(fbProvider)).called(1);

          expect(true, isTrue);
        },
      );

      testWidgets(
        'shows loading indicator when sign in is in progress',
        (tester) async {
          await render(
            tester,
            OAuthProviderButton(
              provider: provider,
              auth: auth,
            ),
          );

          final button = find.byType(OAuthProviderButtonBase);
          await tester.tap(button);
          await tester.pump();

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        },
      );

      testWidgets('signs the user in', (tester) async {
        final listener = MockListener();

        await render(
          tester,
          AuthStateListener<OAuthController>(
            listener: (oldState, state, controller) {
              listener(state);
              return null;
            },
            child: OAuthProviderButton(
              provider: provider,
              auth: auth,
            ),
          ),
        );

        final button = find.byType(OAuthProviderButtonBase);
        await tester.tap(button);
        await tester.pumpAndSettle();

        final result = verify(listener.call(captureAny));
        expect(result.captured[1], isA<SignedIn>());

        final user = (result.captured[1] as SignedIn).user!;
        expect(user.displayName, 'Test User');
        expect(user.email, 'test@test.com');
      });
    },
    skip: !provider.supportsPlatform(defaultTargetPlatform),
  );
}

class MockListener<T> extends Mock {
  void call(AuthState? state) {
    super.noSuchMethod(
      Invocation.method(
        #call,
        [
          state,
        ],
      ),
    );
  }
}

class MockUser extends Mock implements User {
  @override
  String? get displayName => 'Test User';

  @override
  String? get email => 'test@test.com';
}

class MockCredential extends Mock implements UserCredential {
  @override
  User? get user => MockUser();
}

class MockProvider extends Mock implements AppleAuthProvider {}

// ignore: avoid_implementing_value_types
class MockApp extends Mock implements FirebaseApp {}

class MockAuth extends Mock implements FirebaseAuth {
  @override
  Future<UserCredential> signInWithAuthProvider(Object provider) async {
    return super.noSuchMethod(
      Invocation.method(#signInWithAuthProvider, [provider]),
      returnValue: Future.delayed(const Duration(milliseconds: 50))
          .then((_) => MockCredential()),
      returnValueForMissingStub:
          Future.delayed(const Duration(milliseconds: 50))
              .then((_) => MockCredential()),
    );
  }
}
