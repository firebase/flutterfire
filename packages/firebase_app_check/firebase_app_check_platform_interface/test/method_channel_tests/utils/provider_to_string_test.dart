// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_app_check_platform_interface/src/android_provider.dart';
import 'package:firebase_app_check_platform_interface/src/android_providers.dart';
import 'package:firebase_app_check_platform_interface/src/apple_provider.dart';
import 'package:firebase_app_check_platform_interface/src/apple_providers.dart';
import 'package:firebase_app_check_platform_interface/src/method_channel/utils/provider_to_string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getAndroidProviderString', () {
    test(
        'returns new provider type when both providers are provided and legacy is default',
        () {
      final result = getAndroidProviderString(
        legacyProvider: AndroidProvider.playIntegrity,
        newProvider: const AndroidPlayIntegrityProvider(),
      );
      expect(result, 'playIntegrity');
    });

    test(
        'returns legacy provider when explicitly set to debug and new provider is default',
        () {
      final result = getAndroidProviderString(
        legacyProvider: AndroidProvider.debug,
        newProvider: const AndroidPlayIntegrityProvider(),
      );
      expect(result, 'debug');
    });

    test(
        'returns new provider type when only new provider is provided and legacy is default',
        () {
      final result = getAndroidProviderString(
        legacyProvider: AndroidProvider.playIntegrity,
        newProvider: const AndroidDebugProvider(),
      );
      expect(result, 'debug');
    });

    test('returns default when neither provider is provided', () {
      final result = getAndroidProviderString();
      expect(result, 'playIntegrity');
    });
  });

  group('getAppleProviderString', () {
    test('returns default provider when both providers are default', () {
      final result = getAppleProviderString(
        legacyProvider: AppleProvider.deviceCheck,
        newProvider: const AppleDeviceCheckProvider(),
      );
      expect(result, 'deviceCheck');
    });

    test(
        'returns legacy provider when explicitly set to debug and new provider is default',
        () {
      final result = getAppleProviderString(
        legacyProvider: AppleProvider.debug,
        newProvider: const AppleDeviceCheckProvider(),
      );
      expect(result, 'debug');
    });

    test(
        'returns legacy provider when explicitly set to appAttest and new provider is default',
        () {
      final result = getAppleProviderString(
        legacyProvider: AppleProvider.appAttest,
        newProvider: const AppleDeviceCheckProvider(),
      );
      expect(result, 'appAttest');
    });

    test(
        'returns legacy provider when explicitly set to appAttestWithDeviceCheckFallback and new provider is default',
        () {
      final result = getAppleProviderString(
        legacyProvider: AppleProvider.appAttestWithDeviceCheckFallback,
        newProvider: const AppleDeviceCheckProvider(),
      );
      expect(result, 'appAttestWithDeviceCheckFallback');
    });

    test(
        'returns new provider type when new provider is provided and legacy is default',
        () {
      final result = getAppleProviderString(
        legacyProvider: AppleProvider.deviceCheck,
        newProvider: const AppleDebugProvider(),
      );
      expect(result, 'debug');
    });

    test(
        'returns legacy provider when new provider is provided and legacy is default',
        () {
      final result = getAppleProviderString(
        legacyProvider: AppleProvider.deviceCheck,
        newProvider: const AppleAppAttestProvider(),
      );
      expect(result, 'appAttest');
    });

    test('returns default when neither provider is provided', () {
      final result = getAppleProviderString();
      expect(result, 'deviceCheck');
    });

    test(
        'returns new provider when explicitly set to appAttestWithDeviceCheckFallback',
        () {
      final result = getAppleProviderString(
        legacyProvider: AppleProvider.deviceCheck,
        newProvider: const AppleAppAttestWithDeviceCheckFallbackProvider(),
      );
      expect(result, 'appAttestWithDeviceCheckFallback');
    });
  });
}
