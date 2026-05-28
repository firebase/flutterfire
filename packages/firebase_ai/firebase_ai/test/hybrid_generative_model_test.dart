// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:firebase_ai/src/api.dart';
import 'package:firebase_ai/src/base_model.dart';
import 'package:firebase_ai/src/client.dart';
import 'package:firebase_ai/src/content.dart';
import 'package:firebase_ai/src/generated/local_ai.g.dart';
import 'package:firebase_ai/src/hybrid_generative_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

class MockApiClient implements ApiClient {
  bool shouldFail = false;
  String responseText = 'Cloud Response';

  @override
  Future<Map<String, Object?>> makeRequest(Uri uri, Map<String, Object?> body) async {
    if (shouldFail) throw Exception('Cloud Failed');
    return {
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': responseText}
            ]
          }
        }
      ]
    };
  }

  @override
  Stream<Map<String, Object?>> streamRequest(Uri uri, Map<String, Object?> body) {
    if (shouldFail) throw Exception('Cloud Failed');
    return Stream.fromIterable([
      {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': responseText}
              ]
            }
          }
        ]
      }
    ]);
  }
}

class MockLocalApi extends LocalAIApi {
  bool available = true;
  bool shouldFail = false;
  String responseText = 'Local Response';

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<String> generateContent(String prompt) async {
    if (shouldFail) throw Exception('Local Failed');
    return responseText;
  }

  @override
  Future<void> warmup() async {}
  
  @override
  Future<void> startStreaming(String prompt) async {
    if (shouldFail) throw Exception('Local Failed');
  }
}

// ignore: avoid_implementing_value_types
class MockFirebaseApp implements FirebaseApp {
  @override
  String get name => '[DEFAULT]';

  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'dummy_api_key',
        appId: 'dummy_app_id',
        messagingSenderId: 'dummy_sender_id',
        projectId: 'dummy_project_id',
      );
      
  @override
  bool get isAutomaticDataCollectionEnabled => false;

  @override
  Future<void> delete() async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}

  @override
  T? getService<T extends FirebaseService>() => null;

  @override
  void registerService<T extends FirebaseService>(T service, {Future<void> Function(T)? dispose}) {}
}

void main() {
  test('preferCloud succeeds on cloud', () async {
    final apiClient = MockApiClient();
    final local = MockLocalApi();
    final app = MockFirebaseApp();
    
    final cloud = createModelWithClient(
      app: app,
      location: 'us-central1',
      model: 'gemini-pro',
      client: apiClient,
      useVertexBackend: false,
    );

    final model = HybridGenerativeModel(cloudModel: cloud, localApi: local, mode: InferenceMode.preferCloud);

    final response = await model.generateContent([Content.text('hello')]);
    expect(response.text, 'Cloud Response');
  });

  test('preferCloud falls back to local on cloud failure', () async {
    final apiClient = MockApiClient()..shouldFail = true;
    final local = MockLocalApi();
    final app = MockFirebaseApp();
    
    final cloud = createModelWithClient(
      app: app,
      location: 'us-central1',
      model: 'gemini-pro',
      client: apiClient,
      useVertexBackend: false,
    );

    final model = HybridGenerativeModel(cloudModel: cloud, localApi: local, mode: InferenceMode.preferCloud);

    final response = await model.generateContent([Content.text('hello')]);
    expect(response.text, 'Local Response');
  });

  test('preferCloud streaming succeeds on cloud', () async {
    final apiClient = MockApiClient();
    final local = MockLocalApi();
    final app = MockFirebaseApp();
    
    final cloud = createModelWithClient(
      app: app,
      location: 'us-central1',
      model: 'gemini-pro',
      client: apiClient,
      useVertexBackend: false,
    );

    final model = HybridGenerativeModel(cloudModel: cloud, localApi: local, mode: InferenceMode.preferCloud);

    final responses = model.generateContentStream([Content.text('hello')]);
    final textList = await responses.map((r) => r.text).toList();
    expect(textList, ['Cloud Response']);
  });

  test('preferCloud streaming falls back to local on cloud failure before data', () async {
    final apiClient = MockApiClient()..shouldFail = true;
    final local = MockLocalApi();
    final app = MockFirebaseApp();
    
    final cloud = createModelWithClient(
      app: app,
      location: 'us-central1',
      model: 'gemini-pro',
      client: apiClient,
      useVertexBackend: false,
    );

    final mockLocalStream = Stream.fromIterable([
      GenerateContentResponse([
        Candidate(Content('model', [const TextPart('Local Response')]), null, null, null, null)
      ], null)
    ]);

    final model = TestHybridGenerativeModel(
      cloudModel: cloud,
      localApi: local,
      mode: InferenceMode.preferCloud,
      mockLocalStream: mockLocalStream,
    );

    final responses = model.generateContentStream([Content.text('hello')]);
    final textList = await responses.map((r) => r.text).toList();
    expect(textList, ['Local Response']);
  });
}

class TestHybridGenerativeModel extends HybridGenerativeModel {
  TestHybridGenerativeModel({
    required super.cloudModel,
    required super.localApi,
    super.mode,
    this.mockLocalStream,
  });

  Stream<GenerateContentResponse>? mockLocalStream;

  @override
  Stream<GenerateContentResponse> generateLocalStream(Iterable<Content> prompt) {
    if (mockLocalStream != null) return mockLocalStream!;
    return super.generateLocalStream(prompt);
  }
}
