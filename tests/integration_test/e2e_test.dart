import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firebase_core/firebase_core_e2e_test.dart' as firebase_core;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterFire', () {
    firebase_core.main();
  });
}
