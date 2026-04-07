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

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'dart:convert';
import 'package:source_gen/source_gen.dart';
import 'package:firebase_ai/src/annotations.dart'; // Import annotations

/// Generator for [Generable] annotation.
class SchemaGenerator extends GeneratorForAnnotation<Generable> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          '@Generable can only be applied to classes.',
          element: element);
    }

    final className = element.name;
    final fields = element.fields;

    final schemaMap = <String, dynamic>{
      'type': 'OBJECT',
      'properties': <String, dynamic>{},
    };

    final fromJsonBuffer = StringBuffer();
    fromJsonBuffer.writeln('(json) => $className(');

    for (final field in fields) {
      if (field.isSynthetic) continue; // Skip getters/setters

      final fieldName = field.name;
      final fieldType = field.type;

      // Check for @Guide annotation
      final guideAnnotation =
          TypeChecker.fromRuntime(Guide).firstAnnotationOf(field);
      String? description;
      num? minimum;
      num? maximum;
      String? pattern;

      if (guideAnnotation != null) {
        final reader = ConstantReader(guideAnnotation);
        description = reader.read('description').literalValue as String?;
        minimum = reader.read('minimum').literalValue as num?;
        maximum = reader.read('maximum').literalValue as num?;
        pattern = reader.read('pattern').literalValue as String?;
      }

      final fieldSchema = <String, dynamic>{};
      if (description != null) fieldSchema['description'] = description;

      if (fieldType.isDartCoreString) {
        fieldSchema['type'] = 'STRING';
        if (pattern != null) fieldSchema['pattern'] = pattern;
      } else if (fieldType.isDartCoreInt) {
        fieldSchema['type'] = 'INTEGER';
        if (minimum != null) fieldSchema['minimum'] = minimum;
        if (maximum != null) fieldSchema['maximum'] = maximum;
      } else if (fieldType.isDartCoreDouble) {
        fieldSchema['type'] = 'NUMBER';
        if (minimum != null) fieldSchema['minimum'] = minimum;
        if (maximum != null) fieldSchema['maximum'] = maximum;
      } else if (fieldType.isDartCoreBool) {
        fieldSchema['type'] = 'BOOLEAN';
      } else if (fieldType.isDartCoreList) {
        fieldSchema['type'] = 'ARRAY';
        // Handle list item type if possible
        final typeArgs = (fieldType as ParameterizedType).typeArguments;
        if (typeArgs.isNotEmpty) {
           final itemType = typeArgs.first;
           fieldSchema['items'] = _mapPrimitiveType(itemType);
        }
      } else {
        // Handle nested objects or enums
        fieldSchema['type'] = 'OBJECT'; // Fallback
      }

      (schemaMap['properties'] as Map<String, dynamic>)[fieldName] = fieldSchema;

      fromJsonBuffer.writeln('  $fieldName: json[\'$fieldName\'] as ${_mapDartType(fieldType)},');
    }

    fromJsonBuffer.write(')');

    return '''
/// Auto-generated schema for $className.
final ${className}Schema = AutoSchema<$className>(
  schemaMap: const <String, dynamic>${_mapToDartCode(schemaMap)},
  fromJson: $fromJsonBuffer,
);
''';
  }

  Map<String, dynamic> _mapPrimitiveType(DartType type) {
    if (type.isDartCoreString) return {'type': 'STRING'};
    if (type.isDartCoreInt) return {'type': 'INTEGER'};
    if (type.isDartCoreDouble) return {'type': 'NUMBER'};
    if (type.isDartCoreBool) return {'type': 'BOOLEAN'};
    return {'type': 'OBJECT'};
  }

  String _mapDartType(DartType type) {
    if (type.isDartCoreString) return 'String';
    if (type.isDartCoreInt) return 'int';
    if (type.isDartCoreDouble) return 'double';
    if (type.isDartCoreBool) return 'bool';
    if (type.isDartCoreList) {
      final typeArgs = (type as ParameterizedType).typeArguments;
      if (typeArgs.isNotEmpty) {
        return 'List<${_mapDartType(typeArgs.first)}>';
      }
      return 'List';
    }
    return 'Map<String, dynamic>';
  }

  String _mapToDartCode(Map<String, dynamic> map) {
    return jsonEncode(map)
        .replaceAll('"', "'")
        .replaceAll(r'$', r'\$')
        .replaceAll(':', ': ')
        .replaceAll(',', ', ');
  }
}
