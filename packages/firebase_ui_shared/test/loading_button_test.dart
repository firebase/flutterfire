// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoadingButton', () {
    testWidgets('shows label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'label',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('label'), findsOneWidget);
    });

    testWidgets(
      'shows loading indicator when isLoading = true',
      (tester) async {
        var isLoading = false;
        var completer = Completer<void>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => LoadingButton(
                  label: 'button',
                  onTap: () async {
                    setState(() {
                      isLoading = !isLoading;
                    });

                    await completer.future;

                    setState(() {
                      isLoading = !isLoading;
                    });
                  },
                  isLoading: isLoading,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsNothing);
        await tester.tap(find.text('button'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        completer.complete();
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets('works under CupertinoApp', (tester) async {
      var isLoading = false;
      var completer = Completer<void>();

      await tester.pumpWidget(
        CupertinoApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => LoadingButton(
                label: 'button',
                onTap: () async {
                  setState(() {
                    isLoading = !isLoading;
                  });

                  await completer.future;

                  setState(() {
                    isLoading = !isLoading;
                  });
                },
                isLoading: isLoading,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoActivityIndicator), findsNothing);

      await tester.tap(find.text('button'));
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      completer.complete();
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });
  });
}
