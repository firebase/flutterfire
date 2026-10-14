// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config_platform_interface/src/method_channel/utils/error_code.dart';
import 'package:firebase_remote_config_platform_interface/src/method_channel/utils/exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('refineRemoteConfigErrorCode', () {
    test('classifies a missing data connection as a network error', () {
      // Android, through `FirebaseRemoteConfigClientException`.
      expect(
        refineRemoteConfigErrorCode(
          'internal',
          'A data connection is not currently allowed.',
        ),
        'network-error',
      );
      expect(
        refineRemoteConfigErrorCode(
          'internal',
          'Failed to get installations token. A data connection is not '
              'currently allowed.',
        ),
        'network-error',
      );
    });

    test('classifies other connectivity failures as a network error', () {
      for (final String message in <String>[
        'Fetch failed: Unable to resolve host "firebaseremoteconfig.googleapis.com"',
        'The request timed out.',
        'The Internet connection appears to be offline.',
        'Network error (such as timeout or unreachable host) has occurred.',
      ]) {
        expect(
          refineRemoteConfigErrorCode('internal', message),
          'network-error',
          reason: message,
        );
      }
    });

    test('classifies a cancelled fetch', () {
      expect(refineRemoteConfigErrorCode('internal', 'cancelled'), 'cancelled');
      expect(refineRemoteConfigErrorCode('unknown', 'Canceled'), 'cancelled');
    });

    test('classifies a backend status code', () {
      expect(
        refineRemoteConfigErrorCode(
          'internal',
          'Internal Error. Status code: 503',
        ),
        'remote-config-server-error',
      );
      expect(
        refineRemoteConfigErrorCode(
          'internal',
          'Internal Error. Status code: 403',
        ),
        'forbidden',
      );
      expect(
        refineRemoteConfigErrorCode(
          'internal',
          'Internal Error. Status code: 429',
        ),
        'throttled',
      );
    });

    test('leaves an informative status code alone', () {
      expect(
        refineRemoteConfigErrorCode('internal', 'Status code: 200'),
        'internal',
      );
    });

    test('leaves codes the native SDKs classified alone', () {
      expect(
        refineRemoteConfigErrorCode(
          'throttled',
          'frequency of requests exceeds throttled limits',
        ),
        'throttled',
      );
      expect(
        refineRemoteConfigErrorCode(
          'forbidden',
          'A data connection is not currently allowed.',
        ),
        'forbidden',
      );
    });

    test('leaves a message it cannot classify alone', () {
      expect(
        refineRemoteConfigErrorCode(
          'internal',
          'internal remote config fetch error',
        ),
        'internal',
      );
      expect(refineRemoteConfigErrorCode('internal', null), 'internal');
      expect(refineRemoteConfigErrorCode(null, 'cancelled'), 'unknown');
    });
  });

  group('convertPlatformException', () {
    test('throws a FirebaseException with the refined code', () {
      expect(
        () => convertPlatformException(
          PlatformException(
            code: 'firebase_remote_config',
            message: 'A data connection is not currently allowed.',
            details: <String, Object?>{
              'code': 'internal',
              'message': 'A data connection is not currently allowed.',
            },
          ),
          StackTrace.empty,
        ),
        throwsA(
          isA<FirebaseException>()
              .having((e) => e.plugin, 'plugin', 'firebase_remote_config')
              .having((e) => e.code, 'code', 'network-error')
              .having(
                (e) => e.message,
                'message',
                'A data connection is not currently allowed.',
              ),
        ),
      );
    });

    test('keeps the code the native SDK reported', () {
      expect(
        () => convertPlatformException(
          PlatformException(
            code: 'firebase_remote_config',
            message: 'frequency of requests exceeds throttled limits',
            details: <String, Object?>{
              'code': 'throttled',
              'message': 'frequency of requests exceeds throttled limits',
            },
          ),
          StackTrace.empty,
        ),
        throwsA(
          isA<FirebaseException>().having((e) => e.code, 'code', 'throttled'),
        ),
      );
    });

    test('rethrows anything that is not a PlatformException', () {
      final error = StateError('nope');

      expect(
        () => convertPlatformException(error, StackTrace.empty),
        throwsA(same(error)),
      );
    });
  });
}
