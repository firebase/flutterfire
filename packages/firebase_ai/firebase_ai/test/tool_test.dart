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
import 'package:firebase_ai/src/tool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tool Tests', () {
    test('AutoFunctionDeclaration basic properties and toJson', () async {
      // Define a simple callable function
      Future<Map<String, Object?>> myFunction(Map<String, Object?> args) async {
        return {
          'result': 'Hello, ${args['name']}!',
          'age_plus_ten': (args['age'] as int) + 10,
        };
      }

      // Define the schema for the function's parameters
      final parametersSchema = {
        'name': Schema.string(description: 'The name to greet'),
        'age': Schema.integer(description: 'The age of the person'),
      };

      // Create an AutoFunctionDeclaration
      final autoDeclaration = AutoFunctionDeclaration(
        name: 'greetUser',
        description:
            'Greets a user with their name and calculates age plus ten.',
        parameters: parametersSchema,
        optionalParameters: const [],
        callable: myFunction,
      );

      // Verify properties
      expect(autoDeclaration.name, 'greetUser');
      expect(autoDeclaration.description,
          'Greets a user with their name and calculates age plus ten.');
      expect(autoDeclaration.callable, myFunction);

      // Verify toJson output (should match FunctionDeclaration's toJson)
      expect(autoDeclaration.toJson(), {
        'name': 'greetUser',
        'description':
            'Greets a user with their name and calculates age plus ten.',
        'parameters': {
          'type': 'OBJECT',
          'properties': {
            'name': {'type': 'STRING', 'description': 'The name to greet'},
            'age': {'type': 'INTEGER', 'description': 'The age of the person'},
          },
          'required': ['name', 'age'],
        },
      });

      // Optionally, test invoking the callable directly (simulating client execution)
      final result =
          await autoDeclaration.callable({'name': 'Alice', 'age': 30});
      expect(result, {'result': 'Hello, Alice!', 'age_plus_ten': 40});
    });

    test('AutoFunctionDeclaration with optional parameters', () async {
      Future<Map<String, Object?>> optionalParamFunction(
          Map<String, Object?> args) async {
        final greeting =
            args['name'] != null ? 'Hello, ${args['name']}!' : 'Hello!';

        return {'message': greeting};
      }

      final parametersSchema = {
        'name': Schema.string(description: 'An optional name'),
      };

      final autoDeclaration = AutoFunctionDeclaration(
        name: 'optionalGreet',
        description: 'Greets a user, optionally by name.',
        parameters: parametersSchema,
        optionalParameters: const ['name'],
        callable: optionalParamFunction,
      );

      expect(autoDeclaration.name, 'optionalGreet');
      expect(autoDeclaration.description, 'Greets a user, optionally by name.');
      expect(autoDeclaration.callable, optionalParamFunction);
      expect(autoDeclaration.toJson(), {
        'name': 'optionalGreet',
        'description': 'Greets a user, optionally by name.',
        'parameters': {
          'type': 'OBJECT',

          'properties': {
            'name': {'type': 'STRING', 'description': 'An optional name'},
          },

          'required': [], // 'name' is optional, so 'required' is empty
        },
      });

      final resultWithoutName = await autoDeclaration.callable({});
      expect(resultWithoutName, {'message': 'Hello!'});
      final resultWithName = await autoDeclaration.callable({'name': 'Bob'});
      expect(resultWithName, {'message': 'Hello, Bob!'});
    });

    // Test FunctionCallingConfig
    test('FunctionCallingConfig.auto()', () {
      final config = FunctionCallingConfig.auto();
      expect(config.mode, FunctionCallingMode.auto);
      expect(config.allowedFunctionNames, isNull);
      expect(config.toJson(), {'mode': 'AUTO'});
    });

    test('FunctionCallingConfig.any()', () {
      final allowedNames = {'func1', 'func2'};
      final config = FunctionCallingConfig.any(allowedNames);
      expect(config.mode, FunctionCallingMode.any);
      expect(config.allowedFunctionNames, allowedNames);
      expect(config.toJson(), {
        'mode': 'ANY',
        'allowedFunctionNames': ['func1', 'func2'],
      });
    });

    test('FunctionCallingConfig.none()', () {
      final config = FunctionCallingConfig.none();
      expect(config.mode, FunctionCallingMode.none);
      expect(config.allowedFunctionNames, isNull);
      expect(config.toJson(), {'mode': 'NONE'});
    });

    // Test FunctionCallingMode.toJson()
    test('FunctionCallingMode.toJson()', () {
      expect(FunctionCallingMode.auto.toJson(), 'AUTO');
      expect(FunctionCallingMode.any.toJson(), 'ANY');
      expect(FunctionCallingMode.none.toJson(), 'NONE');
    });

    // Test Tool.functionDeclarations()
    test('Tool.functionDeclarations()', () {
      final functionDeclaration = AutoFunctionDeclaration(
        name: 'myFunction',
        description: 'Does something.',
        parameters: {'param1': Schema.string()},
        callable: (args) async => {'result': 'Success'},
      );

      final tool = Tool.functionDeclarations([functionDeclaration]);

      expect(tool.toJson(), {
        'functionDeclarations': [
          {
            'name': 'myFunction',
            'description': 'Does something.',
            'parameters': {
              'type': 'OBJECT',
              'properties': {
                'param1': {'type': 'STRING'},
              },
              'required': ['param1'],
            },
          }
        ]
      });
    });

    // Test Tool.googleSearch()

    test('Tool.googleSearch()', () {
      final tool = Tool.googleSearch();
      expect(tool.toJson(), {
        'googleSearch': {},
      });
    });

    // Test Tool.codeExecution()

    test('Tool.codeExecution()', () {
      final tool = Tool.codeExecution();
      expect(tool.toJson(), {
        'codeExecution': {},
      });
    });

    // Test Tool.urlContext()
    test('Tool.urlContext()', () {
      final tool = Tool.urlContext();
      expect(tool.toJson(), {
        'urlContext': {},
      });
    });

    // Test ToolConfig
    test('ToolConfig with FunctionCallingConfig', () {
      final config = ToolConfig(
        functionCallingConfig: FunctionCallingConfig.auto(),
      );
      expect(config.toJson(), {
        'functionCallingConfig': {'mode': 'AUTO'},
      });
    });

    test('ToolConfig with null FunctionCallingConfig', () {
      final config = ToolConfig();
      expect(config.toJson(), {});
    });

    // Test GoogleSearch, CodeExecution, UrlContext toJson()
    test('GoogleSearch.toJson()', () {
      const search = GoogleSearch();
      expect(search.toJson(), {});
    });

    test('CodeExecution.toJson()', () {
      const execution = CodeExecution();
      expect(execution.toJson(), {});
    });

    test('UrlContext.toJson()', () {
      const context = UrlContext();
      expect(context.toJson(), {});
    });
  });
}
