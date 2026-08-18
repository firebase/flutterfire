// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
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

// Copied from imagen_model.dart for testing purposes as it is a private method.
Map<String, Object?> generateImagenRequest(
  String prompt, {
  String? gcsUri,
  ImagenGenerationConfig? generationConfig,
  ImagenSafetySettings? safetySettings,
}) {
  final parameters = <String, Object?>{
    if (gcsUri != null) 'storageUri': gcsUri,
    'sampleCount': generationConfig?.numberOfImages ?? 1,
    if (generationConfig?.aspectRatio case final aspectRatio?)
      'aspectRatio': aspectRatio.toJson(),
    if (generationConfig?.negativePrompt case final negativePrompt?)
      'negativePrompt': negativePrompt,
    if (generationConfig?.addWatermark case final addWatermark?)
      'addWatermark': addWatermark,
    if (generationConfig?.imageFormat case final imageFormat?)
      'outputOption': imageFormat.toJson(),
    if (safetySettings case final safetySettings?) ...safetySettings.toJson(),
    'includeRaiReason': true,
    'includeSafetyAttributes': true,
  };

  return {
    'instances': [
      {'prompt': prompt}
    ],
    'parameters': parameters,
  };
}

// Copied from imagen_model.dart for testing
Map<String, Object?> generateImagenEditRequest(
  List<ImagenReferenceImage> images,
  String prompt, {
  bool useVertexBackend = true, // Added for testing the throw
  ImagenEditingConfig? config,
  ImagenGenerationConfig? generationConfig,
  ImagenSafetySettings? safetySettings,
}) {
  if (!useVertexBackend) {
    throw FirebaseAIException(
        'Image editing for Imagen is only supported on Vertex AI backend.');
  }
  final parameters = <String, Object?>{
    'sampleCount': generationConfig?.numberOfImages ?? 1,
    if (config?.editMode case final editMode?) 'editMode': editMode.toJson(),
    if (config?.editSteps case final editSteps?)
      'editConfig': {'baseSteps': editSteps},
    if (generationConfig?.negativePrompt case final negativePrompt?)
      'negativePrompt': negativePrompt,
    if (generationConfig?.addWatermark case final addWatermark?)
      'addWatermark': addWatermark,
    if (generationConfig?.imageFormat case final imageFormat?)
      'outputOption': imageFormat.toJson(),
    if (safetySettings case final safetySettings?) ...safetySettings.toJson(),
    'includeRaiReason': true,
    'includeSafetyAttributes': true,
  };

  return {
    'parameters': parameters,
    'instances': [
      {
        'prompt': prompt,
        'referenceImages': images.asMap().entries.map((entry) {
          int index = entry.key;
          var image = entry.value;
          return image.toJson(referenceIdOverrideIfNull: index + images.length);
        }).toList(),
      }
    ],
  };
}

