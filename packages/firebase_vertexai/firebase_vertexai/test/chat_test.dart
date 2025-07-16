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

import 'package:firebase_ai/src/base_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock.dart';
import 'utils/matchers.dart';
import 'utils/stub_client.dart';

void main() {
  setupFirebaseVertexAIMocks();
  // ignore: unused_local_variable
  late FirebaseApp app;

  group('Chat', () {
    const defaultModelName = 'some-model';
    setUpAll(() async {
      // Initialize Firebase
      app = await Firebase.initializeApp();
    });

    (ClientController, GenerativeModel) createModel([
      String modelName = defaultModelName,
    ]) {
      final client = ClientController();
      final model = createModelWithClient(
          app: app,
          useVertexBackend: true,
          model: modelName,
          client: client.client,
          location: 'us-central1');
      return (client, model);
    }

    test('includes chat history in prompt', () async {
      final (client, model) = createModel('models/$defaultModelName');
      final chat = model.startChat(history: [
        Content.text('Hi!'),
        Content.model([TextPart('Hello, how can I help you today?')]),
      ]);
      const prompt = 'Some prompt';
      final response = await client.checkRequest(
        () => chat.sendMessage(Content.text(prompt)),
        verifyRequest: (_, request) {
          final contents = request['contents'];
          expect(contents, hasLength(3));
        },
        response: arbitraryGenerateContentResponse,
      );
      expect(
        chat.history.last,
        matchesContent(response.candidates.first.content),
      );
    });

    test('forwards safety settings', () async {
      final (client, model) = createModel('models/$defaultModelName');
      final chat = model.startChat(safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high,
            HarmBlockMethod.severity),
      ]);
      const prompt = 'Some prompt';
      await client.checkRequest(
        () => chat.sendMessage(Content.text(prompt)),
        verifyRequest: (_, request) {
          expect(request['safetySettings'], [
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_ONLY_HIGH',
              'method': 'SEVERITY'
            },
          ]);
        },
        response: arbitraryGenerateContentResponse,
      );
    });

    test('forwards safety settings and config when streaming', () async {
      final (client, model) = createModel('models/$defaultModelName');
      final chat = model.startChat(safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high,
            HarmBlockMethod.probability),
      ], generationConfig: GenerationConfig(stopSequences: ['a']));
      const prompt = 'Some prompt';
      final responses = await client.checkStreamRequest(
        () async => chat.sendMessageStream(Content.text(prompt)),
        verifyRequest: (_, request) {
          expect(request['safetySettings'], [
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_ONLY_HIGH',
              'method': 'PROBABILITY',
            },
          ]);
        },
        responses: [arbitraryGenerateContentResponse],
      );
      await responses.drain<void>();
    });

    test('forwards generation config', () async {
      final (client, model) = createModel('models/$defaultModelName');
      final chat = model.startChat(
        generationConfig: GenerationConfig(stopSequences: ['a']),
      );
      const prompt = 'Some prompt';
      await client.checkRequest(
        () => chat.sendMessage(Content.text(prompt)),
        verifyRequest: (_, request) {
          expect(request['generationConfig'], {
            'stopSequences': ['a'],
          });
        },
        response: arbitraryGenerateContentResponse,
      );
    });
  });
}
