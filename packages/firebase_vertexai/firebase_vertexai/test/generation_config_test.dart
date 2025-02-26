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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock.dart';
import 'utils/stub_client.dart';

void main() {
  setupFirebaseVertexAIMocks();
  // ignore: unused_local_variable
  late FirebaseApp app;
  setUpAll(() async {
    // Initialize Firebase
    app = await Firebase.initializeApp();
  });
  group('GenerationConfig Tests', () {
    const defaultModelName = 'some-model';

    (ClientController, GenerativeModel) createModel({
      String modelName = defaultModelName,
    }) {
      final client = ClientController();
      final model = createModelWithClient(
          app: app,
          model: modelName,
          client: client.client,
          location: 'us-central1');
      return (client, model);
    }
    test('toJson method', (){
      final generationConfig = GenerationConfig(candidateCount: 2, stopSequences: ['a'], maxOutputTokens: 10,
      topK: 1, topP: 0.5, frequencyPenalty: 0.5, presencePenalty: 0.5);
      final result = {
        if (candidateCount case final candidateCount?)
          'candidateCount': candidateCount,
        if (stopSequences case final stopSequences?)
          'stopSequences': stopSequences,
        if (maxOutputTokens case final maxOutputTokens?)
          'maxOutputTokens': maxOutputTokens,
        if (temperature case final temperature?) 'temperature': temperature,
        if (topP case final topP?) 'topP': topP,
        if (topK case final topK?) 'topK': topK,
        'presencePenalty': presencePenalty,
        'frequencyPenalty': frequencyPenalty,
      };
      expect(generationConfig.toJson(), result);
    });
    test('Test to check if presencePenalty and frequencyPenalty is include in generateContent', () async {
       final (client, model) = createModel();
       final response = await client.checkRequest(
         () => model.generateContent([Content.text('Some prompt')],
         generationConfig: GenerationConfig(presencePenalty: 0.7, frequencyPenalty: 0.3)),
         response: arbitraryGenerateContentResponse,
          verifyRequest: (_,request){
            expect(request['generationConfig'], {
                'candidateCount': 1,
                'stopSequences': ['a'],
                'maxOutputTokens': 10,
                'temperature': 0.5,
                'topP': 0.5,
                'topK': 1,
                'presencePenalty' : 0.7,
                'frequencyPenalty' : 0.3,
              });
          },
       );

    });
  });
}
