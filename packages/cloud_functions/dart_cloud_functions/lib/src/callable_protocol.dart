// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dart_cloud_functions/src/callable_context.dart';
import 'package:dart_cloud_functions/src/firebase_functions_exception.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

/// The headers of a callable request that carries [context]'s tokens.
///
/// The ID token uses the `Bearer` scheme, which callable functions require
/// (`firebase_ai` sends `Firebase` instead).
Map<String, String> callableRequestHeaders(CallableContext context) {
  return {
    'Content-Type': 'application/json',
    if (context.authToken case final authToken?)
      'Authorization': 'Bearer $authToken',
  };
}

/// Hosts that may receive tokens over plain HTTP: the device itself, and
/// `10.0.2.2`, the Android emulator's address for the host machine.
const _loopbackHosts = {'localhost', '127.0.0.1', '::1', '10.0.2.2'};

/// Throws an `unauthenticated` [DartFirebaseFunctionsException] if
/// [context]'s tokens would be sent over plain HTTP to a non-loopback host.
///
/// Tokens are credentials, so, as with `shouldAttachTokens` in the Apple SDK,
/// they only travel over HTTPS or to the local machine, such as the
/// emulator. A call without tokens may use any URL. [allowInsecure] skips the
/// check, for `DartFirebaseFunctions.allowInsecureTokenAttachment`.
void checkTokenTransport(
  Uri endpoint,
  CallableContext context, {
  bool allowInsecure = false,
}) {
  if (!context.hasTokens || allowInsecure || endpoint.scheme == 'https') {
    return;
  }
  if (_loopbackHosts.contains(endpoint.host.toLowerCase())) return;
  throw DartFirebaseFunctionsException(
    code: 'unauthenticated',
    message: 'Refusing to send tokens over HTTP to ${endpoint.host}, which is '
        'not a loopback host.',
  );
}

/// Resolves the URL of a callable function.
///
/// An explicit [uri] is used as is, even when an emulator [origin] is set,
/// which matches the native SDKs. Otherwise [name] is resolved against the
/// emulator (`{origin}/{projectId}/{region}/{name}`) or production
/// (`https://{region}-{projectId}.cloudfunctions.net/{name}`).
Uri callableEndpoint({
  required String projectId,
  required String region,
  String? name,
  Uri? uri,
  String? origin,
}) {
  if (uri != null) return uri;
  if (name == null) {
    throw ArgumentError('Either a function name or a URI is required.');
  }
  if (origin != null) return Uri.parse('$origin/$projectId/$region/$name');
  return Uri.https('$region-$projectId.cloudfunctions.net', name);
}

/// Wraps [parameters] in the `data` envelope of a callable request.
String encodeCallableRequest(Object? parameters) {
  return jsonEncode({'data': parameters});
}

/// Returns the value of a callable response, or throws a
/// [DartFirebaseFunctionsException].
///
/// Successful responses carry the value in `result` (older servers used
/// `data`). Errors carry an `error` object with a canonical `status`, a
/// `message` and optional `details`. Responses without that envelope, such as
/// the emulator's HTML page for an unknown function, fall back to the HTTP
/// status code.
Object? decodeCallableResponse(int statusCode, List<int> bodyBytes) {
  final body = _tryDecodeJson(bodyBytes);
  final error = _errorForResponse(statusCode, body);
  if (error != null) throw error;

  if (body is! Map<String, dynamic>) {
    throw DartFirebaseFunctionsException(
      code: 'internal',
      message: 'Response is not a valid JSON object.',
    );
  }
  if (body.containsKey('result')) return body['result'];
  if (body.containsKey('data')) return body['data'];
  throw DartFirebaseFunctionsException(
    code: 'internal',
    message: 'Response is missing the result field.',
  );
}

/// The exception for a call that exceeded `DartHttpsCallableOptions.timeout`.
DartFirebaseFunctionsException callableTimeoutException(Duration timeout) {
  return DartFirebaseFunctionsException(
    code: 'deadline-exceeded',
    message: 'The call did not complete within ${timeout.inMilliseconds} ms.',
  );
}

/// The exception for a request that could not reach the server.
DartFirebaseFunctionsException callableNetworkException(
  http.ClientException error,
) {
  return DartFirebaseFunctionsException(
    code: 'unavailable',
    message: error.message,
  );
}

/// The exception for a call whose tokens could not be fetched, such as when
/// Firebase Auth fails to refresh an expired ID token.
///
/// Like the native plugins, it uses the code `unknown` and keeps the message
/// of the original [error].
DartFirebaseFunctionsException callableContextException(Object error) {
  final message = switch (error) {
    FirebaseException(:final message?) => message,
    _ => error.toString(),
  };
  return DartFirebaseFunctionsException(code: 'unknown', message: message);
}

Object? _tryDecodeJson(List<int> bodyBytes) {
  try {
    return jsonDecode(utf8.decode(bodyBytes));
  } on FormatException {
    return null;
  }
}

DartFirebaseFunctionsException? _errorForResponse(
  int statusCode,
  Object? body,
) {
  var code = _codeForHttpStatus(statusCode);
  var message = code;
  Object? details;

  final error = body is Map<String, dynamic> ? body['error'] : null;
  if (error is Map<String, dynamic>) {
    final status = error['status'];
    if (status is String) {
      final mappedCode = _codeForCanonicalStatus(status);
      if (mappedCode == null) {
        return DartFirebaseFunctionsException(
          code: 'internal',
          message: status,
        );
      }
      code = mappedCode;
      message = status;
    }
    final errorMessage = error['message'];
    if (errorMessage is String) message = errorMessage;
    details = error['details'];
  }

  if (code == 'ok') return null;
  return DartFirebaseFunctionsException(
    code: code,
    message: message,
    details: details,
  );
}

/// Canonical status names from `google.rpc.Code`, as sent by the backend.
const _canonicalStatuses = {
  'OK',
  'CANCELLED',
  'UNKNOWN',
  'INVALID_ARGUMENT',
  'DEADLINE_EXCEEDED',
  'NOT_FOUND',
  'ALREADY_EXISTS',
  'PERMISSION_DENIED',
  'RESOURCE_EXHAUSTED',
  'FAILED_PRECONDITION',
  'ABORTED',
  'OUT_OF_RANGE',
  'UNIMPLEMENTED',
  'INTERNAL',
  'UNAVAILABLE',
  'DATA_LOSS',
  'UNAUTHENTICATED',
};

/// Maps `INVALID_ARGUMENT` to `invalid-argument`, or returns `null` for a
/// status the protocol doesn't define.
String? _codeForCanonicalStatus(String status) {
  if (!_canonicalStatuses.contains(status)) return null;
  return status.toLowerCase().replaceAll('_', '-');
}

String _codeForHttpStatus(int statusCode) {
  if (statusCode >= 200 && statusCode < 300) return 'ok';
  return switch (statusCode) {
    400 => 'invalid-argument',
    401 => 'unauthenticated',
    403 => 'permission-denied',
    404 => 'not-found',
    409 => 'aborted',
    429 => 'resource-exhausted',
    499 => 'cancelled',
    500 => 'internal',
    501 => 'unimplemented',
    503 => 'unavailable',
    504 => 'deadline-exceeded',
    _ => 'unknown',
  };
}
