// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

part of 'firebase_ml_custom.dart';

void firebaseModelManagerTest() {
  group('$FirebaseModelManager', () {
    final FirebaseModelManager modelManager = FirebaseModelManager.instance;
    const MODEL_NAME = 'mobilenet_v1_1_0_224';
    const INVALID_MODEL_NAME = 'invalidModelName';

    test('download model and get its file', () async {
      final model = FirebaseCustomRemoteModel(MODEL_NAME);

      final conditions = FirebaseModelDownloadConditions(
          androidRequireWifi: true, iosAllowCellularAccess: false);

      await modelManager.download(model, conditions);

      final isModelDownloaded = await modelManager.isModelDownloaded(model);

      expect(isModelDownloaded, isTrue);

      final modelFile = await modelManager.getLatestModelFile(model);

      expect(modelFile, isNotNull);
      expect(modelFile.path.contains(MODEL_NAME), isTrue);
    });

    test('throw an error when model is not downloaded', () async {
      final model = FirebaseCustomRemoteModel(INVALID_MODEL_NAME);

      final conditions = FirebaseModelDownloadConditions();

      if (Platform.isAndroid) {
        expect(
            modelManager.download(model, conditions),
            throwsA(isA<PlatformException>().having(
                (e) => e.toString().toLowerCase(),
                'message',
                contains('failed to schedule the download task'))));
      }

      if (Platform.isIOS) {
        expect(
            modelManager.download(model, conditions),
            throwsA(isA<PlatformException>()
                .having((e) => e.toString(), 'message', contains('404'))));
      }
    });

    test('throw an error when model get file of non-existent model', () {
      final model = FirebaseCustomRemoteModel(INVALID_MODEL_NAME);

      expect(
          modelManager.getLatestModelFile(model),
          throwsA(isA<PlatformException>().having(
              (e) => e.toString(),
              'message',
              contains('make sure your custom remote model is downloaded'))));
    });
  });
}
