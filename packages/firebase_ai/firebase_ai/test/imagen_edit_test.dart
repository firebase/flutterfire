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

import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImagenReferenceImage', () {
    test('ImagenRawImage toJson', () {
      final image = ImagenRawImage(image: ImagenInlineImage(data: []));
      final json = image.toJson();
      expect(json, {
        'image': {'data': 'AA=='}
      });
    });

    test('ImagenRawMask toJson', () {
      final image = ImagenRawMask(mask: ImagenInlineImage(data: []));
      final json = image.toJson();
      expect(json, {
        'image': {'data': 'AA=='},
        'mask': {'type': 'user-provided'}
      });
    });

    test('ImagenSemanticMask toJson', () {
      final image = ImagenSemanticMask(classes: [1, 2]);
      final json = image.toJson();
      expect(json, {
        'mask': {'type': 'semantic'}
      });
    });

    test('ImagenBackgroundMask toJson', () {
      final image = ImagenBackgroundMask();
      final json = image.toJson();
      expect(json, {
        'mask': {'type': 'background'}
      });
    });

    test('ImagenForegroundMask toJson', () {
      final image = ImagenForegroundMask();
      final json = image.toJson();
      expect(json, {
        'mask': {'type': 'foreground'}
      });
    });

    test('ImagenSubjectReference toJson', () {
      final image = ImagenSubjectReference(
        image: ImagenInlineImage(data: []),
        referenceId: 1,
        description: 'a cat',
        subjectType: ImagenSubjectReferenceType.animal,
      );
      final json = image.toJson();
      expect(json, {
        'image': {'data': 'AA=='},
        'referenceId': 1,
        'subject': {'description': 'a cat', 'type': 'animal'}
      });
    });

    test('ImagenStyleReference toJson', () {
      final image = ImagenStyleReference(
        image: ImagenInlineImage(data: []),
        referenceId: 1,
        description: 'van gogh style',
      );
      final json = image.toJson();
      expect(json, {
        'image': {'data': 'AA=='},
        'referenceId': 1,
        'style': {'description': 'van gogh style'}
      });
    });

    test('ImagenControlReference toJson', () {
      final image = ImagenControlReference(
        controlType: ImagenControlType.canny,
        image: ImagenInlineImage(data: []),
        referenceId: 1,
      );
      final json = image.toJson();
      expect(json, {
        'image': {'data': 'AA=='},
        'referenceId': 1,
        'control': {'type': 'canny'}
      });
    });
  });
}
