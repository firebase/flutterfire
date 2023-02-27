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

/// The definition of an input or output data types.
///
/// These types can be objects, but also primitives and arrays.
/// Represents a select subset of an
/// [OpenAPI 3.0 schema object](https://spec.openapis.org/oas/v3.0.3#schema).
final class Schema {
  // ignore: public_member_api_docs
  Schema(
    this.type, {
    this.format,
    this.description,
    this.nullable,
    this.enumValues,
    this.items,
    this.properties,
    this.optionalProperties,
  });

  /// Construct a schema for an object with one or more properties.
  Schema.object({
    required Map<String, Schema> properties,
    List<String>? optionalProperties,
    String? description,
    bool? nullable,
  }) : this(
          SchemaType.object,
          properties: properties,
          optionalProperties: optionalProperties,
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
    String? format,
  }) : this(SchemaType.string,
            description: description, nullable: nullable, format: format);

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

  /// Whether the value may be null.
  bool? nullable;

  /// Possible values if this is a [SchemaType.string] with an enum format.
  List<String>? enumValues;

  /// Schema for the elements if this is a [SchemaType.array].
  Schema? items;

  /// Properties of this type if this is a [SchemaType.object].
  Map<String, Schema>? properties;

  /// Optional Properties if this is a [SchemaType.object].
  ///
  /// The keys from [properties] for properties that are optional if this is a
  /// [SchemaType.object]. Any properties that's not listed in optional will be
  /// treated as required properties
  List<String>? optionalProperties;

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
        // Calculate required properties based on optionalProperties
        if (properties != null)
          'required': optionalProperties != null
              ? properties!.keys
                  .where((key) => !optionalProperties!.contains(key))
                  .toList()
              : properties!.keys.toList(),
      };
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
}
