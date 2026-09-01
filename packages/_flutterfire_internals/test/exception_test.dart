// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('platformExceptionToFirebaseException', () {
    test('reads the code and message from a details map', () {
      final exception = platformExceptionToFirebaseException(
        PlatformException(
          code: 'firebase_database',
          message: 'a channel level message',
          details: {
            'code': 'permission-denied',
            'message':
                "Client doesn't have permission to access the desired "
                'data.',
          },
        ),
        plugin: 'firebase_database',
      );

      expect(exception.plugin, 'firebase_database');
      expect(exception.code, 'permission-denied');
      expect(
        exception.message,
        "Client doesn't have permission to access the desired data.",
      );
    });

    test('keeps the platform message when details omit one', () {
      final exception = platformExceptionToFirebaseException(
        PlatformException(
          code: 'firebase_database',
          message: 'a channel level message',
          details: {'code': 'permission-denied'},
        ),
        plugin: 'firebase_database',
      );

      expect(exception.code, 'permission-denied');
      expect(exception.message, 'a channel level message');
    });

    // Regression test for https://github.com/firebase/flutterfire/issues/18550:
    // the Windows plugins send the native code as `PlatformException.code` with
    // no details payload, and it used to be dropped in favour of `unknown`.
    test('falls back to PlatformException.code when there are no details', () {
      final exception = platformExceptionToFirebaseException(
        PlatformException(
          code: 'permission-denied',
          message: "Client doesn't have permission to access the desired data.",
        ),
        plugin: 'firebase_database',
      );

      expect(exception.code, 'permission-denied');
      expect(
        exception.message,
        "Client doesn't have permission to access the desired data.",
      );
    });

    test('normalises the casing of a PlatformException.code fallback', () {
      // Keeps a native `UNKNOWN` reporting as the documented `unknown`, the
      // same normalisation the auth converter applies to this field.
      final exception = platformExceptionToFirebaseException(
        PlatformException(code: 'PERMISSION_DENIED', message: 'denied'),
        plugin: 'firebase_database',
      );

      expect(exception.code, 'permission-denied');

      expect(
        platformExceptionToFirebaseException(
          PlatformException(code: 'UNKNOWN'),
          plugin: 'firebase_crashlytics',
        ).code,
        'unknown',
      );
    });

    test('ignores PlatformException.code when details are present', () {
      // Pigeon's generic error path sends the exception class name as the code
      // and a stack trace as the details, so a details payload without a code
      // means there is no Firebase code to report.
      final exception = platformExceptionToFirebaseException(
        PlatformException(
          code: 'DatabaseException',
          message: 'Firebase Database error: Permission denied',
          details: 'a stack trace',
        ),
        plugin: 'firebase_database',
      );

      expect(exception.code, 'unknown');
      expect(exception.message, 'a stack trace');
    });

    test('prefers the details code over PlatformException.code', () {
      final exception = platformExceptionToFirebaseException(
        PlatformException(
          code: 'firebase_database',
          details: {'code': 'permission-denied'},
        ),
        plugin: 'firebase_database',
      );

      expect(exception.code, 'permission-denied');
    });

    test('does not report the plugin name as a code', () {
      // The Android and Windows Pigeon APIs put the plugin name in
      // `PlatformException.code` as a channel-level marker.
      final exception = platformExceptionToFirebaseException(
        PlatformException(
          code: 'firebase_database',
          message: 'Firebase Database error: Permission denied',
        ),
        plugin: 'firebase_database',
      );

      expect(exception.code, 'unknown');
      expect(exception.message, 'Firebase Database error: Permission denied');
    });

    test('falls back to unknown when no code is available at all', () {
      final exception = platformExceptionToFirebaseException(
        PlatformException(code: '', message: 'no code anywhere'),
        plugin: 'firebase_database',
      );

      expect(exception.code, 'unknown');
      expect(exception.message, 'no code anywhere');
    });

    test('stringifies non-map details into the message', () {
      final exception = platformExceptionToFirebaseException(
        PlatformException(code: 'unavailable', details: 'a string detail'),
        plugin: 'firebase_database',
      );

      expect(exception.code, 'unknown');
      expect(exception.message, 'a string detail');
    });
  });

  group('convertPlatformExceptionToFirebaseException', () {
    test('converts a PlatformException and preserves the stack trace', () {
      final stackTrace = StackTrace.current;

      try {
        convertPlatformExceptionToFirebaseException(
          PlatformException(code: 'permission-denied', message: 'denied'),
          stackTrace,
          plugin: 'firebase_database',
        );
      } on FirebaseException catch (error, stack) {
        expect(error.code, 'permission-denied');
        expect(error.message, 'denied');
        expect(stack, stackTrace);
      }
    });

    test('rethrows exceptions that are not PlatformExceptions', () {
      final error = StateError('not a platform exception');

      expect(
        () => convertPlatformExceptionToFirebaseException(
          error,
          StackTrace.current,
          plugin: 'firebase_database',
        ),
        throwsA(same(error)),
      );
    });
  });
}
