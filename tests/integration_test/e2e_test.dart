import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firebase_core/firebase_core_e2e_test.dart' as firebase_core;
import 'firebase_analytics/firebase_analytics_e2e_test.dart'
    as firebase_analytics;
import 'cloud_functions/cloud_functions_e2e_test.dart' as cloud_functions;
import 'firebase_app_check/firebase_app_check_e2e_test.dart'
    as firebase_app_check;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterFire', () {
    firebase_core.main();
    firebase_analytics.main();
    cloud_functions.main();
    firebase_app_check.main();
  });
}
