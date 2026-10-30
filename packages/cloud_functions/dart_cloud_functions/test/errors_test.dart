// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dart_cloud_functions/dart_cloud_functions.dart';
import 'package:dart_cloud_functions/src/errors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// Error bodies captured from the Cloud Functions emulator
// (firebase-tools 14.9.0) for the e2e backend in
// .github/workflows/scripts/functions/src/index.ts.
const _invalidArgumentBody =
    '{"error":{"message":"Invalid test requested.","status":"INVALID_ARGUMENT"}}';
const _cancelledWithDetailsBody =
    '{"error":{"details":1234,"message":"Response data was requested to be '
    'sent as part of an Error payload, so here we are!","status":"CANCELLED"}}';

Matcher _isFunctionsException(
  String code, {
  Object? message = anything,
  Object? details = anything,
}) {
  return isA<DartFirebaseFunctionsException>()
      .having((e) => e.code, 'code', code)
      .having((e) => e.message, 'message', message)
      .having((e) => e.details, 'details', details);
}

void main() {
  group('callableErrorForResponse', () {
    test('returns null for a success', () {
      expect(callableErrorForResponse(200, {'result': 1}), isNull);
    });

    test('maps an HttpsError envelope', () {
      expect(
        callableErrorForResponse(400, jsonDecode(_invalidArgumentBody)),
        _isFunctionsException(
          'invalid-argument',
          message: 'Invalid test requested.',
          details: isNull,
        ),
      );
    });

    test('passes through error details', () {
      expect(
        callableErrorForResponse(499, jsonDecode(_cancelledWithDetailsBody)),
        _isFunctionsException('cancelled', details: 1234),
      );
    });

    test('falls back to the HTTP status without an error object', () {
      expect(
        callableErrorForResponse(404, null),
        _isFunctionsException('not-found'),
      );
    });

    test('maps 503 to unavailable', () {
      expect(
        callableErrorForResponse(503, null),
        _isFunctionsException('unavailable'),
      );
    });

    test('maps 409 to aborted', () {
      expect(
        callableErrorForResponse(409, null),
        _isFunctionsException('aborted'),
      );
    });

    test('maps an unexpected HTTP status to unknown', () {
      expect(
        callableErrorForResponse(418, null),
        _isFunctionsException('unknown'),
      );
    });

    test('maps an undefined canonical status to internal', () {
      expect(
        callableErrorForResponse(400, {
          'error': {'status': 'NOT_A_STATUS'},
        }),
        _isFunctionsException('internal'),
      );
    });
  });

  group('callableErrorForResponse on Apple platforms', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    for (final platform in [TargetPlatform.iOS, TargetPlatform.macOS]) {
      test(
        'maps 409 to already-exists on ${platform.name}',
        () {
          debugDefaultTargetPlatformOverride = platform;

          expect(
            callableErrorForResponse(409, null),
            _isFunctionsException('already-exists'),
          );
        },
        testOn: 'vm',
      );

      test(
        'maps an unexpected HTTP status to internal on ${platform.name}',
        () {
          debugDefaultTargetPlatformOverride = platform;

          expect(
            callableErrorForResponse(418, null),
            _isFunctionsException('internal'),
          );
        },
        testOn: 'vm',
      );
    }

    test(
      'keeps the Android and JS codes on web, even in an iOS browser',
      () {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        expect(
          callableErrorForResponse(409, null),
          _isFunctionsException('aborted'),
        );
        expect(
          callableErrorForResponse(418, null),
          _isFunctionsException('unknown'),
        );
      },
      testOn: 'browser',
    );
  });

  group('callableTokenException', () {
    test('describes errors other than FirebaseException', () {
      final exception = callableTokenException(StateError('No token.'));

      expect(exception.code, 'unknown');
      expect(exception.message, 'Bad state: No token.');
    });
  });
}
