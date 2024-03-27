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
import 'dart:ffi';
import 'dart:typed_data';
import 'package:firebase_vertex_ai/firebase_vertex_ai.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as googleAI;

/// The base structured datatype containing multi-part content of a message.
final class Content {
  /// The producer of the content.
  ///
  /// Must be either 'user' or 'model'. Useful to set for multi-turn
  /// conversations, otherwise can be left blank or unset.
  final String? role;

  /// Ordered `Parts` that constitute a single message.
  ///
  /// Parts may have different MIME types.
  final List<Part> parts;

  Content(this.role, this.parts);

  factory Content.fromGoogleAIContent(googleAI.Content content) => Content(
      content.role,
      content.parts.map((p) => Part.fromGoogleAIPart(p)).toList());

  static Content text(String text) => Content('user', [TextPart(text)]);
  static Content data(String mimeType, Uint8List bytes) =>
      Content('user', [DataPart(mimeType, bytes)]);
  static Content multi(Iterable<Part> parts) => Content('user', [...parts]);
  static Content model(Iterable<Part> parts) => Content('model', [...parts]);

  Map<String, Object?> toJson() => {
        if (role case final role?) 'role': role,
        'parts': parts.map((p) => p.toJson()).toList()
      };
  googleAI.Content toGoogleAIContent() =>
      googleAI.Content(role, parts.map((p) => p.toPart()).toList());
}

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
  Object toJson();
  googleAI.Part toPart();
  factory Part.fromGoogleAIPart(googleAI.Part part) => switch (part) {
        googleAI.TextPart textPart => TextPart(textPart.text),
        googleAI.DataPart dataPart =>
          DataPart(dataPart.mimeType, dataPart.bytes),
      };
}

final class TextPart implements Part {
  final String text;
  TextPart(this.text);
  @override
  Object toJson() => {'text': text};
  @override
  googleAI.Part toPart() => googleAI.TextPart(text);
}

final class DataPart implements Part {
  final String mimeType;
  final Uint8List bytes;
  DataPart(this.mimeType, this.bytes);
  @override
  Object toJson() => {
        'inlineData': {'data': base64Encode(bytes), 'mimeType': mimeType}
      };
  @override
  googleAI.Part toPart() => googleAI.DataPart(mimeType, bytes);
}
