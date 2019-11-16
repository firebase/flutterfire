import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e2e/e2e.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can sign-in anonymously', (WidgetTester tester) async {
    final FirebaseAuth authUnderTest = FirebaseAuth.instance;
    final AuthResult result = await authUnderTest.signInAnonymously();
    expect(result, isNotNull);
  });
}
