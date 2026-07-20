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

import '../schema.dart';
import '../tool.dart';

/// A collection of template tools.
final class TemplateTool {
  // ignore: public_member_api_docs
  TemplateTool._(this._functionDeclarations);

  /// Returns a [TemplateTool] instance with list of [TemplateFunctionDeclaration].
  static TemplateTool functionDeclarations(
      List<TemplateFunctionDeclaration> functionDeclarations) {
    return TemplateTool._(functionDeclarations);
  }

  /// Returns a list of all [TemplateAutoFunctionDeclaration] objects
  /// found within the [_functionDeclarations] list.
  List<TemplateAutoFunctionDeclaration> get templateAutoFunctionDeclarations {
    return _functionDeclarations
            ?.whereType<TemplateAutoFunctionDeclaration>()
            .toList() ??
        [];
  }

  final List<TemplateFunctionDeclaration>? _functionDeclarations;

  /// Convert to json object.
  Map<String, Object> toJson() => {
        if (_functionDeclarations case final functionDeclarations?
            when functionDeclarations.isNotEmpty)
          'templateFunctions': functionDeclarations
              .map((f) => f.hasSchema ? f.toJson() : null)
              .where((f) => f != null)
              .toList(),
      };
}

/// A function declaration for a template tool.
class TemplateFunctionDeclaration {
  // ignore: public_member_api_docs
  TemplateFunctionDeclaration(this.name,
      {Map<String, JSONSchema>? parameters,
      List<String> optionalParameters = const []})
      : _schemaObject = parameters != null
            ? JSONSchema.object(
                properties: parameters, optionalProperties: optionalParameters)
            : null;

  /// The name of the function.
  ///
  /// Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum
  /// length of 63.
  final String name;

  final Schema? _schemaObject;

  /// Whether the function declaration has a schema override.
  bool get hasSchema => _schemaObject != null;

  /// Convert to json object.
  Map<String, Object?> toJson() => {
        'name': name,
        if (_schemaObject case final schemaObject?)
          'inputSchema': schemaObject.toJson(),
      };
}

/// A function declaration for a template tool that can be called by the model.
final class TemplateAutoFunctionDeclaration
    extends TemplateFunctionDeclaration {
  // ignore: public_member_api_docs
  TemplateAutoFunctionDeclaration(
      {required String name,
      required this.callable,
      Map<String, JSONSchema>? parameters,
      List<String> optionalParameters = const []})
      : super(name,
            parameters: parameters, optionalParameters: optionalParameters);

  /// The callable function that this declaration represents.
  final FutureOr<Map<String, Object?>> Function(Map<String, Object?> args)
      callable;
}

/// Config for template tools to use with server prompts.
final class TemplateToolConfig {
  // ignore: public_member_api_docs
  TemplateToolConfig({RetrievalConfig? retrievalConfig})
      : _retrievalConfig = retrievalConfig;

  final RetrievalConfig? _retrievalConfig;

  /// Convert to json object.
  Map<String, Object?> toJson() => {
        if (_retrievalConfig case final retrievalConfig?)
          'retrievalConfig': retrievalConfig.toJson(),
      };
}
