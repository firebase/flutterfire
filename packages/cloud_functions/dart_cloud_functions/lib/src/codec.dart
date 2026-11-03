// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dart_cloud_functions/src/context.dart';
import 'package:dart_cloud_functions/src/errors.dart';
import 'package:dart_cloud_functions/src/firebase_functions_exception.dart';

/// The headers of a callable request that carries [context]'s tokens.
///
/// The ID token uses the `Bearer` scheme, which callable functions require.
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

/// Returns the exception for a response with an error [statusCode], from its
/// `error` object or, without one, from the status alone.
DartFirebaseFunctionsException decodeCallableError(
  int statusCode,
  List<int> bodyBytes,
) {
  return callableErrorForResponse(statusCode, _tryDecodeJson(bodyBytes)) ??
      DartFirebaseFunctionsException(
        code: 'internal',
        message: 'Unexpected HTTP status $statusCode.',
      );
}

/// One event of a streaming call: a message the function sent along the way,
/// or its final result.
typedef CallableEvent = ({bool isResult, Object? value});

/// Turns the body of a streaming response into its events.
///
/// The body is in the server-sent events format: each `data:` line holds a
/// JSON object with a `message`, the final `result`, or an `error`, which is
/// thrown as a [DartFirebaseFunctionsException]. Everything else, such as the
/// server's `: ping` heartbeats, is skipped, as in the Android and JS SDKs.
Stream<CallableEvent> decodeCallableEvents(Stream<List<int>> body) async* {
  final lines = body
      .transform(const Utf8Decoder(allowMalformed: true))
      .transform(const LineSplitter());
  await for (final line in lines) {
    if (!line.startsWith('data:')) continue;
    if (_decodeEvent(line.substring('data:'.length)) case final event?) {
      yield event;
    }
  }
}

/// Returns the event in the JSON [data] of one `data:` line, `null` to skip
/// it, or throws the error it carries.
CallableEvent? _decodeEvent(String data) {
  final Object? json;
  try {
    json = jsonDecode(data);
  } on FormatException {
    return null;
  }
  if (json is! Map<String, dynamic>) return null;
  if (json.containsKey('error')) {
    // 500 makes an error without a canonical status `internal`, as in the JS
    // SDK.
    throw callableErrorForResponse(500, json) ??
        DartFirebaseFunctionsException(code: 'internal', message: 'internal');
  }
  if (json.containsKey('result')) {
    return (isResult: true, value: json['result']);
  }
  if (json.containsKey('message')) {
    return (isResult: false, value: json['message']);
  }
  return null;
}

Object? _tryDecodeJson(List<int> bodyBytes) {
  try {
    return jsonDecode(utf8.decode(bodyBytes));
  } on FormatException {
    return null;
  }
}
