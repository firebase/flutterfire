import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/src/auth/widgets/internal/loading_button.dart';
import 'package:flutterfire_ui/src/auth/widgets/internal/universal_button.dart';
import 'package:mockito/mockito.dart';

import '../../test_utils.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('EmailForm', () {
    late Widget widget;

    setUp(() {
      widget = TestMaterialApp(
        child: EmailForm(
          auth: MockFirebaseAuth(),
          action: AuthAction.signIn,
        ),
      );
    });

    testWidgets('has a Sign in button of outlined variant', (tester) async {
      await tester.pumpWidget(widget);
      expect(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is LoadingButton &&
                widget.variant == ButtonVariant.outlined,
          ),
          matching: find.text('Sign in'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has a Forgot password button of text variant', (tester) async {
      await tester.pumpWidget(widget);
      expect(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is UniversalButton &&
                widget.variant == ButtonVariant.text,
          ),
          matching: find.text('Forgot password?'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('respects the EmailFormStyle', (tester) async {
      await tester.pumpWidget(
        FlutterFireUITheme(
          styles: const {
            EmailFormStyle(signInButtonVariant: ButtonVariant.filled)
          },
          child: widget,
        ),
      );

      expect(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is UniversalButton &&
                widget.variant == ButtonVariant.filled,
          ),
          matching: find.text('Sign in'),
        ),
        findsOneWidget,
      );
    });
  });
}
