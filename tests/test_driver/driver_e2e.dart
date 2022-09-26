// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;

import 'cloud_functions/cloud_functions_e2e.dart' as cloud_functions;
import 'firebase_analytics/firebase_analytics_e2e.dart' as firebase_analytics;
import 'firebase_app_check/firebase_app_check_e2e.dart' as firebase_app_check;
import 'firebase_app_installations/firebase_app_installations_e2e.dart'
    as firebase_app_installations;
import 'firebase_auth/firebase_auth_e2e.dart' as firebase_auth;
import 'firebase_core/firebase_core_e2e.dart' as firebase_core;
import 'firebase_crashlytics/firebase_crashlytics_e2e.dart'
    as firebase_crashlytics;
import 'firebase_database/firebase_database_e2e.dart' as firebase_database;
import 'firebase_dynamic_links/firebase_dynamic_links_e2e.dart'
    as firebase_dynamic_links;
//import 'firebase_in_app_messaging/firebase_in_app_messaging_e2e.dart'
//    as firebase_in_app_messaging;
import 'firebase_messaging/firebase_messaging_e2e.dart' as firebase_messaging;
import 'firebase_ml_model_downloader/firebase_ml_model_downloader_e2e.dart'
    as firebase_ml_model_downloader;
import 'firebase_remote_config/firebase_remote_config_e2e.dart'
    as firebase_remote_config;
import 'firebase_storage/firebase_storage_e2e.dart' as firebase_storage;

void setupTests() {
  // Core first.
  firebase_core.setupTests();
  // All other tests.
  firebase_auth.setupTests();
  cloud_functions.setupTests();
  firebase_storage.setupTests();
  firebase_database.setupTests();
  firebase_app_check.setupTests();
  firebase_messaging.setupTests();
  firebase_analytics.setupTests();
  firebase_crashlytics.setupTests();
  firebase_dynamic_links.setupTests();
  firebase_remote_config.setupTests();
  // firebase_in_app_messaging.setupTests();
  firebase_app_installations.setupTests();
  firebase_ml_model_downloader.setupTests();
}

void main() => drive.main(setupTests);
