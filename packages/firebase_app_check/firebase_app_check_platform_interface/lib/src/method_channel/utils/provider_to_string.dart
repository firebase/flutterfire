// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_app_check_platform_interface/src/android_provider.dart';
import 'package:firebase_app_check_platform_interface/src/ios_provider.dart';

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

/// Converts [IosProvider] to [String]
String getIosProviderString(IosProvider? provider) {
  switch (provider) {
    case IosProvider.debug:
      return 'debug';
    case IosProvider.appAttest:
      return 'appAttest';
    case IosProvider.deviceCheck:
      return 'deviceCheck';
    case IosProvider.appAttestWithDeviceCheckFallback:
      return 'appAttestWithDeviceCheckFallback';
    default:
      return 'deviceCheck';
  }
}
