// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('EmailForm', () {
    late Widget widget;

    setUp(() {
      widget = TestMaterialApp(
        child: EmailForm(
          auth: MockAuth(),
          action: AuthAction.signIn,
        ),
      );
    });

    testWidgets('has a Sign in button of outlined variant', (tester) async {
      await tester.pumpWidget(widget);
      final button = find.byType(OutlinedButton);

      expect(button, findsOneWidget);
    });

    testWidgets('has a Forgot password button of text variant', (tester) async {
      await tester.pumpWidget(widget);
      final button = find.byType(TextButton);

      expect(
        button,
        findsOneWidget,
      );
    });

    testWidgets('respects the EmailFormStyle', (tester) async {
      await tester.pumpWidget(
        FirebaseUITheme(
          styles: const {
            EmailFormStyle(signInButtonVariant: ButtonVariant.filled)
          },
          child: widget,
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
    });
  });
}
