// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'firebase_ml_vision.dart';

void textRecognizerTests() {
  FirebaseVisionImage visionImage;

  setUp(() async {
    final String tmpFilename = await _loadImage('assets/test_text.png');
    visionImage = FirebaseVisionImage.fromFilePath(tmpFilename);
  });

  group('$TextRecognizer', () {
    final TextRecognizer recognizer = FirebaseVision.instance.textRecognizer();

    test('processImage', () async {
      final VisionText text = await recognizer.processImage(visionImage);

      expect(text.text, 'TEXT');
    });

    test('close', () {
      expect(recognizer.close(), completes);
    });
  });

  group('Cloud $TextRecognizer', () {
    final TextRecognizer recognizer =
        FirebaseVision.instance.cloudTextRecognizer();

    test('processImage with default options', () async {
      final VisionText text = await recognizer.processImage(visionImage);

      expect(text.text, 'TEXT\n');
    });

    test('close', () {
      expect(recognizer.close(), completes);
    });

    test('processImage with specified options', () async {
      var languageHints = ['en', 'ru'];
      var textModelType = CloudTextModelType.dense;

      var options = CloudTextRecognizerOptions(
          hintedLanguages: languageHints, textModelType: textModelType);
      final TextRecognizer recognizerWithOptions =
          FirebaseVision.instance.cloudTextRecognizer(options);

      final VisionText text =
          await recognizerWithOptions.processImage(visionImage);

      expect(text.text, 'TEXT\n');

      recognizer.close();
    });
  });
}
