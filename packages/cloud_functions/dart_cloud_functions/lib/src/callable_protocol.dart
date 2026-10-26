// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dart_cloud_functions/src/firebase_functions_exception.dart';
import 'package:http/http.dart' as http;

/// Headers sent with every callable request.
const Map<String, String> callableRequestHeaders = {
  'Content-Type': 'application/json',
};

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
