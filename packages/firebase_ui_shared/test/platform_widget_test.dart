// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_shared/src/platform_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class PlatformAware extends PlatformWidget {
  const PlatformAware({super.key});

  @override
  Widget buildCupertino(BuildContext context) {
    return const Text("Cupertino");
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return const Text("Material");
  }

  @override
  Widget? buildWrapper(BuildContext context, Widget child) {
    return Container(
      key: const ValueKey('wrapper'),
      color: Colors.black,
      child: child,
    );
  }
}

void main() {
  group('PlatformWidget', () {
    testWidgets(
      'builds cupertino widget if CupertinoApp is used',
      (tester) async {
        await tester.pumpWidget(
          const CupertinoApp(
            home: PlatformAware(),
          ),
        );

        expect(find.text('Cupertino'), findsOneWidget);
        expect(find.text('Material'), findsNothing);
      },
    );

    testWidgets(
      'builds material widget if MaterialApp is used',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: PlatformAware(),
          ),
        );

        expect(find.text('Cupertino'), findsNothing);
        expect(find.text('Material'), findsOneWidget);
      },
    );

    testWidgets(
      'builds wrapper widget if it is implemented',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: PlatformAware(),
          ),
        );

        expect(find.byKey(const ValueKey('wrapper')), findsOneWidget);

        await tester.pumpWidget(
          const CupertinoApp(
            home: PlatformAware(),
          ),
        );

        expect(find.byKey(const ValueKey('wrapper')), findsOneWidget);
      },
    );
  });
}
