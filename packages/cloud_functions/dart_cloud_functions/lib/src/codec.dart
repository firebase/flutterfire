// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dart_cloud_functions/src/context.dart';
import 'package:dart_cloud_functions/src/errors.dart';
import 'package:dart_cloud_functions/src/firebase_functions_exception.dart';

/// The headers of a callable request that carries [context]'s tokens.
///
/// The ID token uses the `Bearer` scheme, which callable functions require
/// (`firebase_ai` sends `Firebase` instead).
Map<String, String> callableRequestHeaders(CallableContext context) {
  return {
    'Content-Type': 'application/json',
    if (context.authToken case final authToken?)
      'Authorization': 'Bearer $authToken',
    if (context.appCheckToken case final appCheckToken?)
      'X-Firebase-AppCheck': appCheckToken,
  };
}

/// Wraps [parameters] in the `data` envelope of a callable request.
String encodeCallableRequest(Object? parameters) {
  return jsonEncode({'data': parameters});
}

/// Returns the value of a callable response, or throws a
/// [DartFirebaseFunctionsException].
///
/// Successful responses carry the value in `result` (older servers used
/// `data`). For failures, see [callableErrorForResponse].
Object? decodeCallableResponse(int statusCode, List<int> bodyBytes) {
  final body = _tryDecodeJson(bodyBytes);
  final error = callableErrorForResponse(statusCode, body);
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

Object? _tryDecodeJson(List<int> bodyBytes) {
  try {
    return jsonDecode(utf8.decode(bodyBytes));
  } on FormatException {
    return null;
  }
}
