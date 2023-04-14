// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const home = Scaffold(
    body: LoadingIndicator(
      size: 30,
      borderWidth: 2,
    ),
  );

  group('LoadingIndicator', () {
    testWidgets(
      'uses CircularProgressIndicator under MaterialApp',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: home));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'uses CupertinoActivityIndicator under MaterialApp',
      (tester) async {
        await tester.pumpWidget(const CupertinoApp(home: home));
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      },
    );
  });
}
