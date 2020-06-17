// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'firebase_ml_vision.dart';

void landmarkDetectorTests() {
  group('$LandmarkDetector', () {
    final LandmarkDetector detector = FirebaseVision.instance.landmarkDetector(
        const LandmarkDetectorOptions(
            maxResults: 10, modelType: LandmarkModelType.stable_model));

    test('processImage', () async {
      final String tmpFilename = await _loadImage('assets/test_rome.jpg');
      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFilePath(tmpFilename);

      final List<Landmark> landmarks = await detector.processImage(visionImage);

      expect(
          landmarks
              .map((landmark) => landmark.landmark)
              .toSet()
              .toList()
              .where((landmark) => landmark == 'Colosseum')
              .length,
          1);
    });

    test('close', () {
      expect(detector.close(), completes);
    });
  });
}
