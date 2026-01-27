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

import 'dart:async';

import 'api.dart';
import 'base_model.dart';
import 'content.dart';
import 'tool.dart';
import 'utils/chat_utils.dart';
import 'utils/mutex.dart';

/// A back-and-forth chat with a generative model.
///
/// Records messages sent and received in [history]. The history will always
/// record the content from the first candidate in the
/// [GenerateContentResponse], other candidates may be available on the returned
/// response. The history reflects the most current state of the chat session.
final class ChatSession {
  ChatSession._(
      this._generateContent,
      this._generateContentStream,
      this._history,
      this._safetySettings,
      this._generationConfig,
      List<Tool>? tools,
      this._maxTurns)
      : _autoFunctionDeclarations = tools
            ?.expand((tool) => tool.autoFunctionDeclarations)
            .fold(<String, AutoFunctionDeclaration>{}, (map, function) {
          map?[function.name] = function;
          return map;
        });
  final Future<GenerateContentResponse> Function(Iterable<Content> content,
      {List<SafetySetting>? safetySettings,
      GenerationConfig? generationConfig}) _generateContent;
  final Stream<GenerateContentResponse> Function(Iterable<Content> content,
      {List<SafetySetting>? safetySettings,
      GenerationConfig? generationConfig}) _generateContentStream;

  final _mutex = Mutex();

  final List<Content> _history;
  final List<SafetySetting>? _safetySettings;
  final GenerationConfig? _generationConfig;
  final Map<String, AutoFunctionDeclaration>? _autoFunctionDeclarations;
  final int _maxTurns;

  /// The content that has been successfully sent to, or received from, the
  /// generative model.
  ///
  /// If there are outstanding requests from calls to [sendMessage] or
  /// [sendMessageStream], these will not be reflected in the history.
  /// Messages without a candidate in the response are not recorded in history,
  /// including the message sent to the model.
  Iterable<Content> get history => _history.skip(0);

  /// Sends [message] to the model as a continuation of the chat [history].
  ///
  /// Prepends the history to the request and uses the provided model to
  /// generate new content.
  ///
  /// When there are no candidates in the response, the [message] and response
  /// are ignored and will not be recorded in the [history].
  ///
  /// Waits for any ongoing or pending requests to [sendMessage] or
  /// [sendMessageStream] to complete before generating new content.
  /// Successful messages and responses for ongoing or pending requests will
  /// be reflected in the history sent for this message.
  Future<GenerateContentResponse> sendMessage(Content message) async {
    final lock = await _mutex.acquire();
    try {
      final requestHistory = <Content>[message];
      var turn = 0;
      while (turn < _maxTurns) {
        final response = await _generateContent(
            _history.followedBy(requestHistory),
            safetySettings: _safetySettings,
            generationConfig: _generationConfig);

        final functionCalls = response.functionCalls;

        // Only trigger auto-execution if:
        // 1. We have auto-functions configured.
        // 2. The response actually contains function calls.
        // 3. ALL called functions exist in our declarations (prevents crashes).
        final shouldAutoExecute = _autoFunctionDeclarations != null &&
            _autoFunctionDeclarations.isNotEmpty &&
            functionCalls.isNotEmpty &&
            functionCalls
                .every((c) => _autoFunctionDeclarations.containsKey(c.name));
        if (!shouldAutoExecute) {
          // Standard handling: Update history and return the response to the user.
          if (response.candidates case [final candidate, ...]) {
            _history.addAll(requestHistory);
            final normalizedContent = candidate.content.role == null
                ? Content('model', candidate.content.parts)
                : candidate.content;
            _history.add(normalizedContent);
          }
          return response;
        }

        // Auto function execution
        requestHistory.add(response.candidates.first.content);
        final functionResponses = <Part>[];
        for (final functionCall in functionCalls) {
          final function = _autoFunctionDeclarations[functionCall.name];

          Object? result;
          try {
            result = await function!.callable(functionCall.args);
          } catch (e) {
            result = e.toString();
          }
          functionResponses
              .add(FunctionResponse(functionCall.name, {'result': result}));
        }
        requestHistory.add(Content('function', functionResponses));
        turn++;
      }
      throw Exception('Max turns of $_maxTurns reached.');
    } finally {
      lock.release();
    }
  }

