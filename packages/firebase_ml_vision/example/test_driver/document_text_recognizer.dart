// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'firebase_ml_vision.dart';

void documentTextRecognizerTests() {
  group('$DocumentTextRecognizer', () {
    final DocumentTextRecognizer recognizer =
        FirebaseVision.instance.cloudDocumentTextRecognizer();

    test('processImage', () async {
      final tmpFilename = await _loadImage('assets/test_text.png');
      final visionImage = FirebaseVisionImage.fromFilePath(tmpFilename);
      final text = await recognizer.processImage(visionImage);

      expect(text.text, 'TEXT');
    });

    test('close', () {
      expect(recognizer.close(), completes);
    });
  });
}
