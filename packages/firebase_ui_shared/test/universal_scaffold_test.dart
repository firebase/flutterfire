import 'package:firebase_ui_shared/src/universal_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UniversalScaffold', () {
    testWidgets('uses Scaffold under MaterialApp', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UniversalScaffold(
            body: Text('body'),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets(
      'uses CupertinoPageScaffold under CupertinoApp',
      (tester) async {
        await tester.pumpWidget(
          const CupertinoApp(
            home: UniversalScaffold(
              body: Text('body'),
            ),
          ),
        );

        expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      },
    );
  });
}
