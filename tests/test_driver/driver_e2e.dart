// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;

import 'firebase_core/firebase_core_e2e.dart' as firebase_core;

void setupTests() {
  // Core first.
  firebase_core.setupTests();
  // All other tests.
  // firebase_auth.setupTests();
  // cloud_functions.setupTests();
  // firebase_storage.setupTests();
  // firebase_database.setupTests();
  // firebase_app_check.setupTests();
  // firebase_messaging.setupTests();
  // firebase_analytics.setupTests();
  // firebase_crashlytics.setupTests();
  // firebase_dynamic_links.setupTests();
  // firebase_remote_config.setupTests();
  // firebase_in_app_messaging.setupTests();
  // firebase_app_installations.setupTests();
  // firebase_ml_model_downloader.setupTests();
}

void main() => drive.main(setupTests);
