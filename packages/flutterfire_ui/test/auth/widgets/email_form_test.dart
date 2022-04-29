import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/src/auth/widgets/internal/loading_button.dart';
import 'package:flutterfire_ui/src/auth/widgets/internal/universal_button.dart';

import '../../test_utils.dart';

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

    testWidgets('Has a Sign in button of outlined variant', (tester) async {
      await tester.pumpWidget(widget);
      expect(
        find.descendant(
          of: find.byWidgetPredicate((widget) => widget is LoadingButton && widget.variant == ButtonVariant.outlined),
          matching: find.text('Sign in'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Has a Forgot password button of text variant', (tester) async {
      await tester.pumpWidget(widget);
      expect(
        find.descendant(
          of: find.byWidgetPredicate((widget) => widget is UniversalButton && widget.variant == ButtonVariant.text),
          matching: find.text('Forgot password?'),
        ),
        findsOneWidget,
      );
    });
  });
}
