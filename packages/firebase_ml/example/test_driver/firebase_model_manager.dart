// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'firebase_ml.dart';

void firebaseModelManagerTest() {
  group('$FirebaseModelManager', () {
    final FirebaseModelManager modelManager = FirebaseModelManager.instance;
    final String MODEL_NAME = 'myModelName';
    final String INVALID_MODEL_NAME = 'invalidModelName';

    test('downloadModel and get its file', () async {
      var model = FirebaseCustomRemoteModel(MODEL_NAME);

      var conditions = FirebaseModelDownloadConditions(
          androidRequireWifi: true, iosAllowCellularAccess: false);

      await modelManager.download(model, conditions);

      var isModelDownloaded = await modelManager.isModelDownloaded(model);
      expect(isModelDownloaded, isTrue);

      var modelFile = await modelManager.getLatestModelFile(model);
      expect(modelFile, isNotNull);
      expect(modelFile.path.contains(MODEL_NAME), isTrue);
    });

    test('throw an error when model is not downloaded', () async {
      var model = FirebaseCustomRemoteModel(INVALID_MODEL_NAME);

      var conditions = FirebaseModelDownloadConditions();

      expect(() => modelManager.download(model, conditions),
          throwsA(isA<PlatformException>()));
    });

    test('throw an error when model get file of non-existent model', () async {
      var model = FirebaseCustomRemoteModel(INVALID_MODEL_NAME);

      expect(() => modelManager.getLatestModelFile(model),
          throwsA(isA<PlatformException>()));
    });
  });
}
