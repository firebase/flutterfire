import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

import 'package:firebase_admob/firebase_admob.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Initialize Firebase Admob', (WidgetTester tester) async {
    expect(
      FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId),
      completion(isTrue),
    );
  });
}
