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
import 'package:firebase_ai/src/error.dart';
import 'package:firebase_ai/src/live_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LiveAPI Tests', () {
    test('SpeechConfig toJson() returns correct JSON', () {
      final speechConfigWithVoice = SpeechConfig(voiceName: 'Aoede');
      expect(speechConfigWithVoice.toJson(), {
        'voice_config': {
          'prebuilt_voice_config': {'voice_name': 'Aoede'}
        }
      });

      final speechConfigWithoutVoice = SpeechConfig();
      expect(speechConfigWithoutVoice.toJson(), {});
    });

    test('ResponseModalities enum toJson() returns correct value', () {
      expect(ResponseModalities.text.toJson(), 'TEXT');
      expect(ResponseModalities.image.toJson(), 'IMAGE');
      expect(ResponseModalities.audio.toJson(), 'AUDIO');
    });

    test('LiveGenerationConfig toJson() returns correct JSON', () {
      final liveGenerationConfig = LiveGenerationConfig(
        speechConfig: SpeechConfig(voiceName: 'Charon'),
        responseModalities: [ResponseModalities.text, ResponseModalities.audio],
        maxOutputTokens: 100,
        temperature: 0.8,
        topP: 0.95,
        topK: 40,
      );

      expect(liveGenerationConfig.toJson(), {
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
      const functionCall = FunctionCall('test', {});
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
      // ignore: deprecated_member_use_from_same_package
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
      const response = FunctionResponse('test', {});
      final message = LiveClientToolResponse(functionResponses: [response]);
      expect(message.toJson(), {
        'toolResponse': {
          'functionResponses': [
            {'name': 'test', 'response': {}}
          ]
        }
      });

      final message2 = LiveClientToolResponse();
      expect(message2.toJson(), {
        'toolResponse': {'functionResponses': null}
      });
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
      final response = parseServerResponse(jsonObject);
      expect(response.message, isA<LiveServerContent>());
      final contentMessage = response.message as LiveServerContent;
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
      final response = parseServerResponse(jsonObject);
      expect(response.message, isA<LiveServerToolCall>());
      final toolCallMessage = response.message as LiveServerToolCall;
      expect(toolCallMessage.functionCalls, isA<List<FunctionCall>>());
    });

    test('parseServerMessage parses toolCallCancellation message correctly',
        () {
      final jsonObject = jsonDecode('''
        {
          "toolCallCancellation": {
            "ids": ["1", "2"]
          }
        }
        ''') as Map<String, dynamic>;
      final response = parseServerResponse(jsonObject);
      expect(response.message, isA<LiveServerToolCallCancellation>());
      final cancellationMessage =
          response.message as LiveServerToolCallCancellation;
      expect(cancellationMessage.functionIds, ['1', '2']);
    });

    test('parseServerMessage parses setupComplete message correctly', () {
      final jsonObject = {'setupComplete': {}};
      final response = parseServerResponse(jsonObject);
      expect(response.message, isA<LiveServerSetupComplete>());
    });

    test('parseServerMessage throws VertexAIException for error message', () {
      final jsonObject = {'error': {}};
      expect(() => parseServerResponse(jsonObject),
          throwsA(isA<FirebaseAISdkException>()));
    });

    test('parseServerMessage throws VertexAISdkException for unhandled format',
        () {
      final jsonObject = {'unknown': {}};
      expect(() => parseServerResponse(jsonObject),
          throwsA(isA<FirebaseAISdkException>()));
    });

    test(
        'LiveGenerationConfig with transcriptions toJson() returns correct JSON',
        () {
      final liveGenerationConfig = LiveGenerationConfig(
        inputAudioTranscription: AudioTranscriptionConfig(),
        outputAudioTranscription: AudioTranscriptionConfig(),
      );
      // Explicitly, these two config should not exist in the toJson()
      expect(liveGenerationConfig.toJson(), {});
    });

    test('parseServerMessage parses serverContent with transcriptions', () {
      final jsonObject = {
        'serverContent': {
          'modelTurn': {
            'parts': [
              {'text': 'Hello, world!'}
            ]
          },
          'turnComplete': true,
          'inputTranscription': {'text': 'input', 'finished': true},
          'outputTranscription': {'text': 'output', 'finished': false}
        }
      };
      final response = parseServerResponse(jsonObject);
      expect(response.message, isA<LiveServerContent>());
      final contentMessage = response.message as LiveServerContent;
      expect(contentMessage.turnComplete, true);
      expect(contentMessage.modelTurn, isA<Content>());
      expect(contentMessage.inputTranscription, isA<Transcription>());
      expect(contentMessage.inputTranscription?.text, 'input');
      expect(contentMessage.inputTranscription?.finished, true);
      expect(contentMessage.outputTranscription, isA<Transcription>());
      expect(contentMessage.outputTranscription?.text, 'output');
      expect(contentMessage.outputTranscription?.finished, false);
    });
  });
}
