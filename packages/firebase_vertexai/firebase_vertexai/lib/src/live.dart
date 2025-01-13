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
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:firebase_vertexai/firebase_vertexai.dart';

// import 'package:genai/genai.dart';
// import 'package:genai/src/common.dart';

class ApiClient {
  ApiClient(this.baseUrl, this.apiVersion, this.apiKey);
  String baseUrl;
  String apiVersion;
  String apiKey;
}

const _FUNCTION_RESPONSE_REQUIRES_ID =
    'FunctionResponse request must have an `id` field from the'
    ' response of a ToolCall.FunctionalCalls in Google AI.';

class AsyncSession {
  final ApiClient _apiClient;
  final WebSocketChannel _ws;

  AsyncSession({required ApiClient apiClient, required WebSocketChannel ws})
      : _apiClient = apiClient,
        _ws = ws;

  Future<void> send({
    required input,
    bool endOfTurn = false,
  }) async {
    var clientMessage = _parseClientMessage(input, endOfTurn);
    _ws.sink.add(json.encode(clientMessage));
  }

  Stream<LiveServerMessage> receive() async* {
    await for (var message in _ws.stream) {
      var response = json.decode(message);
      Map<String, dynamic> responseDict;

      responseDict = _LiveServerMessageFromVertex(response);

      var result = LiveServerMessage.fromJson(responseDict);

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
        var input = {
          'data': base64Encode(data),
          'mimeType': mimeType,
        };
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
      toObject['model_turn'] = Content.fromJson(fromObject['modelTurn']);
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
    } else if (input is Blob) {
      input.data = base64Encode(input.data);
      input = [input];
    } else if (input is Map &&
        input.containsKey('name') &&
        input.containsKey('response')) {
      if (!_apiClient.vertexai && !input.containsKey('id')) {
        throw ArgumentError(_FUNCTION_RESPONSE_REQUIRES_ID);
      }
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
      var contents = input.map((e) => Content(text: e)).toList();
      return {
        'client_content': {'turns': contents, 'turn_complete': endOfTurn}
      };
    } else if (input is List) {
      if (input.any((e) => e is Map && e.containsKey('data'))) {
        // Do nothing
      } else if (input.any((e) => e is Blob)) {
        input = input.map((e) => (e as Blob).toJson()).toList();
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
      if (!_apiClient.vertexai && !(input.functionResponses[0].id != null)) {
        throw ArgumentError(_FUNCTION_RESPONSE_REQUIRES_ID);
      }
      return {'tool_response': input.toJson()};
    } else if (input is FunctionResponse) {
      if (!_apiClient.vertexai && !(input.id != null)) {
        throw ArgumentError(_FUNCTION_RESPONSE_REQUIRES_ID);
      }
      return {
        'tool_response': {
          'function_responses': [input.toJson()]
        }
      };
    } else if (input is List && input[0] is FunctionResponse) {
      if (!_apiClient.vertexai && !(input[0].id != null)) {
        throw ArgumentError(_FUNCTION_RESPONSE_REQUIRES_ID);
      }
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
  AsyncLive(this.apiClient);
  final ApiClient apiClient;

  Map<String, dynamic> _liveSetupToMldev(
      {String? model, Map<String, dynamic>? config}) {
    var toObject = <String, dynamic>{};

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
            Content.fromJson(config['system_instruction']).toJson();
      }
      if (config.containsKey('tools')) {
        toObject['tools'] = config['tools'];
      }
    }

    var returnValue = {
      'setup': {'model': model}
    };
    returnValue['setup'].addAll(toObject);
    return returnValue;
  }

  Map<String, dynamic> _liveSetupToVertex(
      String model, Map<String, dynamic>? config) {
    var toObject = <String, dynamic>{};

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
            Content.fromJson(config['system_instruction']).toJson();
      }
      if (config.containsKey('tools')) {
        toObject['tools'] = config['tools'];
      }
    }

    var returnValue = {
      'setup': {'model': model}
    };
    returnValue['setup'].addAll(toObject);
    return returnValue;
  }

  Future<AsyncSession> connect({
    required String model,
    Map<String, dynamic>? config,
  }) async {
    var baseUrl = apiClient.baseUrl;
    late String uri;
    late Map<String, String> headers;
    late String request;

    var apiKey = apiClient.apiKey!;
    var version = apiClient.apiVersion;
    uri =
        '$baseUrl/ws/google.ai.generativelanguage.$version.GenerativeService.BidiGenerateContent?key=$apiKey';
    //headers = apiClient._httpOptions['headers'];
    request =
        json.encode(_liveSetupToMldev(model: model, config: config ?? {}));

    var ws = WebSocketChannel.connect(Uri.parse(uri), protocols: ['http']);
    ws.sink.add(request);
    return AsyncSession(apiClient: apiClient, ws: ws);
  }
}
