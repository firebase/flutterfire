// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';

void main() {
  late EmailLinkAuthProvider provider;
  late MockListener listener;
  late MockAuth auth;
  late MockDynamicLinks dynamicLinks;
  late EmailLinkFlow flow;
  late EmailLinkAuthController ctrl;

  final actionCodeSettings = ActionCodeSettings(
    url: 'https://example.com',
    handleCodeInApp: true,
    androidPackageName: 'com.test.app',
  );

  setUp(() {
    auth = MockAuth();
    listener = MockListener();
    dynamicLinks = MockDynamicLinks();

    provider = EmailLinkAuthProvider(
      actionCodeSettings: actionCodeSettings,
      dynamicLinks: dynamicLinks,
    );

    flow = EmailLinkFlow(
      provider: provider,
      auth: auth,
    );

    ctrl = flow;
  });

  group('EmailLinkAuthProvider', () {
    test('has correct provider id', () {
      expect(provider.providerId, 'email_link');
    });

    group('#sendLink', () {
      test('calls onBeforeLinkSent', () {
        provider.authListener = listener;

        provider.sendLink('test@test.com');

        final result = verify(listener.onBeforeLinkSent(captureAny));
        result.called(1);
        expect(result.captured, ['test@test.com']);
      });

      test('calls FirebaseAuth#sendSignInLinkToEmail', () {
        provider.authListener = listener;
        provider.sendLink('test@test.com');

        final result = verify(
          auth.sendSignInLinkToEmail(
            actionCodeSettings: captureAnyNamed('actionCodeSettings'),
            email: captureAnyNamed('email'),
          ),
        );

        result.called(1);
        expect(result.captured[0], actionCodeSettings);
        expect(result.captured[1], 'test@test.com');
      });

      test('calls onLinkSent', () async {
        provider.authListener = listener;

        provider.sendLink('test@test.com');

        await untilCalled(
          auth.sendSignInLinkToEmail(
            email: anyNamed('email'),
            actionCodeSettings: anyNamed('actionCodeSettings'),
          ),
        );

        final result = verify(listener.onLinkSent(captureAny));
        result.called(1);
        expect(result.captured, ['test@test.com']);
      });

      test('calls onError if an error occured', () async {
        provider.authListener = listener;
        final exception = TestException();

        when(
          auth.sendSignInLinkToEmail(
            email: anyNamed('email'),
            actionCodeSettings: anyNamed('actionCodeSettings'),
          ),
        ).thenThrow(exception);

        provider.sendLink('test@test.com');

        await untilCalled(listener.onBeforeLinkSent(any));
        final result = verify(listener.onError(captureAny));

        result.called(1);
        expect(result.captured, [exception]);
      });
    });

    group('#awaitLink', () {
      test(
        'waits for a link from dynamic links and calls onBeforeSignIn',
        () async {
          provider.authListener = listener;
          provider.awaitLink('test@test.com');

          await untilCalled(listener.onBeforeSignIn());

          verify(listener.onBeforeSignIn()).called(1);
        },
      );

      test('calls onError if got not a valid sign in link', () async {
        provider.authListener = listener;
        provider.awaitLink('test@test.com');

        when(auth.isSignInWithEmailLink(any)).thenReturn(false);

        await untilCalled(listener.onError(any));

        final result = verify(listener.onError(captureAny));
        result.called(1);
        expect(result.captured[0], isA<FirebaseAuthException>());
        expect(result.captured[0].code, 'invalid-email-signin-link');
      });

      test(
        'calls FirebaseAuth#signInWithEmailLink when got a valid sign in link',
        () async {
          provider.authListener = listener;
          provider.awaitLink('test@test.com');

          await untilCalled(listener.onBeforeSignIn());

          final result = verify(
            auth.signInWithEmailLink(
              email: captureAnyNamed('email'),
              emailLink: captureAnyNamed('emailLink'),
            ),
          );

          result.called(1);

          expect(result.captured[0], 'test@test.com');
          expect(result.captured[1], 'https://test.com');
        },
      );

      test('calls onSignedIn when sign in succeded', () async {
        provider.authListener = listener;
        provider.awaitLink('test@test.com');

        await untilCalled(listener.onSignedIn(any));
        final result = verify(listener.onSignedIn(captureAny));

        result.called(1);
        expect(result.captured[0], isA<MockCredential>());
      });

      test('calls onError if sing in failed', () async {
        provider.authListener = listener;
        final exception = TestException();

        when(
          auth.signInWithEmailLink(
            email: anyNamed('email'),
            emailLink: anyNamed('emailLink'),
          ),
        ).thenThrow(exception);

        provider.awaitLink('test@test.com');

        await untilCalled(listener.onError(any));
        final result = verify(listener.onError(captureAny));

        result.called(1);
        expect(result.captured, [exception]);
      });
    });
  });

  group('EmailLinkFlowController', () {
    test('#sendLink calls EmailLinkAuthProvider#sendLink', () {
      final provider = MockProvider();
      ctrl = EmailLinkFlow(provider: provider, auth: auth);

      ctrl.sendLink('test@test.com');

      final result = verify(provider.sendLink(captureAny));

      result.called(1);
      expect(result.captured, ['test@test.com']);
    });
  });

  group('EmailLinkFlow', () {
    test('#onLinkSent calls EmailLinkAuthProvider#awaitLink', () {
      final provider = MockProvider();
      flow = EmailLinkFlow(provider: provider, auth: auth);

      flow.onLinkSent('test@test.com');

      final result = verify(provider.awaitLink(captureAny));

      result.called(1);
      expect(result.captured, ['test@test.com']);
    });
  });

  group('AuthFlowBuilder<EmailLinkFlowController>', () {
    testWidgets('emits correct states', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthFlowBuilder<EmailLinkAuthController>(
              auth: auth,
              provider: provider,
              listener: (prevState, state, ctrl) {
                if (prevState is Uninitialized) {
                  expect(state, isA<SendingLink>());
                }

                if (prevState is SendingLink) {
                  expect(state, isA<AwaitingDynamicLink>());
                }

                if (prevState is AwaitingDynamicLink) {
                  expect(state, isA<SigningIn>());
                }

                if (prevState is SignedIn) {
                  expect(state, isA<SignedIn>());
                }
              },
              builder: (context, state, ctrl, _) {
                return ElevatedButton(
                  child: const Text('Sign in'),
                  onPressed: () => ctrl.sendLink('tesT@test.com'),
                );
              },
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      await tester.tap(button);
      await tester.pump();
    });

    testWidgets('emits AuthFailed if an error occured', (tester) async {
      final exception = TestException();

      when(
        auth.signInWithEmailLink(
          email: anyNamed('email'),
          emailLink: anyNamed('emailLink'),
        ),
      ).thenThrow(exception);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthFlowBuilder<EmailLinkAuthController>(
              auth: auth,
              provider: provider,
              listener: (prevState, state, ctrl) {
                if (prevState is Uninitialized) {
                  expect(state, isA<SendingLink>());
                }

                if (prevState is SendingLink) {
                  expect(state, isA<AwaitingDynamicLink>());
                }

                if (prevState is AwaitingDynamicLink) {
                  expect(state, isA<SigningIn>());
                }

                if (prevState is SigningIn) {
                  expect(state, isA<AuthFailed>());
                  expect((state as AuthFailed).exception, exception);
                }
              },
              builder: (context, state, ctrl, _) {
                return ElevatedButton(
                  child: const Text('Sign in'),
                  onPressed: () => ctrl.sendLink('tesT@test.com'),
                );
              },
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      await tester.tap(button);
      await tester.pump();
    });
  });
}

class MockProvider extends Mock implements EmailLinkAuthProvider {
  @override
  void sendLink(String? email) {
    super.noSuchMethod(Invocation.method(#sendLink, [email]));
  }

  @override
  void awaitLink(String? email) {
    super.noSuchMethod(Invocation.method(#awaitLink, [email]));
  }
}

class MockListener extends Mock implements EmailLinkAuthListener {
  @override
  void onSignedIn(UserCredential? credential) {
    super.noSuchMethod(Invocation.method(#onSignedIn, [credential]));
  }

  @override
  void onBeforeLinkSent(String? email) {
    super.noSuchMethod(
      Invocation.method(#onBeforeLinkSent, [email]),
    );
  }

  @override
  void onLinkSent(String? email) {
    super.noSuchMethod(
      Invocation.method(#onLinkSent, [email]),
    );
  }

  @override
  void onError(Object? error) {
    super.noSuchMethod(
      Invocation.method(#onError, [error]),
    );
  }
}
