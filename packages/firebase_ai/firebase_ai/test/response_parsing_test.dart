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

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_ai/src/api.dart';
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
        () => VertexSerialization().parseGenerateContentResponse(decoded),
        throwsA(
          isA<FirebaseAISdkException>().having(
            (e) => e.message,
            'message',
            startsWith('Unhandled format for Content:'),
          ),
        ),
      );
    });

    test('with empty promptFeedback', () {
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
      "index": 0
    }
  ],
  "promptFeedback": {}
}
''';
      final decoded = jsonDecode(response) as Object;
      expect(
        VertexSerialization().parseGenerateContentResponse(decoded),
        isA<GenerateContentResponse>(),
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
          VertexSerialization().parseGenerateContentResponse(decoded);
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
        () => VertexSerialization().parseGenerateContentResponse(decoded),
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
        () => VertexSerialization().parseGenerateContentResponse(decoded),
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
      final generateContentResponse =
          VertexSerialization().parseGenerateContentResponse(decoded);
      expect(
        generateContentResponse,
        matchesGenerateContentResponse(
          GenerateContentResponse(
            [
              Candidate(
                Content.model([
                  const TextPart('Mountain View, California, United States'),
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
          VertexSerialization().parseGenerateContentResponse(decoded);
      expect(
        generateContentResponse,
        matchesGenerateContentResponse(
          GenerateContentResponse(
            [
              Candidate(
                Content.model([const TextPart('placeholder')]),
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
          VertexSerialization().parseGenerateContentResponse(decoded);
      expect(
        generateContentResponse,
        matchesGenerateContentResponse(
          GenerateContentResponse(
            [
              Candidate(
                Content.model([const TextPart('placeholder')]),
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
      final generateContentResponse =
          VertexSerialization().parseGenerateContentResponse(decoded);
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

    test('response including usage metadata', () async {
      const response = '''
{
  "candidates": [{
    "content": {
      "role": "model",
      "parts": [{
        "text": "Here is a description of the image:"
      }]
    },
    "finishReason": "STOP"
  }],
  "usageMetadata": {
    "promptTokenCount": 1837,
    "candidatesTokenCount": 76,
    "totalTokenCount": 1913,
    "promptTokensDetails": [{
      "modality": "TEXT",
      "tokenCount": 76
    }, {
      "modality": "IMAGE",
      "tokenCount": 1806
    }],
    "candidatesTokensDetails": [{
      "modality": "TEXT",
      "tokenCount": 76
    }],
    "toolUsePromptTokenCount": 5
  }
}
        ''';
      final decoded = jsonDecode(response) as Object;
      final generateContentResponse =
          VertexSerialization().parseGenerateContentResponse(decoded);
      expect(
          generateContentResponse.text, 'Here is a description of the image:');
      expect(generateContentResponse.usageMetadata?.totalTokenCount, 1913);
      expect(generateContentResponse.usageMetadata?.toolUsePromptTokenCount, 5);
      expect(
          generateContentResponse
              .usageMetadata?.promptTokensDetails?[1].modality,
          ContentModality.image);
      expect(
          generateContentResponse
              .usageMetadata?.promptTokensDetails?[1].tokenCount,
          1806);
      expect(
          generateContentResponse
              .usageMetadata?.candidatesTokensDetails?.first.modality,
          ContentModality.text);
      expect(
          generateContentResponse
              .usageMetadata?.candidatesTokensDetails?.first.tokenCount,
          76);
    });

    test('countTokens with modality fields returned', () async {
      const response = '''
{
  "totalTokens": 1837,
  "totalBillableCharacters": 117,
  "promptTokensDetails": [{
    "modality": "IMAGE",
    "tokenCount": 1806
  }, {
    "modality": "TEXT",
    "tokenCount": 31
  }]
}
        ''';
      final decoded = jsonDecode(response) as Object;
      final countTokensResponse =
          VertexSerialization().parseCountTokensResponse(decoded);
      expect(countTokensResponse.totalTokens, 1837);
      expect(countTokensResponse.promptTokensDetails?.first.modality,
          ContentModality.image);
      expect(countTokensResponse.promptTokensDetails?.first.tokenCount, 1806);
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
          VertexSerialization().parseGenerateContentResponse(decoded);
      expect(generateContentResponse.text, 'Initial text And more text');
      expect(generateContentResponse.candidates.single.text,
          'Initial text And more text');
    });

    test('url context', () {
      const response = '''
{
  "candidates": [
    {
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "The Berkshire Hathaway Inc. website serves as the official homepage for the company, providing a message from Warren E. Buffett and various corporate information. It includes annual and interim reports, news releases, SEC filings, and information about the annual meeting. The site also features letters from Warren Buffett and Charlie Munger, details on corporate governance and sustainability, and links to Berkshire Hathaway's operating companies. It also warns about fraudulent claims regarding Mr. Buffett's endorsements and provides information on common stock."
          }
        ]
      },
      "finishReason": "STOP",
      "groundingMetadata": {
        "groundingChunks": [
          {
            "web": {
              "uri": "https://berkshirehathaway.com",
              "title": "BERKSHIRE HATHAWAY INC."
            }
          }
        ],
        "groundingSupports": [
          {
            "segment": {
              "startIndex": 273,
              "endIndex": 450,
              "text": "The site also features letters from Warren Buffett and Charlie Munger, details on corporate governance and sustainability, and links to Berkshire Hathaway's operating companies."
            },
            "groundingChunkIndices": [
              0
            ]
          },
          {
            "segment": {
              "startIndex": 503,
              "endIndex": 567,
              "text": "Buffett's endorsements and provides information on common stock."
            },
            "groundingChunkIndices": [
              0
            ]
          }
        ]
      },
      "urlContextMetadata": {
        "urlMetadata": [
          {
            "retrievedUrl": "https://berkshirehathaway.com",
            "urlRetrievalStatus": "URL_RETRIEVAL_STATUS_SUCCESS"
          }
        ]
      }
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 13,
    "candidatesTokenCount": 98,
    "totalTokenCount": 181,
    "promptTokensDetails": [
      {
        "modality": "TEXT",
        "tokenCount": 13
      }
    ],
    "candidatesTokensDetails": [
      {
        "modality": "TEXT",
        "tokenCount": 98
      }
    ],
    "toolUsePromptTokenCount": 34,
    "thoughtsTokenCount": 36
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      final generateContentResponse =
          VertexSerialization().parseGenerateContentResponse(decoded);
      final candidate = generateContentResponse.candidates.first;
      final urlContextMetadata = candidate.urlContextMetadata;
      expect(urlContextMetadata, isNotNull);
      expect(urlContextMetadata!.urlMetadata, hasLength(1));
      expect(urlContextMetadata.urlMetadata.first.retrievedUrl,
          Uri.parse('https://berkshirehathaway.com'));
      expect(urlContextMetadata.urlMetadata.first.urlRetrievalStatus,
          UrlRetrievalStatus.success);
      final usageMetadata = generateContentResponse.usageMetadata;
      expect(usageMetadata, isNotNull);
      expect(usageMetadata!.toolUsePromptTokenCount, 34);
    });

    test('url context mixed validity', () {
      const response = '''
{
  "candidates": [
    {
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "The `browse` tool output shows the following:1.  **Valid Page (`https://ai.google.dev`)**: The tool successfully accessed this URL. It returned a `title` (Gemini Developer API | Gemma open models | Google AI for ...) and extensive `content`, indicating that the page is publicly accessible and rendered correctly.2.  **Broken Page (`https://a-completely-non-existent-url-for-testing.org`)**: The tool reported that it was not able to access the website(s). This indicates that the URL likely does not exist or is unreachable, confirming its broken status.3.  **Paywalled Page (`https://www.nytimes.com/2023/06/25/realestate/barbiecore-home-decor-interior-design.html?...`)**: Similar to the broken page, the tool also reported being not able to access the website(s) for this URL, explicitly mentioning paywalls, login requirements or sensitive information as common reasons. This suggests that the content is behind a paywall or requires authentication, making it inaccessible to the browsing tool.In summary, the `browse` tool successfully retrieved content from the valid page, while it was unable to access both the non-existent URL and the paywalled New York Times article, with specific reasons provided for the latter.The `browse` tool successfully retrieved the content and title from `https://ai.google.dev`, indicating it is a valid and accessible page.For `https://a-completely-non-existent-url-for-testing.org`, the tool reported that it was not able to access the website(s), which confirms it as a broken or non-existent page.Similarly, for `https://www.nytimes.com/2023/06/25/realestate/barbiecore-home-decor-interior-design.html?...`, the tool also stated it was not able to access the website(s), citing paywalls, login requirements or sensitive information as common reasons, confirming its paywalled status."
          }
        ]
      },
      "finishReason": "STOP",
      "groundingMetadata": {
        "groundingChunks": [
          {
            "web": {
              "uri": "https://ai.google.dev",
              "title": "Gemini Developer API | Gemma open models | Google AI for ..."
            }
          }
        ],
        "groundingSupports": [
          {
            "segment": {
              "startIndex": 134,
              "endIndex": 317,
              "text": "It returned a `title` (Gemini Developer API | Gemma open models | Google AI for ...) and extensive `content`, indicating that the page is publicly accessible and rendered correctly."
            },
            "groundingChunkIndices": [
              0
            ]
          },
          {
            "segment": {
              "startIndex": 465,
              "endIndex": 565,
              "text": "This indicates that the URL likely does not exist or is unreachable, confirming its broken status."
            },
            "groundingChunkIndices": [
              1
            ]
          },
          {
            "segment": {
              "startIndex": 892,
              "endIndex": 1015,
              "text": "This suggests that the content is behind a paywall or requires authentication, making it inaccessible to the browsing tool."
            },
            "groundingChunkIndices": [
              2
            ]
          },
          {
            "segment": {
              "startIndex": 1244,
              "endIndex": 1382,
              "text": "The `browse` tool successfully retrieved the content and title from `https://ai.google.dev`, indicating it is a valid and accessible page."
            },
            "groundingChunkIndices": [
              0
            ]
          },
          {
            "segment": {
              "startIndex": 1384,
              "endIndex": 1563,
              "text": "For `https://a-completely-non-existent-url-for-testing.org`, the tool reported that it was not able to access the website(s), which confirms it as a broken or non-existent page."
            },
            "groundingChunkIndices": [
              1
            ]
          },
          {
            "segment": {
              "startIndex": 1565,
              "endIndex": 1855,
              "text": "Similarly, for `https://www.nytimes.com/2023/06/25/realestate/barbiecore-home-decor-interior-design.html?...`, the tool also stated it was not able to access the website(s), citing paywalls, login requirements or sensitive information as common reasons, confirming its paywalled status."
            },
            "groundingChunkIndices": [
              2
            ]
          }
        ]
      },
      "urlContextMetadata": {
        "urlMetadata": [
          {
            "retrievedUrl": "https://www.nytimes.com/2023/06/25/realestate/barbiecore-home-decor-interior-design.html?action=click&contentCollection=undefined&region=Footer&module=WhatsNext&version=WhatsNext&contentID=WhatsNext&moduleDetail=most-emailed-0&pgtype=undefinedl",
            "urlRetrievalStatus": "URL_RETRIEVAL_STATUS_ERROR"
          },
          {
            "retrievedUrl": "https://ai.google.dev",
            "urlRetrievalStatus": "URL_RETRIEVAL_STATUS_SUCCESS"
          },
          {
            "retrievedUrl": "https://a-completely-non-existent-url-for-testing.org",
            "urlRetrievalStatus": "URL_RETRIEVAL_STATUS_ERROR"
          }
        ]
      }
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 116,
    "candidatesTokenCount": 446,
    "totalTokenCount": 918,
    "promptTokensDetails": [
      {
        "modality": "TEXT",
        "tokenCount": 116
      }
    ],
    "candidatesTokensDetails": [
      {
        "modality": "TEXT",
        "tokenCount": 446
      }
    ],
    "toolUsePromptTokenCount": 177,
    "thoughtsTokenCount": 179
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      final generateContentResponse =
          VertexSerialization().parseGenerateContentResponse(decoded);
      final urlContextMetadata =
          generateContentResponse.candidates.first.urlContextMetadata;
      expect(urlContextMetadata, isNotNull);
      expect(urlContextMetadata!.urlMetadata, hasLength(3));
      expect(urlContextMetadata.urlMetadata[2].retrievedUrl,
          Uri.parse('https://a-completely-non-existent-url-for-testing.org'));
      expect(urlContextMetadata.urlMetadata[2].urlRetrievalStatus,
          UrlRetrievalStatus.error);
      expect(urlContextMetadata.urlMetadata[1].retrievedUrl,
          Uri.parse('https://ai.google.dev'));
      expect(urlContextMetadata.urlMetadata[1].urlRetrievalStatus,
          UrlRetrievalStatus.success);
    });

    test('url context missing retrievedUrl', () {
      const response = '''
{
  "candidates": [
    {
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "I attempted to access the provided URLs, but I was unable to retrieve any content from them. The error message indicated that the websites could not be accessed, possibly due to reasons such as paywalls, login requirements, sensitive information, or other access restrictions. This suggests that these pages are not real in the sense of being publicly accessible or existing web pages. The `example.com` domain is typically used for illustrative purposes and not for actual active websites."
          }
        ]
      },
      "finishReason": "STOP",
      "groundingMetadata": {
        "groundingSupports": [
          {
            "segment": {
              "startIndex": 93,
              "endIndex": 275,
              "text": "The error message indicated that the websites could not be accessed, possibly due to reasons such as paywalls, login requirements, sensitive information, or other access restrictions"
            },
            "groundingChunkIndices": [
              0
            ]
          }
        ]
      },
      "urlContextMetadata": {
        "urlMetadata": [
          {
            "urlRetrievalStatus": "URL_RETRIEVAL_STATUS_ERROR"
          }
        ]
      }
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 175,
    "candidatesTokenCount": 93,
    "totalTokenCount": 564,
    "promptTokensDetails": [
      {
        "modality": "TEXT",
        "tokenCount": 175
      }
    ],
    "candidatesTokensDetails": [
      {
        "modality": "TEXT",
        "tokenCount": 93
      }
    ],
    "toolUsePromptTokenCount": 60,
    "thoughtsTokenCount": 236
  }
}
''';
      final decoded = jsonDecode(response) as Object;
      final generateContentResponse =
          VertexSerialization().parseGenerateContentResponse(decoded);
      final urlContextMetadata =
          generateContentResponse.candidates.first.urlContextMetadata;
      expect(urlContextMetadata, isNotNull);
      expect(urlContextMetadata!.urlMetadata, hasLength(1));
      expect(urlContextMetadata.urlMetadata[0].retrievedUrl, isNull);
      expect(urlContextMetadata.urlMetadata[0].urlRetrievalStatus,
          UrlRetrievalStatus.error);
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
      expect(() => VertexSerialization().parseGenerateContentResponse(decoded),
          expectedThrow);
      expect(() => VertexSerialization().parseCountTokensResponse(decoded),
          expectedThrow);
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
      expect(() => VertexSerialization().parseGenerateContentResponse(decoded),
          expectedThrow);
      expect(() => VertexSerialization().parseCountTokensResponse(decoded),
          expectedThrow);
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
      expect(() => VertexSerialization().parseGenerateContentResponse(decoded),
          expectedThrow);
      expect(() => VertexSerialization().parseCountTokensResponse(decoded),
          expectedThrow);
    });
  });
}
