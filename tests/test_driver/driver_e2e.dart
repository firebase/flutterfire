// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'cloud_functions/cloud_functions_e2e.dart' as cloud_functions;
import 'firebase_auth/firebase_auth_e2e.dart' as firebase_auth;
import 'firebase_core/firebase_core_e2e.dart' as firebase_core;
import 'firebase_analytics/firebase_analytics_e2e.dart' as firebase_analytics;

void setupTests() {
  // Core first.
  firebase_core.setupTests();
  // All other tests.
  cloud_functions.setupTests();
  firebase_auth.setupTests();
  firebase_analytics.setupTests();
}

void main() => drive.main(setupTests);
