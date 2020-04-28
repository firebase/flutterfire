import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:e2e/e2e.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can get auto init enabled', (WidgetTester tester) async {
    final FirebaseMessaging messaging = FirebaseMessaging();
    final bool autoInitEnabled = await messaging.autoInitEnabled();
    expect(autoInitEnabled, isTrue);
  });
}
