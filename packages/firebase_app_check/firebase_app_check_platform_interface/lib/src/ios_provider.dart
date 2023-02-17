// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// An enum representing the different types of Apple App Attest providers.
enum AppleProvider {
  // The debug provider
  debug,
  // the default deviceCheck provider
  deviceCheck,
  // The app attest provider (Firebase recommended)
  appAttest,
  // appAttest provider is only available on iOS 14.0+, macOS 14.0+
  appAttestWithDeviceCheckFallback
}
