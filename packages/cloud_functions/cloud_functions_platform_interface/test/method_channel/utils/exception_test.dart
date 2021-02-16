// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions_platform_interface/src/firebase_functions_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/utils/exception.dart';
import 'package:flutter/services.dart';

void main() {
  final Map<String, dynamic> testAdditionalData = <String, dynamic>{
    'foo': 'bar',
  };
  const String testMessage = 'PlatformException Message';
  group('catchPlatformException()', () {
    test('should throw any exception', () async {
      AssertionError assertionError = AssertionError();

      try {
        await catchPlatformException(assertionError);
      } on FirebaseFunctionsException catch (_) {
        fail('should have thrown the original exception');
        // ignore: avoid_catching_errors, in this instance we want to do this
      } on AssertionError catch (_) {
        return;
      } catch (e) {
        fail('should have thrown an Exception and not a ${e.runtimeType}');
      }

      fail('should have thrown an exception');
    });

    test('should catch a [PlatformException] and throw a [FirebaseException]',
        () async {
      PlatformException platformException = PlatformException(
          code: 'UNKNOWN',
          message: testMessage,
          details: {'additionalData': testAdditionalData});
      try {
        await catchPlatformException(platformException);
      } on FirebaseFunctionsException catch (_) {
        return;
      } catch (e) {
        fail(
            'should have thrown an FirebaseFunctionsException and not a ${e.runtimeType}');
      }

      fail('should have thrown an exception');
    });
  });

  group('platformExceptionToFirebaseFunctionsException()', () {
    test('sets code to default value', () {
      PlatformException platformException = PlatformException(
          code: 'native',
          message: testMessage,
          details: {'additionalData': testAdditionalData});

      FirebaseFunctionsException result =
          platformExceptionToFirebaseFunctionsException(platformException)
              as FirebaseFunctionsException;
      expect(result.code, 'unknown');
      expect(result.message, testMessage);

      expect(result.details, isA<Map<String, dynamic>>());
      expect(result.details['foo'], testAdditionalData['foo']);
    });

    test('details = null', () {
      PlatformException platformException =
          PlatformException(code: 'native', message: testMessage);

      FirebaseFunctionsException result =
          platformExceptionToFirebaseFunctionsException(platformException)
              as FirebaseFunctionsException;
      expect(result.code, 'unknown');
      expect(result.message, testMessage);
      expect(result.details, isNull);
    });

    test('additionalData = null', () {
      PlatformException platformException = PlatformException(
          code: 'native',
          message: testMessage,
          details: {'additionalData': null});

      FirebaseFunctionsException result =
          platformExceptionToFirebaseFunctionsException(platformException)
              as FirebaseFunctionsException;
      expect(result.code, 'unknown');
      expect(result.message, testMessage);
      expect(result.details, isNull);
    });
  });
}
