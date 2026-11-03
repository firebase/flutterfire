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
      expect(callableRequestHeaders(const CallableContext()), {
        'Content-Type': 'application/json',
      });
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
      expect(_decode(200, _listFruitBody), [
        'Apple',
        'Banana',
        'Cherry',
        'Date',
        'Fig',
        'Grapes',
      ]);
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

  group('decodeCallableError', () {
    test('maps the error object of an error response', () {
      expect(
        decodeCallableError(400, utf8.encode(_invalidArgumentBody)).code,
        'invalid-argument',
      );
    });

    test('falls back to the HTTP status for a non-JSON body', () {
      expect(
        decodeCallableError(404, utf8.encode(_unknownFunctionBody)).code,
        'not-found',
      );
    });
  });

  group('decodeCallableEvents', () {
    Future<List<CallableEvent>> decodeEvents(List<String> chunks) {
      return decodeCallableEvents(
        Stream.fromIterable(chunks.map(utf8.encode)),
      ).toList();
    }

    test('decodes messages, then the result', () async {
      expect(
        await decodeEvents([
          'data: {"message":"Apple"}\n\n',
          'data: {"message":"Banana"}\n\ndata: {"result":2}\n\n',
        ]),
        [
          (isResult: false, value: 'Apple'),
          (isResult: false, value: 'Banana'),
          (isResult: true, value: 2),
        ],
      );
    });

    test('skips heartbeats and lines that are not events', () async {
      expect(
        await decodeEvents([
          ': ping\n\n',
          'event: unused\n',
          'data: not json\n\n',
          'data: {"unknown":1}\n\n',
          'data: {"result":1}\n\n',
        ]),
        [(isResult: true, value: 1)],
      );
    });

    test('accepts CRLF line endings and data: without a space', () async {
      expect(
        await decodeEvents(['data:{"message":1}\r\n\r\ndata:{"result":2}\r\n']),
        [(isResult: false, value: 1), (isResult: true, value: 2)],
      );
    });

    test('joins lines and characters split across network chunks', () async {
      final bytes = utf8.encode('data: {"message":"é"}\n\n');
      // In UTF-8, é is the two bytes 0xC3 0xA9; split between them.
      final middle = bytes.indexOf(0xA9);

      final events = await decodeCallableEvents(
        Stream.fromIterable([bytes.sublist(0, middle), bytes.sublist(middle)]),
      ).toList();

      expect(events, [(isResult: false, value: 'é')]);
    });

    test('throws an error event', () async {
      await expectLater(
        decodeEvents([
          'data: {"message":"Apple"}\n\n',
          'data: {"error":{"status":"INVALID_ARGUMENT","message":"Bad."}}\n\n',
        ]),
        _throwsCode('invalid-argument'),
      );
    });

    test('makes an error event without a status internal', () async {
      await expectLater(
        decodeEvents(['data: {"error":{"message":"Oops."}}\n\n']),
        _throwsCode('internal'),
      );
    });
  });
}
