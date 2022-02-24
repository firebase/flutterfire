// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_crashlytics_platform_interface/src/method_channel/utils/exception.dart';
import 'package:flutter/services.dart';

void main() {
  group('catchPlatformException()', () {
    test('should throw any exception', () async {
      AssertionError assertionError = AssertionError();

      expect(
        () => convertPlatformException(assertionError, StackTrace.empty),
        throwsA(assertionError),
      );
    });

    test('should catch a [PlatformException] and throw a [FirebaseException]',
        () async {
      PlatformException platformException = PlatformException(code: 'UNKNOWN');

      expect(
        () => convertPlatformException(platformException, StackTrace.empty),
        throwsA(
          isA<FirebaseException>().having((e) => e.code, 'code', 'unknown'),
        ),
      );
    });
  });
}
