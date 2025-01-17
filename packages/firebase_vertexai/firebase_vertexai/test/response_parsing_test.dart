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

import 'dart:convert';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:firebase_vertexai/src/api.dart';
import 'package:firebase_vertexai/src/error.dart';
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
        () => parseGenerateContentResponse(decoded),
        throwsA(
          isA<VertexAISdkException>().having(
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
      final generateContentResponse = parseGenerateContentResponse(decoded);
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
          isA<VertexAIException>().having(
            (e) => e.message,
            'message',
            startsWith('Response was blocked due to safety'),
          ),
        ),
      );
    });
    test('with service api not enabled', () {
      const response = '''
{
  "error": {
    "code": 403,
    "message": "Vertex AI in Firebase API has not been used in project test-project-id-1234 before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/firebasevertexai.googleapis.com/overview?project=test-project-id-1234 then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.",
    "status": "PERMISSION_DENIED",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.Help",
        "links": [
          {
            "description": "Google developers console API activation",
            "url": "https://console.developers.google.com/apis/api/firebasevertexai.googleapis.com/overview?project=test-project-id-1234"
          }
        ]
      },
      {
        "@type": "type.googleapis.com/google.rpc.ErrorInfo",
        "reason": "SERVICE_DISABLED",
        "domain": "googleapis.com",
        "metadata": {
          "service": "firebasevertexai.googleapis.com",
          "consumer": "projects/test-project-id-1234"
        }
      }
    ]
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      expect(
        () => parseGenerateContentResponse(decoded),
        throwsA(
          isA<ServiceApiNotEnabled>().having(
            (e) => e.message,
            'message',
            startsWith(
                'The Vertex AI in Firebase SDK requires the Vertex AI in Firebase API'),
          ),
        ),
      );
    });

    test('with quota exceed', () {
      const response = '''
{
  "error": {
    "code": 429,
    "message": "Quota exceeded for quota metric 'Generate Content API requests per minute' and limit 'GenerateContent request limit per minute for a region' of service 'generativelanguage.googleapis.com' for consumer 'project_number:348715329010'.",
    "status": "RESOURCE_EXHAUSTED",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.ErrorInfo",
        "reason": "RATE_LIMIT_EXCEEDED",
        "domain": "googleapis.com",
        "metadata": {
          "service": "generativelanguage.googleapis.com",
          "consumer": "projects/348715329010",
          "quota_limit_value": "0",
          "quota_limit": "GenerateContentRequestsPerMinutePerProjectPerRegion",
          "quota_location": "us-east2",
          "quota_metric": "generativelanguage.googleapis.com/generate_content_requests"
        }
      },
      {
        "@type": "type.googleapis.com/google.rpc.Help",
        "links": [
          {
            "description": "Request a higher quota limit.",
            "url": "https://cloud.google.com/docs/quota#requesting_higher_quota"
          }
        ]
      }
    ]
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      expect(
        () => parseGenerateContentResponse(decoded),
        throwsA(
          isA<QuotaExceeded>().having(
            (e) => e.message,
            'message',
            startsWith('Quota exceeded for quota metric'),
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
      final generateContentResponse = parseGenerateContentResponse(decoded);
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
      final generateContentResponse = parseGenerateContentResponse(decoded);
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
      final generateContentResponse = parseGenerateContentResponse(decoded);
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
      final generateContentResponse = parseGenerateContentResponse(decoded);
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
      final generateContentResponse = parseGenerateContentResponse(decoded);
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
      expect(() => parseGenerateContentResponse(decoded), expectedThrow);
      expect(() => parseCountTokensResponse(decoded), expectedThrow);
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
      expect(() => parseGenerateContentResponse(decoded), expectedThrow);
      expect(() => parseCountTokensResponse(decoded), expectedThrow);
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
      expect(() => parseGenerateContentResponse(decoded), expectedThrow);
      expect(() => parseCountTokensResponse(decoded), expectedThrow);
    });
  });
}
