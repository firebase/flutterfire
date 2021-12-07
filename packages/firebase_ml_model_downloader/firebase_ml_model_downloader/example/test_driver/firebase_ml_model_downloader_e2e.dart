// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

const kModelName = "mobilenet_v1_1_0_224";
void testsMain() {
  group('$FirebaseModelDownloader', () {
    late FirebaseModelDownloader mlModelDownloader;

    setUpAll(() async {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
          appId: '1:448618578101:ios:3a3c8ae9cb0b6408ac3efc',
          messagingSenderId: '448618578101',
          projectId: 'react-native-firebase-testing',
          authDomain: 'react-native-firebase-testing.firebaseapp.com',
          iosClientId:
              '448618578101-m53gtqfnqipj12pts10590l37npccd2r.apps.googleusercontent.com',
        ),
      );
      mlModelDownloader = FirebaseModelDownloader.instance;
    });

    group('getModel', () {
      test('should return successfully', () async {
        expectLater(
            mlModelDownloader.getModel(
                kModelName, FirebaseModelDownloadType.latestModel),
            completes);
      });
    });

    group('listDownloadedModels', () {
      test('should return successfully', () async {
        expectLater(mlModelDownloader.listDownloadedModels(), completes);
      });
    });

    group('deleteModel throws', () {
      test('should return successfully', () async {
        expectLater(
            mlModelDownloader.deleteDownloadedModel(kModelName), completes);
      });
    });
  });
}

void main() => drive.main(testsMain);
