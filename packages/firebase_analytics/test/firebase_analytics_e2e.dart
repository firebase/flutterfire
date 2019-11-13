import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can log event', (WidgetTester tester) async {
    final Future<void> future = FirebaseAnalytics().logEvent(name: "foo_event");
    expect(future, completes);
  });
}
