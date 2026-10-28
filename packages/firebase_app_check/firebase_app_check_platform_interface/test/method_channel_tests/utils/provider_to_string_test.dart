// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_app_check_platform_interface/src/android_providers.dart';
import 'package:firebase_app_check_platform_interface/src/apple_providers.dart';
import 'package:firebase_app_check_platform_interface/src/method_channel/utils/provider_to_string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getAndroidProviderString', () {
    test('returns the provider type', () {
      expect(
        getAndroidProviderString(const AndroidPlayIntegrityProvider()),
        'playIntegrity',
      );
      expect(getAndroidProviderString(const AndroidDebugProvider()), 'debug');
    });

    test('returns playIntegrity when no provider is provided', () {
      expect(getAndroidProviderString(null), 'playIntegrity');
    });
  });

  group('getAppleProviderString', () {
    test('returns the provider type', () {
      expect(
        getAppleProviderString(const AppleDeviceCheckProvider()),
        'deviceCheck',
      );
      expect(getAppleProviderString(const AppleDebugProvider()), 'debug');
      expect(
        getAppleProviderString(const AppleAppAttestProvider()),
        'appAttest',
      );
      expect(
        getAppleProviderString(
          const AppleAppAttestWithDeviceCheckFallbackProvider(),
        ),
        'appAttestWithDeviceCheckFallback',
      );
    });

    test('returns deviceCheck when no provider is provided', () {
      expect(getAppleProviderString(null), 'deviceCheck');
    });
  });
}
