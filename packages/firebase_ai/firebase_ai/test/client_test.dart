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

import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:firebase_ai/src/client.dart';
import 'package:firebase_ai/src/error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _CustomStreamClient extends http.BaseClient {
  _CustomStreamClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
      _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _handler(request);
}

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

    test(
        'makeRequest times out at defaultTimeout (180s) when HTTP response never completes',
        () {
      fakeAsync((async) {
        final hangingClient = MockClient(
          (_) => Completer<http.Response>().future,
        );
        final client =
            HttpApiClient(apiKey: 'test-key', httpClient: hangingClient);

        Object? caughtError;
        client.makeRequest(uri, requestBody).then<void>(
          (_) {},
          onError: (Object error) {
            caughtError = error;
          },
        );

        async.elapse(const Duration(seconds: 179));
        expect(caughtError, isNull);

        async.elapse(const Duration(seconds: 1));
        expect(caughtError, isA<TimeoutException>());
      });
    });

    test(
        'makeRequest respects custom timeout and succeeds if response arrives before timeout',
        () {
      fakeAsync((async) {
        final responseCompleter = Completer<http.Response>();
        final slowClient = MockClient((_) => responseCompleter.future);
        final client = HttpApiClient(
          apiKey: 'test-key',
          httpClient: slowClient,
          timeout: const Duration(seconds: 10),
        );

        Map<String, Object?>? result;
        Object? caughtError;
        client.makeRequest(uri, requestBody).then<void>(
          (value) {
            result = value;
          },
          onError: (Object error) {
            caughtError = error;
          },
        );

        async.elapse(const Duration(seconds: 9));
        expect(result, isNull);
        expect(caughtError, isNull);

        responseCompleter.complete(
          http.Response(
            jsonEncode(responseJson),
            200,
            headers: {'content-type': 'application/json'},
          ),
        );
        async.flushMicrotasks();
        expect(result, responseJson);
        expect(caughtError, isNull);
      });
    });

    test('streamRequest times out when initial HTTP response headers stall',
        () {
      fakeAsync((async) {
        final hangingHeadersClient = _CustomStreamClient(
          (_) => Completer<http.StreamedResponse>().future,
        );
        final client = HttpApiClient(
          apiKey: 'test-key',
          httpClient: hangingHeadersClient,
          timeout: const Duration(seconds: 10),
        );

        Object? caughtError;
        client.streamRequest(uri, requestBody).listen(
          (_) {},
          onError: (Object error) {
            caughtError = error;
          },
        );

        async.elapse(const Duration(seconds: 9));
        expect(caughtError, isNull);

        async.elapse(const Duration(seconds: 1));
        expect(caughtError, isA<TimeoutException>());
      });
    });

    test('streamRequest times out when non-200 error response body stalls', () {
      fakeAsync((async) {
        final controller = StreamController<List<int>>(
          onCancel: Future<void>.value,
        );
        final stallingErrorClient = _CustomStreamClient(
          (_) async => http.StreamedResponse(controller.stream, 500),
        );
        final client = HttpApiClient(
          apiKey: 'test-key',
          httpClient: stallingErrorClient,
          timeout: const Duration(seconds: 10),
        );

        Object? caughtError;
        client.streamRequest(uri, requestBody).listen(
          (_) {},
          onError: (Object error) {
            caughtError = error;
          },
        );

        async.elapse(const Duration(seconds: 9));
        expect(caughtError, isNull);

        async.elapse(const Duration(seconds: 1));
        expect(caughtError, isA<TimeoutException>());
        controller.close();
      });
    });

    test(
        'streamRequest resets idle timeout on each SSE event and times out only when stream stalls',
        () {
      fakeAsync((async) {
        final controller = StreamController<List<int>>(
          onCancel: Future<void>.value,
        );
        final stallingClient = _CustomStreamClient(
          (_) async => http.StreamedResponse(controller.stream, 200),
        );
        final client = HttpApiClient(
          apiKey: 'test-key',
          httpClient: stallingClient,
          timeout: const Duration(seconds: 10),
        );

        final received = <Map<String, Object?>>[];
        Object? caughtError;
        client.streamRequest(uri, requestBody).listen(
          received.add,
          onError: (Object error) {
            caughtError = error;
          },
        );

        // First chunk arrives at t=6s (< 10s timeout): resets idle timer.
        async.elapse(const Duration(seconds: 6));
        controller.add(utf8.encode('data: {"chunk": 1}\n\n'));
        async.flushMicrotasks();
        expect(received, [
          {'chunk': 1},
        ]);
        expect(caughtError, isNull);

        // Second chunk arrives at t=12s (total 12s > 10s timeout, but 6s since
        // last event): should succeed and reset idle timer again.
        async.elapse(const Duration(seconds: 6));
        controller.add(utf8.encode('data: {"chunk": 2}\n\n'));
        async.flushMicrotasks();
        expect(received, [
          {'chunk': 1},
          {'chunk': 2},
        ]);
        expect(caughtError, isNull);

        // Now stall for 9s after the second chunk: still within 10s idle window.
        async.elapse(const Duration(seconds: 9));
        expect(caughtError, isNull);

        // At 10s of silence after the second chunk, TimeoutException fires.
        async.elapse(const Duration(seconds: 1));
        expect(caughtError, isA<TimeoutException>());
        controller.close();
      });
    });

    test(
        'streamRequest parses no-space data:, multi-line data:, ignores [DONE], and tolerates malformed UTF-8',
        () async {
      final prefixBytes = utf8.encode(
        ': keep-alive\n'
        'event: message\n'
        'id: 1\n'
        'retry: 1000\n'
        'data:{"first":1}\n'
        '\n'
        'data: {\n'
        'data: "second": 2\n'
        'data: }\n'
        '\n'
        'data: [DONE]\n'
        '\n'
        'data: [1, 2, 3]\n'
        '\n'
        'data: {"third":"',
      );
      final suffixBytes = utf8.encode('"}\n\n');
      final rawBytes = <int>[...prefixBytes, 0xFF, ...suffixBytes];

      final streamClient = _CustomStreamClient(
        (_) async => http.StreamedResponse(Stream.value(rawBytes), 200),
      );
      final client =
          HttpApiClient(apiKey: 'test-key', httpClient: streamClient);

      final chunks = await client.streamRequest(uri, requestBody).toList();
      expect(chunks, hasLength(3));
      expect(chunks[0], {'first': 1});
      expect(chunks[1], {'second': 2});
      expect(chunks[2]['third'], '\uFFFD');
    });

    test(
        'streamRequest throws FirebaseAIException on 502 HTML or non-Map error bodies',
        () async {
      final html502Client = MockClient(
        (_) async => http.Response('<html>502 Bad Gateway</html>', 502),
      );
      final client502 =
          HttpApiClient(apiKey: 'test-key', httpClient: html502Client);

      await expectLater(
        client502.streamRequest(uri, requestBody).toList(),
        throwsA(isA<FirebaseAIException>()),
      );

      final array400Client = MockClient(
        (_) async => http.Response('[{"error": "bad request"}]', 400),
      );
      final client400 =
          HttpApiClient(apiKey: 'test-key', httpClient: array400Client);

      await expectLater(
        client400.streamRequest(uri, requestBody).toList(),
        throwsA(isA<FirebaseAIException>()),
      );
    });
  });
}
