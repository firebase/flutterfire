// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// These tests intentionally exercise the deprecated package.
// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_ml_model_downloader_example/firebase_options.dart';

import 'report_test_results.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  reportTestResultsToDriver(binding);

  group(
    'firebase_ml_model_downloader',
    () {
      setUpAll(() async {
        // The native SDK may already have configured [DEFAULT] from a bundled        // GoogleService-Info.plist (the plugin registrant does this before any        // Dart runs). Dart's Firebase.apps cannot see that app until the first        // platform-channel call, so the only reliable guard is catching the        // duplicate-app error and keeping the natively configured instance.        try {          await Firebase.initializeApp(            options: DefaultFirebaseOptions.currentPlatform,          );        } on FirebaseException catch (e) {          if (e.code != 'duplicate-app') {            rethrow;          }        }
      });

      group('listDownloadedModels', () {
        test('should return successfully', () async {
          await expectLater(
            FirebaseModelDownloader.instance.listDownloadedModels(),
            completes,
          );
        });
      });
    },
    // Only supported on Android & iOS/macOS.
    skip: kIsWeb,
  );
}
