// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseVision', () {
    final List<MethodCall> log = <MethodCall>[];
    dynamic returnValue;

    setUp(() {
      FirebaseVision.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);

        switch (methodCall.method) {
          case 'ObjectDetector#processImage':
            return returnValue;
          default:
            return null;
        }
      });
      log.clear();
      FirebaseVision.nextHandle = 0;
    });

    group('$ObjectDetector', () {
      test('processImage', () async {
        final List<dynamic> labelData = <dynamic>[
          <dynamic, dynamic>{
            'left': 0.0,
            'top': 1.0,
            'width': 200.0,
            'height': 300.0,
            'trackingId': 1,
            'category': 'FOOD',
            'confidence': 0.8
          },
          <dynamic, dynamic>{
            'left': 0.0,
            'top': 2.0,
            'width': 150.0,
            'height': 200.0,
            'trackingId': 2,
            'category': 'HOME_GOOD',
            'confidence': 0.9
          },
        ];

        returnValue = labelData;

        final ObjectDetector detector = FirebaseVision.instance.objectDetector(
          const ObjectDetectorOptions(
              mode: ObjectDetectorMode.single, enableClassification: true),
        );

        final FirebaseVisionImage image =
            FirebaseVisionImage.fromFilePath('empty');

        final List<DetectedObject> detectedObjects =
            await detector.processImage(image);

        expect(log, <Matcher>[
          isMethodCall(
            'ObjectDetector#processImage',
            arguments: <String, dynamic>{
              'handle': 0,
              'type': 'file',
              'path': 'empty',
              'bytes': null,
              'metadata': null,
              'options': <String, dynamic>{
                'enableClassification': true,
                'enableMultipleObjects': false,
                'mode': 'single',
              },
            },
          ),
        ]);

        expect(detectedObjects[0].boundingBox.left, 0.0);
        expect(detectedObjects[0].boundingBox.top, 1.0);
        expect(detectedObjects[0].boundingBox.width, 200.0);
        expect(detectedObjects[0].boundingBox.height, 300.0);
        expect(detectedObjects[0].trackingId, 1);
        expect(detectedObjects[0].category, DetectedObjectCategory.FOOD);
        expect(detectedObjects[0].confidence, 0.8);

        expect(detectedObjects[1].boundingBox.left, 0.0);
        expect(detectedObjects[1].boundingBox.top, 2.0);
        expect(detectedObjects[1].boundingBox.width, 150.0);
        expect(detectedObjects[1].boundingBox.height, 200.0);
        expect(detectedObjects[1].trackingId, 2);
        expect(detectedObjects[1].category, DetectedObjectCategory.HOME_GOOD);
        expect(detectedObjects[1].confidence, 0.9);
      });

      test('processImage no objects detected', () async {
        returnValue = <dynamic>[];

        final ObjectDetector detector = FirebaseVision.instance.objectDetector(
          const ObjectDetectorOptions(),
        );
        final FirebaseVisionImage image =
            FirebaseVisionImage.fromFilePath('empty');

        final List<DetectedObject> objects = await detector.processImage(image);

        expect(log, <Matcher>[
          isMethodCall(
            'ObjectDetector#processImage',
            arguments: <String, dynamic>{
              'handle': 0,
              'type': 'file',
              'path': 'empty',
              'bytes': null,
              'metadata': null,
              'options': <String, dynamic>{
                'enableClassification': false,
                'enableMultipleObjects': false,
                'mode': 'stream',
              },
            },
          ),
        ]);

        expect(objects, isEmpty);
      });
    });
  });
}
