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

import 'package:firebase_ai/src/client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final uri = Uri.parse('https://example.com/v1/models/test:generateContent');
  const requestBody = {'prompt': 'hello'};
  const responseJson = {'ok': true};

  MockClient jsonClient() => MockClient((request) async {
        return http.Response(
          jsonEncode(responseJson),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

  MockClient sseClient() => MockClient((request) async {
        return http.Response(
          'data: ${jsonEncode(responseJson)}\n',
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });

  group('HttpApiClient', () {
    test('reuses a single Client for unary requests when none is injected',
        () async {
      var created = 0;

      await http.runWithClient(() async {
        final client = HttpApiClient(apiKey: 'test-key');
        await client.makeRequest(uri, requestBody);
        await client.makeRequest(uri, requestBody);
        expect(created, 1);
      }, () {
        created++;
        return jsonClient();
      });
    });

    test('reuses a single Client for streaming requests when none is injected',
        () async {
      var created = 0;

      await http.runWithClient(() async {
        final client = HttpApiClient(apiKey: 'test-key');
        await client.streamRequest(uri, requestBody).drain<void>();
        await client.streamRequest(uri, requestBody).drain<void>();
        expect(created, 1);
      }, () {
        created++;
        return sseClient();
      });
    });

    test('uses an injected Client for unary and streaming requests', () async {
      final requests = <http.BaseRequest>[];
      final mock = MockClient((request) async {
        requests.add(request);
        if (request.url.queryParameters['alt'] == 'sse') {
          return http.Response(
            'data: ${jsonEncode(responseJson)}\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }
        return http.Response(
          jsonEncode(responseJson),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = HttpApiClient(apiKey: 'test-key', httpClient: mock);
      await client.makeRequest(uri, requestBody);
      await client.streamRequest(uri, requestBody).drain<void>();

      expect(requests, hasLength(2));
      expect(requests.first.method, 'POST');
      expect(requests.last.method, 'POST');
      expect(requests.last.url.queryParameters['alt'], 'sse');
    });
  });
}
