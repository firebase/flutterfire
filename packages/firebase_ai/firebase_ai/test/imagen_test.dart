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
import 'package:firebase_ai/src/imagen_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
