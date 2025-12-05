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

import 'package:firebase_ai/src/schema.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Schema Tests', () {
    // Test basic constructors and toJson() for primitive types
    test('Schema.boolean', () {
      final schema =
          Schema.boolean(description: 'A boolean value', nullable: true, title: 'Is Active');
      expect(schema.type, SchemaType.boolean);
      expect(schema.description, 'A boolean value');
      expect(schema.nullable, true);
      expect(schema.title, 'Is Active');
      expect(schema.toJson(), {
        'type': 'BOOLEAN',
        'description': 'A boolean value',
        'nullable': true,
        'title': 'Is Active',
      });
    });

    test('Schema.integer', () {
      final schema = Schema.integer(format: 'int32', minimum: 0, maximum: 100, title: 'Count');
      expect(schema.type, SchemaType.integer);
      expect(schema.format, 'int32');
      expect(schema.minimum, 0);
      expect(schema.maximum, 100);
      expect(schema.title, 'Count');
      expect(schema.toJson(), {
        'type': 'INTEGER',
        'format': 'int32',
        'minimum': 0.0, // Ensure double conversion
        'maximum': 100.0, // Ensure double conversion
        'title': 'Count',
      });
    });

    test('Schema.number', () {
      final schema = Schema.number(
          format: 'double', nullable: false, minimum: 0.5, maximum: 99.5, title: 'Percentage');
      expect(schema.type, SchemaType.number);
      expect(schema.format, 'double');
      expect(schema.nullable, false);
      expect(schema.minimum, 0.5);
      expect(schema.maximum, 99.5);
      expect(schema.title, 'Percentage');
      expect(schema.toJson(), {
        'type': 'NUMBER',
        'format': 'double',
        'nullable': false,
        'minimum': 0.5,
        'maximum': 99.5,
        'title': 'Percentage',
      });
    });

    test('Schema.string', () {
      final schema = Schema.string(title: 'User Name');
      expect(schema.type, SchemaType.string);
      expect(schema.title, 'User Name');
      expect(schema.toJson(), {'type': 'STRING', 'title': 'User Name'});
    });

    test('Schema.enumString', () {
      final schema = Schema.enumString(enumValues: ['value1', 'value2'], title: 'Status');
      expect(schema.type, SchemaType.string);
      expect(schema.format, 'enum');
      expect(schema.enumValues, ['value1', 'value2']);
      expect(schema.title, 'Status');
      expect(schema.toJson(), {
        'type': 'STRING',
        'format': 'enum',
        'enum': ['value1', 'value2'],
        'title': 'Status',
      });
    });

    // Test constructors and toJson() for complex types
    test('Schema.array', () {
      final itemSchema = Schema.string();
      final schema = Schema.array(items: itemSchema, minItems: 1, maxItems: 5, title: 'Tags');
      expect(schema.type, SchemaType.array);
      expect(schema.items, itemSchema);
      expect(schema.minItems, 1);
      expect(schema.maxItems, 5);
      expect(schema.title, 'Tags');
      expect(schema.toJson(), {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
        'minItems': 1,
        'maxItems': 5,
        'title': 'Tags',
      });
    });

    test('Schema.object', () {
      final properties = {
        'name': Schema.string(),
        'age': Schema.integer(),
        'city': Schema.string(description: 'City of residence'),
      };
      final schema = Schema.object(
        properties: properties,
        optionalProperties: ['age'],
        propertyOrdering: ['name', 'city', 'age'],
        title: 'User Profile',
        description: 'Represents a user profile',
      );
      expect(schema.type, SchemaType.object);
      expect(schema.properties, properties);
      expect(schema.optionalProperties, ['age']);
      expect(schema.propertyOrdering, ['name', 'city', 'age']);
      expect(schema.title, 'User Profile');
      expect(schema.description, 'Represents a user profile');
      expect(schema.toJson(), {
        'type': 'OBJECT',
        'properties': {
          'name': {'type': 'STRING'},
          'age': {'type': 'INTEGER'},
          'city': {'type': 'STRING', 'description': 'City of residence'},
        },
        'required': ['name', 'city'],
        'propertyOrdering': ['name', 'city', 'age'],
        'title': 'User Profile',
        'description': 'Represents a user profile',
      });
    });

    test('Schema.object with empty optionalProperties', () {
      final properties = {
        'name': Schema.string(),
        'age': Schema.integer(),
      };
      final schema = Schema.object(
        properties: properties,
        // No optionalProperties, so all are required
      );
      expect(schema.type, SchemaType.object);
      expect(schema.properties, properties);
      expect(schema.toJson(), {
        'type': 'OBJECT',
        'properties': {
          'name': {'type': 'STRING'},
          'age': {'type': 'INTEGER'},
        },
        'required': ['name', 'age'], // All keys from properties
      });
    });

    test('Schema.object with all properties optional', () {
      final properties = {
        'name': Schema.string(),
        'age': Schema.integer(),
      };
      final schema = Schema.object(
        properties: properties,
        optionalProperties: ['name', 'age'],
      );
      expect(schema.type, SchemaType.object);
      expect(schema.properties, properties);
      expect(schema.optionalProperties, ['name', 'age']);
      expect(schema.toJson(), {
        'type': 'OBJECT',
        'properties': {
          'name': {'type': 'STRING'},
          'age': {'type': 'INTEGER'},
        },
        'required': [], // Empty list as all are optional
      });
    });

    // Test Schema.anyOf
    test('Schema.anyOf', () {
      final schema1 = Schema.string(description: 'A string value');
      final schema2 = Schema.integer(description: 'An integer value');
      final schema = Schema.anyOf(schemas: [schema1, schema2]);

      // The type field is SchemaType.anyOf internally for dispatching toJson
      // but it should not be present in the final JSON for `anyOf`.
      expect(schema.type, SchemaType.anyOf);
      expect(schema.anyOf, [schema1, schema2]);
      expect(schema.toJson(), {
        'anyOf': [
          {'type': 'STRING', 'description': 'A string value'},
          {'type': 'INTEGER', 'description': 'An integer value'},
        ],
      });
    });

    test('Schema.anyOf with complex types', () {
      final userSchema = Schema.object(properties: {
        'id': Schema.integer(),
        'username': Schema.string(),
      }, optionalProperties: [
        'username'
      ]);
      final errorSchema = Schema.object(properties: {
        'errorCode': Schema.integer(),
        'errorMessage': Schema.string(),
      });
      final schema = Schema.anyOf(schemas: [userSchema, errorSchema]);

      expect(schema.type, SchemaType.anyOf);
      expect(schema.anyOf?.length, 2);
      expect(schema.toJson(), {
        'anyOf': [
          {
            'type': 'OBJECT',
            'properties': {
              'id': {'type': 'INTEGER'},
              'username': {'type': 'STRING'},
            },
            'required': ['id'],
          },
          {
            'type': 'OBJECT',
            'properties': {
              'errorCode': {'type': 'INTEGER'},
              'errorMessage': {'type': 'STRING'},
            },
            'required': ['errorCode', 'errorMessage'],
          },
        ],
      });
    });

    // Test SchemaType.toJson()
    test('SchemaType.toJson', () {
      expect(SchemaType.string.toJson(), 'STRING');
      expect(SchemaType.number.toJson(), 'NUMBER');
      expect(SchemaType.integer.toJson(), 'INTEGER');
      expect(SchemaType.boolean.toJson(), 'BOOLEAN');
      expect(SchemaType.array.toJson(), 'ARRAY');
      expect(SchemaType.object.toJson(), 'OBJECT');
      expect(SchemaType.anyOf.toJson(), 'null'); // As per implementation, 'null' string for anyOf
    });

    // Test edge cases
    test('Schema.object with no properties', () {
      final schema = Schema.object(properties: {});
      expect(schema.type, SchemaType.object);
      expect(schema.properties, {});
      expect(schema.toJson(), {
        'type': 'OBJECT',
        'properties': {},
        'required': [],
      });
    });

    test('Schema.array with no items (should not happen with constructor)', () {
      // This is more of a theoretical test as the constructor requires `items`.
      // We construct it manually to test `toJson` robustness.
      final schema = Schema(SchemaType.array);
      expect(schema.type, SchemaType.array);
      expect(schema.toJson(), {
        'type': 'ARRAY',
        // 'items' field should be absent if items is null
      });
    });

    test('Schema with all optional fields null', () {
      final schema = Schema(SchemaType.string); // Only type is provided
      expect(schema.type, SchemaType.string);
      expect(schema.format, isNull);
      expect(schema.description, isNull);
      expect(schema.nullable, isNull);
      expect(schema.enumValues, isNull);
      expect(schema.items, isNull);
      expect(schema.properties, isNull);
      expect(schema.optionalProperties, isNull);
      expect(schema.anyOf, isNull);
      expect(schema.toJson(), {'type': 'STRING'});
    });
  });

  group('Schema.fromJson Tests', () {
    test('Schema.fromJson boolean', () {
      final json = {
        'type': 'BOOLEAN',
        'description': 'A boolean value',
        'nullable': true,
        'title': 'Is Active',
      };
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.boolean);
      expect(schema.description, 'A boolean value');
      expect(schema.nullable, true);
      expect(schema.title, 'Is Active');
    });

    test('Schema.fromJson integer', () {
      final json = {
        'type': 'INTEGER',
        'format': 'int32',
        'minimum': 0.0,
        'maximum': 100.0,
        'title': 'Count',
      };
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.integer);
      expect(schema.format, 'int32');
      expect(schema.minimum, 0.0);
      expect(schema.maximum, 100.0);
      expect(schema.title, 'Count');
    });

    test('Schema.fromJson number', () {
      final json = {
        'type': 'NUMBER',
        'format': 'double',
        'nullable': false,
        'minimum': 0.5,
        'maximum': 99.5,
        'title': 'Percentage',
      };
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.number);
      expect(schema.format, 'double');
      expect(schema.nullable, false);
      expect(schema.minimum, 0.5);
      expect(schema.maximum, 99.5);
      expect(schema.title, 'Percentage');
    });

    test('Schema.fromJson string', () {
      final json = {'type': 'STRING', 'title': 'User Name'};
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.string);
      expect(schema.title, 'User Name');
    });

    test('Schema.fromJson enumString', () {
      final json = {
        'type': 'STRING',
        'format': 'enum',
        'enum': ['value1', 'value2'],
        'title': 'Status',
      };
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.string);
      expect(schema.format, 'enum');
      expect(schema.enumValues, ['value1', 'value2']);
      expect(schema.title, 'Status');
    });

    test('Schema.fromJson array', () {
      final json = {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
        'minItems': 1,
        'maxItems': 5,
        'title': 'Tags',
      };
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.array);
      expect(schema.items?.type, SchemaType.string);
      expect(schema.minItems, 1);
      expect(schema.maxItems, 5);
      expect(schema.title, 'Tags');
    });

    test('Schema.fromJson object', () {
      final json = {
        'type': 'OBJECT',
        'properties': {
          'name': {'type': 'STRING'},
          'age': {'type': 'INTEGER'},
          'city': {'type': 'STRING', 'description': 'City of residence'},
        },
        'required': ['name', 'city'],
        'propertyOrdering': ['name', 'city', 'age'],
        'title': 'User Profile',
        'description': 'Represents a user profile',
      };
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.object);
      expect(schema.properties?.keys, containsAll(['name', 'age', 'city']));
      expect(schema.properties?['name']?.type, SchemaType.string);
      expect(schema.properties?['age']?.type, SchemaType.integer);
      expect(schema.properties?['city']?.description, 'City of residence');
      expect(schema.optionalProperties, ['age']);
      expect(schema.propertyOrdering, ['name', 'city', 'age']);
      expect(schema.title, 'User Profile');
      expect(schema.description, 'Represents a user profile');
    });

    test('Schema.fromJson object with all required', () {
      final json = {
        'type': 'OBJECT',
        'properties': {
          'name': {'type': 'STRING'},
          'age': {'type': 'INTEGER'},
        },
        'required': ['name', 'age'],
      };
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.object);
      expect(schema.optionalProperties, isEmpty);
    });

    test('Schema.fromJson object with all optional', () {
      final json = {
        'type': 'OBJECT',
        'properties': {
          'name': {'type': 'STRING'},
          'age': {'type': 'INTEGER'},
        },
        'required': <String>[],
      };
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.object);
      expect(schema.optionalProperties, containsAll(['name', 'age']));
    });

    test('Schema.fromJson anyOf', () {
      final json = {
        'anyOf': [
          {'type': 'STRING', 'description': 'A string value'},
          {'type': 'INTEGER', 'description': 'An integer value'},
        ],
      };
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.anyOf);
      expect(schema.anyOf?.length, 2);
      expect(schema.anyOf?[0].type, SchemaType.string);
      expect(schema.anyOf?[0].description, 'A string value');
      expect(schema.anyOf?[1].type, SchemaType.integer);
      expect(schema.anyOf?[1].description, 'An integer value');
    });

    test('Schema.fromJson anyOf with complex types', () {
      final json = {
        'anyOf': [
          {
            'type': 'OBJECT',
            'properties': {
              'id': {'type': 'INTEGER'},
              'username': {'type': 'STRING'},
            },
            'required': ['id'],
          },
          {
            'type': 'OBJECT',
            'properties': {
              'errorCode': {'type': 'INTEGER'},
              'errorMessage': {'type': 'STRING'},
            },
            'required': ['errorCode', 'errorMessage'],
          },
        ],
      };
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.anyOf);
      expect(schema.anyOf?.length, 2);
      expect(schema.anyOf?[0].properties?['id']?.type, SchemaType.integer);
      expect(schema.anyOf?[0].optionalProperties, ['username']);
      expect(schema.anyOf?[1].optionalProperties, isEmpty);
    });

    test('Schema.fromJson minimal', () {
      final json = {'type': 'STRING'};
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.string);
      expect(schema.format, isNull);
      expect(schema.description, isNull);
      expect(schema.nullable, isNull);
      expect(schema.enumValues, isNull);
      expect(schema.items, isNull);
      expect(schema.properties, isNull);
      expect(schema.optionalProperties, isNull);
      expect(schema.anyOf, isNull);
    });

    test('Schema.fromJson nested array of objects', () {
      final json = {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'id': {'type': 'INTEGER'},
            'name': {'type': 'STRING'},
          },
          'required': ['id', 'name'],
        },
      };
      final schema = Schema.fromJson(json);
      expect(schema.type, SchemaType.array);
      expect(schema.items?.type, SchemaType.object);
      expect(schema.items?.properties?['id']?.type, SchemaType.integer);
      expect(schema.items?.properties?['name']?.type, SchemaType.string);
    });

    // Round-trip tests: toJson -> fromJson should preserve the schema
    test('Round-trip boolean', () {
      final original =
          Schema.boolean(description: 'A boolean value', nullable: true, title: 'Is Active');
      final json = original.toJson();
      final restored = Schema.fromJson(json);
      expect(restored.type, original.type);
      expect(restored.description, original.description);
      expect(restored.nullable, original.nullable);
      expect(restored.title, original.title);
    });

    test('Round-trip integer', () {
      final original = Schema.integer(format: 'int32', minimum: 0, maximum: 100, title: 'Count');
      final json = original.toJson();
      final restored = Schema.fromJson(json);
      expect(restored.type, original.type);
      expect(restored.format, original.format);
      expect(restored.minimum, original.minimum);
      expect(restored.maximum, original.maximum);
      expect(restored.title, original.title);
    });

    test('Round-trip object with optional properties', () {
      final original = Schema.object(
        properties: {
          'name': Schema.string(),
          'age': Schema.integer(),
          'city': Schema.string(description: 'City of residence'),
        },
        optionalProperties: ['age'],
        propertyOrdering: ['name', 'city', 'age'],
        title: 'User Profile',
        description: 'Represents a user profile',
      );
      final json = original.toJson();
      final restored = Schema.fromJson(json);
      expect(restored.type, original.type);
      expect(restored.properties?.keys, original.properties?.keys);
      expect(restored.optionalProperties, original.optionalProperties);
      expect(restored.propertyOrdering, original.propertyOrdering);
      expect(restored.title, original.title);
      expect(restored.description, original.description);
    });

    test('Round-trip anyOf', () {
      final original = Schema.anyOf(schemas: [
        Schema.string(description: 'A string value'),
        Schema.integer(description: 'An integer value'),
      ]);
      final json = original.toJson();
      final restored = Schema.fromJson(json);
      expect(restored.type, SchemaType.anyOf);
      expect(restored.anyOf?.length, original.anyOf?.length);
      expect(restored.anyOf?[0].type, original.anyOf?[0].type);
      expect(restored.anyOf?[1].type, original.anyOf?[1].type);
    });
  });

  group('SchemaType.fromJson Tests', () {
    test('SchemaType.fromJson parses all types', () {
      expect(SchemaType.fromJson('STRING'), SchemaType.string);
      expect(SchemaType.fromJson('NUMBER'), SchemaType.number);
      expect(SchemaType.fromJson('INTEGER'), SchemaType.integer);
      expect(SchemaType.fromJson('BOOLEAN'), SchemaType.boolean);
      expect(SchemaType.fromJson('ARRAY'), SchemaType.array);
      expect(SchemaType.fromJson('OBJECT'), SchemaType.object);
    });

    test('SchemaType.fromJson throws on unknown type', () {
      expect(
        () => SchemaType.fromJson('UNKNOWN'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
