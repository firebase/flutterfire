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

      try {
        throw convertPlatformException(assertionError);
      } on FirebaseException catch (_) {
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
      } on FirebaseException catch (_) {
        return;
      } catch (_) {
        fail('should have thrown an FirebaseCrashlyticsException');
      }
    });
  });
}
