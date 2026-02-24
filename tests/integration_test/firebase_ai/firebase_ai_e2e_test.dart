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

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/src/api.dart';
import 'package:firebase_ai/src/developer/api.dart';
import 'package:firebase_ai/src/imagen/imagen_content.dart';
import 'package:tests/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('firebase_ai e2e', () {
    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    test('test against all json responses from vertexai-sdk-test-data',
        () async {
      final treeUrl = Uri.parse(
        'https://api.github.com/repos/FirebaseExtended/vertexai-sdk-test-data/git/trees/main?recursive=1',
      );
      final treeResponse = await http.get(treeUrl);
      if (treeResponse.statusCode != 200) {
        fail('Failed to fetch tree: ${treeResponse.statusCode}');
      }
      final treeData = jsonDecode(treeResponse.body);
      final tree = treeData['tree'] as List;

      final jsonFiles = tree.where((item) {
        final path = item['path'] as String;
        return path.startsWith('mock-responses/') && path.endsWith('.json');
      }).toList();

      for (final file in jsonFiles) {
        final path = file['path'] as String;
        final rawUrl = Uri.parse(
          'https://raw.githubusercontent.com/FirebaseExtended/vertexai-sdk-test-data/main/$path',
        );
        final response = await http.get(rawUrl);
        if (response.statusCode != 200) {
          continue;
        }

        final jsonData = jsonDecode(response.body);

        final isVertex = path.contains('vertexai');
        final serializer =
            isVertex ? VertexSerialization() : DeveloperSerialization();

        try {
          if (path.contains('generate-images')) {
            if (path.contains('gcs')) {
              parseImagenGenerationResponse<ImagenGCSImage>(jsonData);
            } else {
              parseImagenGenerationResponse<ImagenInlineImage>(jsonData);
            }
          } else if (path.contains('total-tokens') || path.contains('token')) {
            if (jsonData is Map &&
                (jsonData.containsKey('totalTokens') ||
                    jsonData.containsKey('error'))) {
              serializer.parseCountTokensResponse(jsonData);
            } else {
              serializer.parseGenerateContentResponse(jsonData);
            }
          } else {
            serializer.parseGenerateContentResponse(jsonData);
          }

          if (path.contains('failure') && !path.contains('success')) {
            fail('Expected parsing to fail for $path, but it succeeded.');
          }
        } catch (e) {
          if (path.contains('failure') && !path.contains('success')) {
            // Expected to fail
            expect(
              e,
              isA<Exception>(),
              reason: 'Expected an Exception but got $e for $path',
            );
          } else {
            fail('Failed to parse success file $path: $e');
          }
        }
      }
    });
  });
}
