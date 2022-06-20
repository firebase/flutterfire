import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'cloud_functions/cloud_functions_e2e_test.dart' as cloud_functions;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ignore: unnecessary_lambdas
  group('FlutterFire', () {
    cloud_functions.main();
  });
}
