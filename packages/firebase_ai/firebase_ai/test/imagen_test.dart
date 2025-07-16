// Copyright 2025 Google LLC
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

import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/src/error.dart';
import 'package:firebase_ai/src/imagen_api.dart';
import 'package:firebase_ai/src/imagen_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImagenSafetyFilterLevel', () {
    test('toJson returns correct string values', () {
      expect(ImagenSafetyFilterLevel.blockLowAndAbove.toJson(),
          'block_low_and_above');
      expect(ImagenSafetyFilterLevel.blockMediumAndAbove.toJson(),
          'block_medium_and_above');
      expect(ImagenSafetyFilterLevel.blockOnlyHigh.toJson(), 'block_only_high');
      expect(ImagenSafetyFilterLevel.blockNone.toJson(), 'block_none');
    });
  });

  group('ImagenPersonFilterLevel', () {
    test('toJson returns correct string values', () {
      expect(ImagenPersonFilterLevel.blockAll.toJson(), 'dont_allow');
      expect(ImagenPersonFilterLevel.allowAdult.toJson(), 'allow_adult');
      expect(ImagenPersonFilterLevel.allowAll.toJson(), 'allow_all');
    });
  });

  group('ImagenSafetySettings', () {
    test('toJson with both values', () {
      final settings = ImagenSafetySettings(
        ImagenSafetyFilterLevel.blockMediumAndAbove,
        ImagenPersonFilterLevel.allowAdult,
      );
      final json = settings.toJson();
      expect(json, {
        'safetySetting': 'block_medium_and_above',
        'personGeneration': 'allow_adult',
      });
    });

    test('toJson with only safetyFilterLevel', () {
      final settings = ImagenSafetySettings(
        ImagenSafetyFilterLevel.blockMediumAndAbove,
        null,
      );
      final json = settings.toJson();
      expect(json, {
        'safetySetting': 'block_medium_and_above',
      });
    });

    test('toJson with only personFilterLevel', () {
      final settings = ImagenSafetySettings(
        null,
        ImagenPersonFilterLevel.allowAdult,
      );
      final json = settings.toJson();
      expect(json, {
        'personGeneration': 'allow_adult',
      });
    });

    test('toJson with null values', () {
      final settings = ImagenSafetySettings(null, null);
      final json = settings.toJson();
      expect(json, {});
    });
  });

  group('ImagenAspectRatio', () {
    test('toJson returns correct string values', () {
      expect(ImagenAspectRatio.square1x1.toJson(), '1:1');
      expect(ImagenAspectRatio.portrait9x16.toJson(), '9:16');
      expect(ImagenAspectRatio.landscape16x9.toJson(), '16:9');
      expect(ImagenAspectRatio.portrait3x4.toJson(), '3:4');
      expect(ImagenAspectRatio.landscape4x3.toJson(), '4:3');
    });
  });

  group('ImagenFormat', () {
    test('constructor with mimeType and compressionQuality', () {
      final format = ImagenFormat('image/jpeg', 85);
      expect(format.mimeType, 'image/jpeg');
      expect(format.compressionQuality, 85);
    });

    test('png constructor', () {
      final format = ImagenFormat.png();
      expect(format.mimeType, 'image/png');
      expect(format.compressionQuality, isNull);
    });

    test('jpeg constructor with compressionQuality', () {
      final format = ImagenFormat.jpeg(compressionQuality: 90);
      expect(format.mimeType, 'image/jpeg');
      expect(format.compressionQuality, 90);
    });

    test('jpeg constructor without compressionQuality', () {
      final format = ImagenFormat.jpeg();
      expect(format.mimeType, 'image/jpeg');
      expect(format.compressionQuality, isNull);
    });

    test('jpeg constructor logs warning for out of range compressionQuality',
        () {
      ImagenFormat.jpeg(compressionQuality: 150);
      ImagenFormat.jpeg(compressionQuality: -10);
    });

    test('toJson with mimeType only', () {
      final format = ImagenFormat('image/png', null);
      final json = format.toJson();
      expect(json, {
        'mimeType': 'image/png',
      });
    });

    test('toJson with mimeType and compressionQuality', () {
      final format = ImagenFormat('image/jpeg', 85);
      final json = format.toJson();
      expect(json, {
        'mimeType': 'image/jpeg',
        'compressionQuality': 85,
      });
    });

    test('png toJson', () {
      final format = ImagenFormat.png();
      final json = format.toJson();
      expect(json, {
        'mimeType': 'image/png',
      });
    });

    test('jpeg toJson with compressionQuality', () {
      final format = ImagenFormat.jpeg(compressionQuality: 90);
      final json = format.toJson();
      expect(json, {
        'mimeType': 'image/jpeg',
        'compressionQuality': 90,
      });
    });
  });

  group('ImagenGenerationConfig', () {
    test('constructor with all parameters', () {
      final config = ImagenGenerationConfig(
        numberOfImages: 4,
        negativePrompt: 'blurry, low quality',
        aspectRatio: ImagenAspectRatio.landscape16x9,
        imageFormat: ImagenFormat.jpeg(compressionQuality: 85),
        addWatermark: true,
      );
      expect(config.numberOfImages, 4);
      expect(config.negativePrompt, 'blurry, low quality');
      expect(config.aspectRatio, ImagenAspectRatio.landscape16x9);
      expect(config.imageFormat?.mimeType, 'image/jpeg');
      expect(config.imageFormat?.compressionQuality, 85);
      expect(config.addWatermark, true);
    });

    test('constructor with minimal parameters', () {
      final config = ImagenGenerationConfig();
      expect(config.numberOfImages, isNull);
      expect(config.negativePrompt, isNull);
      expect(config.aspectRatio, isNull);
      expect(config.imageFormat, isNull);
      expect(config.addWatermark, isNull);
    });

    test('toJson with all parameters', () {
      final config = ImagenGenerationConfig(
        numberOfImages: 4,
        negativePrompt: 'blurry, low quality',
        aspectRatio: ImagenAspectRatio.landscape16x9,
        imageFormat: ImagenFormat.jpeg(compressionQuality: 85),
        addWatermark: true,
      );
      final json = config.toJson();
      expect(json, {
        'negativePrompt': 'blurry, low quality',
        'numberOfImages': 4,
        'aspectRatio': '16:9',
        'addWatermark': true,
        'outputOptions': {
          'mimeType': 'image/jpeg',
          'compressionQuality': 85,
        },
      });
    });

    test('toJson with only negativePrompt', () {
      final config = ImagenGenerationConfig(
        negativePrompt: 'blurry, low quality',
      );
      final json = config.toJson();
      expect(json, {
        'negativePrompt': 'blurry, low quality',
      });
    });

    test('toJson with only numberOfImages', () {
      final config = ImagenGenerationConfig(
        numberOfImages: 2,
      );
      final json = config.toJson();
      expect(json, {
        'numberOfImages': 2,
      });
    });

    test('toJson with only aspectRatio', () {
      final config = ImagenGenerationConfig(
        aspectRatio: ImagenAspectRatio.portrait9x16,
      );
      final json = config.toJson();
      expect(json, {
        'aspectRatio': '9:16',
      });
    });

    test('toJson with only imageFormat', () {
      final config = ImagenGenerationConfig(
        imageFormat: ImagenFormat.png(),
      );
      final json = config.toJson();
      expect(json, {
        'outputOptions': {
          'mimeType': 'image/png',
        },
      });
    });

    test('toJson with only addWatermark', () {
      final config = ImagenGenerationConfig(
        addWatermark: false,
      );
      final json = config.toJson();
      expect(json, {
        'addWatermark': false,
      });
    });

    test('toJson with empty config', () {
      final config = ImagenGenerationConfig();
      final json = config.toJson();
      expect(json, {});
    });

    test('toJson with imageFormat uses correct key name "outputOptions"', () {
      final config = ImagenGenerationConfig(
        imageFormat: ImagenFormat.jpeg(compressionQuality: 75),
      );
      final json = config.toJson();

      expect(json.containsKey('outputOptions'), isTrue);
      expect(json.containsKey('outputOption'), isFalse);

      expect(json['outputOptions'], {
        'mimeType': 'image/jpeg',
        'compressionQuality': 75,
      });
    });
  });

  group('ImagenInlineImage', () {
    test('fromJson with valid base64', () {
      final json = {
        'mimeType': 'image/png',
        'bytesBase64Encoded':
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='
      };
      final image = ImagenInlineImage.fromJson(json);
      expect(image.mimeType, 'image/png');
      expect(image.bytesBase64Encoded, isA<Uint8List>());
      expect(image.bytesBase64Encoded, isNotEmpty);
    });

    test('fromJson with invalid base64', () {
      final json = {
        'mimeType': 'image/png',
        'bytesBase64Encoded': 'invalid_base64_string'
      };
      // Expect that the constructor throws an exception.
      expect(() => ImagenInlineImage.fromJson(json), throwsFormatException);
    });

    test('toJson', () {
      final image = ImagenInlineImage(
        mimeType: 'image/png',
        bytesBase64Encoded: Uint8List.fromList(utf8.encode('Hello, world!')),
      );
      final json = image.toJson();
      expect(json, {
        'mimeType': 'image/png',
        'bytesBase64Encoded': 'SGVsbG8sIHdvcmxkIQ==',
      });
    });
  });

  group('ImagenGCSImage', () {
    test('fromJson', () {
      final json = {
        'mimeType': 'image/jpeg',
        'gcsUri':
            'gs://test-project-id-1234.firebasestorage.app/images/1234567890123/sample_0.jpg'
      };
      final image = ImagenGCSImage.fromJson(json);
      expect(image.mimeType, 'image/jpeg');
      expect(image.gcsUri,
          'gs://test-project-id-1234.firebasestorage.app/images/1234567890123/sample_0.jpg');
    });

    test('toJson', () {
      final image = ImagenGCSImage(
        mimeType: 'image/jpeg',
        gcsUri:
            'gs://test-project-id-1234.firebasestorage.app/images/1234567890123/sample_0.jpg',
      );
      final json = image.toJson();
      expect(json, {
        'mimeType': 'image/jpeg',
        'gcsUri':
            'gs://test-project-id-1234.firebasestorage.app/images/1234567890123/sample_0.jpg',
      });
    });
  });

  group('ImagenGenerationResponse', () {
    test('fromJson with gcsUri', () {
      final json = {
        'predictions': [
          {
            'mimeType': 'image/jpeg',
            'gcsUri':
                'gs://test-project-id-1234.firebasestorage.app/images/1234567890123/sample_0.jpg'
          },
          {
            'mimeType': 'image/jpeg',
            'gcsUri':
                'gs://test-project-id-1234.firebasestorage.app/images/1234567890123/sample_1.jpg'
          },
          {
            'mimeType': 'image/jpeg',
            'gcsUri':
                'gs://test-project-id-1234.firebasestorage.app/images/1234567890123/sample_2.jpg'
          },
          {
            'mimeType': 'image/jpeg',
            'gcsUri':
                'gs://test-project-id-1234.firebasestorage.app/images/1234567890123/sample_3.jpg'
          }
        ]
      };
      final response = ImagenGenerationResponse<ImagenGCSImage>.fromJson(json);
      expect(response.images, isA<List<ImagenGCSImage>>());
      expect(response.images.length, 4);
      expect(response.filteredReason, isNull);
    });

    test('fromJson with bytesBase64Encoded', () {
      final json = {
        'predictions': [
          {
            'mimeType': 'image/jpeg',
            'bytesBase64Encoded': 'SGVsbG8sIHdvcmxkIQ=='
          },
          {
            'mimeType': 'image/jpeg',
            'bytesBase64Encoded': 'SGVsbG8sIHdvcmxkIQ=='
          },
          {
            'mimeType': 'image/jpeg',
            'bytesBase64Encoded': 'SGVsbG8sIHdvcmxkIQ=='
          },
          {
            'mimeType': 'image/jpeg',
            'bytesBase64Encoded': 'SGVsbG8sIHdvcmxkIQ=='
          }
        ]
      };
      final response =
          ImagenGenerationResponse<ImagenInlineImage>.fromJson(json);
      expect(response.images, isA<List<ImagenInlineImage>>());
      expect(response.images.length, 4);
      expect(response.filteredReason, isNull);
    });

    test('fromJson with bytesBase64Encoded and raiFilteredReason', () {
      final json = {
        'predictions': [
          {
            'mimeType': 'image/png',
            'bytesBase64Encoded':
                'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='
          },
          {
            'mimeType': 'image/png',
            'bytesBase64Encoded':
                'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='
          },
          {
            'raiFilteredReason':
                'Your current safety filter threshold filtered out 2 generated images. You will not be charged for blocked images. Try rephrasing the prompt. If you think this was an error, send feedback.'
          }
        ]
      };
      final response =
          ImagenGenerationResponse<ImagenInlineImage>.fromJson(json);
      expect(response.images, isA<List<ImagenInlineImage>>());
      expect(response.images.length, 2);
      expect(response.filteredReason,
          'Your current safety filter threshold filtered out 2 generated images. You will not be charged for blocked images. Try rephrasing the prompt. If you think this was an error, send feedback.');
    });

    test('fromJson with only raiFilteredReason', () {
      final json = {
        'predictions': [
          {
            'raiFilteredReason':
                "Unable to show generated images. All images were filtered out because they violated Vertex AI's usage guidelines. You will not be charged for blocked images. Try rephrasing the prompt. If you think this was an error, send feedback. Support codes: 39322892, 29310472"
          }
        ]
      };
      // Expect that the constructor throws an exception.
      expect(() => ImagenGenerationResponse<ImagenInlineImage>.fromJson(json),
          throwsA(isA<ImagenImagesBlockedException>()));
    });

    test('fromJson with empty predictions', () {
      final json = {'predictions': {}};
      // Expect that the constructor throws an exception.
      expect(() => ImagenGenerationResponse<ImagenInlineImage>.fromJson(json),
          throwsA(isA<ServerException>()));
    });

    test('fromJson with unsupported type', () {
      final json = {
        'predictions': [
          {
            'mimeType': 'image/jpeg',
            'gcsUri':
                'gs://test-project-id-1234.firebasestorage.app/images/1234567890123/sample_0.jpg'
          },
        ]
      };
      // Expect that the constructor throws an exception.
      expect(() => ImagenGenerationResponse<ImagenImage>.fromJson(json),
          throwsA(isA<ArgumentError>()));
    });
  });

  group('parseImagenGenerationResponse', () {
    test('with valid response', () {
      final json = {
        'predictions': [
          {
            'mimeType': 'image/jpeg',
            'gcsUri':
                'gs://test-project-id-1234.firebasestorage.app/images/1234567890123/sample_0.jpg'
          },
        ]
      };
      final response = parseImagenGenerationResponse<ImagenGCSImage>(json);
      expect(response.images, isA<List<ImagenGCSImage>>());
      expect(response.images.length, 1);
      expect(response.filteredReason, isNull);
    });

    test('with error', () {
      final json = {
        'error': {
          'code': 400,
          'message':
              "Image generation failed with the following error: The prompt could not be submitted. This prompt contains sensitive words that violate Google's Responsible AI practices. Try rephrasing the prompt. If you think this was an error, send feedback. Support codes: 42876398",
          'status': 'INVALID_ARGUMENT'
        }
      };
      // Expect that the function throws an exception.
      expect(() => parseImagenGenerationResponse<ImagenGCSImage>(json),
          throwsA(isA<ServerException>()));
    });
  });
}
