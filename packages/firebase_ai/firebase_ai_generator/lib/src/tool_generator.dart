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

/// Generator for [GenerateTool] annotation.
class ToolGenerator extends GeneratorForAnnotation<GenerateTool> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! FunctionElement) {
      throw InvalidGenerationSourceError(
          '@GenerateTool can only be applied to functions.',
          element: element);
    }

    final functionName = element.name;
    final parameters = element.parameters;
    final toolName = annotation.read('name').literalValue as String? ?? functionName;
    final description = element.documentationComment ?? 'Auto-generated tool for $functionName';

    final propertiesBuffer = StringBuffer();
    propertiesBuffer.writeln('{');
    
    final callableBuffer = StringBuffer();
    callableBuffer.writeln('(args) async {');
    callableBuffer.writeln('  // Extract arguments');

    for (final param in parameters) {
      final paramName = param.name;
      final paramType = param.type;

      propertiesBuffer.write("    '$paramName': ");
      if (paramType.isDartCoreString) {
        propertiesBuffer.writeln('Schema.string(),');
      } else if (paramType.isDartCoreInt) {
        propertiesBuffer.writeln('Schema.integer(),');
      } else if (paramType.isDartCoreDouble) {
        propertiesBuffer.writeln('Schema.number(),');
      } else if (paramType.isDartCoreBool) {
        propertiesBuffer.writeln('Schema.boolean(),');
      } else {
        propertiesBuffer.writeln('Schema.object(properties: {}), // TODO: Handle complex types');
      }

      callableBuffer.writeln("  final _$paramName = args['$paramName'] as ${_mapDartType(paramType)};");
    }

    propertiesBuffer.write('  }');

    callableBuffer.writeln('  final result = await $functionName(');
    for (final param in parameters) {
      final paramName = param.name;
      callableBuffer.writeln('    _$paramName,');
    }
    callableBuffer.writeln('  );');
    callableBuffer.writeln('  return result.toJson(); // Assumes result has toJson');
    callableBuffer.writeln('}');

    return '''
/// Auto-generated tool wrapper for $functionName.
final ${functionName}Tool = AutoFunctionDeclaration(
  name: '$toolName',
  description: '$description',
  parameters: $propertiesBuffer,
  callable: $callableBuffer,
);
''';
  }

  String _mapDartType(DartType type) {
    if (type.isDartCoreString) return 'String';
    if (type.isDartCoreInt) return 'int';
    if (type.isDartCoreDouble) return 'double';
    if (type.isDartCoreBool) return 'bool';
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
