// @dart=2.9

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:e2e/e2e.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Enable performance collection', (WidgetTester tester) async {
    final FirebasePerformance performance = FirebasePerformance.instance;
    await performance.setPerformanceCollectionEnabled(true);
    expect(performance.isPerformanceCollectionEnabled(), completion(isTrue));
  });
}
