// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import 'utils.dart';

void main() {
  const labels = DefaultLocalizations();

  group('EmailForm', () {
    testWidgets('validates email', (tester) async {
      await render(tester, const EmailForm());

      final inputs = find.byType(TextFormField);
      final emailInput = inputs.first;

      await tester.enterText(emailInput, 'not a vailid email');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text(labels.isNotAValidEmailErrorText), findsOneWidget);
    });

    testWidgets('requires password', (tester) async {
      await render(tester, const EmailForm());

      final inputs = find.byType(TextFormField);
      final emailInput = inputs.first;
      final passwordInput = inputs.at(1);

      await tester.enterText(emailInput, 'test@test.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.enterText(passwordInput, '');
      await tester.pumpAndSettle();

      expect(find.text(labels.passwordIsRequiredErrorText), findsOneWidget);
    });

    testWidgets(
      'shows password confirmation if action is sign up',
      (tester) async {
        await render(tester, const EmailForm(action: AuthAction.signUp));

        final inputs = find.byType(TextFormField);
        expect(inputs, findsNWidgets(3));
      },
    );

    testWidgets(
      'requires password confirmation',
      (tester) async {
        await render(tester, const EmailForm(action: AuthAction.signUp));

        final inputs = find.byType(TextFormField);

        await tester.enterText(inputs.at(0), 'test@test.com');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.enterText(inputs.at(1), 'password');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.enterText(inputs.at(2), '');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.pumpAndSettle();

        expect(
          find.text(labels.confirmPasswordIsRequiredErrorText),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'verifies that password confirmation matches password',
      (tester) async {
        await render(tester, const EmailForm(action: AuthAction.signUp));

        final inputs = find.byType(TextFormField);

        await tester.enterText(inputs.at(0), 'test@test.com');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.enterText(inputs.at(1), 'password');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.enterText(inputs.at(2), 'psasword');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.pumpAndSettle();

        expect(
          find.text(labels.confirmPasswordDoesNotMatchErrorText),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'registers new user',
      (tester) async {
        await render(tester, const EmailForm(action: AuthAction.signUp));

        final inputs = find.byType(TextFormField);

        await tester.enterText(inputs.at(0), 'test@test.com');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.enterText(inputs.at(1), 'password');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.enterText(inputs.at(2), 'password');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 1));

        expect(find.byType(LoadingIndicator), findsOneWidget);
        await tester.pumpAndSettle();

        expect(FirebaseAuth.instance.currentUser, isNotNull);
      },
    );

    testWidgets('shows wrong password error', (tester) async {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password',
      );

      await FirebaseAuth.instance.signOut();

      await render(tester, const EmailForm(action: AuthAction.signIn));

      final inputs = find.byType(TextFormField);

      await tester.enterText(inputs.at(0), 'test@test.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.enterText(inputs.at(1), 'wrongpassword');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pumpAndSettle();

      expect(find.text(labels.wrongOrNoPasswordErrorText), findsOneWidget);
    });

    testWidgets('signs in the user', (tester) async {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password',
      );

      await FirebaseAuth.instance.signOut();

      await render(
        tester,
        FirebaseUIActions(
          actions: [
            AuthStateChangeAction<SignedIn>((context, state) {
              expect(state, isA<SignedIn>());
              expect(state.user, isNotNull);
              expect(state.user!.email, equals('test@test.com'));
            })
          ],
          child: const EmailForm(action: AuthAction.signIn),
        ),
      );

      final inputs = find.byType(TextFormField);

      await tester.enterText(inputs.at(0), 'test@test.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.enterText(inputs.at(1), 'password');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pumpAndSettle();
    });

    testWidgets(
      'links email and password when auth action is link',
      (tester) async {
        await render(
          tester,
          FirebaseUIActions(
            actions: [
              AuthStateChangeAction<CredentialLinked>((context, state) {
                expect(state, isA<CredentialLinked>());
                expect(state.credential, isNotNull);
                expect(state.credential, isA<EmailAuthCredential>());
                expect(
                  (state.credential as EmailAuthCredential).email,
                  equals('test@test.com'),
                );
                expect(
                  (state.credential as EmailAuthCredential).password,
                  equals('password'),
                );

                expect(
                  FirebaseAuth.instance.currentUser!.email,
                  equals('test@test.com'),
                );
              })
            ],
            child: const EmailForm(action: AuthAction.link),
          ),
        );

        await FirebaseAuth.instance.signInAnonymously();

        final inputs = find.byType(TextFormField);

        await tester.enterText(inputs.at(0), 'test@test.com');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.enterText(inputs.at(1), 'password');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.enterText(inputs.at(2), 'password');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.pumpAndSettle();
      },
    );
  });
}
