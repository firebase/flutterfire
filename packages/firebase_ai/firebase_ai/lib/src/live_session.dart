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
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'content.dart';
import 'error.dart';
import 'live_api.dart';
import 'tool.dart';

/// Manages asynchronous communication with Gemini model over a WebSocket
/// connection.
class LiveSession {
  // ignore: public_member_api_docs
  LiveSession._(
    this._ws, {
    required String uri,
    required Map<String, String> headers,
    required String modelString,
    Content? systemInstruction,
    List<Tool>? tools,
    LiveGenerationConfig? liveGenerationConfig,
  })  : _uri = uri,
        _headers = headers,
        _modelString = modelString,
        _systemInstruction = systemInstruction,
        _tools = tools,
        _liveGenerationConfig = liveGenerationConfig,
        _messageController = StreamController<LiveServerResponse>.broadcast() {
    _listenToWebSocket();
  }

  /// Establishes a connection to a live generation service.
  ///
  /// This function handles the WebSocket connection setup and returns an [LiveSession]
  /// object that can be used to communicate with the service.
  ///
  /// Returns a [Future] that resolves to an [LiveSession] object upon successful
  /// connection.
  static Future<LiveSession> connect({
    required String uri,
    required Map<String, String> headers,
    required String modelString,
    Content? systemInstruction,
    List<Tool>? tools,
    SessionResumptionConfig? sessionResumption,
    LiveGenerationConfig? liveGenerationConfig,
  }) async {
    final ws = await _performWebSocketSetup(
      uri: uri,
      headers: headers,
      modelString: modelString,
      systemInstruction: systemInstruction,
      tools: tools,
      sessionResumption: sessionResumption,
      liveGenerationConfig: liveGenerationConfig,
    );
    return LiveSession._(
      ws,
      uri: uri,
      headers: headers,
      modelString: modelString,
      systemInstruction: systemInstruction,
      tools: tools,
      liveGenerationConfig: liveGenerationConfig,
    );
  }

  // Persisted values for session resumption.
  final String _uri;
  final Map<String, String> _headers;
  final String _modelString;
  final Content? _systemInstruction;
  final List<Tool>? _tools;
  final LiveGenerationConfig? _liveGenerationConfig;

  WebSocketChannel _ws;
  StreamController<LiveServerResponse> _messageController;
  late StreamSubscription _wsSubscription;

  static Future<WebSocketChannel> _performWebSocketSetup({
    required String uri,
    required Map<String, String> headers,
    required String modelString,
    Content? systemInstruction,
    List<Tool>? tools,
    SessionResumptionConfig? sessionResumption,
    LiveGenerationConfig? liveGenerationConfig,
  }) async {
    final setupJson = {
      'setup': {
        'model': modelString,
        if (systemInstruction != null)
          'system_instruction': systemInstruction.toJson(),
        if (tools != null) 'tools': tools.map((t) => t.toJson()).toList(),
        if (sessionResumption != null)
          'session_resumption': sessionResumption.toJson(),
        if (liveGenerationConfig != null) ...{
          'generation_config': liveGenerationConfig.toJson(),
          if (liveGenerationConfig.inputAudioTranscription != null)
            'input_audio_transcription':
                liveGenerationConfig.inputAudioTranscription!.toJson(),
          if (liveGenerationConfig.outputAudioTranscription != null)
            'output_audio_transcription':
                liveGenerationConfig.outputAudioTranscription!.toJson(),
          if (liveGenerationConfig.contextWindowCompression
              case final contextWindowCompression?)
            'contextWindowCompression': contextWindowCompression.toJson()
        },
      }
    };

    final request = jsonEncode(setupJson);
    final ws = kIsWeb
        ? WebSocketChannel.connect(Uri.parse(uri))
        : IOWebSocketChannel.connect(Uri.parse(uri), headers: headers);
    await ws.ready;

    ws.sink.add(request);
    return ws;
  }

  void _listenToWebSocket() {
    _wsSubscription = _ws.stream.listen(
      (message) {
        try {
          var jsonString = utf8.decode(message);
          var response = json.decode(jsonString);

          _messageController.add(parseServerResponse(response));
        } catch (e) {
          _messageController.addError(e);
        }
      },
      onError: (error) {
        _messageController.addError(error);
      },
      onDone: _messageController.close,
    );
  }

  Future<void> resumeSession(
      {SessionResumptionConfig? sessionResumption}) async {
    await close();

    _ws = await _performWebSocketSetup(
      uri: _uri,
      headers: _headers,
      modelString: _modelString,
      systemInstruction: _systemInstruction,
      tools: _tools,
      sessionResumption: sessionResumption,
      liveGenerationConfig: _liveGenerationConfig,
    );

    _messageController = StreamController<LiveServerResponse>.broadcast();
    _listenToWebSocket();
  }

