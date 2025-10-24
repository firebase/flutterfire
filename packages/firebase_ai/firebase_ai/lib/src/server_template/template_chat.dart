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

import '../api.dart';
import '../base_model.dart';
import '../content.dart';
import '../utils/chat_utils.dart';
import '../utils/mutex.dart';

/// A back-and-forth chat with a server template.
///
/// Records messages sent and received in [history]. The history will always
/// record the content from the first candidate in the
/// [GenerateContentResponse], other candidates may be available on the returned
/// response. The history is maintained and updated by the `google_generative_ai`
/// package and reflects the most current state of the chat session.
final class TemplateChatSession {
  TemplateChatSession._(
    this._templateHistoryGenerateContent,
    this._templateHistoryGenerateContentStream,
    this._templateId,
    this._history,
  );

  final Future<GenerateContentResponse> Function(
      Iterable<Content> content, String templateId,
      {Map<String, Object?>? inputs}) _templateHistoryGenerateContent;

  final Stream<GenerateContentResponse> Function(
      Iterable<Content> content, String templateId,
      {Map<String, Object?>? inputs}) _templateHistoryGenerateContentStream;
  final String _templateId;
  final List<Content> _history;

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
      {Map<String, Object?>? inputs}) async {
    final lock = await _mutex.acquire();
    try {
      final response = await _templateHistoryGenerateContent(
        _history.followedBy([message]),
        _templateId,
        inputs: inputs,
      );
      if (response.candidates case [final candidate, ...]) {
        _history.add(message);
        final normalizedContent = candidate.content.role == null
            ? Content('model', candidate.content.parts)
            : candidate.content;
        _history.add(normalizedContent);
      }
      return response;
    } finally {
      lock.release();
    }
  }

  Stream<GenerateContentResponse> sendMessageStream(Content message,
      {Map<String, Object?>? inputs}) {
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

/// [StartTemplateChatExtension] on [GenerativeModel]
extension StartTemplateChatExtension on TemplateGenerativeModel {
  /// Starts a [TemplateChatSession] that will use this model to respond to messages.
  ///
  /// ```dart
  /// final chat = model.startChat();
  /// final response = await chat.sendMessage(Content.text('Hello there.'));
  /// print(response.text);
  /// ```
  TemplateChatSession startChat(String templateId, {List<Content>? history}) =>
      TemplateChatSession._(
        templateGenerateContentWithHistory,
        templateGenerateContentWithHistoryStream,
        templateId,
        history ?? [],
      );
}
