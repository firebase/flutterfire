// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

/// The platform in the app ID that `Firebase.initializeApp(demoProjectId:)`
/// creates.
///
/// The Apple SDKs reject app IDs for another platform, so this follows the OS.
String get demoAppPlatform {
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS || Platform.isMacOS) return 'ios';
  // We use 'web' as the default platform for unknown platforms.
  return 'web';
}
