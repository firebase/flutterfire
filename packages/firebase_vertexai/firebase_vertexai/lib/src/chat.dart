// // Copyright 2024 Google LLC
// //
// // Licensed under the Apache License, Version 2.0 (the "License");
// // you may not use this file except in compliance with the License.
// // You may obtain a copy of the License at
// //
// //     http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing, software
// // distributed under the License is distributed on an "AS IS" BASIS,
// // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// // See the License for the specific language governing permissions and
// // limitations under the License.

import 'dart:async';

import 'api.dart';
import 'base_model.dart';
import 'content.dart';
import 'utils/mutex.dart';

/// A back-and-forth chat with a generative model.
///
/// Records messages sent and received in [history]. The history will always
/// record the content from the first candidate in the
/// [GenerateContentResponse], other candidates may be available on the returned
/// response. The history is maintained and updated by the `google_generative_ai`
/// package and reflects the most current state of the chat session.
final class ChatSession {
  ChatSession._(this._generateContent, this._generateContentStream,
      this._history, this._safetySettings, this._generationConfig);
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
      final response = await _generateContent(_history.followedBy([message]),
          safetySettings: _safetySettings, generationConfig: _generationConfig);
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
    final controller = StreamController<GenerateContentResponse>(sync: true);
    _mutex.acquire().then((lock) async {
      try {
        final responses = _generateContentStream(_history.followedBy([message]),
            safetySettings: _safetySettings,
            generationConfig: _generationConfig);
        final content = <Content>[];
        await for (final response in responses) {
          if (response.candidates case [final candidate, ...]) {
            content.add(candidate.content);
          }
          controller.add(response);
        }
        if (content.isNotEmpty) {
          _history.add(message);
          _history.add(_aggregate(content));
        }
      } catch (e, s) {
        controller.addError(e, s);
      }
      lock.release();
      unawaited(controller.close());
    });
    return controller.stream;
  }

  /// Aggregates a list of [Content] responses into a single [Content].
  ///
  /// Includes all the [Content.parts] of every element of [contents],
  /// and concatenates adjacent [TextPart]s into a single [TextPart],
  /// even across adjacent [Content]s.
  Content _aggregate(List<Content> contents) {
    assert(contents.isNotEmpty);
    final role = contents.first.role ?? 'model';
    final textBuffer = StringBuffer();
    // If non-null, only a single text part has been seen.
    TextPart? previousText;
    final parts = <Part>[];
    void addBufferedText() {
      if (textBuffer.isEmpty) return;
      if (previousText case final singleText?) {
        parts.add(singleText);
        previousText = null;
      } else {
        parts.add(TextPart(textBuffer.toString()));
      }
      textBuffer.clear();
    }

    for (final content in contents) {
      for (final part in content.parts) {
        if (part case TextPart(:final text)) {
          if (text.isNotEmpty) {
            previousText = textBuffer.isEmpty ? part : null;
            textBuffer.write(text);
          }
        } else {
          addBufferedText();
          parts.add(part);
        }
      }
    }
    addBufferedText();
    return Content(role, parts);
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
          GenerationConfig? generationConfig}) =>
      ChatSession._(generateContent, generateContentStream, history ?? [],
          safetySettings, generationConfig);
}
