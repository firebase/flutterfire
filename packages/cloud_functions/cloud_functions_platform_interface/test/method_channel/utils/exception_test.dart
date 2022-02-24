// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions_platform_interface/src/firebase_functions_exception.dart';
import 'package:cloud_functions_platform_interface/src/method_channel/utils/exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Map<String, dynamic> testAdditionalData = <String, dynamic>{
    'foo': 'bar',
  };
  const String testMessage = 'PlatformException Message';
  group('convertPlatformException()', () {
    test('should throw any exception', () async {
      AssertionError assertionError = AssertionError();

      expect(
        () => convertPlatformException(assertionError, StackTrace.empty),
        throwsA(isA<AssertionError>()),
      );
    });

    test(
        'should catch a [PlatformException] and throw a [FirebaseFunctionsException]',
        () async {
      PlatformException platformException = PlatformException(
        code: 'foo',
        message: testMessage,
      );

      expect(
        () => convertPlatformException(platformException, StackTrace.empty),
        throwsA(
          isA<FirebaseFunctionsException>()
              .having((e) => e.code, 'code', 'unknown')
              .having((e) => e.message, 'message', testMessage)
              .having((e) => e.details, 'details', isNull),
        ),
      );
    });

    test('should override code and message if provided to additional details',
        () async {
      String code = 'baz';
      PlatformException platformException = PlatformException(
          code: 'foo',
          message: 'bar',
          details: {'code': code, 'message': testMessage});

      expect(
        () => convertPlatformException(platformException, StackTrace.empty),
        throwsA(
          isA<FirebaseFunctionsException>()
              .having((e) => e.code, 'code', code)
              .having((e) => e.message, 'message', testMessage)
              .having((e) => e.details, 'details', isNull),
        ),
      );
    });

    test('should provide additionalData as details', () async {
      PlatformException platformException = PlatformException(
          code: 'UNKNOWN',
          message: testMessage,
          details: {'additionalData': testAdditionalData});

      expect(
        () => convertPlatformException(platformException, StackTrace.empty),
        throwsA(
          isA<FirebaseFunctionsException>()
              .having((e) => e.code, 'code', 'unknown')
              .having((e) => e.message, 'message', testMessage)
              .having(
                  (e) => e.details,
                  'details',
                  isA<Map<String, dynamic>>()
                      .having((e) => e['foo'], 'additionalData', 'bar')),
        ),
      );
    });
  });
}
