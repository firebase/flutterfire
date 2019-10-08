// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:e2e/e2e.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CloudFunctions example widget test',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('hello world!: 0'), findsOneWidget);
    await tester.tap(find.byType(MaterialButton));
    await tester.pumpAndSettle();
    expect(find.text('hello world!: 1'), findsOneWidget);
  });
}
