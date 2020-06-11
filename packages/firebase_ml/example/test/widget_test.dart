import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebaseml_example/main.dart';

void main() {
  testWidgets('Verify Plugin output', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is Text &&
                           widget.data.startsWith('Plugin output:'),
      ),
      findsOneWidget,
    );
  });
}
