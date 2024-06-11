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

import 'package:google_generative_ai/google_generative_ai.dart' as google_ai;

/// Tool details that the model may use to generate a response.
///
/// A `Tool` is a piece of code that enables the system to interact with
/// external systems to perform an action, or set of actions, outside of
/// knowledge and scope of the model.
final class Tool {
  /// Constructor
  Tool({this.functionDeclarations});

  /// A list of `FunctionDeclarations` available to the model that can be used
  /// for function calling.
  ///
  /// The model or system does not execute the function. Instead the defined
  /// function may be returned as a [FunctionCall] with arguments to the client
  /// side for execution. The next conversation turn may contain a
  /// [FunctionResponse]
  /// with the role "function" generation context for the next model turn.
  final List<FunctionDeclaration>? functionDeclarations;

  /// Convert to json object.
  Map<String, Object> toJson() => {
        if (functionDeclarations case final functionDeclarations?)
          'functionDeclarations':
              functionDeclarations.map((f) => f.toJson()).toList(),
      };
}

/// Conversion utilities for [Tool].
extension ToolConversion on Tool {
  /// Returns this tool as a [google_ai.Tool].
  google_ai.Tool toGoogleAI() => google_ai.Tool(
        functionDeclarations: functionDeclarations
            ?.map((f) => f._toGoogleAIToolFunctionDeclaration())
            .toList(),
      );
}

/// Structured representation of a function declaration as defined by the
/// [OpenAPI 3.03 specification](https://spec.openapis.org/oas/v3.0.3).
///
/// Included in this declaration are the function name and parameters. This
/// FunctionDeclaration is a representation of a block of code that can be used
/// as a `Tool` by the model and executed by the client.
final class FunctionDeclaration {
  /// Constructor
  FunctionDeclaration(this.name, this.description, this.parameters);

  /// The name of the function.
  ///
  /// Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum
  /// length of 63.
  final String name;

  /// A brief description of the function.
  final String description;

  /// The definition of an input or output data types.
  final Schema? parameters;

  /// Convert to json object.
  Map<String, Object?> toJson() => {
        'name': name,
        'description': description,
        if (parameters case final parameters?) 'parameters': parameters.toJson()
      };

  google_ai.FunctionDeclaration _toGoogleAIToolFunctionDeclaration() =>
      google_ai.FunctionDeclaration(
        name,
        description,
        parameters?._toGoogleAIToolSchema(),
      );
}

/// Config for tools to use with model.
final class ToolConfig {
  /// Constructor
  ToolConfig({this.functionCallingConfig});

  /// Config for function calling.
  final FunctionCallingConfig? functionCallingConfig;

  /// Convert to json object.
  Map<String, Object?> toJson() => {
        if (functionCallingConfig case final config?)
          'functionCallingConfig': config.toJson(),
      };
}

/// Conversion utilities for [ToolConfig].
extension ToolConfigConversion on ToolConfig {
  /// Returns this tool config as a [google_ai.ToolConfig].
  google_ai.ToolConfig toGoogleAI() => google_ai.ToolConfig(
        functionCallingConfig:
            functionCallingConfig?._toGoogleAIFunctionCallingConfig(),
      );
}

/// Configuration specifying how the model should use the functions provided as
/// tools.
final class FunctionCallingConfig {
  /// Constructor
  FunctionCallingConfig({this.mode, this.allowedFunctionNames});

  /// The mode in which function calling should execute.
  ///
  /// If null, the default behavior will match [FunctionCallingMode.auto].
  final FunctionCallingMode? mode;

  /// A set of function names that, when provided, limits the functions the
  /// model will call.
  ///
  /// This should only be set when the Mode is [FunctionCallingMode.any].
  /// Function names should match [FunctionDeclaration.name]. With mode set to
  /// `any`, model will predict a function call from the set of function names
  /// provided.
  final Set<String>? allowedFunctionNames;

  /// Convert to json object.
  Object toJson() => {
        if (mode case final mode?) 'mode': mode.toJson(),
        if (allowedFunctionNames case final allowedFunctionNames?)
          'allowedFunctionNames': allowedFunctionNames.toList(),
      };

  google_ai.FunctionCallingConfig _toGoogleAIFunctionCallingConfig() =>
      google_ai.FunctionCallingConfig(
        mode: mode?._toGoogleAIFunctionCallingMode(),
        allowedFunctionNames: allowedFunctionNames?.toSet(),
      );
}

/// The mode in which the model should use the functions provided as tools.
enum FunctionCallingMode {
  /// The mode with default model behavior.
  ///
  /// Model decides to predict either a function call or a natural language
  /// response.
  auto,

  /// A mode where the Model is constrained to always predicting a function
  /// call only.
  any,

  /// A mode where the model will not predict any function call.
  ///
  /// Model behavior is same as when not passing any function declarations.
  none;

  /// Convert to json object.
  String toJson() => switch (this) {
        auto => 'AUTO',
        any => 'ANY',
        none => 'NONE',
      };

  google_ai.FunctionCallingMode _toGoogleAIFunctionCallingMode() =>
      switch (this) {
        auto => google_ai.FunctionCallingMode.auto,
        any => google_ai.FunctionCallingMode.any,
        none => google_ai.FunctionCallingMode.none,
      };
}

