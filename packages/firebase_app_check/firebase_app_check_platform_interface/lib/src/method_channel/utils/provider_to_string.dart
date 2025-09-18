// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_app_check_platform_interface/src/android_provider.dart';
import 'package:firebase_app_check_platform_interface/src/android_providers.dart';
import 'package:firebase_app_check_platform_interface/src/apple_provider.dart';
import 'package:firebase_app_check_platform_interface/src/apple_providers.dart';

/// Converts [AndroidAppCheckProvider] to [String] with backwards compatibility
String getAndroidProviderString({
  AndroidProvider? legacyProvider,
  AndroidAppCheckProvider? newProvider,
}) {
  // Prefer new provider over legacy provider
  if (newProvider != null) {
    return newProvider.type;
  }

  return getLegacyAndroidProviderString(legacyProvider);
}

/// Converts [AppleAppCheckProvider] to [String] with backwards compatibility
String getAppleProviderString({
  AppleProvider? legacyProvider,
  AppleAppCheckProvider? newProvider,
}) {
  // Prefer new provider over legacy provider
  if (newProvider != null) {
    return newProvider.type;
  }

  return getLegacyAppleProviderString(legacyProvider);
}

/// Converts [AndroidProvider] enum to [String]
String getLegacyAndroidProviderString(AndroidProvider? provider) {
  switch (provider) {
    case AndroidProvider.debug:
      return 'debug';
    case AndroidProvider.playIntegrity:
    default:
      return 'playIntegrity';
  }
}

/// Converts [AppleProvider] enum to [String]
String getLegacyAppleProviderString(AppleProvider? provider) {
  switch (provider) {
    case AppleProvider.debug:
      return 'debug';
    case AppleProvider.appAttest:
      return 'appAttest';
    case AppleProvider.deviceCheck:
      return 'deviceCheck';
    case AppleProvider.appAttestWithDeviceCheckFallback:
      return 'appAttestWithDeviceCheckFallback';
    default:
      return 'deviceCheck';
  }
}
