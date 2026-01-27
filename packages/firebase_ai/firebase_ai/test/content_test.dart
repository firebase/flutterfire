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
import 'dart:typed_data';

import 'package:firebase_ai/src/content.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock google_ai classes (if needed)
// ...

void main() {
  group('Content tests', () {
    test('constructor', () {
      final content = Content('user',
          [const TextPart('Test'), InlineDataPart('image/png', Uint8List(0))]);
      expect(content.role, 'user');
      expect(content.parts[0], isA<TextPart>());
      expect((content.parts[0] as TextPart).text, 'Test');
      expect(content.parts[1], isA<InlineDataPart>());
      expect((content.parts[1] as InlineDataPart).mimeType, 'image/png');
      expect((content.parts[1] as InlineDataPart).bytes.length, 0);
    });

    test('text()', () {
      final content = Content('user', [const TextPart('Test')]);
      expect(content.role, 'user');
      expect(content.parts[0], isA<TextPart>());
    });

    test('data()', () {
      final content =
          Content('user', [InlineDataPart('image/png', Uint8List(0))]);
      expect(content.parts[0], isA<InlineDataPart>());
    });

    test('multi()', () {
      final content = Content('user',
          [const TextPart('Test'), InlineDataPart('image/png', Uint8List(0))]);
      expect(content.parts.length, 2);
      expect(content.parts[0], isA<TextPart>());
      expect(content.parts[1], isA<InlineDataPart>());
    });

    test('toJson', () {
      final content = Content('user',
          [const TextPart('Test'), InlineDataPart('image/png', Uint8List(0))]);
      final json = content.toJson();
      expect(json['role'], 'user');
      expect((json['parts']! as List).length, 2);
      expect((json['parts']! as List)[0]['text'], 'Test');
      expect(
          (json['parts']! as List)[1]['inlineData']['mimeType'], 'image/png');
      expect((json['parts']! as List)[1]['inlineData']['data'].length, 0);
    });

    test('parseContent', () {
      final json = {
        'role': 'user',
        'parts': [
          {'text': 'Hello'},
        ]
      };
      final content = parseContent(json);
      expect(content.role, 'user');
      expect(content.parts.length, 1);
      expect(content.parts[0], isA<TextPart>());
      expect(reason: 'TextPart', (content.parts[0] as TextPart).text, 'Hello');
    });
  });

  group('Part tests', () {
    test('TextPart with isThought and thoughtSignature toJson', () {
      const part =
          TextPart.forTest('Test', isThought: true, thoughtSignature: 'sig');
      final json = part.toJson() as Map;
      expect(json['text'], 'Test');
      expect(json['thought'], true);
      expect(json['thoughtSignature'], 'sig');
    });

    test('DataPart with isThought and thoughtSignature toJson', () {
      final part = InlineDataPart.forTest('image/png', Uint8List(0),
          isThought: true, thoughtSignature: 'sig');
      final json = part.toJson() as Map;
      final inlineData = json['inlineData'] as Map;
      expect(inlineData['mimeType'], 'image/png');
      expect(inlineData['data'], '');
      expect(json.containsKey('willContinue'), false);
      expect(json['thought'], true);
      expect(json['thoughtSignature'], 'sig');
    });

    test('DataPart with false willContinue toJson', () {
      final part =
          InlineDataPart('image/png', Uint8List(0), willContinue: false);
      final json = part.toJson() as Map;
      final inlineData = json['inlineData'] as Map;
      expect(inlineData['mimeType'], 'image/png');
      expect(inlineData['data'], '');
      expect(inlineData.containsKey('willContinue'), true);
      expect(inlineData['willContinue'], false);
    });

    test('DataPart with true willContinue toJson', () {
      final part =
          InlineDataPart('image/png', Uint8List(0), willContinue: true);
      final json = part.toJson() as Map;
      final inlineData = json['inlineData'] as Map;
      expect(inlineData['mimeType'], 'image/png');
      expect(inlineData['data'], '');
      expect(inlineData.containsKey('willContinue'), true);
      expect(inlineData['willContinue'], true);
    });

    test('FunctionCall with isThought and thoughtSignature toJson', () {
      const part = FunctionCall.forTest(
          'myFunction',
          {
            'arguments': [
              {'text': 'Test'}
            ],
          },
          id: 'myFunctionId',
          isThought: true,
          thoughtSignature: 'sig');
      final json = part.toJson() as Map;
      final functionCall = json['functionCall'] as Map;
      expect(functionCall['name'], 'myFunction');
      final args = functionCall['args'] as Map;
      expect(args.length, 1);
      final arguments = args['arguments'] as List;
      expect(arguments.length, 1);
      final text = arguments[0] as Map;
      expect(text['text'], 'Test');
      expect(functionCall['id'], 'myFunctionId');
      expect(json['thought'], true);
      expect(json['thoughtSignature'], 'sig');
    });

    test('FunctionResponse with isThought', () {
      final part = FunctionResponse(
        'myFunction',
        {
          'inlineData': {
            'mimeType': 'application/octet-stream',
            'data': Uint8List(0)
          }
        },
        id: 'myFunctionId',
        isThought: true,
      );
      final json = part.toJson() as Map;
      final functionResponse = json['functionResponse'] as Map;
      expect(functionResponse['name'], 'myFunction');
      final response = functionResponse['response'] as Map;
      final inlineData = response['inlineData'] as Map;
      expect(inlineData['mimeType'], 'application/octet-stream');
      expect(inlineData['data'], Uint8List(0));
      expect(functionResponse['id'], 'myFunctionId');
      expect(json['thought'], true);
    });

    test('FileData with isThought and thoughtSignature toJson', () {
      const part = FileData.forTest('image/png', 'gs://bucket-name/path',
          isThought: true);
      final json = part.toJson() as Map;
      final fileData = json['file_data'] as Map;
      expect(fileData['mime_type'], 'image/png');
      expect(fileData['file_uri'], 'gs://bucket-name/path');
      expect(json['thought'], true);
    });
  });

  group('parsePart', () {
    test('parses TextPart correctly', () {
      final json = {'text': 'Hello, world!'};
      final result = parsePart(json);
      expect(result, isA<TextPart>());
      expect((result as TextPart).text, 'Hello, world!');
    });

    test('parses FunctionCall correctly', () {
      final json = {
        'functionCall': {
          'name': 'myFunction',
          'args': {'arg1': 1, 'arg2': 'value'},
          'id': '123',
        }
      };
      final result = parsePart(json);
      expect(result, isA<FunctionCall>());
      final functionCall = result as FunctionCall;
      expect(functionCall.name, 'myFunction');
      expect(functionCall.args, {'arg1': 1, 'arg2': 'value'});
      expect(functionCall.id, '123');
    });

    test('parses FileData correctly', () {
      final json = {
        'file_data': {
          'file_uri': 'file:///path/to/file.txt',
          'mime_type': 'text/plain',
        }
      };
      final result = parsePart(json);
      expect(result, isA<FileData>());
      final fileData = result as FileData;
      expect(fileData.fileUri, 'file:///path/to/file.txt');
      expect(fileData.mimeType, 'text/plain');
    });

    test('parses InlineDataPart correctly', () {
      final json = {
        'inlineData': {
          'mimeType': 'image/png',
          'data': base64Encode([1, 2, 3]),
          'willContinue': true
        }
      };
      final result = parsePart(json);
      expect(result, isA<InlineDataPart>());
      final inlineData = result as InlineDataPart;
      expect(inlineData.mimeType, 'image/png');
      expect(inlineData.bytes, [1, 2, 3]);
      expect(inlineData.willContinue, true);
    });

    test('parses InlineDataPart with false willContinue', () {
      final json = {
        'inlineData': {
          'mimeType': 'image/png',
          'data': base64Encode([1, 2, 3]),
          'willContinue': false
        }
      };
      final result = parsePart(json);
      expect(result, isA<InlineDataPart>());
      final inlineData = result as InlineDataPart;
      expect(inlineData.mimeType, 'image/png');
      expect(inlineData.bytes, [1, 2, 3]);
      expect(inlineData.willContinue, false);
    });

    test('parses InlineDataPart without willContinue', () {
      final json = {
        'inlineData': {
          'mimeType': 'image/png',
          'data': base64Encode([1, 2, 3])
        }
      };
      final result = parsePart(json);
      expect(result, isA<InlineDataPart>());
      final inlineData = result as InlineDataPart;
      expect(inlineData.mimeType, 'image/png');
      expect(inlineData.bytes, [1, 2, 3]);
      expect(inlineData.willContinue, null);
    });

    test('returns UnknownPart for functionResponse', () {
      final json = {
        'functionResponse': {'name': 'test', 'response': {}}
      };
      final result = parsePart(json);
      expect(result, isA<UnknownPart>());
      final unknownPart = result as UnknownPart;
      expect(unknownPart.data, json);
    });

    test('returns UnknownPart for invalid JSON', () {
      final json = {'invalid': 'data'};
      final result = parsePart(json);
      expect(result, isA<UnknownPart>());
      final unknownPart = result as UnknownPart;
      expect(unknownPart.data, json);
    });

    test('returns UnknownPart for null input', () {
      final result = parsePart(null);
      expect(result, isA<UnknownPart>());
      final unknownPart = result as UnknownPart;
      expect(unknownPart.data, {'unhandled': null});
    });

    test('returns UnknownPart for empty map', () {
      final result = parsePart({});
      expect(result, isA<UnknownPart>());
      final unknownPart = result as UnknownPart;
      expect(unknownPart.data, {'unhandled': {}});
    });
  });
}
