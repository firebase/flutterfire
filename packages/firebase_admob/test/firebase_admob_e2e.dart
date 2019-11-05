import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:e2e/e2e.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Is true true?', (WidgetTester tester) async {
    expect(
      FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId),
      completion(isTrue),
    );
  });
}
