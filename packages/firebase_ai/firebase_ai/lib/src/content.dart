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
import 'dart:developer';
import 'dart:typed_data';

import 'api.dart';
import 'error.dart';

/// The base structured datatype containing multi-part content of a message.
final class Content {
  // ignore: public_member_api_docs
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
  static Content functionResponse(String name, Map<String, Object?> response,
          {String? id}) =>
      Content('function', [FunctionResponse(name, response, id: id)]);

  /// Return a [Content] with multiple [FunctionResponse].
  static Content functionResponses(Iterable<FunctionResponse> responses) =>
      Content('function', responses.toList());

  /// Return a [Content] with [TextPart] of system instruction.
  static Content system(String instructions) =>
      Content('system', [TextPart(instructions)]);

  /// Convert the [Content] to json format.
  Map<String, Object?> toJson() => {
        if (role case final role?) 'role': role,
        'parts': parts.map((p) {
          return p.toJson();
        }).toList(),
      };
}

/// Parse the [Content] from json object.
Content parseContent(Object jsonObject) {
  return switch (jsonObject) {
    {'role': final String role, 'parts': final List<Object?> parts} =>
      Content(role, parts.map(parsePart).toList()),
    {'role': final String role} =>
      Content(role, <Part>[]), // Handle case with only role
    {'parts': final List<Object?> parts} => Content(
        null, parts.map(parsePart).toList()), // Handle case with only parts
    _ => throw unhandledFormat('Content', jsonObject),
  };
}

/// Parse the [Part] from json object.
Part parsePart(Object? jsonObject) {
  if (jsonObject is! Map<String, Object?>) {
    log('Unhandled part format: $jsonObject');
    return UnknownPart(<String, Object?>{
      'unhandled': jsonObject,
    });
  }

  if (jsonObject.containsKey('functionCall')) {
    final functionCall = jsonObject['functionCall'];
    if (functionCall is Map &&
        functionCall.containsKey('name') &&
        functionCall.containsKey('args')) {
      return FunctionCall(
        functionCall['name'] as String,
        functionCall['args'] as Map<String, Object?>,
        id: functionCall['id'] as String?,
      );
    } else {
      throw unhandledFormat('functionCall', functionCall);
    }
  }
  if (jsonObject.containsKey('executableCode')) {
    final executableCode = jsonObject['executableCode'];
    if (executableCode is Map &&
        executableCode.containsKey('language') &&
        executableCode.containsKey('code')) {
      return ExecutableCodePart(
        executableCode['language'] as String,
        executableCode['code'] as String,
      );
    } else {
      throw unhandledFormat('executableCode', executableCode);
    }
  }
  if (jsonObject.containsKey('codeExecutionResult')) {
    final codeExecutionResult = jsonObject['codeExecutionResult'];
    if (codeExecutionResult is Map &&
        codeExecutionResult.containsKey('outcome') &&
        codeExecutionResult.containsKey('output')) {
      return CodeExecutionResultPart(
        Outcome.parseValue(codeExecutionResult['outcome'] as String),
        codeExecutionResult['output'] as String,
      );
    } else {
      throw unhandledFormat('codeExecutionResult', codeExecutionResult);
    }
  }
  return switch (jsonObject) {
    {'text': final String text} => TextPart(text),
    {
      'file_data': {
        'file_uri': final String fileUri,
        'mime_type': final String mimeType
      }
    } =>
      FileData(mimeType, fileUri),
    {'inlineData': {'mimeType': String mimeType, 'data': String bytes}} =>
      InlineDataPart(mimeType, base64Decode(bytes)),
    _ => () {
        log('unhandled part format: $jsonObject');
        return UnknownPart(jsonObject);
      }(),
  };
}

/// A datatype containing media that is part of a multi-part [Content] message.
sealed class Part {
  /// Convert the [Part] content to json format.
  Object toJson();
}

/// A [Part] that contains unparsable data.
final class UnknownPart implements Part {
  // ignore: public_member_api_docs
  UnknownPart(this.data);

  /// The unparsed data.
  final Map<String, Object?> data;

  @override
  Object toJson() => data;
}

/// A [Part] with the text content.
final class TextPart implements Part {
  // ignore: public_member_api_docs
  TextPart(this.text);

  /// The text content of the [Part]
  final String text;
  @override
  Object toJson() => {'text': text};
}

/// A [Part] with the byte content of a file.
final class InlineDataPart implements Part {
  // ignore: public_member_api_docs
  InlineDataPart(this.mimeType, this.bytes, {this.willContinue});

  /// File type of the [InlineDataPart].
  /// https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/send-multimodal-prompts#media_requirements
  final String mimeType;

  /// Data contents in bytes.
  final Uint8List bytes;

  /// Whether there's more inline data coming for streaming.
  final bool? willContinue;
  @override
  Object toJson() => {
        'inlineData': {
          'data': base64Encode(bytes),
          'mimeType': mimeType,
          if (willContinue != null) 'willContinue': willContinue,
        }
      };

  /// The representation of the data in media streaming chunk.
  Object toMediaChunkJson() => {
        'mimeType': mimeType,
        'data': base64Encode(bytes),
        if (willContinue != null) 'willContinue': willContinue,
      };
}

/// A predicted `FunctionCall` returned from the model that contains
/// a string representing the `FunctionDeclaration.name` with the
/// arguments and their values.
final class FunctionCall implements Part {
  // ignore: public_member_api_docs
  FunctionCall(this.name, this.args, {this.id});

  /// The name of the function to call.
  final String name;

  /// The function parameters and values.
  final Map<String, Object?> args;

  /// The unique id of the function call.
  ///
  /// If populated, the client to execute the [FunctionCall]
  /// and return the response with the matching [id].
  final String? id;

  @override
  Object toJson() => {
        'functionCall': {
          'name': name,
          'args': args,
          if (id != null) 'id': id,
        }
      };
}

/// The response class for [FunctionCall]
final class FunctionResponse implements Part {
  // ignore: public_member_api_docs
  FunctionResponse(this.name, this.response, {this.id});

  /// The name of the function that was called.
  final String name;

  /// The function response.
  ///
  /// The values must be JSON compatible types; `String`, `num`, `bool`, `List`
  /// of JSON compatible types, or `Map` from String to JSON compatible types.
  final Map<String, Object?> response;

  /// The id of the function call this response is for.
  ///
  /// Populated by the client to match the corresponding [FunctionCall.id].
  final String? id;

  @override
  Object toJson() => {
        'functionResponse': {
          'name': name,
          'response': response,
          if (id != null) 'id': id,
        }
      };
}

/// A [Part] with Firebase Storage uri as prompt content
final class FileData implements Part {
  // ignore: public_member_api_docs
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

/// A `Part` that represents the code that is executed by the model.
final class ExecutableCodePart implements Part {
  /// The programming language of the code.
  final String language;

  /// The source code to be executed.
  final String code;

  // ignore: public_member_api_docs
  ExecutableCodePart(this.language, this.code);

  @override
  Object toJson() => {
        'executableCode': {'language': language, 'code': code}
      };
}

/// A `Part` that represents the code execution result from the model.
final class CodeExecutionResultPart implements Part {
  /// The result of the execution.
  final Outcome outcome;

  /// The stdout from the code execution, or an error message if it failed.
  final String output;

  // ignore: public_member_api_docs
  CodeExecutionResultPart(this.outcome, this.output);

  @override
  Object toJson() => {
        'codeExecutionResult': {
          'outcome': outcome.toJson(),
          'output': output
        }
      };
}
