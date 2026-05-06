// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/firebase_ai'),
          (MethodCall call) async {
    if (call.method == 'getPlatformHeaders') {
      return <String, String>{
        'X-Android-Package': 'com.example.test',
        'X-Android-Cert': '12345',
        'x-ios-bundle-identifier': 'com.example.test',
      };
    }
    return null;
  });

  group('platform security headers', () {
    const _channel = MethodChannel('plugins.flutter.io/firebase_ai');
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
}
