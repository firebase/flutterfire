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

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'live_client.dart';
import 'live_content.dart';
import 'content.dart';

// import 'package:genai/genai.dart';
// import 'package:genai/src/common.dart';

const _FUNCTION_RESPONSE_REQUIRES_ID =
    'FunctionResponse request must have an `id` field from the'
    ' response of a ToolCall.FunctionalCalls in Google AI.';

class AsyncSession {
  final WebSocketChannel _ws;

  AsyncSession({required WebSocketChannel ws}) : _ws = ws;

  Future<void> send({
    required Content input,
    bool turnComplete = false,
  }) async {
    // var clientMessage = _parseClientMessage(input, endOfTurn);
    var clientMessage =
        LiveClientContent(turns: [input], turnComplete: turnComplete);
    _ws.sink.add(jsonEncode(clientMessage.toJson()));
  }

  Stream<LiveServerMessage> receive() async* {
    await for (var message in _ws.stream) {
      var jsonString = utf8.decode(message);
      var response = json.decode(jsonString);
      Map<String, dynamic> responseDict;

      responseDict = _LiveServerMessageFromVertex(response);

      var result = parseServerMessage(responseDict);

      if (result.serverContent?.turnComplete ?? false) {
        yield result;
        break;
      }
      yield result;
    }
  }

  Stream<LiveServerMessage> startStream({
    required Stream<List<int>> stream,
    required String mimeType,
  }) async* {
    var completer = Completer();
    // Start the send loop. When stream is complete, complete the completer.
    unawaited(_sendLoop(stream, mimeType, completer));

    // Wait for the send loop to complete or the websocket to close.
    await Future.any([completer.future, _ws.stream.isEmpty]);

    // Close the websocket if it's not already closed.
    if (_ws.closeCode == null) {
      await _ws.sink.close();
    }
  }

  Future<void> _sendLoop(
    Stream<List<int>> dataStream,
    String mimeType,
    Completer completer,
  ) async {
    try {
      await for (var data in dataStream) {
        var input = Content.inlineData(mimeType, Uint8List.fromList(data));

        await send(input: input);
        // Give a chance for the receive loop to process responses.
        await Future.delayed(Duration.zero);
      }
    } finally {
      // Complete the completer to signal the end of the stream.
      completer.complete();
    }
  }

  Map<String, dynamic> _LiveServerContentFromMldev(dynamic fromObject) {
    var toObject = <String, dynamic>{};
    if (fromObject is Map && fromObject.containsKey('modelTurn')) {
      toObject['model_turn'] = parseContent(fromObject['modelTurn']);
    }
    if (fromObject is Map && fromObject.containsKey('turnComplete')) {
      toObject['turn_complete'] = fromObject['turnComplete'];
    }
    return toObject;
  }

  Map<String, dynamic> _LiveToolCallFromMldev(dynamic fromObject) {
    var toObject = <String, dynamic>{};
    if (fromObject is Map && fromObject.containsKey('functionCalls')) {
      toObject['function_calls'] = fromObject['functionCalls'];
    }
    return toObject;
  }

  // Map<String, dynamic> _LiveServerMessageFromMldev(dynamic fromObject) {
  //   var toObject = <String, dynamic>{};
  //   if (fromObject is Map && fromObject.containsKey('serverContent')) {
  //     toObject['server_content'] =
  //         _LiveServerContentFromMldev(fromObject['serverContent']);
  //   }
  //   if (fromObject is Map && fromObject.containsKey('toolCall')) {
  //     toObject['tool_call'] = _LiveToolCallFromMldev(fromObject['toolCall']);
  //   }
  //   if (fromObject is Map && fromObject.containsKey('toolCallCancellation')) {
  //     toObject['tool_call_cancellation'] = fromObject['toolCallCancellation'];
  //   }
  //   return toObject;
  // }

