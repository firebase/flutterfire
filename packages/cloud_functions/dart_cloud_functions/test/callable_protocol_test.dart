// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dart_cloud_functions/dart_cloud_functions.dart';
import 'package:dart_cloud_functions/src/callable_context.dart';
import 'package:dart_cloud_functions/src/callable_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

// Response bodies captured from the Cloud Functions emulator
// (firebase-tools 14.9.0) for the e2e backend in
// .github/workflows/scripts/functions/src/index.ts.
const _listFruitBody =
    '{"result":["Apple","Banana","Cherry","Date","Fig","Grapes"]}';
const _invalidArgumentBody =
    '{"error":{"message":"Invalid test requested.","status":"INVALID_ARGUMENT"}}';
const _cancelledWithDetailsBody =
    '{"error":{"details":1234,"message":"Response data was requested to be '
    'sent as part of an Error payload, so here we are!","status":"CANCELLED"}}';
const _unknownFunctionBody =
    'Function us-central1-doesNotExist does not exist, valid functions are: '
    'us-central1-listFruit';

Object? _decode(int statusCode, String body) =>
    decodeCallableResponse(statusCode, utf8.encode(body));

Matcher _throwsFunctionsException(
  String code, {
  Object? message = anything,
  Object? details = anything,
}) {
  return throwsA(
    isA<DartFirebaseFunctionsException>()
        .having((e) => e.code, 'code', code)
        .having((e) => e.message, 'message', message)
        .having((e) => e.details, 'details', details),
  );
}

void main() {
  group('callableEndpoint', () {
    test('resolves a name against production', () {
      final endpoint = callableEndpoint(
        projectId: 'my-project',
        region: 'europe-west1',
        name: 'listFruit',
      );

      expect(
        endpoint.toString(),
        'https://europe-west1-my-project.cloudfunctions.net/listFruit',
      );
    });

    test('resolves a name against the emulator origin', () {
      final endpoint = callableEndpoint(
        projectId: 'my-project',
        region: 'us-central1',
        name: 'listFruit',
        origin: 'http://localhost:5001',
      );

      expect(
        endpoint.toString(),
        'http://localhost:5001/my-project/us-central1/listFruit',
      );
    });

    test('uses an explicit URI as is, even with an emulator origin', () {
      final uri = Uri.parse('https://listfruits-abc123-uc.a.run.app');

      final endpoint = callableEndpoint(
        projectId: 'my-project',
        region: 'us-central1',
        uri: uri,
        origin: 'http://localhost:5001',
      );

      expect(endpoint, uri);
    });

    test('throws without a name or a URI', () {
      expect(
        () => callableEndpoint(projectId: 'my-project', region: 'us-central1'),
        throwsArgumentError,
      );
    });
  });

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
  });

  group('checkTokenTransport', () {
    const withToken = CallableContext(authToken: 'id-token');

    void check(String url, [CallableContext context = withToken]) =>
        checkTokenTransport(Uri.parse(url), context);

    test('allows tokens over HTTPS', () {
      expect(() => check('https://example.com/listFruit'), returnsNormally);
    });

    for (final host in ['localhost', '127.0.0.1', '[::1]', '10.0.2.2']) {
      test('allows tokens over HTTP to $host', () {
        expect(() => check('http://$host:5001/listFruit'), returnsNormally);
      });
    }

    test('refuses tokens over HTTP to any other host', () {
      expect(
        () => check('http://192.168.1.20:5001/listFruit'),
        _throwsFunctionsException('unauthenticated'),
      );
    });

    test('allows calls without tokens over HTTP to any host', () {
      expect(
        () => check('http://example.com/listFruit', const CallableContext()),
        returnsNormally,
      );
    });

    test('allows tokens over HTTP to any host with allowInsecure', () {
      expect(
        () => checkTokenTransport(
          Uri.parse('http://192.168.1.20:5001/listFruit'),
          withToken,
          allowInsecure: true,
        ),
        returnsNormally,
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
        _throwsFunctionsException('internal'),
      );
    });

    test('rejects a success response that is not JSON', () {
      expect(
        () => _decode(200, 'not json'),
        _throwsFunctionsException('internal'),
      );
    });

    test('maps an HttpsError envelope', () {
      expect(
        () => _decode(400, _invalidArgumentBody),
        _throwsFunctionsException(
          'invalid-argument',
          message: 'Invalid test requested.',
          details: isNull,
        ),
      );
    });

    test('passes through error details', () {
      expect(
        () => _decode(499, _cancelledWithDetailsBody),
        _throwsFunctionsException('cancelled', details: 1234),
      );
    });

    test('falls back to the HTTP status for a non-JSON error body', () {
      expect(
        () => _decode(404, _unknownFunctionBody),
        _throwsFunctionsException('not-found'),
      );
    });

    test('maps an empty 503 to unavailable', () {
      expect(() => _decode(503, ''), _throwsFunctionsException('unavailable'));
    });

    test('maps an unexpected HTTP status to unknown', () {
      expect(() => _decode(418, ''), _throwsFunctionsException('unknown'));
    });

    test('maps an undefined canonical status to internal', () {
      expect(
        () => _decode(400, '{"error":{"status":"NOT_A_STATUS"}}'),
        _throwsFunctionsException('internal'),
      );
    });
  });

  group('callableContextException', () {
    test('describes errors other than FirebaseException', () {
      final exception = callableContextException(StateError('No token.'));

      expect(exception.code, 'unknown');
      expect(exception.message, 'Bad state: No token.');
    });
  });
}
