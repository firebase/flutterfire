// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
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
import 'firebase_messaging/firebase_messaging_e2e_test.dart'
    as firebase_messaging;
import 'firebase_ml_model_downloader/firebase_ml_model_downloader_e2e_test.dart'
    as firebase_ml_model_downloader;
import 'firebase_performance/firebase_performance_e2e_test.dart'
    as firebase_performance;
import 'firebase_remote_config/firebase_remote_config_e2e_test.dart'
    as firebase_remote_config;
import 'firebase_storage/firebase_storage_e2e_test.dart' as firebase_storage;

// Github Actions environment variable
// ignore: do_not_use_environment
final isCI = const String.fromEnvironment('CI').isNotEmpty;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterFire', () {
    // ignore: do_not_use_environment
    if (const String.fromEnvironment('LOCAL_WEB_E2E') == 'true') {
      // for running web e2e locally which doesn't suffer throttling issues
      runAllTests();
      return;
    }

    // ignore: do_not_use_environment
    if (const String.fromEnvironment('APP_CHECK_E2E') == 'true') {
      // app check has been separated out for web due to throttling issues
      firebase_app_check.main();
      return;
    }
    if (kIsWeb) {
      firebase_core.main();
      firebase_auth.main();
      firebase_database.main();
      firebase_crashlytics.main();
      firebase_analytics.main();
      cloud_functions.main();
      firebase_app_installations.main();
      firebase_messaging.main();
      firebase_ml_model_downloader.main();
      firebase_performance.main();
      firebase_remote_config.main();
      firebase_storage.main();
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        runAllTests();
        break;
      case TargetPlatform.windows:
        firebase_core.main();
        firebase_auth.main();
        firebase_remote_config.main();
        firebase_storage.main();
        break;
      default:
        throw UnsupportedError(
          '$defaultTargetPlatform is not supported on FlutterFire E2E tests',
        );
    }
  });
}

void runAllTests() {
  firebase_core.main();
  firebase_auth.main();
  firebase_database.main();
  firebase_crashlytics.main();
  firebase_analytics.main();
  cloud_functions.main();
  firebase_app_installations.main();
  firebase_messaging.main();
  firebase_ml_model_downloader.main();
  firebase_performance.main();
  firebase_remote_config.main();
  firebase_storage.main();
  firebase_app_check.main();
}
