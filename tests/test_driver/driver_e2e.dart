// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'cloud_functions/cloud_functions_e2e.dart' as cloud_functions;
import 'firebase_auth/firebase_auth_e2e.dart' as firebase_auth;
import 'firebase_core/firebase_core_e2e.dart' as firebase_core;
import 'firebase_analytics/firebase_analytics_e2e.dart' as firebase_analytics;
import 'firebase_app_installations/firebase_app_installations_e2e.dart'
    as firebase_app_installations;
import 'firebase_in_app_messaging/firebase_in_app_messaging_e2e.dart'
    as firebase_in_app_messaging;

void setupTests() {
  // Core first.
  firebase_core.setupTests();
  // All other tests.
  firebase_auth.setupTests();
  cloud_functions.setupTests();
  firebase_analytics.setupTests();
  firebase_in_app_messaging.setupTests();
  firebase_app_installations.setupTests();
}

void main() => drive.main(setupTests);
