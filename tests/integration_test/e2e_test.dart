// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'cloud_functions/cloud_functions_e2e_test.dart' as cloud_functions;
import 'firebase_app_installations/firebase_app_installations_e2e_test.dart'
    as firebase_app_installations;
import 'firebase_analytics/firebase_analytics_e2e_test.dart'
    as firebase_analytics;
import 'firebase_core/firebase_core_e2e_test.dart' as firebase_core;
import 'firebase_crashlytics/firebase_crashlytics_e2e_test.dart'
    as firebase_crashlytics;
import 'firebase_auth/firebase_auth_e2e_test.dart' as firebase_auth;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterFire', () {
    cloud_functions.main();
    firebase_app_installations.main();
    firebase_analytics.main();
    firebase_core.main();
    firebase_crashlytics.main();
    firebase_auth.main();
  });
}
