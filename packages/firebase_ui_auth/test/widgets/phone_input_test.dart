// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_auth/src/widgets/phone_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneInput', () {
    testWidgets('shows default country and country code', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhoneInput(initialCountryCode: 'US'),
          ),
        ),
      );

      expect(find.text('United States'), findsOneWidget);
    });

    testWidgets(
      'prompts to select a country if initialCountryCode is null',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PhoneInput(initialCountryCode: null),
            ),
          ),
        );

        expect(find.text('Choose a country'), findsOneWidget);
      },
    );
  });
}
