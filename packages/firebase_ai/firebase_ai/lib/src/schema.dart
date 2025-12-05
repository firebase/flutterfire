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
    this.title,
    this.nullable,
    this.enumValues,
    this.items,
    this.minItems,
    this.maxItems,
    this.minimum,
    this.maximum,
    this.properties,
    this.optionalProperties,
    this.propertyOrdering,
    this.anyOf,
  });

  /// Construct a schema for an object with one or more properties.
  Schema.object({
    required Map<String, Schema> properties,
    List<String>? optionalProperties,
    List<String>? propertyOrdering,
    String? description,
    String? title,
    bool? nullable,
  }) : this(
          SchemaType.object,
          properties: properties,
          optionalProperties: optionalProperties,
          propertyOrdering: propertyOrdering,
          description: description,
          title: title,
          nullable: nullable,
        );

  /// Construct a schema for an array of values with a specified type.
  Schema.array({
    required Schema items,
    String? description,
    String? title,
    bool? nullable,
    int? minItems,
    int? maxItems,
  }) : this(
          SchemaType.array,
          description: description,
          title: title,
          nullable: nullable,
          items: items,
          minItems: minItems,
          maxItems: maxItems,
        );

  /// Construct a schema for bool value.
  Schema.boolean({
    String? description,
    String? title,
    bool? nullable,
  }) : this(
          SchemaType.boolean,
          description: description,
          title: title,
          nullable: nullable,
        );

  /// Construct a schema for an integer number.
  ///
  /// The [format] may be "int32" or "int64".
  Schema.integer({
    String? description,
    String? title,
    bool? nullable,
    String? format,
    int? minimum,
    int? maximum,
  }) : this(
          SchemaType.integer,
          description: description,
          title: title,
          nullable: nullable,
          format: format,
          minimum: minimum?.toDouble(),
          maximum: maximum?.toDouble(),
        );

  /// Construct a schema for a non-integer number.
  ///
  /// The [format] may be "float" or "double".
  Schema.number({
    String? description,
    String? title,
    bool? nullable,
    String? format,
    double? minimum,
    double? maximum,
  }) : this(
          SchemaType.number,
          description: description,
          title: title,
          nullable: nullable,
          format: format,
          minimum: minimum,
          maximum: maximum,
        );

  /// Construct a schema for String value with enumerated possible values.
  Schema.enumString({
    required List<String> enumValues,
    String? description,
    String? title,
    bool? nullable,
  }) : this(
          SchemaType.string,
          enumValues: enumValues,
          description: description,
          title: title,
          nullable: nullable,
          format: 'enum',
        );

  /// Construct a schema for a String value.
  Schema.string({
    String? description,
    String? title,
    bool? nullable,
    String? format,
  }) : this(
          SchemaType.string,
          description: description,
          title: title,
          nullable: nullable,
          format: format,
        );

  /// Construct a schema representing a value that must conform to
  /// *any* (one or more) of the provided sub-schemas.
  ///
  /// This schema instructs the model to produce data that is valid against at
  /// least one of the schemas listed in the `schemas` array. This is useful
  /// when a field can accept multiple distinct types or structures.
  ///
  /// **Example:** A field that can hold either a simple user ID (integer) or a
  /// detailed user object.
  /// ```
  /// Schema.anyOf(anyOf: [
  ///   .Schema.integer(description: "User ID"),
  ///   .Schema.object(properties: [
  ///     "userId": Schema.integer(),
  ///     "userName": Schema.string()
  ///   ], description: "Detailed User Object")
  /// ])
  /// ```
  /// The generated data could be decoded based on which schema it matches.
  Schema.anyOf({
    required List<Schema> schemas,
  }) : this(
          SchemaType.anyOf, // The type will be ignored in toJson
          anyOf: schemas,
        );

  /// Parse a [Schema] from json object.
  factory Schema.fromJson(Map<String, Object?> json) {
    final anyOfJson = json['anyOf'] as List<Object?>?;
    final SchemaType type;
    if (anyOfJson != null) {
      type = SchemaType.anyOf;
    } else {
      // ignore: cast_nullable_to_non_nullable
      type = SchemaType.fromJson(json['type'] as String);
    }

    final propertiesJson = json['properties'] as Map<String, Object?>?;
    final Map<String, Schema>? properties;
    if (propertiesJson != null) {
      properties = {
        for (final entry in propertiesJson.entries)
          entry.key: Schema.fromJson(entry.value! as Map<String, Object?>),
      };
    } else {
      properties = null;
    }

    // Convert 'required' back to 'optionalProperties'
    final requiredJson = json['required'] as List<Object?>?;
    final List<String>? optionalProperties;
    if (properties != null && requiredJson != null) {
      final required = requiredJson.cast<String>().toSet();
      optionalProperties = properties.keys.where((key) => !required.contains(key)).toList();
    } else {
      optionalProperties = null;
    }

    final itemsJson = json['items'] as Map<String, Object?>?;
    final anyOf = anyOfJson?.map((e) => Schema.fromJson(e! as Map<String, Object?>)).toList();

    return Schema(
      type,
      format: json['format'] as String?,
      description: json['description'] as String?,
      title: json['title'] as String?,
      nullable: json['nullable'] as bool?,
      enumValues: (json['enum'] as List<Object?>?)?.cast<String>(),
      items: itemsJson != null ? Schema.fromJson(itemsJson) : null,
      minItems: json['minItems'] as int?,
      maxItems: json['maxItems'] as int?,
      minimum: (json['minimum'] as num?)?.toDouble(),
      maximum: (json['maximum'] as num?)?.toDouble(),
      properties: properties,
      optionalProperties: optionalProperties,
      propertyOrdering: (json['propertyOrdering'] as List<Object?>?)?.cast<String>(),
      anyOf: anyOf,
    );
  }

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

  /// A human-readable name/summary for the schema or a specific property.
  ///
  /// This helps document the schema's purpose but doesn't typically constrain
  /// the generated value. It can subtly guide the model by clarifying the
  /// intent of a field.
  String? title;

  /// Whether the value may be null.
  bool? nullable;

  /// Possible values if this is a [SchemaType.string] with an enum format.
  List<String>? enumValues;

  /// Schema for the elements if this is a [SchemaType.array].
  Schema? items;

  /// An integer specifying the minimum number of items [SchemaType.array] must contain.
  int? minItems;

  /// An integer specifying the maximum number of items [SchemaType.array] must contain.
  int? maxItems;

  /// The minimum value of a numeric type.
  double? minimum;

  /// The maximum value of a numeric type.
  double? maximum;

  /// Properties of this type if this is a [SchemaType.object].
  Map<String, Schema>? properties;

  /// Optional Properties if this is a [SchemaType.object].
  ///
  /// The keys from [properties] for properties that are optional if this is a
  /// [SchemaType.object]. Any properties that's not listed in optional will be
  /// treated as required properties
  List<String>? optionalProperties;

  /// Suggesting order of the properties.
  ///
  /// A specific hint provided to the Gemini model, suggesting the order in
  /// which the keys should appear in the generated JSON string.
  /// Important: Standard JSON objects are inherently unordered collections of
  /// key-value pairs. While the model will try to respect PropertyOrdering in
  /// its textual JSON output.
  List<String>? propertyOrdering;

  /// An array of [Schema] objects to validate generated content.
  ///
  /// The generated data must be valid against *any* (one or more)
  /// of the schemas listed in this array. This allows specifying multiple
  /// possible structures or types for a single field.
  ///
  /// For example, a value could be either a `String` or an `Int`:
  /// ```
  /// Schema.anyOf(schemas: [Schema.string(), Schema.integer()]);
  List<Schema>? anyOf;
  /// Convert to json object.
  Map<String, Object> toJson() => {
        if (type != SchemaType.anyOf)
          'type': type.toJson(), // Omit the field while type is anyOf
        if (format case final format?) 'format': format,
        if (description case final description?) 'description': description,
        if (title case final title?) 'title': title,
        if (nullable case final nullable?) 'nullable': nullable,
        if (enumValues case final enumValues?) 'enum': enumValues,
        if (items case final items?) 'items': items.toJson(),
        if (minItems case final minItems?) 'minItems': minItems,
        if (maxItems case final maxItems?) 'maxItems': maxItems,
        if (minimum case final minimum?) 'minimum': minimum,
        if (maximum case final maximum?) 'maximum': maximum,
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
        if (propertyOrdering case final propertyOrdering?)
          'propertyOrdering': propertyOrdering,
        if (anyOf case final anyOf?)
          'anyOf': anyOf.map((e) => e.toJson()).toList(),
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
  object,

  /// This schema is anyOf type.
  anyOf;

  /// Parse a [SchemaType] from json string.
  static SchemaType fromJson(String json) => switch (json.toUpperCase()) {
        'STRING' => string,
        'NUMBER' => number,
        'INTEGER' => integer,
        'BOOLEAN' => boolean,
        'ARRAY' => array,
        'OBJECT' => object,
        _ => throw FormatException('Unknown SchemaType: $json'),
      };

  /// Convert to json object.
  String toJson() => switch (this) {
        string => 'STRING',
        number => 'NUMBER',
        integer => 'INTEGER',
        boolean => 'BOOLEAN',
        array => 'ARRAY',
        object => 'OBJECT',
        anyOf => 'null',
      };
}
