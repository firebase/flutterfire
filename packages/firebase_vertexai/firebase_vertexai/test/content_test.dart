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
import 'package:firebase_vertexai/firebase_vertexai.dart'
    show VertexAISdkException;
import 'package:flutter_test/flutter_test.dart';

// Mock google_ai classes (if needed)
// ...

void main() {
  group('Content tests', () {
    test('constructor', () {
      final content = Content('user',
          [TextPart('Test'), InlineDataPart('image/png', Uint8List(0))]);
      expect(content.role, 'user');
      expect(content.parts[0], isA<TextPart>());
      expect((content.parts[0] as TextPart).text, 'Test');
      expect(content.parts[1], isA<InlineDataPart>());
      expect((content.parts[1] as InlineDataPart).mimeType, 'image/png');
      expect((content.parts[1] as InlineDataPart).bytes.length, 0);
    });

    test('text()', () {
      final content = Content('user', [TextPart('Test')]);
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
          [TextPart('Test'), InlineDataPart('image/png', Uint8List(0))]);
      expect(content.parts.length, 2);
      expect(content.parts[0], isA<TextPart>());
      expect(content.parts[1], isA<InlineDataPart>());
    });

    test('toJson', () {
      final content = Content('user',
          [TextPart('Test'), InlineDataPart('image/png', Uint8List(0))]);
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
    test('TextPart toJson', () {
      final part = TextPart('Test');
      final json = part.toJson();
      expect((json as Map)['text'], 'Test');
    });

    test('DataPart toJson', () {
      final part = InlineDataPart('image/png', Uint8List(0));
      final json = part.toJson();
      expect((json as Map)['inlineData']['mimeType'], 'image/png');
      expect(json['inlineData']['data'], '');
    });

    test('FunctionCall toJson', () {
      final part = FunctionCall(
          'myFunction',
          {
            'arguments': [
              {'text': 'Test'}
            ],
          },
          id: 'myFunctionId');
      final json = part.toJson();
      expect((json as Map)['functionCall']['name'], 'myFunction');
      expect(json['functionCall']['args'].length, 1);
      expect(json['functionCall']['args']['arguments'].length, 1);
      expect(json['functionCall']['args']['arguments'][0]['text'], 'Test');
      expect(json['functionCall']['id'], 'myFunctionId');
    });

    test('FunctionResponse toJson', () {
      final part = FunctionResponse(
          'myFunction',
          {
            'inlineData': {
              'mimeType': 'application/octet-stream',
              'data': Uint8List(0)
            }
          },
          id: 'myFunctionId');
      final json = part.toJson();
      expect((json as Map)['functionResponse']['name'], 'myFunction');
      expect(json['functionResponse']['response']['inlineData']['mimeType'],
          'application/octet-stream');
      expect(json['functionResponse']['response']['inlineData']['data'],
          Uint8List(0));
      expect(json['functionResponse']['id'], 'myFunctionId');
    });

    test('FileData toJson', () {
      final part = FileData('image/png', 'gs://bucket-name/path');
      final json = part.toJson();
      expect((json as Map)['file_data']['mime_type'], 'image/png');
      expect(json['file_data']['file_uri'], 'gs://bucket-name/path');
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
          'data': base64Encode([1, 2, 3])
        }
      };
      final result = parsePart(json);
      expect(result, isA<InlineDataPart>());
      final inlineData = result as InlineDataPart;
      expect(inlineData.mimeType, 'image/png');
      expect(inlineData.bytes, [1, 2, 3]);
    });

    test('throws UnimplementedError for functionResponse', () {
      final json = {
        'functionResponse': {'name': 'test', 'response': {}}
      };
      expect(() => parsePart(json), throwsA(isA<VertexAISdkException>()));
    });

    test('throws unhandledFormat for invalid JSON', () {
      final json = {'invalid': 'data'};
      expect(() => parsePart(json), throwsA(isA<Exception>()));
    });

    test('throws unhandledFormat for null input', () {
      expect(() => parsePart(null), throwsA(isA<Exception>()));
    });

    test('throws unhandledFormat for empty map', () {
      expect(() => parsePart({}), throwsA(isA<Exception>()));
    });
  });
}
