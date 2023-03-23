// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_shared/src/universal_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UniversalButton', () {
    testWidgets('renders text as content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UniversalButton(text: 'text'),
          ),
        ),
      );

      expect(find.text('text'), findsOneWidget);

      await tester.pumpWidget(
        const CupertinoApp(
          home: Scaffold(
            body: UniversalButton(text: 'text'),
          ),
        ),
      );

      expect(find.text('text'), findsOneWidget);
    });

    testWidgets('prefers child over text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UniversalButton(
              text: 'text',
              child: Text('child'),
            ),
          ),
        ),
      );

      expect(find.text('text'), findsNothing);
      expect(find.text('child'), findsOneWidget);

      await tester.pumpWidget(
        const CupertinoApp(
          home: Scaffold(
            body: UniversalButton(
              text: 'text',
              child: Text('child'),
            ),
          ),
        ),
      );

      expect(find.text('text'), findsNothing);
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets(
      'renders TextButton under MaterialApp when variant is ButtonVariant.text',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: UniversalButton(
                text: 'text',
                variant: ButtonVariant.text,
              ),
            ),
          ),
        );

        expect(find.byType(TextButton), findsOneWidget);
      },
    );

    testWidgets(
      'renders OutlinedButton under MaterialApp when variant '
      'is ButtonVariant.text',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: UniversalButton(
                text: 'text',
                variant: ButtonVariant.outlined,
              ),
            ),
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
      },
    );

    testWidgets(
      'renders ElevatedButton under MaterialApp when variant '
      'is ButtonVariant.text',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: UniversalButton(
                text: 'text',
                variant: ButtonVariant.filled,
              ),
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
      },
    );

    testWidgets(
      'renders CupertinoButton under CupertinoApp',
      (tester) async {
        await tester.pumpWidget(
          const CupertinoApp(
            home: Scaffold(
              body: UniversalButton(
                text: 'text',
                variant: ButtonVariant.text,
              ),
            ),
          ),
        );

        expect(find.byType(CupertinoButton), findsOneWidget);

        await tester.pumpWidget(
          const CupertinoApp(
            home: Scaffold(
              body: UniversalButton(
                text: 'text',
                variant: ButtonVariant.filled,
              ),
            ),
          ),
        );

        expect(find.byType(CupertinoButton), findsOneWidget);

        await tester.pumpWidget(
          const CupertinoApp(
            home: Scaffold(
              body: UniversalButton(
                text: 'text',
                variant: ButtonVariant.outlined,
              ),
            ),
          ),
        );

        expect(find.byType(CupertinoButton), findsOneWidget);
      },
    );

    testWidgets('calls onPressed when button is tapped', (tester) async {
      var pressed = 0;
      void onPressed() {
        pressed++;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalButton(
              text: 'press me',
              onPressed: onPressed,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(UniversalButton));
      await tester.pumpAndSettle();

      expect(pressed, 1);

      await tester.pumpWidget(
        CupertinoApp(
          home: Scaffold(
            body: UniversalButton(
              text: 'press me',
              onPressed: onPressed,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(UniversalButton));
      await tester.pumpAndSettle();

      expect(pressed, 2);
    });
  });
}
