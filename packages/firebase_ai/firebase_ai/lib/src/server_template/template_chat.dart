// Copyright 2026 Google LLC
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

import '../api.dart';
import '../base_model.dart';
import '../content.dart';
import '../utils/chat_utils.dart';
import '../utils/mutex.dart';

final class TemplateAutoFunction {
  TemplateAutoFunction({
    required this.name,
    required this.callable,
  });

  /// The name of the function.
  ///
  /// Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum
  /// length of 63.
  final String name;

  /// The callable function that this declaration represents.
  final FutureOr<Map<String, Object?>> Function(Map<String, Object?> args)
      callable;
}

/// A back-and-forth chat with a server template.
///
/// Records messages sent and received in [history]. The history will always
/// record the content from the first candidate in the
/// [GenerateContentResponse], other candidates may be available on the returned
/// response. The history reflects the most current state of the chat session.
final class TemplateChatSession {
  TemplateChatSession._(
    this._templateHistoryGenerateContent,
    this._templateHistoryGenerateContentStream,
    this._templateId,
    this._history,
    List<TemplateAutoFunction> autoFunctionLists,
    this._maxTurns,
  ) : _autoFunctions = {for (var item in autoFunctionLists) item.name: item};

  final Future<GenerateContentResponse> Function(
      Iterable<Content> content, String templateId,
      {required Map<String, Object?> inputs}) _templateHistoryGenerateContent;

  final Stream<GenerateContentResponse> Function(
          Iterable<Content> content, String templateId,
          {required Map<String, Object?> inputs})
      _templateHistoryGenerateContentStream;
  final String _templateId;
  final List<Content> _history;
  final Map<String, TemplateAutoFunction> _autoFunctions;
  final int _maxTurns;

  final _mutex = Mutex();

  /// The content that has been successfully sent to, or received from, the
  /// generative model.
  ///
  /// If there are outstanding requests from calls to [sendMessage],
  /// these will not be reflected in the history.
  /// Messages without a candidate in the response are not recorded in history,
  /// including the message sent to the model.
  Iterable<Content> get history => _history.skip(0);

  /// Sends [inputs] to the server template as a continuation of the chat [history].
  ///
  /// Prepends the history to the request and uses the provided model to
  /// generate new content.
  ///
  /// When there are no candidates in the response, the [message] and response
  /// are ignored and will not be recorded in the [history].
  Future<GenerateContentResponse> sendMessage(Content message,
      {required Map<String, Object?> inputs}) async {
    final lock = await _mutex.acquire();
    try {
      final requestHistory = <Content>[message];
      var turn = 0;
      while (turn < _maxTurns) {
        final response = await _templateHistoryGenerateContent(
          _history.followedBy(requestHistory),
          _templateId,
          inputs: inputs,
        );

        final functionCalls = response.functionCalls;
        final shouldAutoExecute = _autoFunctions.isNotEmpty &&
            functionCalls.isNotEmpty &&
            functionCalls.every((c) => _autoFunctions.containsKey(c.name));

        if (!shouldAutoExecute) {
          // Standard handling: Update history and return the response to the user.
          if (response.candidates case [final candidate, ...]) {
            _history.add(message);
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
          final function = _autoFunctions[functionCall.name];

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

  /// Sends [message] to the server template as a continuation of the chat
  /// [history].
  ///
  /// Returns a stream of responses, which may be chunks of a single aggregate
  /// response.
  ///
  /// Prepends the history to the request and uses the provided model to
  /// generate new content.
  ///
  /// When there are no candidates in the response, the [message] and response
  /// are ignored and will not be recorded in the [history].
  Stream<GenerateContentResponse> sendMessageStream(Content message,
      {required Map<String, Object?> inputs}) {
    final controller = StreamController<GenerateContentResponse>(sync: true);
    _mutex.acquire().then((lock) async {
      try {
        final responses = _templateHistoryGenerateContentStream(
          _history.followedBy([message]),
          _templateId,
          inputs: inputs,
        );
        final content = <Content>[];
        await for (final response in responses) {
          if (response.candidates case [final candidate, ...]) {
            content.add(candidate.content);
          }
          controller.add(response);
        }
        if (content.isNotEmpty) {
          _history.add(message);
          _history.add(historyAggregate(content));
        }
      } catch (e, s) {
        controller.addError(e, s);
      }
      lock.release();
      unawaited(controller.close());
    });
    return controller.stream;
  }
}

/// An extension on [TemplateGenerativeModel] that provides a `startChat` method.
extension StartTemplateChatExtension on TemplateGenerativeModel {
  /// Starts a [TemplateChatSession] that will use this model to respond to messages.
  ///
  /// ```dart
  /// final chat = model.startChat();
  /// final response = await chat.sendMessage(Content.text('Hello there.'));
  /// print(response.text);
  /// ```
  TemplateChatSession startChat(String templateId,
          {List<Content>? history,
          List<TemplateAutoFunction>? autoFunctions,
          int? maxTurns}) =>
      TemplateChatSession._(
          templateGenerateContentWithHistory,
          templateGenerateContentWithHistoryStream,
          templateId,
          history ?? [],
          autoFunctions ?? [],
          maxTurns ?? 5);
}
