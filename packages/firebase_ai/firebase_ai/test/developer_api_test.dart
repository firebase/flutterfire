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
          }
        };
        final response =
            DeveloperSerialization().parseGenerateContentResponse(jsonResponse);
        expect(response.usageMetadata, isNotNull);
        expect(response.usageMetadata!.promptTokenCount, 10);
        expect(response.usageMetadata!.candidatesTokenCount, 5);
        expect(response.usageMetadata!.totalTokenCount, 15);
        expect(response.usageMetadata!.thoughtsTokenCount, 3);
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

      test(
          'parses usageMetadata with prompt and candidate token details correctly',
          () {
        final jsonResponse = {
          'usageMetadata': {
            'promptTokenCount': 10,
            'candidatesTokenCount': 25,
            'totalTokenCount': 35,
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
        expect(response.usageMetadata!.candidatesTokenCount, 25);
        expect(response.usageMetadata!.totalTokenCount, 35);
        expect(response.usageMetadata!.promptTokensDetails, isNotNull);
        expect(response.usageMetadata!.promptTokensDetails, hasLength(1));
        expect(response.usageMetadata!.promptTokensDetails!.first.tokenCount,
            10);
        expect(response.usageMetadata!.candidatesTokensDetails, isNotNull);
        expect(response.usageMetadata!.candidatesTokensDetails, hasLength(1));
        expect(response.usageMetadata!.candidatesTokensDetails!.first.tokenCount,
            25);
      });
    });
  });
}
