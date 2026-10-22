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

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'error.dart';
import 'firebaseai_version.dart';

/// Client name to feed into the request.
const clientName = 'vertexai-dart/$packageVersion';

/// The interface for client
abstract interface class ApiClient {
  /// Function to make a request
  Future<Map<String, Object?>> makeRequest(Uri uri, Map<String, Object?> body);

  /// Function to make a stream request.
  Stream<Map<String, Object?>> streamRequest(
      Uri uri, Map<String, Object?> body);
}

// Encodes first by `json.encode`, then `utf8.encode`.
// Decodes first by `utf8.decode`, then `json.decode`.
final _utf8Json = json.fuse(utf8);

/// The http implementation of ApiClient
final class HttpApiClient implements ApiClient {
  ///Constructor
  HttpApiClient({
    required String apiKey,
    http.Client? httpClient,
    FutureOr<Map<String, String>> Function()? requestHeaders,
    Duration? timeout,
  })  : _apiKey = apiKey,
        // package:http top-level helpers (http.post, Request.send) create and
        // close a Client per call, which prevents TCP/TLS connection reuse.
        _httpClient = httpClient ?? http.Client(),
        _requestHeaders = requestHeaders,
        _timeout = timeout ?? defaultTimeout;

  /// Default timeout for HTTP requests and streaming SSE events.
  static const Duration defaultTimeout = Duration(seconds: 180);
  final String _apiKey;
  final http.Client _httpClient;
  final Duration _timeout;

  final FutureOr<Map<String, String>> Function()? _requestHeaders;

  Future<Map<String, String>> _headers() async => {
        'x-goog-api-key': _apiKey,
        'x-goog-api-client': clientName,
        'Content-Type': 'application/json',
        if (_requestHeaders case final requestHeaders?)
          ...await requestHeaders(),
      };

  @override
  Future<Map<String, Object?>> makeRequest(
      Uri uri, Map<String, Object?> body) async {
    final headers = await _headers();
    final abortCompleter = Completer<void>();
    void abortRequest() {
      if (!abortCompleter.isCompleted) {
        abortCompleter.complete();
      }
    }

    final request = http.AbortableRequest(
      'POST',
      uri,
      abortTrigger: abortCompleter.future,
    )
      ..headers.addAll(headers)
      ..bodyBytes = _utf8Json.encode(body);
    final sendFuture = _httpClient.send(request);
    unawaited(
      sendFuture.then(
        (lateResponse) {
          if (abortCompleter.isCompleted) {
            lateResponse.stream.listen((_) {}).cancel().ignore();
          }
        },
        onError: (_) {},
      ),
    );
    final http.Response response;
    try {
      final streamedResponse = await sendFuture.timeout(_timeout);
      response =
          await http.Response.fromStream(streamedResponse).timeout(_timeout);
    } on TimeoutException {
      abortRequest();
      rethrow;
    }
    if (response.statusCode >= 500) {
      throw FirebaseAIException(
          'Server Error [${response.statusCode}]: ${response.body}');
    }

    return _utf8Json.decode(response.bodyBytes)! as Map<String, Object?>;
  }

  @override
  Stream<Map<String, Object?>> streamRequest(
      Uri uri, Map<String, Object?> body) async* {
    Uri streamUri = uri.replace(queryParameters: {'alt': 'sse'});
    final abortCompleter = Completer<void>();
    void abortRequest() {
      if (!abortCompleter.isCompleted) {
        abortCompleter.complete();
      }
    }

    final request = http.AbortableRequest(
      'POST',
      streamUri,
      abortTrigger: abortCompleter.future,
    )
      ..bodyBytes = _utf8Json.encode(body)
      ..headers.addAll(await _headers());
    final sendFuture = _httpClient.send(request);
    unawaited(
      sendFuture.then(
        (lateResponse) {
          if (abortCompleter.isCompleted) {
            lateResponse.stream.listen((_) {}).cancel().ignore();
          }
        },
        onError: (_) {},
      ),
    );
    final http.StreamedResponse response;
    try {
      response = await sendFuture.timeout(_timeout);
    } on TimeoutException {
      abortRequest();
      rethrow;
    }
    try {
      if (response.statusCode != 200) {
        final String responseBody;
        try {
          responseBody = await const Utf8Decoder(allowMalformed: true)
              .bind(response.stream.timeout(_timeout))
              .join();
        } on TimeoutException {
          abortRequest();
          rethrow;
        }
        try {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map<String, Object?>) {
            // Yield a potential error object like a normal result for
            // consistency with `makeRequest` and `parseError`.
            yield decoded;
            return;
          }
        } on FormatException {
          // Fall through to throw FirebaseAIException below when the error body
          // is not JSON (e.g. an HTML 502 error page).
        }
        throw FirebaseAIException(
          'Server Error [${response.statusCode}]: $responseBody',
        );
      }
      final lines = const Utf8Decoder(allowMalformed: true)
          .bind(response.stream)
          .transform(const LineSplitter())
          .timeout(_timeout);
      final dataBuffer = <String>[];
      Map<String, Object?>? flushDataBuffer() {
        if (dataBuffer.isEmpty) return null;
        final jsonText = dataBuffer.join('\n').trim();
        dataBuffer.clear();
        if (jsonText.isEmpty || jsonText == '[DONE]') return null;
        final decoded = jsonDecode(jsonText);
        if (decoded is Map<String, Object?>) {
          return decoded;
        }
        throw FormatException('Unexpected SSE data payload', jsonText);
      }

      try {
        await for (final line in lines) {
          if (line.isEmpty) {
            final chunk = flushDataBuffer();
            if (chunk != null) yield chunk;
            continue;
          }
          if (line.startsWith(':')) {
            continue;
          }
          if (line.startsWith('data:')) {
            var payload = line.substring('data:'.length);
            if (payload.startsWith(' ')) {
              payload = payload.substring(1);
            }
            dataBuffer.add(payload);
          }
        }
      } on TimeoutException {
        abortRequest();
        rethrow;
      }
      final trailing = flushDataBuffer();
      if (trailing != null) yield trailing;
    } finally {
      abortRequest();
    }
  }
}
