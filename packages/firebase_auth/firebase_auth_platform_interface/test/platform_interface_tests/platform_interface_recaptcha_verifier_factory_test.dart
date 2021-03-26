// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  group('$RecaptchaVerifierFactoryPlatform()', () {
    late TestRecaptchaVerifierFactoryPlatform recaptchaVerifierFactoryPlatform;

    setUpAll(() async {
      recaptchaVerifierFactoryPlatform = TestRecaptchaVerifierFactoryPlatform();
    });

    test('Constructor', () {
      expect(
        recaptchaVerifierFactoryPlatform,
        isA<RecaptchaVerifierFactoryPlatform>(),
      );
      expect(
        recaptchaVerifierFactoryPlatform,
        isA<PlatformInterface>(),
      );
    });

    group('set.instance', () {
      test('sets current instance', () {
        // should not throw
        RecaptchaVerifierFactoryPlatform.instance =
            recaptchaVerifierFactoryPlatform;
      });
    });

    test('get.instance', () {
      RecaptchaVerifierFactoryPlatform.instance =
          recaptchaVerifierFactoryPlatform;
      final result = RecaptchaVerifierFactoryPlatform.instance;

      expect(result, isA<RecaptchaVerifierFactoryPlatform>());
    });

    group('verifyExtends()', () {
      test('calls successfully', () {
        RecaptchaVerifierFactoryPlatform.verifyExtends(
          recaptchaVerifierFactoryPlatform,
        );
      });
    });

    test('throws if delegate', () async {
      expect(
        () => recaptchaVerifierFactoryPlatform.delegate,
        throwsUnimplementedError,
      );
    });

    group('delegateFor()', () {
      test('throws UnimplementedError error', () async {
        expect(
          () => recaptchaVerifierFactoryPlatform.delegateFor(),
          throwsUnimplementedError,
        );
      });
    });

    test('throws if type', () async {
      expect(
        () => recaptchaVerifierFactoryPlatform.type,
        throwsUnimplementedError,
      );
    });

    test('throws if clear()', () async {
      expect(
        () => recaptchaVerifierFactoryPlatform.clear(),
        throwsUnimplementedError,
      );
    });

    test('throws if render()', () async {
      await expectLater(
        () => recaptchaVerifierFactoryPlatform.render(),
        throwsUnimplementedError,
      );
    });

    test('throws if verify()', () async {
      await expectLater(
        () => recaptchaVerifierFactoryPlatform.verify(),
        throwsUnimplementedError,
      );
    });
  });
}

class TestRecaptchaVerifierFactoryPlatform
    extends RecaptchaVerifierFactoryPlatform {
  TestRecaptchaVerifierFactoryPlatform() : super();
}
