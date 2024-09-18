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

import 'package:firebase_vertexai/src/vertex_schema.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Schema Tests', () {
    // Test basic constructors and toJson() for primitive types
    test('Schema.boolean', () {
      final schema =
          Schema.boolean(description: 'A boolean value', nullable: true);
      expect(schema.type, SchemaType.boolean);
      expect(schema.description, 'A boolean value');
      expect(schema.nullable, true);
      expect(schema.toJson(), {
        'type': 'BOOLEAN',
        'description': 'A boolean value',
        'nullable': true,
      });
    });

    test('Schema.integer', () {
      final schema = Schema.integer(format: 'int32');
      expect(schema.type, SchemaType.integer);
      expect(schema.format, 'int32');
      expect(schema.toJson(), {
        'type': 'INTEGER',
        'format': 'int32',
      });
    });

    test('Schema.number', () {
      final schema = Schema.number(format: 'double', nullable: false);
      expect(schema.type, SchemaType.number);
      expect(schema.format, 'double');
      expect(schema.nullable, false);
      expect(schema.toJson(), {
        'type': 'NUMBER',
        'format': 'double',
        'nullable': false,
      });
    });

    test('Schema.string', () {
      final schema = Schema.string();
      expect(schema.type, SchemaType.string);
      expect(schema.toJson(), {'type': 'STRING'});
    });

    test('Schema.enumString', () {
      final schema = Schema.enumString(enumValues: ['value1', 'value2']);
      expect(schema.type, SchemaType.string);
      expect(schema.format, 'enum');
      expect(schema.enumValues, ['value1', 'value2']);
      expect(schema.toJson(), {
        'type': 'STRING',
        'format': 'enum',
        'enum': ['value1', 'value2'],
      });
    });

    // Test constructors and toJson() for complex types
    test('Schema.array', () {
      final itemSchema = Schema.string();
      final schema = Schema.array(items: itemSchema);
      expect(schema.type, SchemaType.array);
      expect(schema.items, itemSchema);
      expect(schema.toJson(), {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      });
    });

    test('Schema.object', () {
      final properties = {
        'name': Schema.string(),
        'age': Schema.integer(),
      };
      final schema = Schema.object(
        properties: properties,
        optionalProperties: ['age'],
      );
      expect(schema.type, SchemaType.object);
      expect(schema.properties, properties);
      expect(schema.optionalProperties, ['age']);
      expect(schema.toJson(), {
        'type': 'OBJECT',
        'properties': {
          'name': {'type': 'STRING'},
          'age': {'type': 'INTEGER'},
        },
        'required': ['name'],
      });
    });

    test('Schema.object with empty optionalProperties', () {
      final properties = {
        'name': Schema.string(),
        'age': Schema.integer(),
      };
      final schema = Schema.object(
        properties: properties,
      );
      expect(schema.type, SchemaType.object);
      expect(schema.properties, properties);
      expect(schema.toJson(), {
        'type': 'OBJECT',
        'properties': {
          'name': {'type': 'STRING'},
          'age': {'type': 'INTEGER'},
        },
        'required': ['name', 'age'],
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
    });

    // Add more tests as needed to cover other scenarios and edge cases
  });
}
