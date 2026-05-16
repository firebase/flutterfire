// Copyright 2026 Google LLC
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

import 'dart:async';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_ai/src/base_model.dart';
import 'package:firebase_ai/src/client.dart';
import 'package:firebase_ai/src/local_model_runner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:flutter_test/flutter_test.dart';

import 'mock.dart';
import 'utils/matchers.dart';

class FakeLocalModelRunner extends Fake implements LocalModelRunner {
  bool isInstalledResult = true;
  bool initializeCalled = false;
  bool closeCalled = false;
  int initializeCount = 0;

  GenerateContentResponse? generateContentResult;
  Object? generateContentError;

  Stream<GenerateContentResponse>? generateContentStreamResult;
  Object? generateContentStreamError;

  CountTokensResponse? countTokensResult;
  Object? countTokensError;

  @override
  Future<bool> isInstalled() async => isInstalledResult;

  @override
  Future<void> initialize() async {
    initializeCalled = true;
    initializeCount++;
  }

  @override
  Future<GenerateContentResponse> generateContent(
    Iterable<Content> prompt, {
    List<Tool>? tools,
    ToolConfig? toolConfig,
    Content? systemInstruction,
  }) async {
    if (generateContentError != null) {
      throw generateContentError!;
    }
    return generateContentResult ??
        GenerateContentResponse([
          Candidate(
            Content('model', [const TextPart('fake local response')]),
            null,
            null,
            null,
            null,
          )
        ], null);
  }

  @override
  Stream<GenerateContentResponse> generateContentStream(
    Iterable<Content> prompt, {
    List<Tool>? tools,
    ToolConfig? toolConfig,
    Content? systemInstruction,
  }) {
    if (generateContentStreamError != null) {
      return Stream.error(generateContentStreamError!);
    }
    if (generateContentStreamResult != null) {
      return generateContentStreamResult!;
    }
    return Stream.value(GenerateContentResponse([
      Candidate(
        Content('model', [const TextPart('fake local stream response')]),
        null,
        null,
        null,
        null,
      )
    ], null));
  }

  @override
  Future<CountTokensResponse> countTokens(Iterable<Content> contents) async {
    if (countTokensError != null) {
      throw countTokensError!;
    }
    return countTokensResult ?? CountTokensResponse(42);
  }

  @override
  Future<void> close() async {
    closeCalled = true;
  }
}

class MockApiClient implements ApiClient {
  Map<String, Object?>? response;
  List<Map<String, Object?>>? streamResponses;
  Object? error;
  Uri? lastUri;
  Map<String, Object?>? lastBody;
  int requestCount = 0;

  MockApiClient({this.response, this.streamResponses, this.error});

  @override
  Future<Map<String, Object?>> makeRequest(
    Uri uri,
    Map<String, Object?> body,
  ) async {
    lastUri = uri;
    lastBody = body;
    requestCount++;
    if (error != null) throw error!;
    return response ?? {};
  }

  @override
  Stream<Map<String, Object?>> streamRequest(
    Uri uri,
    Map<String, Object?> body,
  ) {
    lastUri = uri;
    lastBody = body;
    requestCount++;
    if (error != null) return Stream.error(error!);
    return Stream.fromIterable(streamResponses ?? []);
  }
}

const Map<String, Object?> arbitraryGenerateContentResponse = {
  'candidates': [
    {
      'content': {
        'role': 'model',
        'parts': [
          {'text': 'Some Response'},
        ],
      },
    },
  ],
};

