// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may
// obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImagenReferenceImage', () {
    test('ImagenRawImage toJson', () {
      final image = ImagenRawImage(
          image: ImagenInlineImage(
              bytesBase64Encoded: Uint8List.fromList([]),
              mimeType: 'image/jpeg'),
          referenceId: 1);
      final json = image.toJson();
      expect(json, {
        'referenceType': 'REFERENCE_TYPE_RAW',
        'referenceId': 1,
        'referenceImage': {'bytesBase64Encoded': '', 'mimeType': 'image/jpeg'}
      });
    });

    test('ImagenRawMask toJson', () {
      final image = ImagenRawMask(
          mask: ImagenInlineImage(
              bytesBase64Encoded: Uint8List.fromList([]),
              mimeType: 'image/jpeg'),
          referenceId: 1);
      final json = image.toJson();
      expect(json, {
        'referenceType': 'REFERENCE_TYPE_MASK',
        'referenceId': 1,
        'referenceImage': {'bytesBase64Encoded': '', 'mimeType': 'image/jpeg'},
        'maskImageConfig': {'maskMode': 'MASK_MODE_USER_PROVIDED'}
      });
    });

    test('ImagenSemanticMask toJson', () {
      final image = ImagenSemanticMask(classes: [1, 2], referenceId: 1);
      final json = image.toJson();
      expect(json, {
        'referenceType': 'REFERENCE_TYPE_MASK',
        'referenceId': 1,
        'maskImageConfig': {
          'maskMode': 'MASK_MODE_SEMANTIC',
          'maskClasses': '[1,2]'
        }
      });
    });

    test('ImagenBackgroundMask toJson', () {
      final image = ImagenBackgroundMask(referenceId: 1);
      final json = image.toJson();
      expect(json, {
        'referenceType': 'REFERENCE_TYPE_MASK',
        'referenceId': 1,
        'maskImageConfig': {'maskMode': 'MASK_MODE_BACKGROUND'}
      });
    });

    test('ImagenForegroundMask toJson', () {
      final image = ImagenForegroundMask(referenceId: 1);
      final json = image.toJson();
      expect(json, {
        'referenceType': 'REFERENCE_TYPE_MASK',
        'referenceId': 1,
        'maskImageConfig': {'maskMode': 'MASK_MODE_FOREGROUND'}
      });
    });

    test('ImagenSubjectReference toJson', () {
      final image = ImagenSubjectReference(
        image: ImagenInlineImage(
            bytesBase64Encoded: Uint8List.fromList([]), mimeType: 'image/jpeg'),
        description: 'a cat',
        subjectType: ImagenSubjectReferenceType.animal,
        referenceId: 1,
      );
      final json = image.toJson();
      expect(json, {
        'referenceType': 'REFERENCE_TYPE_SUBJECT',
        'referenceId': 1,
        'referenceImage': {'bytesBase64Encoded': '', 'mimeType': 'image/jpeg'},
        'subjectImageConfig': {
          'subjectDescription': 'a cat',
          'subjectType': 'SUBJECT_TYPE_ANIMAL'
        }
      });
    });

    test('ImagenStyleReference toJson', () {
      final image = ImagenStyleReference(
        image: ImagenInlineImage(
            bytesBase64Encoded: Uint8List.fromList([]), mimeType: 'image/jpeg'),
        description: 'van gogh style',
        referenceId: 1,
      );
      final json = image.toJson();
      expect(json, {
        'referenceType': 'REFERENCE_TYPE_STYLE',
        'referenceId': 1,
        'referenceImage': {'mimeType': 'image/jpeg', 'bytesBase64Encoded': ''},
        'styleImageConfig': {'styleDescription': 'van gogh style'}
      });
    });

    test('ImagenControlReference toJson', () {
      final image = ImagenControlReference(
        controlType: ImagenControlType.canny,
        image: ImagenInlineImage(
            bytesBase64Encoded: Uint8List.fromList([]), mimeType: 'image/jpeg'),
        referenceId: 1,
      );
      final json = image.toJson();
      expect(json, {
        'referenceType': 'REFERENCE_TYPE_CONTROL',
        'referenceId': 1,
        'referenceImage': {'bytesBase64Encoded': '', 'mimeType': 'image/jpeg'},
        'controlImageConfig': {'controlType': 'CONTROL_TYPE_CANNY'}
      });
    });
  });
}
