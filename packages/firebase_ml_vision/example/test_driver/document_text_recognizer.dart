// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

part of 'firebase_ml_vision.dart';

void documentTextRecognizerTests() {
  group('$DocumentTextRecognizer', () {
    final recognizer = FirebaseVision.instance.cloudDocumentTextRecognizer();
    FirebaseVisionImage visionImage;

    setUp(() async {
      final tmpFilename = await _loadImage('assets/test_text.png');
      visionImage = FirebaseVisionImage.fromFilePath(tmpFilename);
    });

    test('processImage with default options', () async {
      final text = await recognizer.processImage(visionImage);

      expect(text.text, 'TEXT\n');
    });

    test('processImage with specified options', () async {
      final hintedLanguages = ['en', 'ru'];
      final options =
          CloudDocumentRecognizerOptions(hintedLanguages: hintedLanguages);
      FirebaseVision.instance.cloudDocumentTextRecognizer(options);
      final text = await recognizer.processImage(visionImage);

      expect(text.text, 'TEXT\n');
    });

    test('close', () {
      expect(recognizer.close(), completes);
    });
  });
}
