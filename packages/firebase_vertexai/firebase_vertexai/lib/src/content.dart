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

import 'dart:convert';
import 'dart:typed_data';
import 'error.dart';

/// The base structured datatype containing multi-part content of a message.
final class Content {
  /// Constructor
  Content(this.role, this.parts);

  /// The producer of the content.
  ///
  /// Must be either 'user' or 'model'. Useful to set for multi-turn
  /// conversations, otherwise can be left blank or unset.
  final String? role;

  /// Ordered `Parts` that constitute a single message.
  ///
  /// Parts may have different MIME types.
  final List<Part> parts;

  /// Return a [Content] with [TextPart].
  static Content text(String text) => Content('user', [TextPart(text)]);

  /// Return a [Content] with [InlineDataPart].
  static Content inlineData(String mimeType, Uint8List bytes) =>
      Content('user', [InlineDataPart(mimeType, bytes)]);

  /// Return a [Content] with multiple [Part]s.
  static Content multi(Iterable<Part> parts) => Content('user', [...parts]);

  /// Return a [Content] with multiple [Part]s from the model.
  static Content model(Iterable<Part> parts) => Content('model', [...parts]);

  /// Return a [Content] with [FunctionResponse].
  static Content functionResponse(String name, Map<String, Object?> response) =>
      Content('function', [FunctionResponse(name, response)]);

  /// Return a [Content] with multiple [FunctionResponse].
  static Content functionResponses(Iterable<FunctionResponse> responses) =>
      Content('function', responses.toList());

  /// Return a [Content] with [TextPart] of system instruction.
  static Content system(String instructions) =>
      Content('system', [TextPart(instructions)]);

  /// Convert the [Content] to json format.
  Map<String, Object?> toJson() => {
        if (role case final role?) 'role': role,
        'parts': parts.map((p) => p.toJson()).toList()
      };
}

/// Parse the [Content] from json object.
Content parseContent(Object jsonObject) {
  return switch (jsonObject) {
    {'parts': final List<Object?> parts} => Content(
        switch (jsonObject) {
          {'role': final String role} => role,
          _ => null,
        },
        parts.map(_parsePart).toList()),
    _ => throw unhandledFormat('Content', jsonObject),
  };
}

Part _parsePart(Object? jsonObject) {
  return switch (jsonObject) {
    {'text': final String text} => TextPart(text),
    {
      'functionCall': {
        'name': final String name,
        'args': final Map<String, Object?> args
      }
    } =>
      FunctionCall(name, args),
    {
      'file_data': {
        'file_uri': final String fileUri,
        'mime_type': final String mimeType
      }
    } =>
      FileData(mimeType, fileUri),
    {
      'functionResponse': {'name': String _, 'response': Map<String, Object?> _}
    } =>
      throw UnimplementedError('FunctionResponse part not yet supported'),
    {'inlineData': {'mimeType': String mimeType, 'data': String bytes}} =>
      InlineDataPart(mimeType, base64Decode(bytes)),
    _ => throw unhandledFormat('Part', jsonObject),
  };
}

/// A datatype containing media that is part of a multi-part [Content] message.
sealed class Part {
  /// Convert the [Part] content to json format.
  Object toJson();
}

/// A [Part] with the text content.
final class TextPart implements Part {
  /// Constructor
  TextPart(this.text);

  /// The text content of the [Part]
  final String text;
  @override
  Object toJson() => {'text': text};
}

/// A [Part] with the byte content of a file.
final class InlineDataPart implements Part {
  /// Constructor
  InlineDataPart(this.mimeType, this.bytes);

  /// File type of the [InlineDataPart].
  /// https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/send-multimodal-prompts#media_requirements
  final String mimeType;

  /// Data contents in bytes.
  final Uint8List bytes;
  @override
  Object toJson() => {
        'inlineData': {'data': base64Encode(bytes), 'mimeType': mimeType}
      };
}

/// A predicted `FunctionCall` returned from the model that contains
/// a string representing the `FunctionDeclaration.name` with the
/// arguments and their values.
final class FunctionCall implements Part {
  /// Constructor
  FunctionCall(this.name, this.args);

  /// The name of the function to call.
  final String name;

  /// The function parameters and values.
  final Map<String, Object?> args;

  @override
  // TODO: Do we need the wrapper object?
  Object toJson() => {
        'functionCall': {'name': name, 'args': args}
      };
}

/// The response class for [FunctionCall]
final class FunctionResponse implements Part {
  /// Constructor
  FunctionResponse(this.name, this.response);

  /// The name of the function that was called.
  final String name;

  /// The function response.
  ///
  /// The values must be JSON compatible types; `String`, `num`, `bool`, `List`
  /// of JSON compatible types, or `Map` from String to JSON compatible types.
  final Map<String, Object?> response;

  @override
  Object toJson() => {
        'functionResponse': {'name': name, 'response': response}
      };
}

/// A [Part] with Firebase Storage uri as prompt content
final class FileData implements Part {
  /// Constructor
  FileData(this.mimeType, this.fileUri);

  /// File type of the [FileData].
  /// https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/send-multimodal-prompts#media_requirements
  final String mimeType;

  /// The gs link for Firebase Storage reference
  final String fileUri;

  @override
  Object toJson() => {
        'file_data': {'file_uri': fileUri, 'mime_type': mimeType}
      };
}
