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

import 'content.dart';
import 'error.dart';
import 'live_api.dart';

const _FUNCTION_RESPONSE_REQUIRES_ID =
    'FunctionResponse request must have an `id` field from the'
    ' response of a ToolCall.FunctionalCalls in Google AI.';

/// Manages asynchronous communication with Gemini model over a WebSocket
/// connection.
class LiveSession {
  // ignore: public_member_api_docs
  LiveSession({required WebSocketChannel ws}) : _ws = ws;
  final WebSocketChannel _ws;

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
    print('Sending $clientJson');
    _ws.sink.add(clientJson);
  }

  /// Sends realtime input (media chunks) to the server.
  ///
  /// [mediaChunks]: The list of media chunks to send.
  Future<void> sendMediaChunks({
    required List<InlineDataPart> mediaChunks,
  }) async {
    _checkWsStatus();
    var clientMessage = LiveClientRealtimeInput(mediaChunks: mediaChunks);

    var clientJson = jsonEncode(clientMessage.toJson());
    // print('Streaming $clientJson');
    _ws.sink.add(clientJson);
  }

  /// Starts streaming media chunks to the server from the provided [mediaChunkStream].
  ///
  /// This function asynchronously processes each [InlineDataPart] from the given
  /// [mediaChunkStream] and sends it to the server via the WebSocket connection.
  ///
  /// Parameters:
  /// - [mediaChunkStream]: The stream of [InlineDataPart] objects to send to the server.
  Future<void> startMediaStream(Stream<InlineDataPart> mediaChunkStream) async {
    _checkWsStatus();

    try {
      await for (var chunk in mediaChunkStream) {
        await _sendMediaChunk(chunk);
      }
    } catch (e) {
      print('Error during stream processing: $e');
      // Handle the error appropriately (e.g., close the WebSocket, notify the user)
    } finally {
      print('Stream processing completed.');
    }
  }

  Future<void> _sendMediaChunk(InlineDataPart chunk) async {
    var clientMessage = LiveClientRealtimeInput(
        mediaChunks: [chunk]); // Create a list with the single chunk
    var clientJson = jsonEncode(clientMessage.toJson());
    _ws.sink.add(clientJson);
  }

  /// Receives messages from the server.
  ///
  /// Returns a [Stream] of [LiveServerMessage] objects representing the
  /// messages received from the server.
  Stream<LiveServerMessage> receive() async* {
    _checkWsStatus();
    await for (var message in _ws.stream) {
      var jsonString = utf8.decode(message);
      var response = json.decode(jsonString);
      //print(response);

      var result = parseServerMessage(response);

      yield result;
    }
  }

  /// Receives messages from the server and invokes the [callback] function with each message.
  ///
  /// This function asynchronously processes messages from the server and passes each
  /// [LiveServerMessage] to the provided [callback] function.
  Future<void> receiveWithCallback(
      Future<void> Function(LiveServerMessage message) callback) async {
    _checkWsStatus();
    await for (var message in _ws.stream) {
      var jsonString = utf8.decode(message);
      var response = json.decode(jsonString);

      var result = parseServerMessage(response);

      await callback(result);
    }
  }

  /// Closes the WebSocket connection.
  Future<void> close() async {
    await _ws.sink.close();
  }

  void _checkWsStatus() {
    if (_ws.closeCode != null) {
      var message =
          'WebSocket status: Closed, closeCode: ${_ws.closeCode}, closeReason: ${_ws.closeReason}';

      throw LiveWebSocketClosedException(message);
    }
  }

  void printWsStatus() {
    if (_ws.closeCode != null) {
      print('WebSocket status: Closed, close code ${_ws.closeCode}');
      print('Closed reason ${_ws.closeReason}');
    } else {
      print('WebSocket status: Open');
    }
  }
}