  Map<String, dynamic> _LiveServerContentFromVertex(dynamic fromObject) {
    var toObject = <String, dynamic>{};
    if (fromObject is Map && fromObject.containsKey('modelTurn')) {
      toObject['model_turn'] = parseContent(fromObject['modelTurn']);
    }
    if (fromObject is Map && fromObject.containsKey('turnComplete')) {
      toObject['turn_complete'] = fromObject['turnComplete'];
    }
    return toObject;
  }

  Map<String, dynamic> _LiveToolCallFromVertex(dynamic fromObject) {
    var toObject = <String, dynamic>{};
    if (fromObject is Map && fromObject.containsKey('functionCalls')) {
      toObject['function_calls'] = fromObject['functionCalls'];
    }
    return toObject;
  }

  Map<String, dynamic> _LiveServerMessageFromVertex(dynamic fromObject) {
    var toObject = <String, dynamic>{};
    if (fromObject is Map && fromObject.containsKey('serverContent')) {
      toObject['server_content'] =
          _LiveServerContentFromVertex(fromObject['serverContent']);
    }
    if (fromObject is Map && fromObject.containsKey('toolCall')) {
      toObject['tool_call'] = _LiveToolCallFromVertex(fromObject['toolCall']);
    }
    if (fromObject is Map && fromObject.containsKey('toolCallCancellation')) {
      toObject['tool_call_cancellation'] = fromObject['toolCallCancellation'];
    }
    return toObject;
  }

  dynamic _parseClientMessage(input, bool endOfTurn) {
    if (input is String) {
      input = [input];
    } else if (input is Map && input.containsKey('data')) {
      if (input['data'] is List<int>) {
        var decodedData = base64Encode(input['data']);
        input['data'] = decodedData;
      }
      input = [input];
    } else if (input is InlineDataPart) {
      input = [input];
    } else if (input is Map &&
        input.containsKey('name') &&
        input.containsKey('response')) {
      input = [input];
    }

    if (input is List &&
        input.any((e) =>
            e is Map && e.containsKey('name') && e.containsKey('response'))) {
      // ToolResponse.FunctionResponse
      return {
        'tool_response': {'function_responses': input}
      };
    } else if (input is List && input.any((e) => e is String)) {
      var contents = input.map((e) => Content.text(e)).toList();
      return {
        'client_content': {'turns': contents, 'turn_complete': endOfTurn}
      };
    } else if (input is List) {
      if (input.any((e) => e is Map && e.containsKey('data'))) {
        // Do nothing
      } else if (input.any((e) => e is InlineDataPart)) {
        input = input.map((e) => (e as InlineDataPart).toJson()).toList();
      } else {
        throw ArgumentError(
            'Unsupported input type "${input.runtimeType}" or input content "$input"');
      }
      return {
        'realtime_input': {'media_chunks': input}
      };
    } else if (input is Map && input.containsKey('content')) {
      return {'client_content': input};
    } else if (input is LiveClientRealtimeInput) {
      var clientMessage = input.toJson();
      if (clientMessage['realtime_input']['media_chunks'][0]['data']
          is List<int>) {
        clientMessage['realtime_input']['media_chunks'] =
            clientMessage['realtime_input']['media_chunks']
                .map((e) => {
                      'data': base64Encode(e['data']),
                      'mimeType': e['mime_type'],
                    })
                .toList();
      }
      return clientMessage;
    } else if (input is LiveClientContent) {
      return {'client_content': input.toJson()};
    } else if (input is LiveClientToolResponse) {
      return {'tool_response': input.toJson()};
    } else if (input is FunctionResponse) {
      return {
        'tool_response': {
          'function_responses': [input.toJson()]
        }
      };
    } else if (input is List && input[0] is FunctionResponse) {
      return {
        'tool_response': {
          'function_responses': input.map((e) => e.toJson()).toList()
        }
      };
    } else {
      throw ArgumentError(
          'Unsupported input type "${input.runtimeType}" or input content "$input"');
    }
  }

  Future<void> close() async {
    await _ws.sink.close();
  }
}

class AsyncLive {
  AsyncLive(this._baseUrl, this._apiKey, this._apiVersion, this._location);

  final String _baseUrl;
  final String _apiKey;
  final String _apiVersion;
  final String _location;

