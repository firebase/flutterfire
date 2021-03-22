// @dart=2.9

import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();
  FirebaseInAppMessaging fiam;

  setUp(() {
    fiam = FirebaseInAppMessaging();
  });

  testWidgets('triggerEvent', (WidgetTester tester) async {
    expect(fiam.triggerEvent('someEvent'), completes);
  });

  testWidgets('logging', (WidgetTester tester) async {
    expect(fiam.setMessagesSuppressed(true), completes);
    expect(fiam.setAutomaticDataCollectionEnabled(true), completes);
  });
}
