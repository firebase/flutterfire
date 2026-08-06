// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// CI shard entrypoint. `e2e_test.dart` still runs every suite in one process
// (Windows and local runs use it); CI splits that run across shards so a hang
// or flake costs one small job instead of the whole suite.
//
// This shard collects every suite that is not Auth, Storage, Database or
// Functions. The suites run in the same relative order as
// `e2e_test.dart`'s `runAllTests()`, since they still share one process here.

import 'package:flutter/foundation.dart';

import '../firebase_ai/firebase_ai_e2e_test.dart' as firebase_ai;
import '../firebase_analytics/firebase_analytics_e2e_test.dart'
    as firebase_analytics;
import '../firebase_app_check/firebase_app_check_e2e_test.dart'
    as firebase_app_check;
import '../firebase_app_installations/firebase_app_installations_e2e_test.dart'
    as firebase_app_installations;
import '../firebase_core/firebase_core_e2e_test.dart' as firebase_core;
import '../firebase_crashlytics/firebase_crashlytics_e2e_test.dart'
    as firebase_crashlytics;
import '../firebase_messaging/firebase_messaging_e2e_test.dart'
    as firebase_messaging;
import '../firebase_ml_model_downloader/firebase_ml_model_downloader_e2e_test.dart'
    as firebase_ml_model_downloader;
import '../firebase_performance/firebase_performance_e2e_test.dart'
    as firebase_performance;
import '../firebase_remote_config/firebase_remote_config_e2e_test.dart'
    as firebase_remote_config;

void main() {
  firebase_core.main();
  firebase_ai.main();
  firebase_crashlytics.main();
  firebase_analytics.main();
  firebase_app_installations.main();
  firebase_messaging.main();
  firebase_ml_model_downloader.main();
  firebase_performance.main();
  firebase_remote_config.main();

  if (!kIsWeb) {
    // App Check is throttled on web, so web runs it in its own job
    // (`web-app-check`, driven by the APP_CHECK_E2E dart-define). Matches the
    // `kIsWeb` branch of `e2e_test.dart`, which also leaves it out.
    firebase_app_check.main();
  }
}
