import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('get version', (WidgetTester tester) async {
    final String version = await Crashlytics.instance.getVersion();
    expect(version, isNotNull);
  });
}
