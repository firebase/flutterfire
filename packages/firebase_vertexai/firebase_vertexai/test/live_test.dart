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
import 'dart:typed_data';

import 'package:firebase_vertexai/src/content.dart';
import 'package:firebase_vertexai/src/error.dart';
import 'package:firebase_vertexai/src/live_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LiveAPI Tests', () {
    test('Voices enum toJson() returns correct value', () {
      expect(Voice.Aoede.toJson(), 'Aoede');
      expect(Voice.Charon.toJson(), 'Charon');
      expect(Voice.Fenrir.toJson(), 'Fenrir');
      expect(Voice.Kore.toJson(), 'Kore');
      expect(Voice.Puck.toJson(), 'Puck');
    });

    test('SpeechConfig toJson() returns correct JSON', () {
      final speechConfigWithVoice = SpeechConfig(voice: Voice.Aoede);
      expect(speechConfigWithVoice.toJson(), {
        'voice_config': {
          'prebuilt_voice_config': {'voice_name': 'Aoede'}
        }
      });

      final speechConfigWithoutVoice = SpeechConfig();
      expect(speechConfigWithoutVoice.toJson(), {});
    });

    test('ResponseModalities enum toJson() returns correct value', () {
      expect(ResponseModalities.unspecified.toJson(), 'MODALITY_UNSPECIFIED');
      expect(ResponseModalities.text.toJson(), 'TEXT');
      expect(ResponseModalities.image.toJson(), 'IMAGE');
      expect(ResponseModalities.audio.toJson(), 'AUDIO');
    });

    test('LiveGenerationConfig toJson() returns correct JSON', () {
      final liveGenerationConfig = LiveGenerationConfig(
        speechConfig: SpeechConfig(voice: Voice.Charon),
        responseModalities: [ResponseModalities.text, ResponseModalities.audio],
        candidateCount: 2,
        maxOutputTokens: 100,
        temperature: 0.8,
        topP: 0.95,
        topK: 40,
      );

      expect(liveGenerationConfig.toJson(), {
        'candidateCount': 2,
        'maxOutputTokens': 100,
        'temperature': 0.8,
        'topP': 0.95,
        'topK': 40,
        'speechConfig': {
          'voice_config': {
            'prebuilt_voice_config': {'voice_name': 'Charon'}
          }
        },
        'responseModalities': ['TEXT', 'AUDIO'],
      });

      final liveGenerationConfigWithoutOptionals = LiveGenerationConfig();
      expect(liveGenerationConfigWithoutOptionals.toJson(), {});
    });

    test('LiveServerContent constructor and properties', () {
      final content = Content.text('Hello, world!');
      final message = LiveServerContent(
        modelTurn: content,
        turnComplete: true,
        interrupted: false,
      );
      expect(message.modelTurn, content);
      expect(message.turnComplete, true);
      expect(message.interrupted, false);

      final message2 = LiveServerContent();
      expect(message2.modelTurn, null);
      expect(message2.turnComplete, null);
      expect(message2.interrupted, null);
    });

    test('LiveServerToolCall constructor and properties', () {
      final functionCall = FunctionCall('test', {});
      final message = LiveServerToolCall(functionCalls: [functionCall]);
      expect(message.functionCalls, [functionCall]);

      final message2 = LiveServerToolCall();
      expect(message2.functionCalls, null);
    });

    test('LiveServerToolCallCancellation constructor and properties', () {
      final message = LiveServerToolCallCancellation(functionIds: ['1', '2']);
      expect(message.functionIds, ['1', '2']);

      final message2 = LiveServerToolCallCancellation();
      expect(message2.functionIds, null);
    });

    test('LiveClientRealtimeInput toJson() returns correct JSON', () {
      final part = InlineDataPart('audio/pcm', Uint8List.fromList([1, 2, 3]));
      final message = LiveClientRealtimeInput(mediaChunks: [part]);
      expect(message.toJson(), {
        'realtime_input': {
          'media_chunks': [
            {
              'mimeType': 'audio/pcm',
              'data': 'AQID',
            }
          ],
        },
      });

      final message2 = LiveClientRealtimeInput();
      expect(message2.toJson(), {
        'realtime_input': {
          'media_chunks': null,
        },
      });
    });

    test('LiveClientContent toJson() returns correct JSON', () {
      final content = Content.text('some test input');
      final message = LiveClientContent(turns: [content], turnComplete: true);
      expect(message.toJson(), {
        'client_content': {
          'turns': [
            {
              'role': 'user',
              'parts': [
                {'text': 'some test input'}
              ]
            }
          ],
          'turn_complete': true,
        }
      });

      final message2 = LiveClientContent();
      expect(message2.toJson(), {
        'client_content': {
          'turns': null,
          'turn_complete': null,
        }
      });
    });

    test('LiveClientToolResponse toJson() returns correct JSON', () {
      final response = FunctionResponse('test', {});
      final message = LiveClientToolResponse(functionResponses: [response]);
      expect(message.toJson(), {
        'functionResponses': [
          {
            'functionResponse': {'name': 'test', 'response': {}}
          }
        ]
      });

      final message2 = LiveClientToolResponse();
      expect(message2.toJson(), {'functionResponses': null});
    });

    test('parseServerMessage parses serverContent message correctly', () {
      final jsonObject = {
        'serverContent': {
          'modelTurn': {
            'parts': [
              {'text': 'Hello, world!'}
            ]
          },
          'turnComplete': true,
        }
      };
      final message = parseServerMessage(jsonObject);
      expect(message, isA<LiveServerContent>());
      final contentMessage = message as LiveServerContent;
      expect(contentMessage.turnComplete, true);
      expect(contentMessage.modelTurn, isA<Content>());
    });

    test('parseServerMessage parses toolCall message correctly', () {
      final jsonObject = {
        'toolCall': {
          'functionCalls': [
            {
              'name': 'test1',
              'args': {'foo1': 'bar1'}
            },
            {
              'name': 'test2',
              'args': {'foo2': 'bar2'}
            }
          ]
        }
      };
      final message = parseServerMessage(jsonObject);
      expect(message, isA<LiveServerToolCall>());
      final toolCallMessage = message as LiveServerToolCall;
      expect(toolCallMessage.functionCalls, isA<List<FunctionCall>>());
    });

    test('parseServerMessage parses toolCallCancellation message correctly',
        () {
      final jsonObject = {
        'toolCallCancellation': {
          'ids': ['1', '2']
        }
      };
      final message = parseServerMessage(jsonObject);
      expect(message, isA<LiveServerToolCallCancellation>());
      final cancellationMessage = message as LiveServerToolCallCancellation;
      expect(cancellationMessage.functionIds, ['1', '2']);
    });

    test('parseServerMessage parses setupComplete message correctly', () {
      final jsonObject = {'setupComplete': {}};
      final message = parseServerMessage(jsonObject);
      expect(message, isA<LiveServerSetupComplete>());
    });

    test('parseServerMessage throws VertexAIException for error message', () {
      final jsonObject = {'error': {}};
      expect(() => parseServerMessage(jsonObject),
          throwsA(isA<VertexAISdkException>()));
    });

    test('parseServerMessage throws VertexAISdkException for unhandled format',
        () {
      final jsonObject = {'unknown': {}};
      expect(() => parseServerMessage(jsonObject),
          throwsA(isA<VertexAISdkException>()));
    });
  });
}
