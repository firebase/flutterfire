// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dart_cloud_functions/src/firebase_callable_context.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appCheckTokenOrPlaceholder', () {
    test('returns the token', () async {
      final token =
          await appCheckTokenOrPlaceholder(() async => 'app-check-token');

      expect(token, 'app-check-token');
    });

    test('returns the placeholder instead of throwing when fetching fails',
        () async {
      final token = await appCheckTokenOrPlaceholder(
        () async => throw FirebaseException(
          plugin: 'firebase_app_check',
          code: 'unknown',
          message: 'Too many attempts.',
        ),
      );

      expect(token, placeholderAppCheckToken);
    });
  });

  test('placeholderAppCheckToken matches the native SDKs', () {
    expect(
      utf8.decode(base64.decode(placeholderAppCheckToken)),
      '{"error":"UNKNOWN_ERROR"}',
    );
  });
}
