import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firebase_app_installations/firebase_app_installations_e2e_test.dart'
    as firebase_app_installations;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ignore: unnecessary_lambdas
  group('FlutterFire', () {
    firebase_app_installations.main();
  });
}
