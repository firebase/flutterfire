// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _channel = MethodChannel('plugins.flutter.io/firebase_ai');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('firebase_ai', () {
    group('platform security headers', () {
      testWidgets(
        'returns non-empty headers on mobile platforms',
        skip: kIsWeb,
        (WidgetTester tester) async {
          final headers = await _channel.invokeMapMethod<String, String>(
            'getPlatformHeaders',
          );

          expect(
            headers,
            isNotNull,
            reason: 'Native plugin should return platform headers',
          );
          expect(
            headers,
            isNotEmpty,
            reason: 'Native plugin should return non-empty platform headers',
          );
        },
      );

      testWidgets(
        'returns correct Android headers',
        skip: kIsWeb || defaultTargetPlatform != TargetPlatform.android,
        (WidgetTester tester) async {
          final headers = await _channel.invokeMapMethod<String, String>(
            'getPlatformHeaders',
          );

          expect(headers, isNotNull);
          expect(headers, contains('X-Android-Package'));
          expect(
            headers!['X-Android-Package'],
            isNotEmpty,
            reason: 'Package name should not be empty',
          );
          // Cert may be empty in some emulator environments, but key must exist.
          expect(headers, contains('X-Android-Cert'));
        },
      );

      testWidgets(
        'returns correct iOS/macOS headers',
        skip: kIsWeb ||
            (defaultTargetPlatform != TargetPlatform.iOS &&
                defaultTargetPlatform != TargetPlatform.macOS),
        (WidgetTester tester) async {
          final headers = await _channel.invokeMapMethod<String, String>(
            'getPlatformHeaders',
          );

          expect(headers, isNotNull);
          expect(headers, contains('x-ios-bundle-identifier'));
          expect(
            headers!['x-ios-bundle-identifier'],
            isNotEmpty,
            reason: 'Bundle identifier should not be empty',
          );
        },
      );

      testWidgets(
        'returns empty headers on web',
        skip: !kIsWeb,
        (WidgetTester tester) async {
          // On web, no native plugin is registered, so the channel call
          // should throw a MissingPluginException.
          expect(
            () => _channel.invokeMapMethod<String, String>(
              'getPlatformHeaders',
            ),
            throwsA(isA<MissingPluginException>()),
          );
        },
      );
    });
  });
}
