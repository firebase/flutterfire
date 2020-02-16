import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can run transaction', (WidgetTester tester) async {
    final result = await Firestore.instance
        .runTransaction((Transaction transaction) async {});
    expect(result, isMap);
  });
}
