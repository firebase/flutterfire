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

import 'package:firebase_ai/src/error.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart'
    show VertexAIException, VertexAISdkException;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VertexAI Exceptions', () {
    test('VertexAIException toString', () {
      final exception = VertexAIException('Test message');
      expect(exception.toString(), 'VertexAIException: Test message');
    });

    test('InvalidApiKey toString', () {
      final exception = InvalidApiKey('Invalid API key provided.');
      expect(exception.toString(), 'Invalid API key provided.');
    });

    test('UnsupportedUserLocation message', () {
      final exception = UnsupportedUserLocation();
      expect(
          exception.message, 'User location is not supported for the API use.');
    });

    test('ServiceApiNotEnabled message', () {
      final exception = ServiceApiNotEnabled('projects/test-project');
      expect(
          exception.message,
          'The Vertex AI in Firebase SDK requires the Vertex AI in Firebase API '
          '(`firebasevertexai.googleapis.com`) to be enabled in your Firebase project. Enable this API '
          'by visiting the Firebase Console at '
          'https://console.firebase.google.com/project/test-project/genai '
          'and clicking "Get started". If you enabled this API recently, wait a few minutes for the '
          'action to propagate to our systems and then retry.');
    });

    test('QuotaExceeded toString', () {
      final exception = QuotaExceeded('Quota for this API has been exceeded.');
      expect(exception.toString(), 'Quota for this API has been exceeded.');
    });

    test('ServerException toString', () {
      final exception = ServerException('Server error occurred.');
      expect(exception.toString(), 'Server error occurred.');
    });

    test('VertexAISdkException toString', () {
      final exception = VertexAISdkException('SDK failed to parse response.');
      expect(
          exception.toString(),
          'SDK failed to parse response.\n'
          'This indicates a problem with the Vertex AI in Firebase SDK. '
          'Try updating to the latest version '
          '(https://pub.dev/packages/firebase_ai/versions), '
          'or file an issue at '
          'https://github.com/firebase/flutterfire/issues.');
    });

    test('ImagenImagesBlockedException toString', () {
      final exception =
          ImagenImagesBlockedException('All images were blocked.');
      expect(exception.toString(), 'All images were blocked.');
    });

    test('LiveWebSocketClosedException toString - DEADLINE_EXCEEDED', () {
      final exception = LiveWebSocketClosedException(
          'DEADLINE_EXCEEDED: Connection timed out.');
      expect(exception.toString(),
          'The current live session has expired. Please start a new session.');
    });

    test('LiveWebSocketClosedException toString - RESOURCE_EXHAUSTED', () {
      final exception = LiveWebSocketClosedException(
          'RESOURCE_EXHAUSTED: Too many connections.');
      expect(
          exception.toString(),
          'You have exceeded the maximum number of concurrent sessions. '
          'Please close other sessions and try again later.');
    });

    test('LiveWebSocketClosedException toString - Other', () {
      final exception =
          LiveWebSocketClosedException('WebSocket connection closed.');
      expect(exception.toString(), 'WebSocket connection closed.');
    });

    group('parseError', () {
      test('parses API_KEY_INVALID', () {
        final json = {
          'message': 'Invalid API key',
          'details': [
            {'reason': 'API_KEY_INVALID'}
          ]
        };
        final exception = parseError(json);
        expect(exception, isInstanceOf<InvalidApiKey>());
        expect(exception.message, 'Invalid API key');
      });

      test('parses UNSUPPORTED_USER_LOCATION', () {
        final json = {
          'message': 'User location is not supported for the API use.'
        };
        final exception = parseError(json);
        expect(exception, isInstanceOf<UnsupportedUserLocation>());
      });

      test('parses QUOTA_EXCEEDED', () {
        final json = {'message': 'Quota exceeded: Limit reached.'};
        final exception = parseError(json);
        expect(exception, isInstanceOf<QuotaExceeded>());
        expect(exception.message, 'Quota exceeded: Limit reached.');
      });

      test('parses SERVICE_API_NOT_ENABLED', () {
        final json = {
          'message': 'API not enabled',
          'status': 'PERMISSION_DENIED',
          'details': [
            {
              'metadata': {
                'service': 'firebasevertexai.googleapis.com',
                'consumer': 'projects/my-project-id',
              }
            }
          ]
        };
        final exception = parseError(json);
        expect(exception, isInstanceOf<ServiceApiNotEnabled>());
        expect(
            (exception as ServiceApiNotEnabled).message,
            'The Vertex AI in Firebase SDK requires the Vertex AI in Firebase API '
            '(`firebasevertexai.googleapis.com`) to be enabled in your Firebase project. Enable this API '
            'by visiting the Firebase Console at '
            'https://console.firebase.google.com/project/my-project-id/genai '
            'and clicking "Get started". If you enabled this API recently, wait a few minutes for the '
            'action to propagate to our systems and then retry.');
      });

      test('parses SERVER_ERROR', () {
        final json = {'message': 'Internal server error.'};
        final exception = parseError(json);
        expect(exception, isInstanceOf<ServerException>());
        expect(exception.message, 'Internal server error.');
      });

      test('parses UNHANDLED_FORMAT', () {
        final json = {'unexpected': 'format'};
        expect(() => parseError(json),
            throwsA(isInstanceOf<VertexAISdkException>()));
      });
    });
  });
}