  /// Sends content to the server.
  ///
  /// [input] (optional): The content to send.
  /// [turnComplete] (optional): Indicates if the turn is complete. Defaults to false.
  Future<void> send({
    Content? input,
    bool turnComplete = false,
  }) async {
    _checkWsStatus();
    var clientMessage = input != null
        ? LiveClientContent(turns: [input], turnComplete: turnComplete)
        : LiveClientContent(turnComplete: turnComplete);
    var clientJson = jsonEncode(clientMessage.toJson());
    _ws.sink.add(clientJson);
  }

  /// Sends tool responses for function calling to the server.
  ///
  /// [functionResponses] (optional): The list of function responses.
  Future<void> sendToolResponse(
      List<FunctionResponse>? functionResponses) async {
    final toolResponse =
        LiveClientToolResponse(functionResponses: functionResponses);
    _checkWsStatus();
    var clientJson = jsonEncode(toolResponse.toJson());
    _ws.sink.add(clientJson);
  }

  /// Sends audio data to the server in realtime.
  ///
  /// Check https://ai.google.dev/api/live#bidigeneratecontentrealtimeinput for
  /// details about the realtime input usage.
  /// [audio]: The audio data to send.
  Future<void> sendAudioRealtime(InlineDataPart audio) async {
    _checkWsStatus();
    var clientMessage = LiveClientRealtimeInput.audio(audio);
    var clientJson = jsonEncode(clientMessage.toJson());
    _ws.sink.add(clientJson);
  }

  /// Sends video data to the server in realtime.
  ///
  /// Check https://ai.google.dev/api/live#bidigeneratecontentrealtimeinput for
  /// details about the realtime input usage.
  /// [video]: The video data to send.
  Future<void> sendVideoRealtime(InlineDataPart video) async {
    _checkWsStatus();
    var clientMessage = LiveClientRealtimeInput.video(video);
    var clientJson = jsonEncode(clientMessage.toJson());
    _ws.sink.add(clientJson);
  }

  /// Sends text data to the server in realtime.
  ///
  /// Check https://ai.google.dev/api/live#bidigeneratecontentrealtimeinput for
  /// details about the realtime input usage.
  /// [text]: The text data to send.
  Future<void> sendTextRealtime(String text) async {
    _checkWsStatus();
    var clientMessage = LiveClientRealtimeInput.text(text);
    var clientJson = jsonEncode(clientMessage.toJson());
    _ws.sink.add(clientJson);
  }

  /// Sends realtime input (media chunks) to the server.
  ///
  /// [mediaChunks]: The list of media chunks to send.
  @Deprecated(
      'Use sendAudioRealtime, sendVideoRealtime, or sendTextRealtime instead')
  Future<void> sendMediaChunks({
    required List<InlineDataPart> mediaChunks,
  }) async {
    _checkWsStatus();
    var clientMessage = LiveClientRealtimeInput(mediaChunks: mediaChunks);
    var clientJson = jsonEncode(clientMessage.toJson());
    _ws.sink.add(clientJson);
  }

  /// Starts streaming media chunks to the server from the provided [mediaChunkStream].
  ///
  /// This function asynchronously processes each [InlineDataPart] from the given
  /// [mediaChunkStream] and sends it to the server via the WebSocket connection.
  ///
  /// Parameters:
  /// - [mediaChunkStream]: The stream of [InlineDataPart] objects to send to the server.
  @Deprecated('Use sendAudio, sendVideo, or sendText with a stream instead')
  Future<void> sendMediaStream(Stream<InlineDataPart> mediaChunkStream) async {
    _checkWsStatus();

    try {
      await for (final chunk in mediaChunkStream) {
        await _sendMediaChunk(chunk);
      }
    } catch (e) {
      throw FirebaseAISdkException(e.toString());
    } finally {
      log('Stream processing completed.');
    }
  }

  Future<void> _sendMediaChunk(InlineDataPart chunk) async {
    var clientMessage = LiveClientRealtimeInput(
        // ignore: deprecated_member_use_from_same_package
        mediaChunks: [chunk]); // Create a list with the single chunk
    var clientJson = jsonEncode(clientMessage.toJson());
    _ws.sink.add(clientJson);
  }

  /// Receives messages from the server.
  ///
  /// Returns a [Stream] of [LiveServerResponse] objects representing the
  /// messages received from the server. The stream will stops once the server
  /// sends turn complete message.
  Stream<LiveServerResponse> receive() async* {
    _checkWsStatus();

    await for (final result in _messageController.stream) {
      yield result;
      final message = result.message;

      if (message is LiveServerContent &&
          message.turnComplete != null &&
          message.turnComplete!) {
        break; // Exit the loop when the turn is complete
      }
    }
  }

  /// Closes the WebSocket connection.
  Future<void> close() async {
    await _wsSubscription.cancel();
    await _messageController.close();
    await _ws.sink.close();
  }

  void _checkWsStatus() {
    if (_ws.closeCode != null) {
      var message =
          'WebSocket Closed, closeCode: ${_ws.closeCode}, closeReason: ${_ws.closeReason}';

      throw LiveWebSocketClosedException(message);
    }
  }
}
