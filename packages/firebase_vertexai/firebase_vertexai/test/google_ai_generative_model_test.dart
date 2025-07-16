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

import 'package:firebase_ai/src/base_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock.dart';
import 'utils/matchers.dart';
import 'utils/stub_client.dart';

void main() {
  setupFirebaseVertexAIMocks();
  late FirebaseApp app;
  setUpAll(() async {
    // Initialize Firebase
    app = await Firebase.initializeApp();
  });
  group('GenerativeModel', () {
    const defaultModelName = 'some-model';

    (ClientController, GenerativeModel) createModel({
      String modelName = defaultModelName,
      List<Tool>? tools,
      ToolConfig? toolConfig,
      Content? systemInstruction,
    }) {
      final client = ClientController();
      final model = createModelWithClient(
          useVertexBackend: false,
          app: app,
          model: modelName,
          client: client.client,
          tools: tools,
          toolConfig: toolConfig,
          systemInstruction: systemInstruction,
          location: 'us-central1');
      return (client, model);
    }

    test('strips leading "models/" from model name', () async {
      final (client, model) = createModel(
        modelName: 'models/$defaultModelName',
      );
      const prompt = 'Some prompt';
      await client.checkRequest(
        () => model.generateContent([Content.text(prompt)]),
        response: arbitraryGenerateContentResponse,
        verifyRequest: (uri, _) {
          expect(uri.path, endsWith('/models/some-model:generateContent'));
        },
      );
    });

    test('allows specifying a tuned model', () async {
      final (client, model) = createModel(
        modelName: 'tunedModels/$defaultModelName',
      );
      const prompt = 'Some prompt';
      await client.checkRequest(
        () => model.generateContent([Content.text(prompt)]),
        response: arbitraryGenerateContentResponse,
        verifyRequest: (uri, _) {
          expect(uri.path, endsWith('/tunedModels/some-model:generateContent'));
        },
      );
    });

    test('allows specifying an API version', () async {
      final (client, model) = createModel(
          // requestOptions: RequestOptions(apiVersion: 'override_version'),
          );
      const prompt = 'Some prompt';
      await client.checkRequest(
        () => model.generateContent([Content.text(prompt)]),
        response: arbitraryGenerateContentResponse,
        verifyRequest: (uri, _) {
          expect(uri.path, startsWith('/override_version/'));
        },
      );
    }, skip: 'No support for overriding API version');

    group('generate unary content', () {
      test('can make successful request', () async {
        final (client, model) = createModel();
        const prompt = 'Some prompt';
        const result = 'Some response';
        final response = await client.checkRequest(
          () => model.generateContent([Content.text(prompt)]),
          verifyRequest: (uri, request) {
            expect(
              uri,
              Uri.parse(
                'https://firebasevertexai.googleapis.com/v1beta/'
                'projects/123/'
                'models/some-model:generateContent',
              ),
            );
            expect(request, {
              'model': 'models/$defaultModelName',
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
            });
          },
          response: {
            'candidates': [
              {
                'content': {
                  'role': 'model',
                  'parts': [
                    {'text': result},
                  ],
                },
              },
            ],
          },
        );
        expect(
          response,
          matchesGenerateContentResponse(
            GenerateContentResponse([
              Candidate(
                Content('model', [TextPart(result)]),
                null,
                null,
                null,
                null,
              ),
            ], null),
          ),
        );
      });

      test('can override safety settings', () async {
        final (client, model) = createModel();
        const prompt = 'Some prompt';
        await client.checkRequest(
          () => model.generateContent(
            [Content.text(prompt)],
            safetySettings: [
              SafetySetting(
                HarmCategory.dangerousContent,
                HarmBlockThreshold.high,
                null,
              ),
            ],
          ),
          response: arbitraryGenerateContentResponse,
          verifyRequest: (_, request) {
            expect(request['safetySettings'], [
              {
                'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                'threshold': 'BLOCK_ONLY_HIGH',
              },
            ]);
          },
        );
      });

      test('can override generation config', () async {
        final (client, model) = createModel();
        const prompt = 'Some prompt';
        await client.checkRequest(
          () => model.generateContent([
            Content.text(prompt),
          ], generationConfig: GenerationConfig(stopSequences: ['a'])),
          verifyRequest: (_, request) {
            expect(request['generationConfig'], {
              'stopSequences': ['a'],
            });
          },
          response: arbitraryGenerateContentResponse,
        );
      });

      test('can pass system instructions', () async {
        const instructions = 'Do a good job';
        final (client, model) = createModel(
          systemInstruction: Content.system(instructions),
        );
        const prompt = 'Some prompt';
        await client.checkRequest(
          () => model.generateContent([Content.text(prompt)]),
          verifyRequest: (_, request) {
            expect(request['systemInstruction'], {
              'role': 'system',
              'parts': [
                {'text': instructions},
              ],
            });
          },
          response: arbitraryGenerateContentResponse,
        );
      });

      test('can pass tools and function calling config', () async {
        final (client, model) = createModel(
          tools: [
            Tool.functionDeclarations([
              FunctionDeclaration(
                'someFunction',
                'Some cool function.',
                parameters: {
                  'schema1': Schema.string(description: 'Some parameter.'),
                },
              ),
            ]),
          ],
          toolConfig: ToolConfig(
            functionCallingConfig: FunctionCallingConfig.any(
              {'someFunction'},
            ),
          ),
        );
        const prompt = 'Some prompt';
        await client.checkRequest(
          () => model.generateContent([Content.text(prompt)]),
          verifyRequest: (_, request) {
            expect(request['tools'], [
              {
                'functionDeclarations': [
                  {
                    'name': 'someFunction',
                    'description': 'Some cool function.',
                    'parameters': {
                      'type': 'OBJECT',
                      'properties': {
                        'schema1': {
                          'type': 'STRING',
                          'description': 'Some parameter.'
                        }
                      },
                      'required': ['schema1']
                    }
                  },
                ],
              },
            ]);
            expect(request['toolConfig'], {
              'functionCallingConfig': {
                'mode': 'ANY',
                'allowedFunctionNames': ['someFunction'],
              },
            });
          },
          response: arbitraryGenerateContentResponse,
        );
      });

      test('can override tools and function calling config', () async {
        final (client, model) = createModel();
        const prompt = 'Some prompt';
        await client.checkRequest(
          () => model.generateContent(
            [Content.text(prompt)],
            tools: [
              Tool.functionDeclarations([
                FunctionDeclaration(
                  'someFunction',
                  'Some cool function.',
                  parameters: {
                    'schema1': Schema.string(description: 'Some parameter.'),
                  },
                ),
              ]),
            ],
            toolConfig: ToolConfig(
              functionCallingConfig: FunctionCallingConfig.any(
                {'someFunction'},
              ),
            ),
          ),
          verifyRequest: (_, request) {
            expect(request['tools'], [
              {
                'functionDeclarations': [
                  {
                    'name': 'someFunction',
                    'description': 'Some cool function.',
                    'parameters': {
                      'type': 'OBJECT',
                      'properties': {
                        'schema1': {
                          'type': 'STRING',
                          'description': 'Some parameter.'
                        }
                      },
                      'required': ['schema1']
                    }
                  },
                ],
              },
            ]);
            expect(request['toolConfig'], {
              'functionCallingConfig': {
                'mode': 'ANY',
                'allowedFunctionNames': ['someFunction'],
              },
            });
          },
          response: arbitraryGenerateContentResponse,
        );
      });

      test('can enable code execution', () async {
        final (client, model) = createModel(tools: [
          // Tool(codeExecution: CodeExecution()),
        ]);
        const prompt = 'Some prompt';
        await client.checkRequest(
          () => model.generateContent([Content.text(prompt)]),
          verifyRequest: (_, request) {
            expect(request['tools'], [
              {'codeExecution': <String, Object?>{}}
            ]);
          },
          response: arbitraryGenerateContentResponse,
        );
      }, skip: 'No support for code executation');

      test('can override code execution', () async {
        final (client, model) = createModel();
        const prompt = 'Some prompt';
        await client.checkRequest(
          () => model.generateContent([
            Content.text(prompt)
          ], tools: [
            // Tool(codeExecution: CodeExecution()),
          ]),
          verifyRequest: (_, request) {
            expect(request['tools'], [
              {'codeExecution': <String, Object?>{}}
            ]);
          },
          response: arbitraryGenerateContentResponse,
        );
      }, skip: 'No support for code execution');
    });

    group('generate content stream', () {
      test('can make successful request', () async {
        final (client, model) = createModel();
        const prompt = 'Some prompt';
        final results = {'First response', 'Second Response'};
        final response = await client.checkStreamRequest(
          () async => model.generateContentStream([Content.text(prompt)]),
          verifyRequest: (uri, request) {
            expect(
              uri,
              Uri.parse(
                'https://firebasevertexai.googleapis.com/v1beta/'
                'projects/123/'
                'models/some-model:streamGenerateContent',
              ),
            );
            expect(request, {
              'model': 'models/$defaultModelName',
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
            });
          },
          responses: [
            for (final result in results)
              {
                'candidates': [
                  {
                    'content': {
                      'role': 'model',
                      'parts': [
                        {'text': result},
                      ],
                    },
                  },
                ],
              },
          ],
        );
        expect(
          response,
          emitsInOrder([
            for (final result in results)
              matchesGenerateContentResponse(
                GenerateContentResponse([
                  Candidate(
                    Content('model', [TextPart(result)]),
                    null,
                    null,
                    null,
                    null,
                  ),
                ], null),
              ),
          ]),
        );
      });

      test('can override safety settings', () async {
        final (client, model) = createModel();
        const prompt = 'Some prompt';
        final responses = await client.checkStreamRequest(
          () async => model.generateContentStream(
            [Content.text(prompt)],
            safetySettings: [
              SafetySetting(
                HarmCategory.dangerousContent,
                HarmBlockThreshold.high,
                null,
              ),
            ],
          ),
          verifyRequest: (_, request) {
            expect(request['safetySettings'], [
              {
                'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                'threshold': 'BLOCK_ONLY_HIGH',
              },
            ]);
          },
          responses: [arbitraryGenerateContentResponse],
        );
        await responses.drain<void>();
      });

      test('can override generation config', () async {
        final (client, model) = createModel();
        const prompt = 'Some prompt';
        final responses = await client.checkStreamRequest(
          () async => model.generateContentStream([
            Content.text(prompt),
          ], generationConfig: GenerationConfig(stopSequences: ['a'])),
          verifyRequest: (_, request) {
            expect(request['generationConfig'], {
              'stopSequences': ['a'],
            });
          },
          responses: [arbitraryGenerateContentResponse],
        );
        await responses.drain<void>();
      });
    });

    group('count tokens', () {
      test('can make successful request', () async {
        final (client, model) = createModel();
        const prompt = 'Some prompt';
        final response = await client.checkRequest(
          () => model.countTokens([Content.text(prompt)]),
          verifyRequest: (uri, request) {
            expect(
              uri,
              Uri.parse(
                'https://firebasevertexai.googleapis.com/v1beta/'
                'projects/123/'
                'models/some-model:countTokens',
              ),
            );
            expect(request, {
              'generateContentRequest': {
                'model': 'models/$defaultModelName',
                'contents': [
                  {
                    'role': 'user',
                    'parts': [
                      {'text': prompt},
                    ],
                  },
                ],
              }
            });
          },
          response: {'totalTokens': 2},
        );
        expect(response, matchesCountTokensResponse(CountTokensResponse(2)));
      });

      test('can override GenerateContentRequest fields', () async {
        final (client, model) = createModel();
        const prompt = 'Some prompt';
        await client.checkRequest(
          response: {'totalTokens': 100},
          () => model.countTokens(
            [Content.text(prompt)],
            // safetySettings: [
            //   SafetySetting(
            //     HarmCategory.dangerousContent,
            //     HarmBlockThreshold.high,
            //     null,
            //   ),
            // ],
            // generationConfig: GenerationConfig(stopSequences: ['a']),
            // tools: [
            //   Tool(functionDeclarations: [
            //     FunctionDeclaration(
            //       'someFunction',
            //       'Some cool function.',
            //       Schema(SchemaType.string, description: 'Some parameter.'),
            //     ),
            //   ]),
            // ],
            // toolConfig: ToolConfig(
            //   functionCallingConfig: FunctionCallingConfig(
            //     mode: FunctionCallingMode.any,
            //     allowedFunctionNames: {'someFunction'},
            //   ),
            // ),
          ),
          verifyRequest: (_, countTokensRequest) {
            expect(countTokensRequest, isNotNull);
            final request = countTokensRequest['generateContentRequest']!
                as Map<String, Object?>;
            expect(request['safetySettings'], [
              {
                'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                'threshold': 'BLOCK_ONLY_HIGH',
              },
            ]);
            expect(request['generationConfig'], {
              'stopSequences': ['a'],
            });
            expect(request['tools'], [
              {
                'functionDeclarations': [
                  {
                    'name': 'someFunction',
                    'description': 'Some cool function.',
                    'parameters': {
                      'type': 'STRING',
                      'description': 'Some parameter.',
                    },
                  },
                ],
              },
            ]);
            expect(request['toolConfig'], {
              'functionCallingConfig': {
                'mode': 'ANY',
                'allowedFunctionNames': ['someFunction'],
              },
            });
          },
        );
      }, skip: 'Only content argument supported for countTokens');
    });

    group('embed content', () {
      test('can make successful request', () async {
        final (client, model) = createModel();
        const prompt = 'Some prompt';
        final response = await client.checkRequest(
          () async {
            // await model.embedContent(Content.text(prompt));
          },
          verifyRequest: (uri, request) {
            expect(
              uri,
              Uri.parse(
                'https://firebasevertexai.googleapis.com/v1beta/'
                'projects/123/'
                'models/some-model:embedContent',
              ),
            );
            expect(request, {
              'content': {
                'role': 'user',
                'parts': [
                  {'text': prompt},
                ],
              },
            });
          },
          response: {
            'embedding': {
              'values': [0.1, 0.2, 0.3],
            },
          },
        );
        expect(
          response,
          // matchesEmbedContentResponse(
          //   EmbedContentResponse(ContentEmbedding([0.1, 0.2, 0.3])),
          // ),
          isNotNull,
        );
      });

      test('embed content with reduced output dimensionality', () async {
        final (client, model) = createModel();
        const content = 'Some content';
        const outputDimensionality = 1;
        final embeddingValues = [0.1];

        await client.checkRequest(() async {
          Content.text(content);
          // await model.embedContent(
          //   Content.text(content),
          //   outputDimensionality: outputDimensionality,
          // );
        }, verifyRequest: (_, request) {
          expect(request,
              containsPair('outputDimensionality', outputDimensionality));
        }, response: {
          'embedding': {'values': embeddingValues},
        });
      });
    }, skip: 'No support for embedding content');

    group('batch embed contents', () {
      test('can make successful request', () async {
        final (client, model) = createModel();
        const prompt1 = 'Some prompt';
        const prompt2 = 'Another prompt';
        final embedding1 = [0.1, 0.2, 0.3];
        final embedding2 = [0.4, 0.5, 1.6];
        final response = await client.checkRequest(
          () async {
            // await model.batchEmbedContents([
            //   EmbedContentRequest(Content.text(prompt1)),
            //   EmbedContentRequest(Content.text(prompt2)),
            // ]);
          },
          verifyRequest: (uri, request) {
            expect(
              uri,
              Uri.parse(
                'https://firebasevertexai.googleapis.com/v1beta/'
                'projects/123/'
                'models/some-model:batchEmbedContents',
              ),
            );
            expect(request, {
              'requests': [
                {
                  'content': {
                    'role': 'user',
                    'parts': [
                      {'text': prompt1},
                    ],
                  },
                  'model': 'models/$defaultModelName',
                },
                {
                  'content': {
                    'role': 'user',
                    'parts': [
                      {'text': prompt2},
                    ],
                  },
                  'model': 'models/$defaultModelName',
                },
              ],
            });
          },
          response: {
            'embeddings': [
              {'values': embedding1},
              {'values': embedding2},
            ],
          },
        );
        expect(
          response,
          isNotNull,
          // matchesBatchEmbedContentsResponse(
          //   BatchEmbedContentsResponse([
          //     ContentEmbedding(embedding1),
          //     ContentEmbedding(embedding2),
          //   ]),
          // ),
        );
      });

      test('batch embed contents with reduced output dimensionality', () async {
        final (client, model) = createModel();
        const content1 = 'Some content 1';
        const content2 = 'Some content 2';
        const outputDimensionality = 1;
        final embeddingValues1 = [0.1];
        final embeddingValues2 = [0.4];

        await client.checkRequest(() async {
          Content.text(content1);
          Content.text(content2);
          // await model.batchEmbedContents([
          //   EmbedContentRequest(
          //     Content.text(content1),
          //     outputDimensionality: outputDimensionality,
          //   ),
          //   EmbedContentRequest(
          //     Content.text(content2),
          //     outputDimensionality: outputDimensionality,
          //   ),
          // ]);
        }, verifyRequest: (_, request) {
          expect(request['requests'], [
            containsPair('outputDimensionality', outputDimensionality),
            containsPair('outputDimensionality', outputDimensionality),
          ]);
        }, response: {
          'embeddings': [
            {'values': embeddingValues1},
            {'values': embeddingValues2},
          ],
        });
      });
    }, skip: 'No support for embed content');
  });
}
