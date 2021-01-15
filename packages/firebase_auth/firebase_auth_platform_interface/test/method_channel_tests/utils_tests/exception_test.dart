// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/utils/exception.dart';
import 'package:flutter/services.dart';

void main() {
  group('catchPlatformException()', () {
    test('should throw any exception', () async {
      AssertionError assertionError = AssertionError();

      try {
        throw convertPlatformException(assertionError);
      } on FirebaseAuthException catch (_) {
        fail('should have thrown the original exception');
      } catch (_) {
        return;
      }
    });

    test('should catch a [PlatformException] and throw a [FirebaseException]',
        () async {
      PlatformException platformException = PlatformException(code: 'UNKNOWN');
      try {
        throw convertPlatformException(platformException);
      } on FirebaseAuthException catch (_) {
        return;
      } catch (_) {
        fail('should have thrown an FirebaseAuthException');
      }
    });
  });
  group('platformExceptionToFirebaseAuthException()', () {
    test('sets code to default value', () {
      AuthCredential authCredential = const AuthCredential(
        providerId: 'testProviderId',
        signInMethod: 'email',
        token: 1,
      );

      PlatformException platformException = PlatformException(
          code: 'native',
          message: 'PlatformException Message',
          details: {
            'additionalData': {'authCredential': authCredential.asMap()}
          });

      FirebaseAuthException result =
          platformExceptionToFirebaseAuthException(platformException)
              as FirebaseAuthException;
      expect(result.code, equals('unknown'));
      expect(result.message, equals('PlatformException Message'));
      expect(result.email, isNull);

      expect(result.credential, isA<AuthCredential>());
      expect(result.credential!.providerId, equals(authCredential.providerId));
      expect(result.credential!.token, equals(authCredential.token));
      expect(
        result.credential!.signInMethod,
        equals(authCredential.signInMethod),
      );
    });

    test('sets correct values from additionalData', () {
      AuthCredential authCredential = EmailAuthProvider.credential(
          email: 'test@email.com', password: 'testPassword');

      PlatformException platformException =
          PlatformException(code: 'native', message: 'a message', details: {
        'code': 'A Known Code',
        'message': 'A Known Message',
        'additionalData': {
          'email': 'test@email.com',
          'authCredential': authCredential.asMap(),
        }
      });

      FirebaseAuthException result =
          platformExceptionToFirebaseAuthException(platformException)
              as FirebaseAuthException;
      expect(result.code, equals('A Known Code'));
      expect(result.message, equals('A Known Message'));
      expect(result.email, 'test@email.com');

      expect(result.credential, isA<AuthCredential>());
      expect(result.credential!.providerId, equals(authCredential.providerId));
      expect(result.credential!.token, equals(authCredential.token));
      expect(
          result.credential!.signInMethod, equals(authCredential.signInMethod));
    });

    test('details = null', () {
      PlatformException platformException = PlatformException(
        code: 'native',
        message: 'a message',
      );

      FirebaseAuthException result =
          platformExceptionToFirebaseAuthException(platformException)
              as FirebaseAuthException;
      expect(result.code, equals('unknown'));
      expect(result.message, equals('a message'));
      expect(result.email, null);

      expect(result.credential, isNull);
    });

    test('additionalData = null', () {
      PlatformException platformException = PlatformException(
          code: 'native',
          message: 'a message',
          details: {'additionalData': null});

      FirebaseAuthException result =
          platformExceptionToFirebaseAuthException(platformException)
              as FirebaseAuthException;
      expect(result.code, equals('unknown'));
      expect(result.message, equals('a message'));
      expect(result.email, isNull);

      expect(result.credential, isNull);
    });

    test('authCredential = null', () {
      PlatformException platformException = PlatformException(
        code: 'native',
        message: 'a message',
        details: {
          'code': 'A Known Code',
          'message': 'A Known Message',
          'additionalData': {'email': 'test@email.com'}
        },
      );

      FirebaseAuthException result =
          platformExceptionToFirebaseAuthException(platformException)
              as FirebaseAuthException;
      expect(result.code, equals('A Known Code'));
      expect(result.message, equals('A Known Message'));
      expect(result.email, 'test@email.com');

      expect(result.credential, isNull);
    });
  });
}
