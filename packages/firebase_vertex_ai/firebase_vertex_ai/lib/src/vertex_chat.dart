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

// import 'dart:async';

// import 'packageapi.dart';
// import 'vertex_content.dart';
// import 'vertex_model.dart';
// import 'vertex_api.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';

// /// A back-and-forth chat with a generative model.
// ///
// /// Records messages sent and received in [history]. The history will always
// /// record the content from the first candidate in the
// /// [GenerateContentResponse], other candidates may be available on the returned
// /// response.
// final class VertexChatSession {
//   final Future<VertexGenerateContentResponse> Function(
//       Iterable<VertexContent> content,
//       {List<VertexSafetySetting>? safetySettings,
//       VertexGenerationConfig? generationConfig}) _generateContent;
//   final Stream<VertexGenerateContentResponse> Function(
//       Iterable<VertexContent> content,
//       {List<VertexSafetySetting>? safetySettings,
//       VertexGenerationConfig? generationConfig}) _generateContentStream;

//   final List<VertexContent> _history;
//   final List<VertexSafetySetting>? _safetySettings;
//   final VertexGenerationConfig? _generationConfig;
//   final ChatSession _chatSession;

//   /// Creates a new chat session with the provided model.

//   VertexChatSession._(this._generateContent, this._generateContentStream,
//       this._history, this._safetySettings, this._generationConfig)
//       : _chatSession = ChatSession._(_generateContent, _generateContentStream,
//             _history, _safetySettings, _generationConfig);

//   /// The content that has been successfully sent to, or received from, the
//   /// generative model.
//   ///
//   /// If there are outstanding requests from calls to [sendMessage] or
//   /// [sendMessageStream], these will not be reflected in the history.
//   /// Messages without a candidate in the response are not recorded in history,
//   /// including the message sent to the model.
//   Iterable<VertexContent> get history => _history.skip(0);

//   /// Sends [message] to the model as a continuation of the chat [history].
//   ///
//   /// Prepends the history to the request and uses the provided model to
//   /// generate new content.
//   ///
//   /// When there are no candidates in the response, the [message] and response
//   /// are ignored and will not be recorded in the [history].
//   ///
//   /// Waits for any ongoing or pending requests to [sendMessage] or
//   /// [sendMessageStream] to complete before generating new content.
//   /// Successful messages and responses for ongoing or pending requests will
//   /// be reflected in the history sent for this message.
//   Future<VertexGenerateContentResponse> sendMessage(
//       VertexContent message) async {
//     final lock = await _mutex.acquire();
//     try {
//       final response = await _generateContent(_history.followedBy([message]),
//           safetySettings: _safetySettings, generationConfig: _generationConfig);
//       if (response.candidates case [final candidate, ...]) {
//         _history.add(message);
//         // TODO: Append role?
//         _history.add(candidate.content);
//       }
//       return response;
//     } finally {
//       lock.release();
//     }
//   }

//   /// Continues the chat with a new [message].
//   ///
//   /// Sends [message] to the model as a continuation of the chat [history] and
//   /// reads the response in a stream.
//   /// Prepends the history to the request and uses the provided model to
//   /// generate new content.
//   ///
//   /// When there are no candidates in any response in the stream, the [message]
//   /// and responses are ignored and will not be recorded in the [history].
//   ///
//   /// Waits for any ongoing or pending requests to [sendMessage] or
//   /// [sendMessageStream] to complete before generating new content.
//   /// Successful messages and responses for ongoing or pending requests will
//   /// be reflected in the history sent for this message.
//   ///
//   /// Waits to read the entire streamed response before recording the message
//   /// and response and allowing pending messages to be sent.
//   Stream<VertexGenerateContentResponse> sendMessageStream(
//       VertexContent message) {
//     final controller = StreamController<GenerateContentResponse>(sync: true);
//     _mutex.acquire().then((lock) async {
//       try {
//         final responses = _generateContentStream(_history.followedBy([message]),
//             safetySettings: _safetySettings,
//             generationConfig: _generationConfig);
//         final content = <VertexContent>[];
//         await for (final response in responses) {
//           if (response.candidates case [final candidate, ...]) {
//             content.add(candidate.content);
//           }
//           controller.add(response);
//         }
//         if (content.isNotEmpty) {
//           _history.add(message);
//           _history.add(_aggregate(content));
//         }
//       } catch (e, s) {
//         controller.addError(e, s);
//       }
//       lock.release();
//       unawaited(controller.close());
//     });
//     return controller.stream;
//   }

//   /// Aggregates a list of [VertexContent] responses into a single [VertexContent].
//   ///
//   /// Includes all the [VertexContent.parts] of every element of [contents],
//   /// and concatenates adjacent [VertexTextPart]s into a single [VertexTextPart],
//   /// even across adjacent [VertexContent]s.
//   VertexContent _aggregate(List<VertexContent> contents) {
//     assert(contents.isNotEmpty);
//     final role = contents.first.role ?? 'model';
//     final textBuffer = StringBuffer();
//     // If non-null, only a single text part has been seen.
//     VertexTextPart? previousText;
//     final parts = <VertexPart>[];
//     void addBufferedText() {
//       if (textBuffer.isEmpty) return;
//       // TODO: When updating min SDK remove workaround.
//       // if (previousText case final singleText?) {
//       final singleText = previousText;
//       if (singleText != null) {
//         parts.add(singleText);
//         previousText = null;
//       } else {
//         parts.add(VertexTextPart(textBuffer.toString()));
//       }
//       textBuffer.clear();
//     }

//     for (final content in contents) {
//       for (final part in content.parts) {
//         switch (part) {
//           case VertexTextPart(:final text):
//             if (text.isNotEmpty) {
//               previousText = textBuffer.isEmpty ? part : null;
//               textBuffer.write(text);
//             }
//           case VertexDataPart():
//             addBufferedText();
//             parts.add(part);
//         }
//       }
//     }
//     addBufferedText();
//     return VertexContent(role, parts);
//   }
// }

// extension VertexStartChatExtension on VertexGenerativeModel {
//   /// Starts a [VertexChatSession] that will use this model to respond to messages.
//   ///
//   /// ```dart
//   /// final chat = model.startChat();
//   /// final response = await chat.sendMessage(Content.text('Hello there.'));
//   /// print(response.text);
//   /// ```
//   VertexChatSession startChat(
//           {List<VertexContent>? history,
//           List<VertexSafetySetting>? safetySettings,
//           VertexGenerationConfig? generationConfig}) =>
//       VertexChatSession._(generateContent, generateContentStream, history ?? [],
//           safetySettings, generationConfig);
// }
