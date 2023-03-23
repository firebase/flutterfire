// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const icon = UniversalIcon(
    cupertinoIcon: CupertinoIcons.check_mark,
    materialIcon: Icons.check,
  );
  group('UniversalIcon', () {
    testWidgets('uses cupertinoIcon under CupertinoApp', (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: UniversalScaffold(body: icon),
        ),
      );

      expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('uses materialIcon under MaterialApp', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UniversalScaffold(body: icon),
        ),
      );

      expect(find.byIcon(CupertinoIcons.check_mark), findsNothing);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
