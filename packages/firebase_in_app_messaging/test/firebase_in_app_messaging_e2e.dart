import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('test triggerEvent', (WidgetTester tester) async {
    expect(
        () async =>
            await FirebaseInAppMessaging.instance.triggerEvent("foobar"),
        returnsNormally);
  });
}
