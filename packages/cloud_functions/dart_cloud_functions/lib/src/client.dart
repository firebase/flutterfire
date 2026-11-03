// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:dart_cloud_functions/src/codec.dart';
import 'package:dart_cloud_functions/src/context.dart';
import 'package:dart_cloud_functions/src/errors.dart';
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
    final abort = Completer<void>();
    final request = _request(url, data, context, abort.future);
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

  /// Streams the function at [url] with [data]: the messages it sends, then
  /// its result.
  ///
  /// The request carries [context]'s tokens. With an [idleTimeout], the
  /// stream fails with `deadline-exceeded` if no data arrives for that long.
  /// The server's heartbeats count as data, so long streams keep going.
  /// Cancelling the subscription, a timeout or any other failure aborts the
  /// request.
  Stream<CallableEvent> streamFunction(
    Uri url,
    Object? data, {
    required CallableContext context,
    Duration? idleTimeout,
  }) async* {
    final abort = Completer<void>();
    final request = _request(url, data, context, abort.future)
      ..headers['Accept'] = 'text/event-stream';
    try {
      final response = await _timeout(_httpClient.send(request), idleTimeout);
      final body = _idleTimeout(response.stream, idleTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final bytes = await http.ByteStream(body).toBytes();
        throw decodeCallableError(response.statusCode, bytes);
      }
      await for (final event in decodeCallableEvents(body)) {
        yield event;
      }
    } on TimeoutException {
      if (idleTimeout == null) rethrow;
      throw callableTimeoutException(idleTimeout);
    } on http.ClientException catch (error) {
      throw callableNetworkException(error);
    } finally {
      if (!abort.isCompleted) abort.complete();
    }
  }

  /// A POST of [data] in the `data` envelope, with [context]'s tokens, that
  /// [abortTrigger] can abort.
  http.AbortableRequest _request(
    Uri url,
    Object? data,
    CallableContext context,
    Future<void> abortTrigger,
  ) {
    return http.AbortableRequest('POST', url, abortTrigger: abortTrigger)
      ..headers.addAll(callableRequestHeaders(context))
      ..body = encodeCallableRequest(data);
  }
}

/// Fails [future] with a [TimeoutException] if it takes longer than [timeout],
/// when set.
Future<T> _timeout<T>(Future<T> future, Duration? timeout) =>
    timeout == null ? future : future.timeout(timeout);

/// Fails [stream] with a [TimeoutException] if it goes longer than [timeout]
/// without an event, when set.
Stream<T> _idleTimeout<T>(Stream<T> stream, Duration? timeout) =>
    timeout == null ? stream : stream.timeout(timeout);