void main() {
  setupFirebaseVertexAIMocks();
  late FirebaseApp app;

  setUpAll(() async {
    app = await Firebase.initializeApp();
  });

  group('Hybrid Mode Tests', () {
    const modelName = 'gemini-1.5-flash';
    final hybridConfig = HybridConfig(
      localConfig: LocalModelConfig(
        modelType: gemma.ModelType.gemmaIt,
        modelPath: 'models/gemma-2b.bin',
      ),
      initialPreference: HybridPreference.onlyCloud,
    );

    GenerativeModel createTestModel({
      ApiClient? client,
      HybridConfig? config,
      FakeLocalModelRunner? fakeLocalRunner,
    }) {
      final model = createModelWithClient(
        app: app,
        location: 'us-central1',
        model: modelName,
        client: client ?? MockApiClient(),
        useVertexBackend: false,
        hybridConfig: config ?? hybridConfig,
      );
      if (fakeLocalRunner != null) {
        model.localRunner = fakeLocalRunner;
      }
      return model;
    }

    group('onlyCloud preference', () {
      test('generateContent goes to cloud', () async {
        final mockClient = MockApiClient(response: arbitraryGenerateContentResponse);
        final model = createTestModel(
          client: mockClient,
          fakeLocalRunner: FakeLocalModelRunner(),
        );

        await model.setPreference(HybridPreference.onlyCloud);

        final response = await model.generateContent([Content.text('hello')]);

        expect(response.text, 'Some Response');
        expect(mockClient.requestCount, 1);
      });

      test('generateContentStream goes to cloud', () async {
        final mockClient = MockApiClient(streamResponses: [arbitraryGenerateContentResponse]);
        final model = createTestModel(
          client: mockClient,
          fakeLocalRunner: FakeLocalModelRunner(),
        );

        await model.setPreference(HybridPreference.onlyCloud);

        final stream = model.generateContentStream([Content.text('hello')]);
        final results = await stream.toList();

        expect(results.first.text, 'Some Response');
        expect(mockClient.requestCount, 1);
      });

      test('countTokens goes to cloud', () async {
        final mockClient = MockApiClient(response: {'totalTokens': 5});
        final model = createTestModel(
          client: mockClient,
          fakeLocalRunner: FakeLocalModelRunner(),
        );

        await model.setPreference(HybridPreference.onlyCloud);

        final response = await model.countTokens([Content.text('hello')]);

        expect(response.totalTokens, 5);
        expect(mockClient.requestCount, 1);
      });
    });

    group('onlyLocal preference', () {
      test('generateContent goes to local', () async {
        final fakeLocalRunner = FakeLocalModelRunner();
        final model = createTestModel(fakeLocalRunner: fakeLocalRunner);

        await model.setPreference(HybridPreference.onlyLocal);

        final response = await model.generateContent([Content.text('hello')]);

        expect(response.text, 'fake local response');
        expect(fakeLocalRunner.initializeCalled, true);
      });

      test('generateContentStream goes to local', () async {
        final fakeLocalRunner = FakeLocalModelRunner();
        final model = createTestModel(fakeLocalRunner: fakeLocalRunner);

        await model.setPreference(HybridPreference.onlyLocal);

        final stream = model.generateContentStream([Content.text('hello')]);
        final results = await stream.toList();

        expect(results.first.text, 'fake local stream response');
        expect(fakeLocalRunner.initializeCalled, true);
      });

      test('countTokens goes to local', () async {
        final fakeLocalRunner = FakeLocalModelRunner();
        final model = createTestModel(fakeLocalRunner: fakeLocalRunner);

        await model.setPreference(HybridPreference.onlyLocal);

        final response = await model.countTokens([Content.text('hello')]);

        expect(response.totalTokens, 42);
        expect(fakeLocalRunner.initializeCalled, true);
      });
    });

    group('preferLocal preference', () {
      test('goes to local when installed', () async {
        final fakeLocalRunner = FakeLocalModelRunner()..isInstalledResult = true;
        final model = createTestModel(fakeLocalRunner: fakeLocalRunner);

        await model.setPreference(HybridPreference.preferLocal);

        final response = await model.generateContent([Content.text('hello')]);

        expect(response.text, 'fake local response');
        expect(fakeLocalRunner.initializeCalled, true);
      });

      test('goes to cloud when local not installed', () async {
        final fakeLocalRunner = FakeLocalModelRunner()..isInstalledResult = false;
        final mockClient = MockApiClient(response: arbitraryGenerateContentResponse);
        final model = createTestModel(
          client: mockClient,
          fakeLocalRunner: fakeLocalRunner,
        );

        await model.setPreference(HybridPreference.preferLocal);

        final response = await model.generateContent([Content.text('hello')]);

        expect(response.text, 'Some Response');
        expect(fakeLocalRunner.initializeCalled, false);
        expect(mockClient.requestCount, 1);
      });

      test('falls back to cloud when local fails', () async {
        final fakeLocalRunner = FakeLocalModelRunner()
          ..isInstalledResult = true
          ..generateContentError = Exception('Local engine crash');
        final mockClient = MockApiClient(response: arbitraryGenerateContentResponse);
        final model = createTestModel(
          client: mockClient,
          fakeLocalRunner: fakeLocalRunner,
        );

        await model.setPreference(HybridPreference.preferLocal);

        final response = await model.generateContent([Content.text('hello')]);

        expect(response.text, 'Some Response');
        expect(fakeLocalRunner.initializeCalled, true);
        expect(mockClient.requestCount, 1);
      });

      test('falls back to cloud when local stream fails', () async {
        final fakeLocalRunner = FakeLocalModelRunner()
          ..isInstalledResult = true
          ..generateContentStreamError = Exception('Local stream crash');
        final mockClient = MockApiClient(streamResponses: [arbitraryGenerateContentResponse]);
        final model = createTestModel(
          client: mockClient,
          fakeLocalRunner: fakeLocalRunner,
        );

        await model.setPreference(HybridPreference.preferLocal);

        final stream = model.generateContentStream([Content.text('hello')]);
        final results = await stream.toList();

        expect(results.first.text, 'Some Response');
        expect(fakeLocalRunner.initializeCalled, true);
        expect(mockClient.requestCount, 1);
      });
    });

    group('preferCloud preference', () {
      test('goes to cloud when cloud succeeds', () async {
        final fakeLocalRunner = FakeLocalModelRunner();
        final mockClient = MockApiClient(response: arbitraryGenerateContentResponse);
        final model = createTestModel(
          client: mockClient,
          fakeLocalRunner: fakeLocalRunner,
        );

        await model.setPreference(HybridPreference.preferCloud);

        final response = await model.generateContent([Content.text('hello')]);

        expect(response.text, 'Some Response');
        expect(fakeLocalRunner.initializeCalled, false);
        expect(mockClient.requestCount, 1);
      });

      test('falls back to local when cloud fails and local is installed', () async {
        final fakeLocalRunner = FakeLocalModelRunner()..isInstalledResult = true;
        final mockClient = MockApiClient(error: Exception('Cloud offline'));
        final model = createTestModel(
          client: mockClient,
          fakeLocalRunner: fakeLocalRunner,
        );

        await model.setPreference(HybridPreference.preferCloud);

        final response = await model.generateContent([Content.text('hello')]);

        expect(response.text, 'fake local response');
        expect(fakeLocalRunner.initializeCalled, true);
        expect(mockClient.requestCount, 1);
      });

      test('does NOT fall back to local when cloud fails but local is NOT installed', () async {
        final fakeLocalRunner = FakeLocalModelRunner()..isInstalledResult = false;
        final mockClient = MockApiClient(error: Exception('Cloud offline'));
        final model = createTestModel(
          client: mockClient,
          fakeLocalRunner: fakeLocalRunner,
        );

        await model.setPreference(HybridPreference.preferCloud);

        await expectLater(
          model.generateContent([Content.text('hello')]),
          throwsA(isA<Exception>()),
        );
        expect(fakeLocalRunner.initializeCalled, false);
        expect(mockClient.requestCount, 1);
      });

      test('falls back to local when cloud stream fails and local is installed', () async {
        final fakeLocalRunner = FakeLocalModelRunner()..isInstalledResult = true;
        final mockClient = MockApiClient(error: Exception('Cloud stream offline'));
        final model = createTestModel(
          client: mockClient,
          fakeLocalRunner: fakeLocalRunner,
        );

        await model.setPreference(HybridPreference.preferCloud);

        final stream = model.generateContentStream([Content.text('hello')]);
        final results = await stream.toList();

        expect(results.first.text, 'fake local stream response');
        expect(fakeLocalRunner.initializeCalled, true);
        expect(mockClient.requestCount, 1);
      });
    });
  });
}
