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

import 'package:firebase_ai/src/content.dart';
import 'package:firebase_ai/src/developer/api.dart';
import 'package:firebase_ai/src/error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeveloperSerialization', () {
    group('parseGenerateContentResponse', () {
      test('parses usageMetadata with thoughtsTokenCount correctly', () {
        final jsonResponse = {
          'candidates': [
            {
              'content': {
                'role': 'model',
                'parts': [
                  {'text': 'Some generated text.'}
                ]
              },
              'finishReason': 'STOP',
            }
          ],
          'usageMetadata': {
            'promptTokenCount': 10,
            'candidatesTokenCount': 5,
            'totalTokenCount': 15,
            'thoughtsTokenCount': 3,
            'promptTokensDetails': [
              {'modality': 'TEXT', 'tokenCount': 10}
            ],
            'candidatesTokensDetails': [
              {'modality': 'TEXT', 'tokenCount': 25}
            ],
          }
        };
        final response =
            DeveloperSerialization().parseGenerateContentResponse(jsonResponse);
        expect(response.usageMetadata, isNotNull);
        expect(response.usageMetadata!.promptTokenCount, 10);
        expect(response.usageMetadata!.candidatesTokenCount, 5);
        expect(response.usageMetadata!.totalTokenCount, 15);
        expect(response.usageMetadata!.thoughtsTokenCount, 3);
        expect(response.usageMetadata!.promptTokensDetails, isNotNull);
        expect(response.usageMetadata!.promptTokensDetails, hasLength(1));
        expect(
            response.usageMetadata!.promptTokensDetails!.first.tokenCount, 10);
        expect(response.usageMetadata!.candidatesTokensDetails, isNotNull);
        expect(response.usageMetadata!.candidatesTokensDetails, hasLength(1));
        expect(
            response.usageMetadata!.candidatesTokensDetails!.first.tokenCount,
            25);
      });

      test('parses usageMetadata when thoughtsTokenCount is missing', () {
        final jsonResponse = {
          'candidates': [
            {
              'content': {
                'role': 'model',
                'parts': [
                  {'text': 'Some generated text.'}
                ]
              },
              'finishReason': 'STOP',
            }
          ],
          'usageMetadata': {
            'promptTokenCount': 10,
            'candidatesTokenCount': 5,
            'totalTokenCount': 15,
            // thoughtsTokenCount is missing
            'promptTokensDetails': [
              {'modality': 'TEXT', 'tokenCount': 10}
            ],
            'candidatesTokensDetails': [
              {'modality': 'TEXT', 'tokenCount': 25}
            ],
          }
        };
        final response =
            DeveloperSerialization().parseGenerateContentResponse(jsonResponse);
        expect(response.usageMetadata, isNotNull);
        expect(response.usageMetadata!.promptTokenCount, 10);
        expect(response.usageMetadata!.candidatesTokenCount, 5);
        expect(response.usageMetadata!.totalTokenCount, 15);
        expect(response.usageMetadata!.thoughtsTokenCount, isNull);
      });

      test('parses usageMetadata when thoughtsTokenCount is present but null',
          () {
        final jsonResponse = {
          'candidates': [
            {
              'content': {
                'role': 'model',
                'parts': [
                  {'text': 'Some generated text.'}
                ]
              },
              'finishReason': 'STOP',
            }
          ],
          'usageMetadata': {
            'promptTokenCount': 10,
            'candidatesTokenCount': 5,
            'totalTokenCount': 15,
            'thoughtsTokenCount': null,
          }
        };
        final response =
            DeveloperSerialization().parseGenerateContentResponse(jsonResponse);
        expect(response.usageMetadata, isNotNull);
        expect(response.usageMetadata!.thoughtsTokenCount, isNull);
      });

      test('parses response when usageMetadata is missing', () {
        final jsonResponse = {
          'candidates': [
            {
              'content': {
                'role': 'model',
                'parts': [
                  {'text': 'Some generated text.'}
                ]
              },
              'finishReason': 'STOP',
            }
          ],
          // usageMetadata is missing
        };
        final response =
            DeveloperSerialization().parseGenerateContentResponse(jsonResponse);
        expect(response.usageMetadata, isNull);
      });

      group('groundingMetadata parsing', () {
        test('parses valid response with full grounding metadata', () {
          final jsonResponse = {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'This is a grounded response.'}
                  ]
                },
                'finishReason': 'STOP',
                'groundingMetadata': {
                  'webSearchQueries': ['query1', 'query2'],
                  'searchEntryPoint': {'renderedContent': '<div></div>'},
                  'groundingChunks': [
                    {
                      'web': {
                        'uri': 'http://example.com/1',
                        'title': 'Example Page 1',
                      }
                    }
                  ],
                  'groundingSupport': [
                    {
                      'segment': {
                        'startIndex': 5,
                        'endIndex': 13,
                        'text': 'grounded'
                      },
                      'groundingChunkIndices': [0],
                    }
                  ]
                }
              }
            ]
          };

          final response = DeveloperSerialization()
              .parseGenerateContentResponse(jsonResponse);
          final groundingMetadata = response.candidates.first.groundingMetadata;

          expect(groundingMetadata, isNotNull);
          expect(groundingMetadata!.webSearchQueries,
              equals(['query1', 'query2']));
          expect(groundingMetadata.searchEntryPoint?.renderedContent,
              '<div></div>');

          final groundingChunk = groundingMetadata.groundingChunks.first;
          expect(groundingChunk.web?.uri, 'http://example.com/1');
          expect(groundingChunk.web?.title, 'Example Page 1');
          expect(groundingChunk.web?.domain, isNull);

          final groundingSupport = groundingMetadata.groundingSupport.first;
          expect(groundingSupport.segment.startIndex, 5);
          expect(groundingSupport.segment.endIndex, 13);
          expect(groundingSupport.segment.partIndex, 0);
          expect(groundingSupport.segment.text, 'grounded');
          expect(groundingSupport.groundingChunkIndices, [0]);
        });

        test(
            'parses groundingMetadata with all optional fields null/missing and empty lists',
            () {
          final jsonResponse = {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Test'}
                  ]
                },
                'finishReason': 'STOP',
                'groundingMetadata': {
                  // All fields are missing
                }
              }
            ]
          };
          final response = DeveloperSerialization()
              .parseGenerateContentResponse(jsonResponse);
          final groundingMetadata = response.candidates.first.groundingMetadata;

          expect(groundingMetadata, isNotNull);
          expect(groundingMetadata!.searchEntryPoint, isNull);
          expect(groundingMetadata.groundingChunks, isEmpty);
          expect(groundingMetadata.groundingSupport, isEmpty);
          expect(groundingMetadata.webSearchQueries, isEmpty);
        });

        test('handles absence of groundingMetadata field', () {
          final jsonResponse = {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Test'}
                  ]
                },
                'finishReason': 'STOP'
                // No groundingMetadata key
              }
            ]
          };
          final response = DeveloperSerialization()
              .parseGenerateContentResponse(jsonResponse);
          final candidate = response.candidates.first;
          expect(candidate.groundingMetadata, isNull);
        });

        test(
            'throws FormatException if renderedContent is missing in searchEntryPoint',
            () {
          final jsonResponse = {
            'candidates': [
              {
                'groundingMetadata': {'searchEntryPoint': {}}
              }
            ]
          };

          expect(
              () => DeveloperSerialization()
                  .parseGenerateContentResponse(jsonResponse),
              throwsA(isA<FirebaseAISdkException>().having(
                  (e) => e.message, 'message', contains('SearchEntryPoint'))));
        });

        test(
            'parses groundingSupport and filters out entries without a segment',
            () {
          final jsonResponse = {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Test'}
                  ]
                },
                'finishReason': 'STOP',
                'groundingMetadata': {
                  'groundingSupport': [
                    // Valid entry
                    {
                      'segment': {
                        'startIndex': 0,
                        'endIndex': 4,
                        'text': 'Test'
                      },
                      'groundingChunkIndices': [0]
                    },
                    // Invalid entry - missing segment
                    {
                      'groundingChunkIndices': [1]
                    },
                    // Invalid entry - empty object
                    {}
                  ]
                }
              }
            ]
          };

          final response = DeveloperSerialization()
              .parseGenerateContentResponse(jsonResponse);
          final groundingMetadata = response.candidates.first.groundingMetadata;

          expect(groundingMetadata, isNotNull);
          // The invalid entries should be filtered out.
          expect(groundingMetadata!.groundingSupport, hasLength(1));

          final validSupport = groundingMetadata.groundingSupport.first;
          expect(validSupport.segment.text, 'Test');
          expect(validSupport.groundingChunkIndices, [0]);
        });
      });

      test('parses usageMetadata when token details are missing', () {
        final jsonResponse = {
          'usageMetadata': {
            'promptTokenCount': 10,
            'candidatesTokenCount': 25,
            'totalTokenCount': 35,
          }
        };

        final response =
            DeveloperSerialization().parseGenerateContentResponse(jsonResponse);

        expect(response.usageMetadata, isNotNull);
        expect(response.usageMetadata!.promptTokenCount, 10);
        expect(response.usageMetadata!.candidatesTokenCount, 25);
        expect(response.usageMetadata!.totalTokenCount, 35);
        expect(response.usageMetadata!.promptTokensDetails, isNull);
        expect(response.usageMetadata!.candidatesTokensDetails, isNull);
      });

      test('parses inlineData part correctly', () {
        final inlineData = Uint8List.fromList([1, 2, 3, 4]);
        final jsonResponse = {
          'candidates': [
            {
              'content': {
                'role': 'model',
                'parts': [
                  {
                    'inlineData': {
                      'mimeType': 'application/octet-stream',
                      'data': base64Encode(inlineData),
                    }
                  }
                ]
              },
              'finishReason': 'STOP',
            }
          ],
        };
        final response =
            DeveloperSerialization().parseGenerateContentResponse(jsonResponse);
        final part = response.candidates.first.content.parts.first;
        expect(part, isA<InlineDataPart>());
        expect((part as InlineDataPart).mimeType, 'application/octet-stream');
        expect(part.bytes, inlineData);
      });
    });
  });
}
