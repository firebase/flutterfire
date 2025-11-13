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

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_ai/src/base_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'mock.dart';

// A response for generateContent and generateContentStream.
final _arbitraryGenerateContentResponse = {
  'candidates': [
    {
      'content': {
        'role': 'model',
        'parts': [
          {'text': 'Some response'},
        ],
      },
    },
  ],
};

// A response for Imagen's generateImages.
final _arbitraryImagenResponse = {
  'predictions': [
    {
      'mimeType': 'image/png',
      'bytesBase64Encoded':
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='
    }
  ]
};

void main() {
  setupFirebaseVertexAIMocks();
  late FirebaseApp app;
  setUpAll(() async {
    app = await Firebase.initializeApp();
  });

  group('TemplateGenerativeModel', () {
    const templateId = 'my-template';
    const location = 'us-central1';

    TemplateGenerativeModel createModel(http.Client client,
        {bool useVertexBackend = true}) {
      // ignore: invalid_use_of_internal_member
      return createTestTemplateGenerativeModel(
        app: app,
        location: location,
        useVertexBackend: useVertexBackend,
        client: client,
      );
    }

    test('generateContent can make successful request', () async {
      final mockHttp = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(request.url.path,
            endsWith('/templates/$templateId:templateGenerateContent'));
        expect(body['inputs'], {'prompt': 'Some prompt'});
        return http.Response(jsonEncode(_arbitraryGenerateContentResponse), 200,
            headers: {'content-type': 'application/json'});
      });

      final model = createModel(mockHttp);
      final response = await model
          .generateContent(templateId, inputs: {'prompt': 'Some prompt'});
      expect(response.text, 'Some response');
    });

    test('generateContentStream can make successful request', () async {
      final mockHttp = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(request.url.path,
            endsWith('/templates/$templateId:templateStreamGenerateContent'));
        expect(body['inputs'], {'prompt': 'Some prompt'});
        final responsePayload = jsonEncode(_arbitraryGenerateContentResponse);
        final stream = Stream.value(utf8.encode('data: $responsePayload'));
        final streamedResponse = http.StreamedResponse(stream, 200,
            headers: {'content-type': 'application/json'});
        return http.Response.fromStream(streamedResponse);
      });

      final model = createModel(mockHttp);
      final responseStream = model
          .generateContentStream(templateId, inputs: {'prompt': 'Some prompt'});
      final response = await responseStream.first;
      expect(response.text, 'Some response');
    });
  });

  group('TemplateImagenModel', () {
    const templateId = 'my-imagen-template';
    const location = 'us-central1';

    TemplateImagenModel createModel(http.Client client,
        {bool useVertexBackend = true}) {
      // ignore: invalid_use_of_internal_member
      return createTestTemplateImagenModel(
          app: app,
          location: location,
          useVertexBackend: useVertexBackend,
          client: client);
    }

    test('generateImages can make successful request', () async {
      final mockHttp = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(request.url.path,
            endsWith('/templates/$templateId:templatePredict'));
        expect(body['inputs'], {'prompt': 'A cat'});
        return http.Response(jsonEncode(_arbitraryImagenResponse), 200,
            headers: {'content-type': 'application/json'});
      });
      final model = createModel(mockHttp);
      final response =
          await model.generateImages(templateId, inputs: {'prompt': 'A cat'});
      expect(response.images, hasLength(1));
      expect(response.images.first, isA<ImagenInlineImage>());
    });
  });
}
