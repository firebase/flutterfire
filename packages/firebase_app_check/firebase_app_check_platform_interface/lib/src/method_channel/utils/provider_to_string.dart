// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_app_check_platform_interface/src/android_provider.dart';
import 'package:firebase_app_check_platform_interface/src/apple_provider.dart';

/// Converts [AndroidProvider] to [String]
String getAndroidProviderString(AndroidProvider? provider) {
  switch (provider) {
    // ignore: deprecated_member_use_from_same_package
    case AndroidProvider.safetyNet:
      return 'safetyNet';
    case AndroidProvider.debug:
      return 'debug';
    case AndroidProvider.playIntegrity:
    default:
      return 'playIntegrity';
  }
}

/// Converts [AppleProvider] to [String]
String getAppleProviderString(AppleProvider? provider) {
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
