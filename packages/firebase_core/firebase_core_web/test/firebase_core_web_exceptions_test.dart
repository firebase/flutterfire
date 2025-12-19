// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('no default app', () {
    setUp(() async {
      FirebasePlatform.instance = FirebaseCoreWeb();
    });

    test(
        'should throw exception if no default app is available & no options are provided',
        () async {
      await expectLater(
        FirebasePlatform.instance.initializeApp,
        throwsAssertionError,
      );
    });
  });

  group('.initializeApp()', () {
    setUp(() async {
      FirebasePlatform.instance = FirebaseCoreWeb();
    });

    group('secondary apps', () {
      test('should throw exception if no options are provided with a named app',
          () async {
        await expectLater(
          () => FirebasePlatform.instance.initializeApp(name: 'foo'),
          throwsAssertionError,
        );
      });
    });
  });

  group('apps getter', () {
    setUp(() async {
      FirebasePlatform.instance = FirebaseCoreWeb();
    });

    test('should return empty list when Firebase is not initialized', () {
      expect(FirebasePlatform.instance.apps, isEmpty);
    });
  });
}
