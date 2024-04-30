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

part of firebase_vertexai;

/// The base structured datatype containing multi-part content of a message.
final class Content {
  /// Constructor
  Content(this.role, this.parts);
  factory Content._fromGoogleAIContent(google_ai.Content content) =>
      Content(content.role, content.parts.map(Part._fromGoogleAIPart).toList());

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

  /// Return a [Content] with [DataPart].
  static Content data(String mimeType, Uint8List bytes) =>
      Content('user', [DataPart(mimeType, bytes)]);

  /// Return a [Content] with multiple [Part]s.
  static Content multi(Iterable<Part> parts) => Content('user', [...parts]);

  /// Return a [Content] with multiple [Part]s from the model.
  static Content model(Iterable<Part> parts) => Content('model', [...parts]);

  static Content functionResponse(
          String name, Map<String, Object?>? response) =>
      Content('function', [FunctionResponse(name, response)]);
  static Content system(String instructions) =>
      Content('system', [TextPart(instructions)]);

  /// Convert the [Content] to json format.
  Map<String, Object?> toJson() => {
        if (role case final role?) 'role': role,
        'parts': parts.map((p) => p.toJson()).toList()
      };
  google_ai.Content _toGoogleAIContent() =>
      google_ai.Content(role, parts.map((p) => p.toPart()).toList());
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
    _ => throw FormatException('Unhandled Content format', jsonObject),
  };
}

Part _parsePart(Object? jsonObject) {
  return switch (jsonObject) {
    {'text': final String text} => TextPart(text),
    {'inlineData': {'mimeType': String _, 'data': String _}} =>
      throw UnimplementedError('inlineData content part not yet supported'),
    _ => throw FormatException('Unhandled Part format', jsonObject),
  };
}

/// A datatype containing media that is part of a multi-part [Content] message.
sealed class Part {
  factory Part._fromGoogleAIPart(google_ai.Part part) => switch (part) {
        google_ai.TextPart textPart => TextPart(textPart.text),
        google_ai.DataPart dataPart =>
          DataPart(dataPart.mimeType, dataPart.bytes),
        google_ai.FilePart() => throw UnimplementedError(),
        google_ai.FunctionCall functionCall =>
          FunctionCall(functionCall.name, functionCall.args),
        google_ai.FunctionResponse functionResponse =>
          FunctionResponse(functionResponse.name, functionResponse.response),
      };

  /// Convert the [Part] content to json format.
  Object toJson();

  /// Convert the [Part] content to [google_ai.Part].
  google_ai.Part toPart();
}

/// A [Part] with the text content.
final class TextPart implements Part {
  /// Constructor
  TextPart(this.text);

  /// The text content of the [Part]
  final String text;
  @override
  Object toJson() => {'text': text};
  @override
  google_ai.Part toPart() => google_ai.TextPart(text);
}

/// A [Part] with the byte content of a file.
final class DataPart implements Part {
  /// Constructor
  DataPart(this.mimeType, this.bytes);

  /// File type of the [DataPart]. https://cloud.google.com/document-ai/docs/file-types
  final String mimeType;

  /// Data contents in bytes.
  final Uint8List bytes;
  @override
  Object toJson() => {
        'inlineData': {'data': base64Encode(bytes), 'mimeType': mimeType}
      };
  @override
  google_ai.Part toPart() => google_ai.DataPart(mimeType, bytes);
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
  @override
  google_ai.Part toPart() => google_ai.FunctionCall(name, args);
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
  /// of JSON compatibles types, or `Map` from String to JSON compatible types.
  final Map<String, Object?>? response;

  @override
  Object toJson() => {
        'functionResponse': {'name': name, 'response': response}
      };
  @override
  google_ai.Part toPart() => google_ai.FunctionResponse(name, response);
}