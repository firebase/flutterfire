// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:developer' as developer;

import 'package:dart_cloud_functions/src/callable_context.dart';
import 'package:dart_cloud_functions/src/callable_protocol.dart';
import 'package:http/http.dart' as http;

/// Calls callable functions over HTTP.
///
/// Speaks the callable protocol: it wraps the data in the `data` envelope,
/// sends the context's tokens as headers, and turns the response into the
/// function's result or a `DartFirebaseFunctionsException`.
///
/// One [http.Client] carries every call, so calls reuse open connections
/// instead of paying for a new TCP and TLS handshake every time, as the native
/// SDKs do. It's never closed, because that would cut off every call in
/// flight.
final class CallableClient {
  /// Creates a client that sends requests with [httpClient], or with a new
  /// [http.Client] when omitted.
  CallableClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  /// Calls the function at [url] with [data] and returns its result.
  ///
  /// The request carries [context]'s tokens. A call that hasn't finished
  /// within [timeout] fails with `deadline-exceeded`, and its request is
  /// aborted so it stops holding a connection, as when the native SDKs time
  /// out. Clients that can't abort requests, such as `MockClient`, still fail
  /// on time.
  Future<Object?> callFunction(
    Uri url,
    Object? data, {
    required CallableContext context,
    required Duration timeout,
  }) async {
    developer.log('POST $url', name: 'dart_cloud_functions');
    final abort = Completer<void>();
    final request = http.AbortableRequest(
      'POST',
      url,
      abortTrigger: abort.future,
    )
      ..headers.addAll(callableRequestHeaders(context))
      ..body = encodeCallableRequest(data);
    try {
      final response = await _httpClient
          .send(request)
          .then(http.Response.fromStream)
          .timeout(timeout);
      return decodeCallableResponse(response.statusCode, response.bodyBytes);
    } on TimeoutException {
      abort.complete();
      throw callableTimeoutException(timeout);
    } on http.ClientException catch (error) {
      throw callableNetworkException(error);
    }
  }
}

