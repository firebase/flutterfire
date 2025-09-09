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
    if (safetySettings?.personFilterLevel case final personFilterLevel?)
      'personGeneration': personFilterLevel.toJson(),
    if (safetySettings?.safetyFilterLevel case final safetyFilterLevel?)
      'safetySetting': safetyFilterLevel.toJson(),
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
  });
}