  Map<String, dynamic> _liveSetupToMldev(
      {String? model, Map<String, dynamic>? config}) {
    var toObject = <String, dynamic>{};
    var returnValue = <String, dynamic>{};
    // if (config != null) {
    //   if (config.containsKey('generation_config')) {
    //     toObject['generationConfig'] = config['generation_config'];
    //   }
    //   if (config.containsKey('response_modalities')) {
    //     if (toObject.containsKey('generationConfig')) {
    //       toObject['generationConfig']['responseModalities'] =
    //           config['response_modalities'];
    //     } else {
    //       toObject['generationConfig'] = {
    //         'responseModalities': config['response_modalities']
    //       };
    //     }
    //   }
    //   if (config.containsKey('speech_config')) {
    //     if (toObject.containsKey('generationConfig')) {
    //       toObject['generationConfig']['speechConfig'] =
    //           config['speech_config'];
    //     } else {
    //       toObject['generationConfig'] = {
    //         'speechConfig': config['speech_config']
    //       };
    //     }
    //   }
    //   if (config.containsKey('system_instruction')) {
    //     toObject['systemInstruction'] =
    //         parseContent(config['system_instruction']).toJson();
    //   }
    //   if (config.containsKey('tools')) {
    //     toObject['tools'] = config['tools'];
    //   }
    // }

    returnValue['setup'] = <String, dynamic>{};
    returnValue['setup']['model'] = 'models/$model';
    returnValue['setup'].addAll(config);
    return returnValue;
  }

  Map<String, dynamic> _liveSetupToVertex(
      String model, Map<String, dynamic>? config) {
    var toObject = <String, dynamic>{};
    var returnValue = <String, dynamic>{};
    if (config != null) {
      if (config.containsKey('generation_config')) {
        toObject['generationConfig'] = config['generation_config'];
      }
      if (config.containsKey('response_modalities')) {
        if (toObject.containsKey('generationConfig')) {
          toObject['generationConfig']['responseModalities'] =
              config['response_modalities'];
        } else {
          toObject['generationConfig'] = {
            'responseModalities': config['response_modalities']
          };
        }
      } else {
        // Set default to AUDIO to align with MLDev API.
        if (toObject.containsKey('generationConfig')) {
          toObject['generationConfig']['responseModalities'] = ['AUDIO'];
        } else {
          toObject['generationConfig'] = {
            'responseModalities': ['AUDIO']
          };
        }
      }
      if (config.containsKey('speech_config')) {
        if (toObject.containsKey('generationConfig')) {
          toObject['generationConfig']['speechConfig'] =
              config['speech_config'];
        } else {
          toObject['generationConfig'] = {
            'speechConfig': config['speech_config']
          };
        }
      }
      if (config.containsKey('system_instruction')) {
        toObject['systemInstruction'] =
            parseContent(config['system_instruction']).toJson();
      }
      if (config.containsKey('tools')) {
        toObject['tools'] = config['tools'];
      }
    }

    returnValue['setup'] = <String, dynamic>{};
    returnValue['setup']['model'] = model;
    returnValue['setup'].addAll(toObject);
    return returnValue;
  }

  Future<AsyncSession> connect({
    required String model,
    Map<String, dynamic>? config,
  }) async {
    late String uri;
    late Map<String, String> headers;
    late String request;

    uri =
        'wss://$_baseUrl/ws/google.ai.generativelanguage.$_apiVersion.GenerativeService.BidiGenerateContent?key=$_apiKey';
    //headers = apiClient._httpOptions['headers'];
    request = jsonEncode(_liveSetupToMldev(model: model, config: config ?? {}));

    var ws = WebSocketChannel.connect(Uri.parse(uri));
    await ws.ready;

    print(request);

    ws.sink.add(request);

    // Listen for incoming messages
    // ws.stream.listen(
    //   (message) {
    //     print('Received: $message');
    //   },
    //   onError: (error) {
    //     print('WebSocket error: $error');
    //     // Handle the error, potentially resending the message
    //   },
    // );

    return AsyncSession(ws: ws);
  }
}
