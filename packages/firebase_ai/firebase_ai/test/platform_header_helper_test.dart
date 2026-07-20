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

import 'package:firebase_ai/src/platform_header_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(clearPlatformSecurityHeadersCache);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platformHeaderChannel, null);
  });

  group('getPlatformSecurityHeaders', () {
    test('returns headers from native plugin', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platformHeaderChannel,
              (MethodCall methodCall) async {
        if (methodCall.method == 'getPlatformHeaders') {
          return <String, String>{
            'X-Android-Package': 'com.example.test',
            'X-Android-Cert': 'AABBCCDD',
          };
        }
        return null;
      });

      final headers = await getPlatformSecurityHeaders();

      expect(headers['X-Android-Package'], 'com.example.test');
      expect(headers['X-Android-Cert'], 'AABBCCDD');
      expect(headers.length, 2);
    });

    test('returns iOS bundle identifier from native plugin', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platformHeaderChannel,
              (MethodCall methodCall) async {
        if (methodCall.method == 'getPlatformHeaders') {
          return <String, String>{
            'x-ios-bundle-identifier': 'com.example.iosapp',
          };
        }
        return null;
      });

      final headers = await getPlatformSecurityHeaders();

      expect(headers['x-ios-bundle-identifier'], 'com.example.iosapp');
      expect(headers.length, 1);
    });

    test('caches result across calls', () async {
      var callCount = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platformHeaderChannel,
              (MethodCall methodCall) async {
        callCount++;
        return <String, String>{
          'X-Android-Package': 'com.example.test',
          'X-Android-Cert': 'AABBCCDD',
        };
      });

      await getPlatformSecurityHeaders();
      await getPlatformSecurityHeaders();
      await getPlatformSecurityHeaders();

      expect(callCount, 1);
    });

    test('returns empty map when native plugin is not available', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platformHeaderChannel,
              (MethodCall methodCall) async {
        throw MissingPluginException();
      });

      final headers = await getPlatformSecurityHeaders();

      expect(headers, isEmpty);
    });

    test('returns empty map when native plugin returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platformHeaderChannel,
              (MethodCall methodCall) async {
        return null;
      });

      final headers = await getPlatformSecurityHeaders();

      expect(headers, isEmpty);
    });
  });
}
