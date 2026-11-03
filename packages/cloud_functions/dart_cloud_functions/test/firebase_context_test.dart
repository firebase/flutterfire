// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dart_cloud_functions/src/firebase_context.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('idTokenOrNullOnWeb', () {
    Future<String?> failingGetToken() async => throw FirebaseException(
      plugin: 'firebase_auth',
      code: 'network-request-failed',
    );

    test('returns the token', () async {
      expect(await idTokenOrNullOnWeb(() async => 'id-token'), 'id-token');
    });

    test('rethrows a failure on Android and Apple', () async {
      await expectLater(
        idTokenOrNullOnWeb(failingGetToken, onWeb: false),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('returns null on web when fetching fails', () async {
      expect(await idTokenOrNullOnWeb(failingGetToken, onWeb: true), isNull);
    });
  });

  group('appCheckTokenOrFallback', () {
    Future<String?> failingGetToken() async => throw FirebaseException(
      plugin: 'firebase_app_check',
      code: 'unknown',
      message: 'Too many attempts.',
    );

    test('returns the token', () async {
      final token = await appCheckTokenOrFallback(
        () async => 'app-check-token',
      );

      expect(token, 'app-check-token');
    });

    test(
      'returns the placeholder on Android and Apple when fetching fails',
      () async {
        final token = await appCheckTokenOrFallback(
          failingGetToken,
          onWeb: false,
        );

        expect(token, placeholderAppCheckToken);
      },
    );

    test('returns null on web when fetching fails', () async {
      final token = await appCheckTokenOrFallback(failingGetToken, onWeb: true);

      expect(token, isNull);
    });
  });

  test('placeholderAppCheckToken matches the native SDKs', () {
    expect(
      utf8.decode(base64.decode(placeholderAppCheckToken)),
      '{"error":"UNKNOWN_ERROR"}',
    );
  });
}
