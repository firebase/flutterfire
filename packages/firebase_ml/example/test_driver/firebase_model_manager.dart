// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'firebase_ml.dart';

void firebaseModelManagerTest() {
  group('$FirebaseModelManager', () {
    final FirebaseModelManager modelManager = FirebaseModelManager.instance;

    test('downloadModel', () async {
      FirebaseCustomRemoteModel model =
          FirebaseCustomRemoteModel('image_classification');
      assert(model != null);

      FirebaseModelDownloadConditions conditions =
          FirebaseModelDownloadConditions(requireWifi: true);

      await modelManager.download(model, conditions);
      expect(model.modelHash, isNotNull);

      var isModelDownloaded = await modelManager.isModelDownloaded(model);
      expect(isModelDownloaded, isTrue);

      var modelFile = await modelManager.getLatestModelFile(model);
      expect(modelFile, isNotNull);
      expect(modelFile.path.runtimeType, ''.runtimeType);
    });
  });
}