/// The definition of an input or output data types.
///
/// These types can be objects, but also primitives and arrays.
/// Represents a select subset of an
/// [OpenAPI 3.0 schema object](https://spec.openapis.org/oas/v3.0.3#schema).
final class Schema {
  /// Constructor
  Schema(
    this.type, {
    this.format,
    this.description,
    this.nullable,
    this.enumValues,
    this.items,
    this.properties,
    this.requiredProperties,
  });

  /// Construct a schema for an object with one or more properties.
  Schema.object({
    required Map<String, Schema> properties,
    List<String>? requiredProperties,
    String? description,
    bool? nullable,
  }) : this(
          SchemaType.object,
          properties: properties,
          requiredProperties: requiredProperties,
          description: description,
          nullable: nullable,
        );

  /// Construct a schema for an array of values with a specified type.
  Schema.array({
    required Schema items,
    String? description,
    bool? nullable,
  }) : this(
          SchemaType.array,
          description: description,
          nullable: nullable,
          items: items,
        );

  /// Construct a schema for bool value.
  Schema.boolean({
    String? description,
    bool? nullable,
  }) : this(
          SchemaType.boolean,
          description: description,
          nullable: nullable,
        );

  /// Construct a schema for an integer number.
  ///
  /// The [format] may be "int32" or "int64".
  Schema.integer({
    String? description,
    bool? nullable,
    String? format,
  }) : this(
          SchemaType.integer,
          description: description,
          nullable: nullable,
          format: format,
        );

  /// Construct a schema for a non-integer number.
  ///
  /// The [format] may be "float" or "double".
  Schema.number({
    String? description,
    bool? nullable,
    String? format,
  }) : this(
          SchemaType.number,
          description: description,
          nullable: nullable,
          format: format,
        );

  /// Construct a schema for String value with enumerated possible values.
  Schema.enumString({
    required List<String> enumValues,
    String? description,
    bool? nullable,
  }) : this(
          SchemaType.string,
          enumValues: enumValues,
          description: description,
          nullable: nullable,
          format: 'enum',
        );

  /// Construct a schema for a String value.
  Schema.string({
    String? description,
    bool? nullable,
  }) : this(
          SchemaType.string,
          description: description,
          nullable: nullable,
        );

  /// The type of this value.
  SchemaType type;

  /// The format of the data.
  ///
  /// This is used only for primitive datatypes.
  ///
  /// Supported formats:
  ///  for [SchemaType.number] type: float, double
  ///  for [SchemaType.integer] type: int32, int64
  ///  for [SchemaType.string] type: enum. See [enumValues]
  String? format;

  /// A brief description of the parameter.
  ///
  /// This could contain examples of use.
  /// Parameter description may be formatted as Markdown.
  String? description;

  /// Whether the value mey be null.
  bool? nullable;

  /// Possible values if this is a [SchemaType.string] with an enum format.
  List<String>? enumValues;

  /// Schema for the elements if this is a [SchemaType.array].
  Schema? items;

  /// Properties of this type if this is a [SchemaType.object].
  Map<String, Schema>? properties;

  /// The keys from [properties] for properties that are required if this is a
  /// [SchemaType.object].
  List<String>? requiredProperties;

  /// Convert to json object.
  Map<String, Object> toJson() => {
        'type': type.toJson(),
        if (format case final format?) 'format': format,
        if (description case final description?) 'description': description,
        if (nullable case final nullable?) 'nullable': nullable,
        if (enumValues case final enumValues?) 'enum': enumValues,
        if (items case final items?) 'items': items.toJson(),
        if (properties case final properties?)
          'properties': {
            for (final MapEntry(:key, :value) in properties.entries)
              key: value.toJson()
          },
        if (requiredProperties case final requiredProperties?)
          'required': requiredProperties
      };

  google_ai.Schema _toGoogleAIToolSchema() => google_ai.Schema(
      type._toGoogleAIToolSchemaType(),
      format: format,
      description: description,
      nullable: nullable,
      enumValues: enumValues,
      items: items?._toGoogleAIToolSchema(),
      properties: properties
          ?.map((key, value) => MapEntry(key, value._toGoogleAIToolSchema())),
      requiredProperties: requiredProperties);
}

/// The value type of a [Schema].
enum SchemaType {
  /// string type.
  string,

  /// number type
  number,

  /// integer type
  integer,

  /// boolean type
  boolean,

  /// array type
  array,

  /// object type
  object;

  /// Convert to json object.
  String toJson() => switch (this) {
        string => 'STRING',
        number => 'NUMBER',
        integer => 'INTEGER',
        boolean => 'BOOLEAN',
        array => 'ARRAY',
        object => 'OBJECT',
      };

  google_ai.SchemaType _toGoogleAIToolSchemaType() => switch (this) {
        string => google_ai.SchemaType.string,
        number => google_ai.SchemaType.number,
        integer => google_ai.SchemaType.integer,
        boolean => google_ai.SchemaType.boolean,
        array => google_ai.SchemaType.array,
        object => google_ai.SchemaType.object,
      };
}
