// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_app_check_platform_interface/src/android_providers.dart';
import 'package:firebase_app_check_platform_interface/src/apple_providers.dart';

/// Converts [AndroidAppCheckProvider] to the native provider name.
String getAndroidProviderString(AndroidAppCheckProvider? provider) {
  return provider?.type ?? 'playIntegrity';
}

/// Converts [AppleAppCheckProvider] to the native provider name.
String getAppleProviderString(AppleAppCheckProvider? provider) {
  return provider?.type ?? 'deviceCheck';
}
