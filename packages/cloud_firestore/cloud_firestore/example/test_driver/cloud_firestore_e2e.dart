import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can initialize the plugin', (WidgetTester tester) async {
    Firestore firestore = Firestore();
    expect(firestore, isNotNull);
  });
}
