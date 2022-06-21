import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firebase_analytics/firebase_analytics_e2e_test.dart'
    as firebase_analytics;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ignore: unnecessary_lambdas
  group('FlutterFire', () {
    firebase_analytics.main();
  });
}
