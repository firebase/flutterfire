// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$AppCheckTokenResult', () {
    final expirationTime = DateTime.fromMillisecondsSinceEpoch(1234567890);
    final result = AppCheckTokenResult(
      token: 'test-token',
      expirationTime: expirationTime,
    );

    test('exposes token metadata', () {
      expect(result.token, 'test-token');
      expect(result.expirationTime, expirationTime);
    });

    test('supports unavailable expiration metadata', () {
      const result = AppCheckTokenResult(token: 'test-token');

      expect(result.expirationTime, isNull);
    });

    test('toString()', () {
      expect(
        result.toString(),
        '$AppCheckTokenResult(token: test-token, expirationTime: $expirationTime)',
      );
    });
  });
}
