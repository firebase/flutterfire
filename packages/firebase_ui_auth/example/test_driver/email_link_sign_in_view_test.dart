// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import 'utils.dart';

final actionCodeSettings = ActionCodeSettings(
  url: 'http://$testEmulatorHost:9099',
  handleCodeInApp: true,
  androidMinimumVersion: '1',
  androidPackageName: 'io.flutter.plugins.firebase_ui.firebase_ui_example',
  iOSBundleId: 'io.flutter.plugins.flutterfireui.flutterfireUIExample',
);

final emailLinkProvider = EmailLinkAuthProvider(
  actionCodeSettings: actionCodeSettings,
);

void main() {
  const labels = DefaultLocalizations();

  group('EmailLinkSignInView', () {
    testWidgets('validates email', (tester) async {
      await render(
        tester,
        EmailLinkSignInView(provider: emailLinkProvider),
      );

      final input = find.byType(TextFormField);
      await tester.enterText(input, 'notanemail');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pumpAndSettle();

      expect(find.text(labels.isNotAValidEmailErrorText), findsOneWidget);
    });

    testWidgets('sends a link to an email', (tester) async {
      await render(
        tester,
        EmailLinkSignInView(
          provider: emailLinkProvider,
        ),
      );

      final input = find.byType(TextFormField);
      await tester.enterText(input, 'test@test.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pumpAndSettle();

      expect(find.text(labels.signInWithEmailLinkSentText), findsOneWidget);
    });
  });
}
