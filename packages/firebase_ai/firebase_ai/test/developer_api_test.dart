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

import 'package:firebase_ai/src/api.dart';
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
            'toolUsePromptTokensDetails': [
              {'modality': 'TEXT', 'tokenCount': 12}
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
        expect(response.usageMetadata!.toolUsePromptTokensDetails, isNotNull);
        expect(
            response.usageMetadata!.toolUsePromptTokensDetails, hasLength(1));
        expect(
            response
                .usageMetadata!.toolUsePromptTokensDetails!.first.tokenCount,
            12);
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
                  'groundingSupports': [
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

          final groundingSupports = groundingMetadata.groundingSupports.first;
          expect(groundingSupports.segment.startIndex, 5);
          expect(groundingSupports.segment.endIndex, 13);
          expect(groundingSupports.segment.partIndex, 0);
          expect(groundingSupports.segment.text, 'grounded');
          expect(groundingSupports.groundingChunkIndices, [0]);
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
          expect(groundingMetadata.groundingSupports, isEmpty);
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
            'parses groundingSupports and filters out entries without a segment',
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
                  'groundingSupports': [
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
          expect(groundingMetadata!.groundingSupports, hasLength(1));

          final validSupport = groundingMetadata.groundingSupports.first;
          expect(validSupport.segment.text, 'Test');
          expect(validSupport.groundingChunkIndices, [0]);
        });
      });

      group('UrlContextMetadata parsing', () {
        test('parses valid response with full url context metadata', () {
          final jsonResponse = {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Some text'}
                  ]
                },
                'finishReason': 'STOP',
                'urlContextMetadata': {
                  'urlMetadata': [
                    {
                      'retrievedUrl': 'https://example.com',
                      'urlRetrievalStatus': 'URL_RETRIEVAL_STATUS_SUCCESS'
                    }
                  ]
                }
              }
            ]
          };
          final response = DeveloperSerialization()
              .parseGenerateContentResponse(jsonResponse);
          final urlContextMetadata =
              response.candidates.first.urlContextMetadata;
          expect(urlContextMetadata, isNotNull);
          expect(urlContextMetadata!.urlMetadata, hasLength(1));
          final urlMetadata = urlContextMetadata.urlMetadata.first;
          expect(urlMetadata.retrievedUrl, Uri.parse('https://example.com'));
          expect(urlMetadata.urlRetrievalStatus, UrlRetrievalStatus.success);
        });

        test('parses response with missing retrievedUrl', () {
          final jsonResponse = {
            'candidates': [
              {
                'urlContextMetadata': {
                  'urlMetadata': [
                    {'urlRetrievalStatus': 'URL_RETRIEVAL_STATUS_ERROR'}
                  ]
                }
              }
            ]
          };
          final response = DeveloperSerialization()
              .parseGenerateContentResponse(jsonResponse);
          final urlMetadata =
              response.candidates.first.urlContextMetadata!.urlMetadata.first;
          expect(urlMetadata.retrievedUrl, isNull);
          expect(urlMetadata.urlRetrievalStatus, UrlRetrievalStatus.error);
        });

        test('handles empty urlMetadata list', () {
          final jsonResponse = {
            'candidates': [
              {
                'urlContextMetadata': {'urlMetadata': []}
              }
            ]
          };
          final response = DeveloperSerialization()
              .parseGenerateContentResponse(jsonResponse);
          final urlContextMetadata =
              response.candidates.first.urlContextMetadata;
          expect(urlContextMetadata, isNotNull);
          expect(urlContextMetadata!.urlMetadata, isEmpty);
        });

        test('handles missing urlContextMetadata field', () {
          final jsonResponse = {
            'candidates': [
              {'finishReason': 'STOP'}
            ]
          };
          final response = DeveloperSerialization()
              .parseGenerateContentResponse(jsonResponse);
          final candidate = response.candidates.first;
          expect(candidate.urlContextMetadata, isNull);
        });

        test('throws for invalid urlContextMetadata structure', () {
          final jsonResponse = {
            'candidates': [
              {'urlContextMetadata': 'not_a_map'}
            ]
          };
          expect(
              () => DeveloperSerialization()
                  .parseGenerateContentResponse(jsonResponse),
              throwsA(isA<FirebaseAISdkException>().having((e) => e.message,
                  'message', contains('UrlContextMetadata'))));
        });

        test('throws for invalid urlMetadata item in list', () {
          final jsonResponse = {
            'candidates': [
              {
                'urlContextMetadata': {
                  'urlMetadata': ['not_a_map']
                }
              }
            ]
          };
          expect(
              () => DeveloperSerialization()
                  .parseGenerateContentResponse(jsonResponse),
              throwsA(isA<FirebaseAISdkException>().having(
                  (e) => e.message, 'message', contains('UrlMetadata'))));
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

      test('parses safety ratings specific to developer API', () {
        final jsonResponse = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Test'}
                ]
              },
              'safetyRatings': [
                {
                  'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                  'probability': 'HIGH',
                  'blocked': true,
                  // These fields should be ignored by the developer parser
                  'severity': 'HARM_SEVERITY_HIGH',
                  'severityScore': 0.9
                }
              ]
            }
          ]
        };
        final response =
            DeveloperSerialization().parseGenerateContentResponse(jsonResponse);
        final rating = response.candidates.first.safetyRatings!.first;
        expect(rating.category, HarmCategory.dangerousContent);
        expect(rating.probability, HarmProbability.high);
        expect(rating.isBlocked, true);
        expect(rating.severity, isNull);
        expect(rating.severityScore, isNull);
      });
    });

    group('parseCountTokensResponse', () {
      test('parses valid JSON correctly', () {
        final json = {'totalTokens': 123};
        final response =
            DeveloperSerialization().parseCountTokensResponse(json);
        expect(response.totalTokens, 123);
        // Developer API does not return other fields
        // ignore: deprecated_member_use_from_same_package
        expect(response.totalBillableCharacters, isNull);
        expect(response.promptTokensDetails, isNull);
      });

      test('throws FirebaseAIException on error response', () {
        final json = {
          'error': {'code': 400, 'message': 'Invalid request'}
        };
        expect(() => DeveloperSerialization().parseCountTokensResponse(json),
            throwsA(isA<FirebaseAIException>()));
      });

      test('throws unhandledFormat on invalid JSON', () {
        final json = {'wrongKey': 123};
        expect(() => DeveloperSerialization().parseCountTokensResponse(json),
            throwsA(isA<FirebaseAISdkException>()));
      });
    });

    group('generateContentRequest', () {
      test('serializes safetySettings correctly for developer API', () {
        final request = DeveloperSerialization().generateContentRequest(
          [],
          (prefix: 'models', name: 'gemini-pro'),
          [
            SafetySetting(
                HarmCategory.dangerousContent, HarmBlockThreshold.high, null)
          ],
          null,
          null,
          null,
          null,
        );
        final safetySettings = request['safetySettings']! as List;
        expect(safetySettings, hasLength(1));
        expect(safetySettings.first, {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_ONLY_HIGH'
        });
      });

      test('throws ArgumentError for safetySetting with method', () {
        expect(
            () => DeveloperSerialization().generateContentRequest(
                  [],
                  (prefix: 'models', name: 'gemini-pro'),
                  [
                    SafetySetting(HarmCategory.dangerousContent,
                        HarmBlockThreshold.high, HarmBlockMethod.severity)
                  ],
                  null,
                  null,
                  null,
                  null,
                ),
            throwsA(isA<ArgumentError>()));
      });
    });

    group('countTokensRequest', () {
      test('serializes request with generateContentRequest wrapper', () {
        final request = DeveloperSerialization().countTokensRequest(
          [Content.text('hello')],
          (prefix: 'models', name: 'gemini-pro'),
          [],
          null,
          null,
          null,
        );
        expect(request.containsKey('generateContentRequest'), isTrue);
        final wrappedRequest =
            request['generateContentRequest']! as Map<String, Object?>;
        expect(wrappedRequest['model'], 'models/gemini-pro');
        final contents = wrappedRequest['contents']! as List;
        expect(contents, hasLength(1));
      });
    });
  });
}
