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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'firebase_ml_model_downloader',
    () {
      setUpAll(() async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
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
