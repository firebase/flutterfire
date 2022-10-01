import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'cloud_functions/cloud_functions_e2e_test.dart' as cloud_functions;
import 'firebase_analytics/firebase_analytics_e2e_test.dart'
    as firebase_analytics;
import 'firebase_app_check/firebase_app_check_e2e_test.dart'
    as firebase_app_check;
import 'firebase_app_installations/firebase_app_installations_e2e_test.dart'
    as firebase_app_installations;
import 'firebase_auth/firebase_auth_e2e_test.dart' as firebase_auth;
import 'firebase_core/firebase_core_e2e_test.dart' as firebase_core;
import 'firebase_crashlytics/firebase_crashlytics_e2e_test.dart'
    as firebase_crashlytics;
import 'firebase_database/firebase_database_e2e_test.dart' as firebase_database;
import 'firebase_dynamic_links/firebase_dynamic_links_e2e_test.dart'
    as firebase_dynamic_links;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterFire', () {
    firebase_core.main();
    firebase_database.main();
    firebase_crashlytics.main();
    firebase_auth.main();
    firebase_analytics.main();
    cloud_functions.main();
    firebase_app_check.main();
    firebase_app_installations.main();
    firebase_dynamic_links.main();
  });
}