void main() {
  group('ImagenModel request generation', () {
    group('generateImagenRequest', () {
      test('creates a basic request with default parameters', () {
        final request = generateImagenRequest('a beautiful landscape');
        expect(request['instances'], [
          {'prompt': 'a beautiful landscape'}
        ]);
        final params = request['parameters']! as Map<String, Object?>;
        expect(params['sampleCount'], 1);
        expect(params['includeRaiReason'], true);
        expect(params['includeSafetyAttributes'], true);
        expect(params.containsKey('storageUri'), isFalse);
        expect(params.containsKey('aspectRatio'), isFalse);
        expect(params.containsKey('negativePrompt'), isFalse);
        expect(params.containsKey('addWatermark'), isFalse);
        expect(params.containsKey('outputOption'), isFalse);
        expect(params.containsKey('personGeneration'), isFalse);
        expect(params.containsKey('safetySetting'), isFalse);
      });

      test('includes all generation config parameters', () {
        final config = ImagenGenerationConfig(
          numberOfImages: 4,
          aspectRatio: ImagenAspectRatio.landscape16x9,
          negativePrompt: 'text, watermark',
          addWatermark: false,
          imageFormat: ImagenFormat.png(),
        );
        final request = generateImagenRequest('a futuristic city',
            generationConfig: config);
        final params = request['parameters']! as Map<String, Object?>;
        expect(params['sampleCount'], 4);
        expect(params['aspectRatio'], '16:9');
        expect(params['negativePrompt'], 'text, watermark');
        expect(params['addWatermark'], false);
        expect(params['outputOption'], {'mimeType': 'image/png'});
        expect(params['includeRaiReason'], true);
        expect(params['includeSafetyAttributes'], true);
      });

      test('includes all safety settings parameters', () {
        final settings = ImagenSafetySettings(
          ImagenSafetyFilterLevel.blockNone,
          ImagenPersonFilterLevel.allowAdult,
        );
        final request =
            generateImagenRequest('a robot army', safetySettings: settings);
        final params = request['parameters']! as Map<String, Object?>;
        expect(params['personGeneration'], 'allow_adult');
        expect(params['safetySetting'], 'block_none');
        expect(params['includeRaiReason'], true);
        expect(params['includeSafetyAttributes'], true);
      });

      test('includes gcsUri when provided', () {
        const uri = 'gs://my-test-bucket/image.png';
        final request = generateImagenRequest('a photo of a cat', gcsUri: uri);
        final params = request['parameters']! as Map<String, Object?>;
        expect(params['storageUri'], uri);
        expect(params['includeRaiReason'], true);
        expect(params['includeSafetyAttributes'], true);
      });

      test('combines all parameters correctly', () {
        final config = ImagenGenerationConfig(
          numberOfImages: 2,
          negativePrompt: 'dark',
        );
        final settings = ImagenSafetySettings(
          ImagenSafetyFilterLevel.blockLowAndAbove,
          ImagenPersonFilterLevel.blockAll,
        );
        const uri = 'gs://my-test-bucket/output/';
        final request = generateImagenRequest(
          'a sunny beach',
          gcsUri: uri,
          generationConfig: config,
          safetySettings: settings,
        );

        final params = request['parameters']! as Map<String, Object?>;
        expect(params['storageUri'], uri);
        expect(params['sampleCount'], 2);
        expect(params['negativePrompt'], 'dark');
        expect(params['safetySetting'], 'block_low_and_above');
        expect(params['includeRaiReason'], true);
        expect(params['includeSafetyAttributes'], true);
        expect(request['instances'], [
          {'prompt': 'a sunny beach'}
        ]);
      });
    });

    group('generateImagenEditRequest', () {
      late List<ImagenReferenceImage> referenceImages;

      setUp(() {
        final dummyBytes = Uint8List.fromList([1, 2, 3]);
        final dummyInlineImage = ImagenInlineImage(
            bytesBase64Encoded: dummyBytes, mimeType: 'image/jpeg');
        referenceImages = [ImagenRawImage(image: dummyInlineImage)];
      });

      test('creates a basic edit request', () {
        final request =
            generateImagenEditRequest(referenceImages, 'make it sunny');
        final params = request['parameters']! as Map<String, Object?>;
        expect(params['sampleCount'], 1);
        expect(params.containsKey('editMode'), isFalse);
        expect(params['includeRaiReason'], true);
        expect(params['includeSafetyAttributes'], true);

        final instances = request['instances']! as List;
        expect(instances, hasLength(1));
        final instance = instances.first as Map<String, Object?>;
        expect(instance['prompt'], 'make it sunny');
        expect(instance['referenceImages'], isNotNull);
      });

      test('does not include aspectRatio from generation config', () {
        final config = ImagenGenerationConfig(
          numberOfImages: 2, // This should be included as sampleCount
          aspectRatio: ImagenAspectRatio.square1x1, // This should be ignored
        );
        final request = generateImagenEditRequest(
          referenceImages,
          'add a rainbow',
          generationConfig: config,
        );
        final params = request['parameters']! as Map<String, Object?>;
        expect(params['sampleCount'], 2);
        expect(params.containsKey('aspectRatio'), isFalse,
            reason: 'aspectRatio is not a valid parameter for edit requests.');
        expect(params['includeRaiReason'], true);
        expect(params['includeSafetyAttributes'], true);
      });

      test('includes other valid generation config values', () {
        final config = ImagenGenerationConfig(
          negativePrompt: 'rain',
          addWatermark: true,
          imageFormat: ImagenFormat.jpeg(),
        );
        final request = generateImagenEditRequest(
          referenceImages,
          'make it brighter',
          generationConfig: config,
        );
        final params = request['parameters']! as Map<String, Object?>;
        expect(params['negativePrompt'], 'rain');
        expect(params['addWatermark'], true);
        expect(params['outputOption'], {'mimeType': 'image/jpeg'});
        expect(params['includeRaiReason'], true);
        expect(params['includeSafetyAttributes'], true);
      });

      test('includes editing config', () {
        final editConfig = ImagenEditingConfig(
          editMode: ImagenEditMode.inpaintInsertion,
          editSteps: 10,
        );
        final request = generateImagenEditRequest(
          referenceImages,
          'remove the background',
          config: editConfig,
        );
        final params = request['parameters']! as Map<String, Object?>;
        expect(params['editMode'], 'EDIT_MODE_INPAINT_INSERTION');
        expect(params['editConfig'], {'baseSteps': 10});
        expect(params['includeRaiReason'], true);
        expect(params['includeSafetyAttributes'], true);
      });

      test('throws exception if not using Vertex backend', () {
        expect(
          () => generateImagenEditRequest(
            referenceImages,
            'a prompt',
            useVertexBackend: false,
          ),
          throwsA(isA<FirebaseAIException>()),
        );
      });
    });
  });
}
