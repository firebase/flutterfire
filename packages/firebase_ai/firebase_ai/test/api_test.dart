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

// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:convert';

import 'package:firebase_ai/src/api.dart';
import 'package:firebase_ai/src/content.dart';
import 'package:firebase_ai/src/error.dart';
import 'package:firebase_ai/src/schema.dart';
import 'package:flutter_test/flutter_test.dart';

// --- Mock/Helper Implementations ---
// Minimal implementations or mocks for classes from imported files
// to make tests self-contained and focused on the target file's logic.

void main() {
  group('CountTokensResponse', () {
    test('constructor initializes fields correctly', () {
      final details = [ModalityTokenCount(ContentModality.text, 10)];
      final response = CountTokensResponse(100, promptTokensDetails: details);
      expect(response.totalTokens, 100);
      expect(response.promptTokensDetails, same(details));
    });

    test('constructor with null optional fields', () {
      final response = CountTokensResponse(100);
      expect(response.totalTokens, 100);
      expect(response.promptTokensDetails, isNull);
    });
  });

  group('GenerateContentResponse', () {
    // Mock candidates

    final textContent = Content.text('Hello');

    final candidateWithText =
        Candidate(textContent, null, null, FinishReason.stop, null);
    final candidateWithMultipleTextParts = Candidate(
        Content('model', [const TextPart('Hello'), const TextPart(' World')]),
        null,
        null,
        FinishReason.stop,
        null);

    final candidateFinishedSafety = Candidate(
        textContent, null, null, FinishReason.safety, 'Safety concern');
    final candidateFinishedRecitation = Candidate(
        textContent, null, null, FinishReason.recitation, 'Recited content');

    group('.text getter', () {
      test('returns null if no candidates and no prompt feedback', () {
        final response = GenerateContentResponse([], null);
        expect(response.text, isNull);
      });

      test(
          'throws FirebaseAIException if prompt was blocked without message or reason',
          () {
        final feedback = PromptFeedback(BlockReason.safety, null, []);
        final response = GenerateContentResponse([], feedback);
        expect(
            () => response.text,
            throwsA(isA<FirebaseAIException>().having((e) => e.message,
                'message', 'Response was blocked due to safety')));
      });

      test(
          'throws FirebaseAIException if prompt was blocked with reason and message',
          () {
        final feedback =
            PromptFeedback(BlockReason.other, 'Custom block message', []);
        final response = GenerateContentResponse([], feedback);
        expect(
            () => response.text,
            throwsA(isA<FirebaseAIException>().having(
                (e) => e.message,
                'message',
                'Response was blocked due to other: Custom block message')));
      });

      test(
          'throws FirebaseAIException if first candidate finished due to safety',
          () {
        final response =
            GenerateContentResponse([candidateFinishedSafety], null);
        expect(
            () => response.text,
            throwsA(isA<FirebaseAIException>().having(
                (e) => e.message,
                'message',
                'Candidate was blocked due to safety: Safety concern')));
      });
      test(
          'throws FirebaseAIException if first candidate finished due to safety without message',
          () {
        final candidateFinishedSafetyNoMsg =
            Candidate(textContent, null, null, FinishReason.safety, '');
        final response =
            GenerateContentResponse([candidateFinishedSafetyNoMsg], null);
        expect(
            () => response.text,
            throwsA(isA<FirebaseAIException>().having((e) => e.message,
                'message', 'Candidate was blocked due to safety')));
      });

      test(
          'throws FirebaseAIException if first candidate finished due to recitation',
          () {
        final response =
            GenerateContentResponse([candidateFinishedRecitation], null);
        expect(
            () => response.text,
            throwsA(isA<FirebaseAIException>().having(
                (e) => e.message,
                'message',
                'Candidate was blocked due to recitation: Recited content')));
      });

      test('returns text from single TextPart in first candidate', () {
        final response = GenerateContentResponse([candidateWithText], null);
        expect(response.text, 'Hello');
      });

      test('concatenates text from multiple TextParts in first candidate', () {
        final response =
            GenerateContentResponse([candidateWithMultipleTextParts], null);
        expect(response.text, 'Hello World');
      });
    });

    group('.functionCalls getter', () {
      test('returns empty list if no candidates', () {
        final response = GenerateContentResponse([], null);
        expect(response.functionCalls, isEmpty);
      });

      test('returns empty list if first candidate has no FunctionCall parts',
          () {
        final response = GenerateContentResponse([candidateWithText], null);
        expect(response.functionCalls, isEmpty);
      });
    });
    test('constructor initializes fields correctly', () {
      final candidates = [candidateWithText];
      final feedback = PromptFeedback(null, null, []);

      final response = GenerateContentResponse(
        candidates,
        feedback,
      );

      expect(response.candidates, same(candidates));
      expect(response.promptFeedback, same(feedback));
    });
  });

  group('PromptFeedback', () {
    test('constructor initializes fields correctly', () {
      final ratings = [
        SafetyRating(HarmCategory.dangerousContent, HarmProbability.high)
      ];
      final feedback = PromptFeedback(BlockReason.safety, 'Blocked', ratings);
      expect(feedback.blockReason, BlockReason.safety);
      expect(feedback.blockReasonMessage, 'Blocked');
      expect(feedback.safetyRatings, same(ratings));
    });
  });

  group('Candidate', () {
    final textContent = Content.text('Test text');
    group('.text getter', () {
      test('throws FirebaseAIException if finishReason is safety with message',
          () {
        final candidate = Candidate(textContent, null, null,
            FinishReason.safety, 'Safety block message');
        expect(
            () => candidate.text,
            throwsA(isA<FirebaseAIException>().having(
                (e) => e.message,
                'message',
                'Candidate was blocked due to safety: Safety block message')));
      });
      test(
          'throws FirebaseAIException if finishReason is safety without message',
          () {
        final candidate = Candidate(
            textContent, null, null, FinishReason.safety, ''); // Empty message
        expect(
            () => candidate.text,
            throwsA(isA<FirebaseAIException>().having((e) => e.message,
                'message', 'Candidate was blocked due to safety')));
      });

      test(
          'throws FirebaseAIException if finishReason is recitation with message',
          () {
        final candidate = Candidate(textContent, null, null,
            FinishReason.recitation, 'Recitation block message');
        expect(
            () => candidate.text,
            throwsA(isA<FirebaseAIException>().having(
                (e) => e.message,
                'message',
                'Candidate was blocked due to recitation: Recitation block message')));
      });

      test('returns text from single TextPart', () {
        final candidate =
            Candidate(textContent, null, null, FinishReason.stop, null);
        expect(candidate.text, 'Test text');
      });

      test('concatenates text from multiple TextParts', () {
        final multiPartContent = Content(
            'model', [const TextPart('Part 1'), const TextPart('. Part 2')]);
        final candidate =
            Candidate(multiPartContent, null, null, FinishReason.stop, null);
        expect(candidate.text, 'Part 1. Part 2');
      });

      test('returns text if finishReason is other non-blocking reason', () {
        final candidate =
            Candidate(textContent, null, null, FinishReason.maxTokens, null);
        expect(candidate.text, 'Test text');
      });
    });
    test('constructor initializes fields correctly', () {
      final content = Content.text('Hello');
      final ratings = [
        SafetyRating(HarmCategory.harassment, HarmProbability.low)
      ];
      final citationMeta = CitationMetadata([]);
      final urlContextMetadata = UrlContextMetadata(urlMetadata: []);
      final candidate = Candidate(
          content, ratings, citationMeta, FinishReason.stop, 'Finished',
          urlContextMetadata: urlContextMetadata);

      expect(candidate.content, same(content));
      expect(candidate.safetyRatings, same(ratings));
      expect(candidate.citationMetadata, same(citationMeta));
      expect(candidate.finishReason, FinishReason.stop);
      expect(candidate.finishMessage, 'Finished');
      expect(candidate.urlContextMetadata, same(urlContextMetadata));
    });
  });

  group('SafetyRating', () {
    test('constructor initializes fields correctly', () {
      final rating = SafetyRating(
          HarmCategory.hateSpeech, HarmProbability.medium,
          probabilityScore: 0.6,
          isBlocked: true,
          severity: HarmSeverity.high,
          severityScore: 0.9);
      expect(rating.category, HarmCategory.hateSpeech);
      expect(rating.probability, HarmProbability.medium);
      expect(rating.probabilityScore, 0.6);
      expect(rating.isBlocked, true);
      expect(rating.severity, HarmSeverity.high);
      expect(rating.severityScore, 0.9);
    });
  });

  group('Enums', () {
    test('BlockReason toJson and toString', () {
      expect(BlockReason.unknown.toJson(), 'UNKNOWN');
      expect(BlockReason.safety.toJson(), 'SAFETY');
      expect(BlockReason.other.toJson(), 'OTHER');
    });

    test('HarmCategory toJson and toString', () {
      expect(HarmCategory.unknown.toJson(), 'UNKNOWN');
      expect(HarmCategory.harassment.toJson(), 'HARM_CATEGORY_HARASSMENT');
      expect(HarmCategory.hateSpeech.toJson(), 'HARM_CATEGORY_HATE_SPEECH');
      expect(HarmCategory.sexuallyExplicit.toJson(),
          'HARM_CATEGORY_SEXUALLY_EXPLICIT');
      expect(HarmCategory.dangerousContent.toJson(),
          'HARM_CATEGORY_DANGEROUS_CONTENT');
    });

    test('HarmProbability toJson and toString', () {
      expect(HarmProbability.unknown.toJson(), 'UNKNOWN');
      expect(HarmProbability.negligible.toJson(), 'NEGLIGIBLE');
      expect(HarmProbability.low.toJson(), 'LOW');
      expect(HarmProbability.medium.toJson(), 'MEDIUM');
      expect(HarmProbability.high.toJson(), 'HIGH');
    });

    test('HarmSeverity toJson and toString', () {
      expect(HarmSeverity.unknown.toJson(), 'UNKNOWN');
      expect(HarmSeverity.negligible.toJson(), 'NEGLIGIBLE');
      expect(HarmSeverity.low.toJson(), 'LOW');
      expect(HarmSeverity.medium.toJson(), 'MEDIUM');
      expect(HarmSeverity.high.toJson(), 'HIGH');
    });

    test('FinishReason toJson and toString', () {
      expect(FinishReason.unknown.toJson(), 'UNKNOWN');
      expect(FinishReason.stop.toJson(), 'STOP');
      expect(FinishReason.maxTokens.toJson(), 'MAX_TOKENS');
      expect(FinishReason.safety.toJson(), 'SAFETY');
      expect(FinishReason.recitation.toJson(), 'RECITATION');
      expect(FinishReason.malformedFunctionCall.toJson(),
          'MALFORMED_FUNCTION_CALL');
      expect(FinishReason.other.toJson(), 'OTHER');
    });

    test('ContentModality toJson and toString', () {
      expect(ContentModality.unspecified.toJson(), 'MODALITY_UNSPECIFIED');
      expect(ContentModality.text.toJson(), 'TEXT');
      expect(ContentModality.image.toJson(), 'IMAGE');
      expect(ContentModality.video.toJson(), 'VIDEO');
      expect(ContentModality.audio.toJson(), 'AUDIO');
      expect(ContentModality.document.toJson(), 'DOCUMENT');
    });

    test('HarmBlockThreshold toJson and toString', () {
      expect(HarmBlockThreshold.low.toJson(), 'BLOCK_LOW_AND_ABOVE');
      expect(HarmBlockThreshold.medium.toJson(), 'BLOCK_MEDIUM_AND_ABOVE');
      expect(HarmBlockThreshold.high.toJson(), 'BLOCK_ONLY_HIGH');
      expect(HarmBlockThreshold.none.toJson(), 'BLOCK_NONE');
      expect(HarmBlockThreshold.off.toJson(), 'OFF');
    });

    test('HarmBlockMethod toJson and toString', () {
      expect(HarmBlockMethod.severity.toJson(), 'SEVERITY');
      expect(HarmBlockMethod.probability.toJson(), 'PROBABILITY');
      expect(HarmBlockMethod.unspecified.toJson(),
          'HARM_BLOCK_METHOD_UNSPECIFIED');
    });

    test('TaskType toJson and toString', () {
      expect(TaskType.unspecified.toJson(), 'TASK_TYPE_UNSPECIFIED');
      expect(TaskType.retrievalQuery.toJson(), 'RETRIEVAL_QUERY');
      expect(TaskType.retrievalDocument.toJson(), 'RETRIEVAL_DOCUMENT');
      expect(TaskType.semanticSimilarity.toJson(), 'SEMANTIC_SIMILARITY');
      expect(TaskType.classification.toJson(), 'CLASSIFICATION');
      expect(TaskType.clustering.toJson(), 'CLUSTERING');
    });
  });

  group('CitationMetadata and Citation', () {
    test('Citation constructor', () {
      final uri = Uri.parse('http://example.com');
      final citation = Citation(0, 10, uri, 'Apache-2.0');
      expect(citation.startIndex, 0);
      expect(citation.endIndex, 10);
      expect(citation.uri, uri);
      expect(citation.license, 'Apache-2.0');
    });
    test('CitationMetadata constructor', () {
      final citation = Citation(0, 5, Uri.parse('a.com'), 'MIT');
      final metadata = CitationMetadata([citation]);
      expect(metadata.citations, hasLength(1));
      expect(metadata.citations.first, same(citation));
    });
  });

  group('ModalityTokenCount', () {
    test('constructor initializes fields correctly', () {
      final mtc = ModalityTokenCount(ContentModality.image, 150);
      expect(mtc.modality, ContentModality.image);
      expect(mtc.tokenCount, 150);
    });
  });

  group('SafetySetting', () {
    test('toJson with all fields', () {
      final setting = SafetySetting(HarmCategory.dangerousContent,
          HarmBlockThreshold.medium, HarmBlockMethod.severity);
      expect(setting.toJson(), {
        'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
        'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        'method': 'SEVERITY',
      });
    });

    test('toJson with method null (default to probability in spirit)', () {
      // The toJson implementation will omit method if null
      final setting =
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.low, null);
      expect(setting.toJson(), {
        'category': 'HARM_CATEGORY_HARASSMENT',
        'threshold': 'BLOCK_LOW_AND_ABOVE',
      });
    });
  });

  group('GroundingMetadata', () {
    test('constructor initializes fields correctly', () {
      final searchEntryPoint = SearchEntryPoint(renderedContent: '<div></div>');
      final groundingChunk = GroundingChunk(web: WebGroundingChunk(uri: 'uri'));
      final groundingSupport = GroundingSupport(
          segment: Segment(startIndex: 0, partIndex: 0, endIndex: 1, text: ''),
          groundingChunkIndices: [0]);
      final metadata = GroundingMetadata(
        searchEntryPoint: searchEntryPoint,
        groundingChunks: [groundingChunk],
        groundingSupport: [groundingSupport],
        webSearchQueries: ['web query'],
      );

      expect(metadata.searchEntryPoint, same(searchEntryPoint));
      expect(metadata.groundingChunks.first, same(groundingChunk));
      expect(metadata.groundingSupport.first, same(groundingSupport));
      expect(metadata.webSearchQueries, ['web query']);
    });
  });

  group('UrlContextMetadata', () {
    test('UrlMetadata constructor', () {
      final uri = Uri.parse('http://example.com/page');
      final metadata = UrlMetadata(
          retrievedUrl: uri, urlRetrievalStatus: UrlRetrievalStatus.success);
      expect(metadata.retrievedUrl, uri);
      expect(metadata.urlRetrievalStatus, UrlRetrievalStatus.success);
    });

    test('UrlContextMetadata constructor', () {
      final urlMetadata = UrlMetadata(
          retrievedUrl: Uri.parse('http://example.com'),
          urlRetrievalStatus: UrlRetrievalStatus.success);
      final contextMetadata = UrlContextMetadata(urlMetadata: [urlMetadata]);
      expect(contextMetadata.urlMetadata, hasLength(1));
      expect(contextMetadata.urlMetadata.first, same(urlMetadata));
    });
  });

  group('GenerationConfig & BaseGenerationConfig', () {
    test('GenerationConfig toJson with all fields', () {
      final schema = Schema.object(properties: {});
      final thinkingConfig = ThinkingConfig(thinkingBudget: 100);
      final config = GenerationConfig(
        candidateCount: 1,
        stopSequences: ['\n', 'stop'],
        maxOutputTokens: 200,
        temperature: 0.7,
        topP: 0.95,
        topK: 50,
        presencePenalty: 0.3,
        frequencyPenalty: 0.4,
        responseMimeType: 'application/json',
        responseSchema: schema,
        thinkingConfig: thinkingConfig,
      );
      expect(config.toJson(), {
        'candidateCount': 1,
        'maxOutputTokens': 200,
        'temperature': 0.7,
        'topP': 0.95,
        'topK': 50,
        'presencePenalty': 0.3,
        'frequencyPenalty': 0.4,
        'stopSequences': ['\n', 'stop'],
        'responseMimeType': 'application/json',
        'responseSchema': schema.toJson(),
        'thinkingConfig': {'thinkingBudget': 100},
      });
    });

    test('GenerationConfig toJson with responseJsonSchema', () {
      final jsonSchema = {
        'type': 'object',
        'properties': {
          'recipeName': {'type': 'string'}
        },
        'required': ['recipeName']
      };
      final config = GenerationConfig(
        responseMimeType: 'application/json',
        responseJsonSchema: jsonSchema,
      );
      final json = config.toJson();
      expect(json['responseMimeType'], 'application/json');
      final dynamic responseSchema = json['responseJsonSchema'];
      expect(responseSchema, isA<Map<String, Object?>>());
      expect(responseSchema, equals(jsonSchema));
    });

    test(
        'throws assertion if both responseSchema and responseJsonSchema are provided',
        () {
      final schema = Schema.object(properties: {});
      final jsonSchema =
          (json.decode('{"type": "string", "title": "MyString"}') as Map)
              .cast<String, Object?>();
      expect(
          () => GenerationConfig(
              responseSchema: schema, responseJsonSchema: jsonSchema),
          throwsA(isA<AssertionError>()));
    });

    test('GenerationConfig toJson with empty stopSequences (omitted)', () {
      final config = GenerationConfig(stopSequences: []);
      expect(config.toJson(), {}); // Empty list for stopSequences is omitted
    });

    test('GenerationConfig toJson with some fields null', () {
      final config = GenerationConfig(
        temperature: 0.7,
        responseMimeType: 'text/plain',
      );
      expect(config.toJson(), {
        'temperature': 0.7,
        'responseMimeType': 'text/plain',
      });
    });

    test('GenerationConfig toJson without thinkingConfig', () {
      final config = GenerationConfig(temperature: 0.5);
      expect(config.toJson(), {'temperature': 0.5});
    });
  });

  group('ThinkingConfig', () {
    test('toJson with thinkingBudget set', () {
      final config = ThinkingConfig(thinkingBudget: 123);

      expect(config.toJson(), {'thinkingBudget': 123});
    });

    test('toJson with thinkingLevel set', () {
      final config = ThinkingConfig.withThinkingLevel(ThinkingLevel.high,
          includeThoughts: true);

      expect(
          config.toJson(), {'thinkingLevel': 'HIGH', 'includeThoughts': true});
    });

    test('toJson with includeThoughts set', () {
      final config = ThinkingConfig(includeThoughts: true);

      expect(config.toJson(), {'includeThoughts': true});
    });

    test('toJson with thinkingBudget and thinkingLevel null', () {
      final config = ThinkingConfig();

      // Expecting the key to be absent or the value to be explicitly null,
      // depending on implementation. Current implementation omits the key.
      expect(config.toJson(), {});
    });

    test('constructor initializes thinkingBudget', () {
      final config = ThinkingConfig(thinkingBudget: 456);

      expect(config.thinkingBudget, 456);
      expect(config.thinkingLevel, isNull);
      expect(config.includeThoughts, isNull);
    });

    test('constructor initializes thinkingLevel', () {
      final config = ThinkingConfig(thinkingLevel: ThinkingLevel.low);

      expect(config.thinkingBudget, isNull);
      expect(config.thinkingLevel, ThinkingLevel.low);
      expect(config.includeThoughts, isNull);
    });

    test('constructor initializes includeThoughts', () {
      final config = ThinkingConfig(includeThoughts: true);

      expect(config.thinkingBudget, isNull);
      expect(config.thinkingLevel, isNull);
      expect(config.includeThoughts, isTrue);
    });

    test('withThinkingBudget factory initializes correctly', () {
      final config =
          ThinkingConfig.withThinkingBudget(789, includeThoughts: false);

      expect(config.thinkingBudget, 789);
      expect(config.thinkingLevel, isNull);
      expect(config.includeThoughts, isFalse);
    });

    test('withThinkingLevel factory initializes correctly', () {
      final config = ThinkingConfig.withThinkingLevel(ThinkingLevel.medium,
          includeThoughts: true);

      expect(config.thinkingBudget, isNull);
      expect(config.thinkingLevel, ThinkingLevel.medium);
      expect(config.includeThoughts, isTrue);
    });

    test(
        'deprecated constructor throws AssertionError if both thinkingBudget and thinkingLevel are provided',
        () {
      expect(
          () => ThinkingConfig(
              thinkingBudget: 100, thinkingLevel: ThinkingLevel.high),
          throwsA(isA<AssertionError>()));
    });
  });

  group('Parsing Functions', () {
    group('parseCountTokensResponse', () {
      test('parses valid full JSON correctly', () {
        final json = {
          'totalTokens': 120,
          'promptTokensDetails': [
            {
              'modality': 'TEXT',
            },
            {'modality': 'IMAGE', 'tokenCount': 20}
          ]
        };
        final response = VertexSerialization().parseCountTokensResponse(json);
        expect(response.totalTokens, 120);
        expect(response.promptTokensDetails, isNotNull);
        expect(response.promptTokensDetails, hasLength(2));
        expect(response.promptTokensDetails![0].modality, ContentModality.text);
        expect(response.promptTokensDetails![0].tokenCount, 0);
        expect(
            response.promptTokensDetails![1].modality, ContentModality.image);
        expect(response.promptTokensDetails![1].tokenCount, 20);
      });

      test('parses valid JSON with minimal fields (only totalTokens)', () {
        final json = {'totalTokens': 50};
        final response = VertexSerialization().parseCountTokensResponse(json);
        expect(response.totalTokens, 50);
        expect(response.promptTokensDetails, isNull);
      });

      test('throws FirebaseAIException if JSON contains error field', () {
        final json = {
          'error': {'code': 400, 'message': 'Invalid request'}
        };
        expect(() => VertexSerialization().parseCountTokensResponse(json),
            throwsA(isA<FirebaseAIException>()));
      });

      test('throws FormatException for invalid JSON structure (not a Map)', () {
        const json = 'not_a_map';
        expect(
            () => VertexSerialization().parseCountTokensResponse(json),
            throwsA(isA<FirebaseAISdkException>().having(
                (e) => e.message, 'message', contains('CountTokensResponse'))));
      });

      test('throws if totalTokens is missing', () {
        final json = {'totalBillableCharacters': 100};
        expect(() => VertexSerialization().parseCountTokensResponse(json),
            throwsA(anything)); // More specific error expected
      });
    });

    group('parseGenerateContentResponse', () {
      final basicCandidateJson = {
        'content': {
          'role': 'model',
          'parts': [
            {'text': 'Hello world'}
          ]
        },
        'finishReason': 'STOP',
        'safetyRatings': [
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'probability': 'NEGLIGIBLE'
          }
        ]
      };

      test('parses valid JSON with candidates and promptFeedback', () {
        final json = {
          'candidates': [basicCandidateJson],
          'promptFeedback': {
            'blockReason': 'SAFETY',
            'blockReasonMessage': 'Prompt was too spicy.',
            'safetyRatings': [
              {
                'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                'probability': 'HIGH',
                'blocked': true,
                'severity': 'HARM_SEVERITY_HIGH',
                'severityScore': 0.95
              }
            ]
          },
          'usageMetadata': {
            'promptTokenCount': 10,
            'candidatesTokenCount': 20,
            'totalTokenCount': 30,
            'promptTokensDetails': [
              {'modality': 'TEXT', 'tokenCount': 10}
            ],
            'candidatesTokensDetails': [
              {'modality': 'TEXT', 'tokenCount': 20}
            ],
          }
        };
        final response =
            VertexSerialization().parseGenerateContentResponse(json);
        expect(response.candidates, hasLength(1));
        expect(response.candidates.first.text, 'Hello world');
        expect(response.candidates.first.finishReason, FinishReason.stop);
        expect(response.candidates.first.safetyRatings, isNotNull);
        expect(response.candidates.first.safetyRatings, hasLength(1));

        expect(response.promptFeedback, isNotNull);
        expect(response.promptFeedback!.blockReason, BlockReason.safety);
        expect(response.promptFeedback!.blockReasonMessage,
            'Prompt was too spicy.');
        expect(response.promptFeedback!.safetyRatings, hasLength(1));
        expect(response.promptFeedback!.safetyRatings.first.category,
            HarmCategory.dangerousContent);
        expect(response.promptFeedback!.safetyRatings.first.probability,
            HarmProbability.high);
        expect(response.promptFeedback!.safetyRatings.first.isBlocked, true);
        expect(response.promptFeedback!.safetyRatings.first.severity,
            HarmSeverity.high);
        expect(
            response.promptFeedback!.safetyRatings.first.severityScore, 0.95);

        expect(response.usageMetadata, isNotNull);
        expect(response.usageMetadata!.promptTokenCount, 10);
        expect(response.usageMetadata!.candidatesTokenCount, 20);
        expect(response.usageMetadata!.totalTokenCount, 30);
        expect(response.usageMetadata!.promptTokensDetails, hasLength(1));
        expect(response.usageMetadata!.candidatesTokensDetails, hasLength(1));
      });

      group('usageMetadata parsing', () {
        test('parses usageMetadata when thoughtsTokenCount is set', () {
          final json = {
            'usageMetadata': {
              'promptTokenCount': 10,
              'candidatesTokenCount': 20,
              'totalTokenCount': 30,
              'thoughtsTokenCount': 5,
              'toolUsePromptTokenCount': 12
            }
          };
          final response =
              VertexSerialization().parseGenerateContentResponse(json);
          expect(response.usageMetadata, isNotNull);
          expect(response.usageMetadata!.promptTokenCount, 10);
          expect(response.usageMetadata!.candidatesTokenCount, 20);
          expect(response.usageMetadata!.totalTokenCount, 30);
          expect(response.usageMetadata!.thoughtsTokenCount, 5);
          expect(response.usageMetadata!.toolUsePromptTokenCount, 12);
        });

        test('parses usageMetadata when thoughtsTokenCount is missing', () {
          final json = {
            'usageMetadata': {
              'promptTokenCount': 10,
              'candidatesTokenCount': 20,
              'totalTokenCount': 30,
            }
          };
          final response =
              VertexSerialization().parseGenerateContentResponse(json);
          expect(response.usageMetadata, isNotNull);
          expect(response.usageMetadata!.thoughtsTokenCount, isNull);
        });
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

          final response =
              VertexSerialization().parseGenerateContentResponse(jsonResponse);
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

        test('parses with empty or minimal grounding sub-components', () {
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
                  'groundingChunks': [
                    {},
                    {'web': {}},
                  ],
                  'groundingSupport': [
                    {},
                    {
                      'groundingChunkIndices': [0],
                    },
                    {
                      'groundingChunkIndices': [0],
                      'segment': {
                        'startIndex': 5,
                        'partIndex': 0,
                        'endIndex': 13,
                        'text': 'grounded'
                      },
                    }
                  ]
                }
              }
            ]
          };

          final response =
              VertexSerialization().parseGenerateContentResponse(jsonResponse);
          final groundingMetadata = response.candidates.first.groundingMetadata;

          expect(groundingMetadata, isNotNull);
          expect(groundingMetadata!.webSearchQueries,
              equals(['query1', 'query2']));

          expect(groundingMetadata.searchEntryPoint, isNull);
          expect(groundingMetadata.groundingChunks[0].web, isNull);

          expect(groundingMetadata.groundingChunks[1].web, isNotNull);
          expect(groundingMetadata.groundingChunks[1].web?.uri, isNull);
          expect(groundingMetadata.groundingChunks[1].web?.title, isNull);
          expect(groundingMetadata.groundingChunks[1].web?.domain, isNull);

          expect(
              groundingMetadata.groundingSupport,
              hasLength(
                  1)); // GroundingSupport's without a segment are filtered out
          final firstSupport = groundingMetadata.groundingSupport[0];
          expect(firstSupport.segment, isNotNull);
          expect(firstSupport.groundingChunkIndices, isNotEmpty);
        });

        test(
            'throws FormatException if renderedContent is missing in searchEntryPoint',
            () {
          final jsonResponse = {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'This is a grounded response.'}
                  ]
                },
                'finishReason': 'STOP',
                'groundingMetadata': {'searchEntryPoint': {}}
              }
            ]
          };

          expect(
              () => VertexSerialization()
                  .parseGenerateContentResponse(jsonResponse),
              throwsA(isA<FirebaseAISdkException>().having(
                  (e) => e.message, 'message', contains('SearchEntryPoint'))));
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
                  // searchEntryPoint is missing
                  // groundingChunks is missing (defaults to [])
                  // groundingSupport is missing (defaults to [])
                  // webSearchQueries is missing (defaults to [])
                }
              }
            ]
          };
          final response =
              VertexSerialization().parseGenerateContentResponse(jsonResponse);
          final groundingMetadata = response.candidates.first.groundingMetadata;

          expect(groundingMetadata, isNotNull);
          expect(groundingMetadata!.searchEntryPoint, isNull);
          expect(groundingMetadata.groundingChunks, isEmpty);
          expect(groundingMetadata.groundingSupport, isEmpty);
          expect(groundingMetadata.webSearchQueries, isEmpty);
        });

        test('throws FormatException for invalid item in groundingChunks', () {
          final json = {
            'candidates': [
              {
                'groundingMetadata': {
                  'groundingChunks': ['not_a_map']
                }
              }
            ]
          };
          expect(
              () => VertexSerialization().parseGenerateContentResponse(json),
              throwsA(isA<FirebaseAISdkException>().having(
                  (e) => e.message, 'message', contains('GroundingChunk'))));
        });

        test('throws FormatException for invalid item in groundingSupport', () {
          final json = {
            'candidates': [
              {
                'groundingMetadata': {
                  'groundingSupport': ['not_a_map']
                }
              }
            ]
          };
          expect(
              () => VertexSerialization().parseGenerateContentResponse(json),
              throwsA(isA<FirebaseAISdkException>().having(
                  (e) => e.message, 'message', contains('GroundingSupport'))));
        });

        test('throws FormatException for invalid searchEntryPoint structure',
            () {
          final json = {
            'candidates': [
              {
                'groundingMetadata': {'searchEntryPoint': 'not_a_map'}
              }
            ]
          };
          expect(
              () => VertexSerialization().parseGenerateContentResponse(json),
              throwsA(isA<FirebaseAISdkException>().having(
                  (e) => e.message, 'message', contains('SearchEntryPoint'))));
        });

        test(
            'throws FormatException for invalid segment structure in groundingSupport',
            () {
          final json = {
            'candidates': [
              {
                'groundingMetadata': {
                  'groundingSupport': [
                    {'segment': 'not_a_map'}
                  ]
                }
              }
            ]
          };
          expect(
              () => VertexSerialization().parseGenerateContentResponse(json),
              throwsA(isA<FirebaseAISdkException>()
                  .having((e) => e.message, 'message', contains('Segment'))));
        });

        test(
            'throws FormatException for invalid web structure in groundingChunk',
            () {
          final json = {
            'candidates': [
              {
                'groundingMetadata': {
                  'groundingChunks': [
                    {'web': 'not_a_map'}
                  ]
                }
              }
            ]
          };
          expect(
              () => VertexSerialization().parseGenerateContentResponse(json),
              throwsA(isA<FirebaseAISdkException>().having(
                  (e) => e.message, 'message', contains('WebGroundingChunk'))));
        });

        test('parses malformedFunctionCall finishReason', () {
          final jsonResponse = {
            'candidates': [
              {'finishReason': 'MALFORMED_FUNCTION_CALL'}
            ]
          };
          final response =
              VertexSerialization().parseGenerateContentResponse(jsonResponse);
          expect(response.candidates.first.finishReason,
              FinishReason.malformedFunctionCall);
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

          final response =
              VertexSerialization().parseGenerateContentResponse(jsonResponse);
          final groundingMetadata = response.candidates.first.groundingMetadata;

          expect(groundingMetadata, isNotNull);
          // The invalid entries should be filtered out.
          expect(groundingMetadata!.groundingSupport, hasLength(1));

          final validSupport = groundingMetadata.groundingSupport.first;
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
          final response =
              VertexSerialization().parseGenerateContentResponse(jsonResponse);
          final urlContextMetadata =
              response.candidates.first.urlContextMetadata;
          expect(urlContextMetadata, isNotNull);
          expect(urlContextMetadata!.urlMetadata, hasLength(1));
          final urlMetadata = urlContextMetadata.urlMetadata.first;
          expect(urlMetadata.retrievedUrl, Uri.parse('https://example.com'));
          expect(urlMetadata.urlRetrievalStatus, UrlRetrievalStatus.success);
        });

        test(
            'parses valid response with full url context metadata and list of url metadata',
            () {
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
                    },
                    {
                      'retrievedUrl': 'https://foo.com',
                      'urlRetrievalStatus': 'URL_RETRIEVAL_STATUS_ERROR'
                    }
                  ]
                }
              }
            ]
          };
          final response =
              VertexSerialization().parseGenerateContentResponse(jsonResponse);
          final urlContextMetadata =
              response.candidates.first.urlContextMetadata;
          expect(urlContextMetadata, isNotNull);
          expect(urlContextMetadata!.urlMetadata, hasLength(2));
          final firstUrlMetadata = urlContextMetadata.urlMetadata.first;
          expect(
              firstUrlMetadata.retrievedUrl, Uri.parse('https://example.com'));
          expect(
              firstUrlMetadata.urlRetrievalStatus, UrlRetrievalStatus.success);
          final secondUrlMetadata = urlContextMetadata.urlMetadata[1];
          expect(secondUrlMetadata.retrievedUrl, Uri.parse('https://foo.com'));
          expect(
              secondUrlMetadata.urlRetrievalStatus, UrlRetrievalStatus.error);
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
          final response =
              VertexSerialization().parseGenerateContentResponse(jsonResponse);
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
          final response =
              VertexSerialization().parseGenerateContentResponse(jsonResponse);
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
          final response =
              VertexSerialization().parseGenerateContentResponse(jsonResponse);
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
              () => VertexSerialization()
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
              () => VertexSerialization()
                  .parseGenerateContentResponse(jsonResponse),
              throwsA(isA<FirebaseAISdkException>().having(
                  (e) => e.message, 'message', contains('UrlMetadata'))));
        });
      });

      test('parses JSON with no candidates (empty list)', () {
        final json = {'candidates': []};
        final response =
            VertexSerialization().parseGenerateContentResponse(json);
        expect(response.candidates, isEmpty);
        expect(response.promptFeedback, isNull);
        expect(response.usageMetadata, isNull);
      });

      test('parses JSON with null candidates (treated as empty)', () {
        // The code defaults to <Candidate>[] if 'candidates' key is missing
        final json = {'promptFeedback': null};
        final response =
            VertexSerialization().parseGenerateContentResponse(json);
        expect(response.candidates, isEmpty);
        expect(response.promptFeedback, isNull);
      });

      test('parses JSON with missing optional fields in candidate', () {
        final json = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Minimal'}
                ]
              }
              // Missing finishReason, safetyRatings, citationMetadata, finishMessage
            }
          ]
        };
        final response =
            VertexSerialization().parseGenerateContentResponse(json);
        expect(response.candidates, hasLength(1));
        expect(response.candidates.first.text, 'Minimal');
        expect(response.candidates.first.finishReason, isNull);
        expect(response.candidates.first.safetyRatings, isNull);
        expect(response.candidates.first.citationMetadata, isNull);
        expect(response.candidates.first.finishMessage, isNull);
      });

      test('parses usageMetadata for no tokenCount', () {
        final json = {
          'candidates': [basicCandidateJson],
          'usageMetadata': {
            'promptTokenCount': 10,
            'candidatesTokenCount': 20,
            'totalTokenCount': 30,
            'promptTokensDetails': [
              {'modality': 'TEXT', 'tokenCount': 10}
            ],
            'candidatesTokensDetails': [
              {
                'modality': 'TEXT',
              }
            ],
            'toolUsePromptTokensDetails': [
              {'modality': 'TEXT', 'tokenCount': 12}
            ],
          }
        };
        final response =
            VertexSerialization().parseGenerateContentResponse(json);
        expect(response.candidates, hasLength(1));
        expect(response.candidates.first.text, 'Hello world');
        expect(response.candidates.first.finishReason, FinishReason.stop);
        expect(response.candidates.first.safetyRatings, isNotNull);
        expect(response.candidates.first.safetyRatings, hasLength(1));

        expect(response.usageMetadata, isNotNull);
        expect(response.usageMetadata!.promptTokenCount, 10);
        expect(response.usageMetadata!.candidatesTokenCount, 20);
        expect(response.usageMetadata!.totalTokenCount, 30);
        expect(response.usageMetadata!.promptTokensDetails, hasLength(1));
        expect(response.usageMetadata!.promptTokensDetails!.first.modality,
            ContentModality.text);
        expect(
            response.usageMetadata!.promptTokensDetails!.first.tokenCount, 10);
        expect(response.usageMetadata!.candidatesTokensDetails, hasLength(1));
        expect(response.usageMetadata!.candidatesTokensDetails!.first.modality,
            ContentModality.text);
        expect(
            response.usageMetadata!.candidatesTokensDetails!.first.tokenCount,
            0);
        expect(
            response.usageMetadata!.toolUsePromptTokensDetails, hasLength(1));
        expect(
            response.usageMetadata!.toolUsePromptTokensDetails!.first.modality,
            ContentModality.text);
        expect(
            response
                .usageMetadata!.toolUsePromptTokensDetails!.first.tokenCount,
            12);
      });

      test('parses citationMetadata with "citationSources"', () {
        final json = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Cited text'}
                ]
              },
              'citationMetadata': {
                'citationSources': [
                  {
                    'startIndex': 0,
                    'endIndex': 5,
                    'uri': 'http://example.com/source1',
                    'license': 'CC-BY'
                  }
                ]
              }
            }
          ]
        };
        final response =
            VertexSerialization().parseGenerateContentResponse(json);
        final candidate = response.candidates.first;
        expect(candidate.citationMetadata, isNotNull);
        expect(candidate.citationMetadata!.citations, hasLength(1));
        expect(candidate.citationMetadata!.citations.first.uri.toString(),
            'http://example.com/source1');
      });
      test('parses citationMetadata with "citations" (Vertex SDK format)', () {
        final json = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Cited text'}
                ]
              },
              'citationMetadata': {
                'citations': [
                  // Vertex SDK uses 'citations'
                  {
                    'startIndex': 0,
                    'endIndex': 5,
                    'uri': 'http://example.com/source2',
                    'license': 'MIT'
                  }
                ]
              }
            }
          ]
        };
        final response =
            VertexSerialization().parseGenerateContentResponse(json);
        final candidate = response.candidates.first;
        expect(candidate.citationMetadata, isNotNull);
        expect(candidate.citationMetadata!.citations, hasLength(1));
        expect(candidate.citationMetadata!.citations.first.uri.toString(),
            'http://example.com/source2');
        expect(candidate.citationMetadata!.citations.first.license, 'MIT');
      });

      test('throws FirebaseAIException if JSON contains error field', () {
        final json = {
          'error': {'code': 500, 'message': 'Internal server error'}
        };
        expect(() => VertexSerialization().parseGenerateContentResponse(json),
            throwsA(isA<FirebaseAIException>()));
      });

      test('handles missing content in candidate gracefully (empty content)',
          () {
        final json = {
          'candidates': [
            {
              // No 'content' field
              'finishReason': 'STOP',
            }
          ]
        };
        final response =
            VertexSerialization().parseGenerateContentResponse(json);
        expect(response.candidates, hasLength(1));
        expect(response.candidates.first.content.parts, isEmpty);
        expect(response.candidates.first.text, isNull);
      });
      test('throws FormatException for invalid candidate structure (not a Map)',
          () {
        final jsonResponse = {
          'candidates': ['not_a_map_candidate']
        };
        expect(
            () => VertexSerialization()
                .parseGenerateContentResponse(jsonResponse),
            throwsA(isA<FirebaseAISdkException>()
                .having((e) => e.message, 'message', contains('Candidate'))));
      });

      test('throws FormatException for invalid safety rating structure', () {
        final jsonResponse = {
          'candidates': [
            {
              'content': {'parts': []},
              'safetyRatings': ['not_a_map_rating']
            }
          ]
        };
        expect(
            () => VertexSerialization()
                .parseGenerateContentResponse(jsonResponse),
            throwsA(isA<FirebaseAISdkException>().having(
                (e) => e.message, 'message', contains('SafetyRating'))));
      });
      test('throws FormatException for invalid citation metadata structure',
          () {
        final jsonResponse = {
          'candidates': [
            {
              'content': {'parts': []},
              'citationMetadata': 'not_a_map_citation'
            }
          ]
        };
        expect(
            () => VertexSerialization()
                .parseGenerateContentResponse(jsonResponse),
            throwsA(isA<FirebaseAISdkException>().having(
                (e) => e.message, 'message', contains('CitationMetadata'))));
      });
      test('throws FormatException for invalid prompt feedback structure', () {
        final jsonResponse = {'promptFeedback': 'not_a_map_feedback'};
        expect(
            () => VertexSerialization()
                .parseGenerateContentResponse(jsonResponse),
            throwsA(isA<FirebaseAISdkException>().having(
                (e) => e.message, 'message', contains('PromptFeedback'))));
      });
      test('throws FormatException for invalid usage metadata structure', () {
        final jsonResponse = {'usageMetadata': 'not_a_map_usage'};
        expect(
            () => VertexSerialization()
                .parseGenerateContentResponse(jsonResponse),
            throwsA(isA<FirebaseAISdkException>().having(
                (e) => e.message, 'message', contains('UsageMetadata'))));
      });
      test('throws FormatException for invalid modality token count structure',
          () {
        final jsonResponse = {
          'usageMetadata': {
            'promptTokensDetails': ['not_a_map_modality']
          }
        };
        expect(
            () => VertexSerialization()
                .parseGenerateContentResponse(jsonResponse),
            throwsA(isA<FirebaseAISdkException>().having(
                (e) => e.message, 'message', contains('ModalityTokenCount'))));
      });
    });
  });
}
