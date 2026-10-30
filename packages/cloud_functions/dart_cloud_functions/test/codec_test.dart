// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dart_cloud_functions/dart_cloud_functions.dart';
import 'package:dart_cloud_functions/src/codec.dart';
import 'package:dart_cloud_functions/src/context.dart';
import 'package:flutter_test/flutter_test.dart';

// Response bodies captured from the Cloud Functions emulator
// (firebase-tools 14.9.0) for the e2e backend in
// .github/workflows/scripts/functions/src/index.ts.
const _listFruitBody =
    '{"result":["Apple","Banana","Cherry","Date","Fig","Grapes"]}';
const _invalidArgumentBody =
    '{"error":{"message":"Invalid test requested.","status":"INVALID_ARGUMENT"}}';
const _unknownFunctionBody =
    'Function us-central1-doesNotExist does not exist, valid functions are: '
    'us-central1-listFruit';

Object? _decode(int statusCode, String body) =>
    decodeCallableResponse(statusCode, utf8.encode(body));

Matcher _throwsCode(String code) {
  return throwsA(
    isA<DartFirebaseFunctionsException>().having((e) => e.code, 'code', code),
  );
}

void main() {
  group('callableRequestHeaders', () {
    test('sends JSON without tokens', () {
      expect(
        callableRequestHeaders(const CallableContext()),
        {'Content-Type': 'application/json'},
      );
    });

    test('sends the ID token with the Bearer scheme', () {
      expect(
        callableRequestHeaders(const CallableContext(authToken: 'id-token')),
        containsPair('Authorization', 'Bearer id-token'),
      );
    });

    test('sends the App Check token as X-Firebase-AppCheck', () {
      expect(
        callableRequestHeaders(
          const CallableContext(appCheckToken: 'app-check-token'),
        ),
        containsPair('X-Firebase-AppCheck', 'app-check-token'),
      );
    });
  });

  group('encodeCallableRequest', () {
    test('wraps parameters in a data envelope', () {
      expect(
        jsonDecode(encodeCallableRequest({'type': 'number', 'value': 1})),
        {
          'data': {'type': 'number', 'value': 1},
        },
      );
    });

    test('sends null as an explicit null', () {
      expect(encodeCallableRequest(null), '{"data":null}');
    });
  });

  group('decodeCallableResponse', () {
    test('returns the result field', () {
      expect(
        _decode(200, _listFruitBody),
        ['Apple', 'Banana', 'Cherry', 'Date', 'Fig', 'Grapes'],
      );
    });

    test('returns objects as Map<String, dynamic>', () {
      expect(
        _decode(200, '{"result":{"foo":"bar"}}'),
        isA<Map<String, dynamic>>(),
      );
    });

    test('accepts the legacy data field', () {
      expect(_decode(200, '{"data":"legacy"}'), 'legacy');
    });

    test('rejects a success response without a result field', () {
      expect(
        () => _decode(200, '{"unexpected":true}'),
        _throwsCode('internal'),
      );
    });

    test('rejects a success response that is not JSON', () {
      expect(() => _decode(200, 'not json'), _throwsCode('internal'));
    });

    test('throws the error in an HttpsError envelope', () {
      expect(
        () => _decode(400, _invalidArgumentBody),
        _throwsCode('invalid-argument'),
      );
    });

    test('falls back to the HTTP status for a non-JSON error body', () {
      expect(
        () => _decode(404, _unknownFunctionBody),
        _throwsCode('not-found'),
      );
    });
  });
}
