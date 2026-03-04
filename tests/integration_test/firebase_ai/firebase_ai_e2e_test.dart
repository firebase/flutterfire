// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:firebase_ai/src/platform_header_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('firebase_ai', () {
    group('platform security headers', () {
      testWidgets('returns non-empty headers on mobile platforms',
          (WidgetTester tester) async {
        final headers = await getPlatformSecurityHeaders();

        expect(headers, isNotEmpty,
            reason: 'Native plugin should return platform headers');
      });

      testWidgets('returns correct Android headers',
          (WidgetTester tester) async {
        if (!Platform.isAndroid) return;

        final headers = await getPlatformSecurityHeaders();

        expect(headers, contains('X-Android-Package'));
        expect(headers['X-Android-Package'], isNotEmpty,
            reason: 'Package name should not be empty');
        // Cert may be empty in some emulator environments, but key must exist.
        expect(headers, contains('X-Android-Cert'));
      });

      testWidgets('returns correct iOS/macOS headers',
          (WidgetTester tester) async {
        if (!Platform.isIOS && !Platform.isMacOS) return;

        final headers = await getPlatformSecurityHeaders();

        expect(headers, contains('x-ios-bundle-identifier'));
        expect(headers['x-ios-bundle-identifier'], isNotEmpty,
            reason: 'Bundle identifier should not be empty');
      });

      testWidgets('caches headers across calls',
          (WidgetTester tester) async {
        final headers1 = await getPlatformSecurityHeaders();
        final headers2 = await getPlatformSecurityHeaders();

        expect(identical(headers1, headers2), isTrue,
            reason: 'Headers should be cached after first call');
      });
    });
  });
}