  /// Continues the chat with a new [message].
  ///
  /// Sends [message] to the model as a continuation of the chat [history] and
  /// reads the response in a stream.
  /// Prepends the history to the request and uses the provided model to
  /// generate new content.
  ///
  /// When there are no candidates in any response in the stream, the [message]
  /// and responses are ignored and will not be recorded in the [history].
  ///
  /// Waits for any ongoing or pending requests to [sendMessage] or
  /// [sendMessageStream] to complete before generating new content.
  /// Successful messages and responses for ongoing or pending requests will
  /// be reflected in the history sent for this message.
  ///
  /// Waits to read the entire streamed response before recording the message
  /// and response and allowing pending messages to be sent.
  Stream<GenerateContentResponse> sendMessageStream(Content message) {
    final controller = StreamController<GenerateContentResponse>();
    _mutex.acquire().then((lock) async {
      try {
        final requestHistory = <Content>[message];
        var turn = 0;
        while (turn < _maxTurns) {
          final responses = _generateContentStream(
              _history.followedBy(requestHistory),
              safetySettings: _safetySettings,
              generationConfig: _generationConfig);

          final turnChunks = <GenerateContentResponse>[];
          await for (final response in responses) {
            turnChunks.add(response);
            controller.add(response);
          }
          if (turnChunks.isEmpty) break;
          final aggregatedContent = historyAggregate(turnChunks.map((r) {
            final content = r.candidates.firstOrNull?.content;
            if (content == null) {
              throw Exception('No content in response candidate');
            }
            return content;
          }).toList());

          final functionCalls =
              aggregatedContent.parts.whereType<FunctionCall>().toList();

          // Check if we should actually execute these functions.
          final shouldAutoExecute = _autoFunctionDeclarations != null &&
              _autoFunctionDeclarations.isNotEmpty &&
              functionCalls.isNotEmpty &&
              functionCalls
                  .every((c) => _autoFunctionDeclarations.containsKey(c.name));

          if (!shouldAutoExecute) {
            _history.addAll(requestHistory);
            _history.add(aggregatedContent);
            return;
          }

          requestHistory.add(aggregatedContent);
          final functionResponseFutures =
              functionCalls.map((functionCall) async {
            final function = _autoFunctionDeclarations[functionCall.name];

            Object? result;
            try {
              result = await function!.callable(functionCall.args);
            } catch (e) {
              result = e.toString();
            }
            return FunctionResponse(functionCall.name, {'result': result});
          });
          final functionResponseParts =
              await Future.wait(functionResponseFutures);
          requestHistory.add(Content.functionResponses(functionResponseParts));
          turn++;
        }
        throw Exception('Max turns of $_maxTurns reached.');
      } catch (e, s) {
        controller.addError(e, s);
      } finally {
        lock.release();
        unawaited(controller.close());
      }
    });
    return controller.stream;
  }
}

/// [StartChatExtension] on [GenerativeModel]
extension StartChatExtension on GenerativeModel {
  /// Starts a [ChatSession] that will use this model to respond to messages.
  ///
  /// ```dart
  /// final chat = model.startChat();
  /// final response = await chat.sendMessage(Content.text('Hello there.'));
  /// print(response.text);
  /// ```
  ChatSession startChat(
          {List<Content>? history,
          List<SafetySetting>? safetySettings,
          GenerationConfig? generationConfig,
          int? maxTurns}) =>
      ChatSession._(generateContent, generateContentStream, history ?? [],
          safetySettings, generationConfig, tools, maxTurns ?? 5);
}
