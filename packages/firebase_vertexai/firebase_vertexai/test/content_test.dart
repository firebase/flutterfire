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

import 'dart:typed_data';

import 'package:firebase_vertexai/src/content.dart';
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
}
