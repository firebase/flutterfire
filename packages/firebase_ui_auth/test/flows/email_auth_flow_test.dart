// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';

void main() {
  late EmailAuthFlow flow;
  late MockAuth auth;
  late MockAuthListener mockListener;

  late EmailAuthProvider provider;

  setUp(() {
    auth = MockAuth();
    provider = EmailAuthProvider();

    flow = EmailAuthFlow(
      action: AuthAction.signIn,
      auth: auth,
      provider: provider,
    );

    mockListener = MockAuthListener();
  });

  tearDown(() {
    // simulate sign out
    auth.user = null;
  });

  group('EmailAuthProvider', () {
    test('has correct provider id', () {
      expect(flow.provider.providerId, 'password');
    });

    group('#authenticate', () {
      test('calls signInWithCredential', () {
        flow.provider.authenticate('email', 'password');
        final result = verify(auth.signInWithCredential(captureAny));

        result.called(1);

        expect(result.captured[0], isA<EmailAuthCredential>());
        expect(result.captured[0].email, 'email');
        expect(result.captured[0].password, 'password');
      });

      test('calls createUserWithEmailAndPassword if action is signUp', () {
        provider.authenticate('email', 'password', AuthAction.signUp);
        provider.auth = MockAuth();

        final result = verify(
          auth.createUserWithEmailAndPassword(
            email: captureAnyNamed('email'),
            password: captureAnyNamed('password'),
          ),
        )..called(1);

        expect(result.captured, ['email', 'password']);
      });

      test('calls linkWithCredential if action is link', () {
        final user = MockUser();
        auth.user = user;

        provider.authenticate('email', 'password', AuthAction.link);
        verify(user.linkWithCredential(any)).called(1);
      });

      test('calls onBeforeSignIn', () {
        flow.provider.authListener = mockListener;
        flow.provider.authenticate('email', 'password');

        verify(mockListener.onBeforeSignIn()).called(1);
      });

      test('calls onBeforeCredentialLinked if action is link', () {
        flow.provider.authListener = mockListener;
        flow.provider.authenticate('email', 'password', AuthAction.link);

        verify(mockListener.onCredentialReceived(any)).called(1);
      });

      test('calls onSignedIn', () async {
        flow.provider.authListener = mockListener;

        final cred = MockCredential();
        when(auth.signInWithCredential(any)).thenAnswer((_) async {
          return cred;
        });

        flow.provider.authenticate('email', 'password');

        await untilCalled(auth.signInWithCredential(any));
        final result = verify(mockListener.onSignedIn(captureAny))..called(1);

        expect(result.captured[0], cred);
      });

      test('calls onCredentialLinked if action is link', () async {
        flow.provider.authListener = mockListener;

        final user = MockUser();
        auth.user = user;

        flow.provider.authenticate('email', 'password', AuthAction.link);

        await untilCalled(user.linkWithCredential(any));
        final result = verify(mockListener.onCredentialLinked(captureAny))
          ..called(1);

        expect(result.captured[0], isA<EmailAuthCredential>());
        expect(result.captured[0].email, 'email');
        expect(result.captured[0].password, 'password');
      });

      test('calls onError if error occured', () async {
        final exception = TestException();
        when(auth.signInWithCredential(any)).thenThrow(exception);

        flow.provider.authListener = mockListener;
        flow.provider.authenticate('email', 'password');

        await untilCalled(auth.signInWithCredential(any));
        final result = verify(mockListener.onError(captureAny))..called(1);

        expect(result.captured[0], exception);
      });
    });
  });

  group('EmailAuthController', () {
    group('#setEmailAndPassword', () {
      test('calls EmailAuthProvider#signIn', () {
        final provider = MockProvider();
        final ctrl = EmailAuthFlow(provider: provider, auth: MockAuth());

        ctrl.setEmailAndPassword('email', 'password');

        final result = verify(
          provider.authenticate(
            captureAny,
            captureAny,
            captureAny,
          ),
        )..called(1);

        expect(result.captured[0], 'email');
        expect(result.captured[1], 'password');
        expect(result.captured[2], AuthAction.signIn);
      });
    });
  });

  group('AuthFlowBuilder<EmailAuthController>', () {
    testWidgets('emits correct states during sign in', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthFlowBuilder<EmailAuthController>(
              auth: auth,
              listener: (prevState, state, ctrl) {
                if (prevState is AwaitingEmailAndPassword) {
                  expect(state, isA<SigningIn>());
                }

                if (prevState is SigningIn) {
                  expect(state, isA<SignedIn>());
                }
              },
              builder: (context, state, ctrl, _) {
                return ElevatedButton(
                  child: const Text('Sign in'),
                  onPressed: () => ctrl.setEmailAndPassword(
                    'email',
                    'password',
                  ),
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

    testWidgets('emits AuthFailed if error occured', (tester) async {
      final exception = TestException();
      when(auth.signInWithCredential(any)).thenThrow(exception);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthFlowBuilder<EmailAuthController>(
              auth: auth,
              listener: (prevState, state, ctrl) {
                if (prevState is AwaitingEmailAndPassword) {
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
                  onPressed: () => ctrl.setEmailAndPassword(
                    'email',
                    'password',
                  ),
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

class MockProvider extends Mock implements EmailAuthProvider {
  @override
  void authenticate(
    String? email,
    String? password, [
    AuthAction? action = AuthAction.signIn,
  ]) {
    super.noSuchMethod(Invocation.method(#signIn, [email, password, action]));
  }
}

class MockAuthListener extends Mock implements EmailAuthListener {
  @override
  void onCredentialReceived(AuthCredential? credential) {
    super.noSuchMethod(
      Invocation.method(
        #onBeforeCredentialLinked,
        [credential],
      ),
    );
  }

  @override
  void onCredentialLinked(AuthCredential? credential) {
    super.noSuchMethod(
      Invocation.method(
        #onCredentialLinked,
        [credential],
      ),
    );
  }

  @override
  void onSignedIn(UserCredential? credential) {
    super.noSuchMethod(
      Invocation.method(
        #onSignedIn,
        [credential],
      ),
    );
  }

  @override
  void onError(Object? error) {
    super.noSuchMethod(Invocation.method(#onError, [error]));
  }
}
