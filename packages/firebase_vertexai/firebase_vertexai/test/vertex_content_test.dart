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

import 'package:firebase_vertexai/firebase_vertexai.dart'; // Your library
import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as google_ai;

// Mock google_ai classes (if needed)
// ...

void main() {
  group('Content tests', () {
    test('constructor', () {
      final content = Content(
          'user', [TextPart('Test'), DataPart('image/png', Uint8List(0))]);
      expect(content.role, 'user');
      expect(content.parts[0], isA<TextPart>());
      expect((content.parts[0] as TextPart).text, 'Test');
      expect(content.parts[1], isA<DataPart>());
      expect((content.parts[1] as DataPart).mimeType, 'image/png');
      expect((content.parts[1] as DataPart).bytes.length, 0);
    });

    test('text()', () {
      final content = Content('user', [TextPart('Test')]);
      expect(content.role, 'user');
      expect(content.parts[0], isA<TextPart>());
    });

    test('data()', () {
      final content = Content('user', [DataPart('image/png', Uint8List(0))]);
      expect(content.parts[0], isA<DataPart>());
    });

    test('multi()', () {
      final content = Content(
          'user', [TextPart('Test'), DataPart('image/png', Uint8List(0))]);
      expect(content.parts.length, 2);
      expect(content.parts[0], isA<TextPart>());
      expect(content.parts[1], isA<DataPart>());
    });

    test('toJson', () {
      final content = Content(
          'user', [TextPart('Test'), DataPart('image/png', Uint8List(0))]);
      final json = content.toJson();
      expect(json['role'], 'user');
      expect((json['parts']! as List).length, 2);
      expect((json['parts']! as List)[0]['text'], 'Test');
      expect(
          (json['parts']! as List)[1]['inlineData']['mimeType'], 'image/png');
      expect((json['parts']! as List)[1]['inlineData']['data'].length, 0);
      // ... verify json structure
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
      // ... verify content
    });

    // ... additional tests for edge cases (e.g., null role, empty parts list)
  });

  group('Part tests', () {
    test('TextPart toJson', () {
      final part = TextPart('Test');
      final json = part.toJson();
      expect((json as Map)['text'], 'Test');
      // ... verify json structure
    });

    test('TextPart toPart', () {
      final part = TextPart('Test');
      final newPart = part.toPart();
      expect(newPart, isA<google_ai.TextPart>());
      expect((newPart as google_ai.TextPart).text, 'Test');
    });

    test('DataPart toJson', () {
      final part = DataPart('image/png', Uint8List(0));
      final json = part.toJson();
      expect((json as Map)['inlineData']['mimeType'], 'image/png');
      expect(json['inlineData']['data'], '');
      // ... verify json structure
    });

    test('DataPart toPart', () {
      final part = DataPart('image/png', Uint8List(0));
      final newPart = part.toPart();
      expect(newPart, isA<google_ai.DataPart>());
      expect((newPart as google_ai.DataPart).mimeType, 'image/png');
      expect(newPart.bytes.length, 0);
    });

    test('FunctionCall toJson', () {
      final part = FunctionCall('myFunction', {
        'arguments': [
          {'text': 'Test'}
        ]
      });
      final json = part.toJson();
      expect((json as Map)['functionCall']['name'], 'myFunction');
      expect(json['functionCall']['args'].length, 1);
      expect(json['functionCall']['args']['arguments'].length, 1);
      expect(json['functionCall']['args']['arguments'][0]['text'], 'Test');
      // ... verify json structure
    });

    test('FunctionCall toPart', () {
      final part = FunctionCall('myFunction', {
        'arguments': [
          {'text': 'Test'}
        ]
      });
      final newPart = part.toPart();
      expect(newPart, isA<google_ai.FunctionCall>());
      expect((newPart as google_ai.FunctionCall).name, 'myFunction');
      expect(newPart.args.length, 1);
      expect((newPart.args['arguments']! as List).length, 1);
      expect((newPart.args['arguments']! as List)[0]['text'], 'Test');
    });

    test('FunctionResponse toJson', () {
      final part = FunctionResponse('myFunction', {
        'inlineData': {
          'mimeType': 'application/octet-stream',
          'data': Uint8List(0)
        }
      });
      final json = part.toJson();
      expect((json as Map)['functionResponse']['name'], 'myFunction');
      expect(json['functionResponse']['response']['inlineData']['mimeType'],
          'application/octet-stream');
      expect(json['functionResponse']['response']['inlineData']['data'],
          Uint8List(0));

      // ... verify json structure
    });

    test('FunctionResponse toPart', () {
      final part = FunctionResponse('myFunction', {
        'inlineData': {
          'mimeType': 'application/octet-stream',
          'data': Uint8List(0)
        }
      });
      final newPart = part.toPart();
      expect(newPart, isA<google_ai.FunctionResponse>());
      expect((newPart as google_ai.FunctionResponse).name, 'myFunction');
      expect(newPart.response?.length, 1);
    });

    test('FileData toJson', () {
      final part = FileData('image/png', 'gs://bucket-name/path');
      final json = part.toJson();
      expect((json as Map)['file_data']['mime_type'], 'image/png');
      expect(json['file_data']['file_uri'], 'gs://bucket-name/path');
      // ... verify json structure
    });
  });
}
