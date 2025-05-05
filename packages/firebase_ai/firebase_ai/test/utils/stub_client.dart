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

import 'dart:collection';

import 'package:firebase_ai/src/client.dart';

class ClientController {
  final _client = _ControlledClient();
  ApiClient get client => _client;

  /// Run [body] and return [response] for a single call to
  /// [ApiClient.streamRequest].
  ///
  /// Check expectations for the request URI and JSON payload with the
  /// [verifyRequest] callback.
  Future<T> checkRequest<T>(
    Future<T> Function() body, {
    required Map<String, Object?> response,
    void Function(Uri, Map<String, Object?>)? verifyRequest,
  }) async {
    _client._requestExpectations.addLast(verifyRequest);
    _client._responses.addLast([response]);
    final result = await body();
    assert(_client._responses.isEmpty);
    return result;
  }

  /// Run [body] and return [responses] for a single call to
  /// [ApiClient.streamRequest].
  ///
  /// Check expectations for the request URI and JSON payload with the
  /// [verifyRequest] callback.
  Future<T> checkStreamRequest<T>(
    Future<T> Function() body, {
    required Iterable<Map<String, Object?>> responses,
    void Function(Uri, Map<String, Object?>)? verifyRequest,
  }) async {
    _client._requestExpectations.addLast(verifyRequest);
    _client._responses.addLast(responses.toList());
    final result = await body();
    assert(_client._responses.isEmpty);
    return result;
  }
}

final class _ControlledClient implements ApiClient {
  final _requestExpectations =
      Queue<void Function(Uri, Map<String, Object?>)?>();
  final _responses = Queue<List<Map<String, Object?>>>();

  @override
  Future<Map<String, Object?>> makeRequest(
    Uri uri,
    Map<String, Object?> body,
  ) async {
    _requestExpectations.removeFirst()?.call(uri, body);
    return _responses.removeFirst().single;
  }

  @override
  Stream<Map<String, Object?>> streamRequest(
    Uri uri,
    Map<String, Object?> body,
  ) {
    _requestExpectations.removeFirst()?.call(uri, body);
    return Stream.fromIterable(_responses.removeFirst());
  }
}

const Map<String, Object?> arbitraryGenerateContentResponse = {
  'candidates': [
    {
      'content': {
        'role': 'model',
        'parts': [
          {'text': 'Some Response'},
        ],
      },
    },
  ],
};
