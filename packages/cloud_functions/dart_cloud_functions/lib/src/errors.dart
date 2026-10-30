// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart_cloud_functions/src/firebase_functions_exception.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Returns the exception a callable response carries, or `null` if the call
/// succeeded.
///
/// Errors carry an `error` object with a canonical `status`, a `message` and
/// optional `details`. Responses without that envelope, such as the
/// emulator's HTML page for an unknown function, fall back to the HTTP
/// [statusCode], mapped as each platform's native SDK does: on iOS and macOS,
/// 409 is `already-exists` and statuses it doesn't know are `internal`; on
/// Android and the web, they're `aborted` and `unknown`.
DartFirebaseFunctionsException? callableErrorForResponse(
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
DartFirebaseFunctionsException callableTokenException(Object error) {
  final message = switch (error) {
    FirebaseException(:final message?) => message,
    _ => error.toString(),
  };
  return DartFirebaseFunctionsException(code: 'unknown', message: message);
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

/// Maps an HTTP status to a code, as the current platform's native SDK does.
String _codeForHttpStatus(int statusCode) {
  if (statusCode >= 200 && statusCode < 300) return 'ok';
  return switch (statusCode) {
    400 => 'invalid-argument',
    401 => 'unauthenticated',
    403 => 'permission-denied',
    404 => 'not-found',
    409 => _isApple ? 'already-exists' : 'aborted',
    429 => 'resource-exhausted',
    499 => 'cancelled',
    500 => 'internal',
    501 => 'unimplemented',
    503 => 'unavailable',
    504 => 'deadline-exceeded',
    _ => _isApple ? 'internal' : 'unknown',
  };
}

/// Whether the app runs on iOS or macOS, where the native SDK maps a few HTTP
/// statuses differently from the Android and JS SDKs.
bool get _isApple =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS);
