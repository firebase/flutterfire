// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

import 'package:drive/drive.dart';
import 'package:flutter/foundation.dart';
import '../firebase_default_options.dart';

const testModelName = 'mobilenet_v1_1_0_224';

void setupTests() {
  group(
    'firebase_ml_model_downloader',
    () {
      setUpAll(() async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      });

      group(
        'getModel',
        () {
          test(
            'should return successfully',
            () async {
              await expectLater(
                FirebaseModelDownloader.instance.getModel(
                  testModelName,
                  FirebaseModelDownloadType.latestModel,
                ),
                completes,
              );
            },
            retry: 2,
            timeout: const Timeout(Duration(seconds: 45)),
          );
        },
        // TODO(salakar): always fails on CI but works fine locally.
        skip: true,
      );

      group('listDownloadedModels', () {
        test('should return successfully', () async {
          await expectLater(
            FirebaseModelDownloader.instance.listDownloadedModels(),
            completes,
          );
        });
      });

      group('deleteModel throws', () {
        test(
          'should return successfully',
          () async {
            await expectLater(
              FirebaseModelDownloader.instance
                  .deleteDownloadedModel(testModelName),
              completes,
            );
          },
          // TODO(salakar): skipping since getModel fails on CI but works fine locally (can't delete without first getting the model).
          skip: true,
        );
      });
    },
    // Only supported on Android & iOS/macOS.
    skip: kIsWeb,
  );
}
