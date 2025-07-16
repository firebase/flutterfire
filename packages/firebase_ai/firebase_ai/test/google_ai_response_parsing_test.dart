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
import 'package:firebase_ai/src/developer/api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/matchers.dart';

void main() {
  group('throws errors for invalid GenerateContentResponse', () {
    test('with empty content', () {
      const response = '''
{
  "candidates": [
    {
      "content": {},
      "index": 0
    }
  ],
  "promptFeedback": {
    "safetyRatings": [
      {
        "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_HATE_SPEECH",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_HARASSMENT",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
        "probability": "NEGLIGIBLE"
      }
    ]
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      expect(
        () => DeveloperSerialization().parseGenerateContentResponse(decoded),
        throwsA(
          isA<FirebaseAISdkException>().having(
            (e) => e.message,
            'message',
            startsWith('Unhandled format for Content:'),
          ),
        ),
      );
    });

    test('with a blocked prompt', () {
      const response = '''
{
  "promptFeedback": {
    "blockReason": "SAFETY",
    "safetyRatings": [
      {
        "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_HATE_SPEECH",
        "probability": "HIGH"
      },
      {
        "category": "HARM_CATEGORY_HARASSMENT",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
        "probability": "NEGLIGIBLE"
      }
    ]
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      final generateContentResponse =
          DeveloperSerialization().parseGenerateContentResponse(decoded);
      expect(
        generateContentResponse,
        matchesGenerateContentResponse(
          GenerateContentResponse(
            [],
            PromptFeedback(BlockReason.safety, null, [
              SafetyRating(
                HarmCategory.sexuallyExplicit,
                HarmProbability.negligible,
              ),
              SafetyRating(HarmCategory.hateSpeech, HarmProbability.high),
              SafetyRating(HarmCategory.harassment, HarmProbability.negligible),
              SafetyRating(
                HarmCategory.dangerousContent,
                HarmProbability.negligible,
              ),
            ]),
          ),
        ),
      );
      expect(
        () => generateContentResponse.text,
        throwsA(
          isA<FirebaseAIException>().having(
            (e) => e.message,
            'message',
            startsWith('Response was blocked due to safety'),
          ),
        ),
      );
    });
  });

  group('parses successful GenerateContentResponse', () {
    test('with a basic reply', () async {
      const response = '''
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "Mountain View, California, United States"
          }
        ],
        "role": "model"
      },
      "finishReason": "STOP",
      "index": 0,
      "safetyRatings": [
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "probability": "NEGLIGIBLE"
        }
      ]
    }
  ],
  "promptFeedback": {
    "safetyRatings": [
      {
        "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_HATE_SPEECH",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_HARASSMENT",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
        "probability": "NEGLIGIBLE"
      }
    ]
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      final generateContentResponse =
          DeveloperSerialization().parseGenerateContentResponse(decoded);
      expect(
        generateContentResponse,
        matchesGenerateContentResponse(
          GenerateContentResponse(
            [
              Candidate(
                Content.model([
                  TextPart('Mountain View, California, United States'),
                ]),
                [
                  SafetyRating(
                    HarmCategory.sexuallyExplicit,
                    HarmProbability.negligible,
                  ),
                  SafetyRating(
                    HarmCategory.hateSpeech,
                    HarmProbability.negligible,
                  ),
                  SafetyRating(
                    HarmCategory.harassment,
                    HarmProbability.negligible,
                  ),
                  SafetyRating(
                    HarmCategory.dangerousContent,
                    HarmProbability.negligible,
                  ),
                ],
                null,
                FinishReason.stop,
                null,
              ),
            ],
            PromptFeedback(null, null, [
              SafetyRating(
                HarmCategory.sexuallyExplicit,
                HarmProbability.negligible,
              ),
              SafetyRating(HarmCategory.hateSpeech, HarmProbability.negligible),
              SafetyRating(HarmCategory.harassment, HarmProbability.negligible),
              SafetyRating(
                HarmCategory.dangerousContent,
                HarmProbability.negligible,
              ),
            ]),
          ),
        ),
      );
    });

    test('with a citation', () async {
      const response = '''
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "placeholder"
          }
        ],
        "role": "model"
      },
      "finishReason": "STOP",
      "index": 0,
      "safetyRatings": [
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "probability": "NEGLIGIBLE"
        }
      ],
      "citationMetadata": {
        "citationSources": [
          {
            "startIndex": 574,
            "endIndex": 705,
            "uri": "https://example.com/",
            "license": ""
          },
          {
            "startIndex": 899,
            "endIndex": 1026,
            "uri": "https://example.com/",
            "license": ""
          },
          {
            "startIndex": 899,
            "endIndex": 1026
          },
          {
            "uri": "https://example.com/",
            "license": ""
          },
          {}
        ]
      }
    }
  ],
  "promptFeedback": {
    "safetyRatings": [
      {
        "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_HATE_SPEECH",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_HARASSMENT",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
        "probability": "NEGLIGIBLE"
      }
    ]
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      final generateContentResponse =
          DeveloperSerialization().parseGenerateContentResponse(decoded);
      expect(
        generateContentResponse,
        matchesGenerateContentResponse(
          GenerateContentResponse(
            [
              Candidate(
                Content.model([TextPart('placeholder')]),
                [
                  SafetyRating(
                    HarmCategory.sexuallyExplicit,
                    HarmProbability.negligible,
                  ),
                  SafetyRating(
                    HarmCategory.hateSpeech,
                    HarmProbability.negligible,
                  ),
                  SafetyRating(
                    HarmCategory.harassment,
                    HarmProbability.negligible,
                  ),
                  SafetyRating(
                    HarmCategory.dangerousContent,
                    HarmProbability.negligible,
                  ),
                ],
                CitationMetadata([
                  Citation(574, 705, Uri.https('example.com'), ''),
                  Citation(899, 1026, Uri.https('example.com'), ''),
                ]),
                FinishReason.stop,
                null,
              ),
            ],
            PromptFeedback(null, null, [
              SafetyRating(
                HarmCategory.sexuallyExplicit,
                HarmProbability.negligible,
              ),
              SafetyRating(HarmCategory.hateSpeech, HarmProbability.negligible),
              SafetyRating(HarmCategory.harassment, HarmProbability.negligible),
              SafetyRating(
                HarmCategory.dangerousContent,
                HarmProbability.negligible,
              ),
            ]),
          ),
        ),
      );
    });

    test('with a vertex formatted citation', () async {
      const response = '''
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "placeholder"
          }
        ],
        "role": "model"
      },
      "finishReason": "STOP",
      "index": 0,
      "safetyRatings": [
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "probability": "NEGLIGIBLE"
        }
      ],
      "citationMetadata": {
        "citations": [
          {
            "startIndex": 574,
            "endIndex": 705,
            "uri": "https://example.com/",
            "license": ""
          },
          {
            "startIndex": 899,
            "endIndex": 1026,
            "uri": "https://example.com/",
            "license": ""
          },
          {
            "startIndex": 899,
            "endIndex": 1026
          },
          {
            "uri": "https://example.com/",
            "license": ""
          },
          {}
        ]
      }
    }
  ],
  "promptFeedback": {
    "safetyRatings": [
      {
        "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_HATE_SPEECH",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_HARASSMENT",
        "probability": "NEGLIGIBLE"
      },
      {
        "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
        "probability": "NEGLIGIBLE"
      }
    ]
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      final generateContentResponse =
          DeveloperSerialization().parseGenerateContentResponse(decoded);
      expect(
        generateContentResponse,
        matchesGenerateContentResponse(
          GenerateContentResponse(
            [
              Candidate(
                Content.model([TextPart('placeholder')]),
                [
                  SafetyRating(
                    HarmCategory.sexuallyExplicit,
                    HarmProbability.negligible,
                  ),
                  SafetyRating(
                    HarmCategory.hateSpeech,
                    HarmProbability.negligible,
                  ),
                  SafetyRating(
                    HarmCategory.harassment,
                    HarmProbability.negligible,
                  ),
                  SafetyRating(
                    HarmCategory.dangerousContent,
                    HarmProbability.negligible,
                  ),
                ],
                CitationMetadata([
                  Citation(574, 705, Uri.https('example.com'), ''),
                  Citation(899, 1026, Uri.https('example.com'), ''),
                ]),
                FinishReason.stop,
                null,
              ),
            ],
            PromptFeedback(null, null, [
              SafetyRating(
                HarmCategory.sexuallyExplicit,
                HarmProbability.negligible,
              ),
              SafetyRating(HarmCategory.hateSpeech, HarmProbability.negligible),
              SafetyRating(HarmCategory.harassment, HarmProbability.negligible),
              SafetyRating(
                HarmCategory.dangerousContent,
                HarmProbability.negligible,
              ),
            ]),
          ),
        ),
      );
    });

    test('with code execution', () async {
      const response = '''
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "executableCode": {
              "language": "PYTHON",
              "code": "print('hello world')"
            }
          },
          {
            "codeExecutionResult": {
              "outcome": "OUTCOME_OK",
              "output": "hello world"
            }
          },
          {
            "text": "hello world"
          }
        ],
        "role": "model"
      },
      "finishReason": "STOP",
      "index": 0
    }
  ]
}
''';
      final decoded = jsonDecode(response) as Object;
      final generateContentResponse =
          DeveloperSerialization().parseGenerateContentResponse(decoded);
      expect(
        generateContentResponse,
        matchesGenerateContentResponse(
          GenerateContentResponse(
            [
              Candidate(
                Content.model([
                  // ExecutableCode(Language.python, 'print(\'hello world\')'),
                  // CodeExecutionResult(Outcome.ok, 'hello world'),
                  TextPart('hello world')
                ]),
                [],
                null,
                FinishReason.stop,
                null,
              ),
            ],
            null,
          ),
        ),
      );
    }, skip: 'Code Execution Unsupported');

    test('allows missing content', () async {
      const response = '''
{
  "candidates": [
    {
      "finishReason": "SAFETY",
      "index": 0,
      "safetyRatings": [
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "probability": "NEGLIGIBLE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "probability": "LOW"
        },
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "probability": "MEDIUM"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "probability": "NEGLIGIBLE"
        }
      ]
    }
  ]
}
''';
      final decoded = jsonDecode(response) as Object;
      final generateContentResponse =
          DeveloperSerialization().parseGenerateContentResponse(decoded);
      expect(
        generateContentResponse,
        matchesGenerateContentResponse(
          GenerateContentResponse([
            Candidate(
                Content(null, []),
                [
                  SafetyRating(
                    HarmCategory.sexuallyExplicit,
                    HarmProbability.negligible,
                  ),
                  SafetyRating(
                      HarmCategory.hateSpeech, HarmProbability.negligible),
                  SafetyRating(
                      HarmCategory.harassment, HarmProbability.negligible),
                  SafetyRating(
                    HarmCategory.dangerousContent,
                    HarmProbability.negligible,
                  ),
                ],
                CitationMetadata([]),
                FinishReason.safety,
                null),
          ], null),
        ),
      );
    });

    test('text getter joins content', () async {
      const response = '''
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "Initial text"
          },
          {
            "functionCall": {"name": "someFunction", "args": {}}
          },
          {
            "text": " And more text"
          }
        ],
        "role": "model"
      },
      "finishReason": "STOP",
      "index": 0
    }
  ]
}
''';
      final decoded = jsonDecode(response) as Object;
      final generateContentResponse =
          DeveloperSerialization().parseGenerateContentResponse(decoded);
      expect(generateContentResponse.text, 'Initial text And more text');
      expect(generateContentResponse.candidates.single.text,
          'Initial text And more text');
    });
  });

  group('parses and throws error responses', () {
    test('for invalid API key', () async {
      const response = '''
{
  "error": {
    "code": 400,
    "message": "API key not valid. Please pass a valid API key.",
    "status": "INVALID_ARGUMENT",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.ErrorInfo",
        "reason": "API_KEY_INVALID",
        "domain": "googleapis.com",
        "metadata": {
          "service": "generativelanguage.googleapis.com"
        }
      },
      {
        "@type": "type.googleapis.com/google.rpc.DebugInfo",
        "detail": "Invalid API key: AIzv00G7VmUCUeC-5OglO3hcXM"
      }
    ]
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      final expectedThrow = throwsA(
        isA<InvalidApiKey>().having(
          (e) => e.message,
          'message',
          'API key not valid. Please pass a valid API key.',
        ),
      );
      expect(
          () => DeveloperSerialization().parseGenerateContentResponse(decoded),
          expectedThrow);
      expect(() => DeveloperSerialization().parseCountTokensResponse(decoded),
          expectedThrow);
      // expect(() => parseEmbedContentResponse(decoded), expectedThrow);
    });

    test('for unsupported user location', () async {
      const response = r'''
{
  "error": {
    "code": 400,
    "message": "User location is not supported for the API use.",
    "status": "FAILED_PRECONDITION",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.DebugInfo",
        "detail": "[ORIGINAL ERROR] generic::failed_precondition: User location is not supported for the API use. [google.rpc.error_details_ext] { message: \"User location is not supported for the API use.\" }"
      }
    ]
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      final expectedThrow = throwsA(
        isA<UnsupportedUserLocation>().having(
          (e) => e.message,
          'message',
          'User location is not supported for the API use.',
        ),
      );
      expect(
          () => DeveloperSerialization().parseGenerateContentResponse(decoded),
          expectedThrow);
      expect(() => DeveloperSerialization().parseCountTokensResponse(decoded),
          expectedThrow);
      // expect(() => parseEmbedContentResponse(decoded), expectedThrow);
    });

    test('for general server errors', () async {
      const response = r'''
{
  "error": {
    "code": 404,
    "message": "models/unknown is not found for API version v1, or is not supported for GenerateContent. Call ListModels to see the list of available models and their supported methods.",
    "status": "NOT_FOUND",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.DebugInfo",
        "detail": "[ORIGINAL ERROR] generic::not_found: models/unknown is not found for API version v1, or is not supported for GenerateContent. Call ListModels to see the list of available models and their supported methods. [google.rpc.error_details_ext] { message: \"models/unknown is not found for API version v1, or is not supported for GenerateContent. Call ListModels to see the list of available models and their supported methods.\" }"
      }
    ]
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      final expectedThrow = throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          startsWith(
            'models/unknown is not found for API version v1, '
            'or is not supported for GenerateContent.',
          ),
        ),
      );
      expect(
          () => DeveloperSerialization().parseGenerateContentResponse(decoded),
          expectedThrow);
      expect(() => DeveloperSerialization().parseCountTokensResponse(decoded),
          expectedThrow);
      // expect(() => parseEmbedContentResponse(decoded), expectedThrow);
    });
  });
}
