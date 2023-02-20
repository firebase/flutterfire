// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// An enum representing the different types of Apple App Attest providers.
enum AppleProvider {
  /// The debug provider. No furhter configuration in your iOS code required. You simply need to copy/paste the debug token
  /// from the console when you run the app and add the token to your Firebase console. See documentation:
  /// https://firebase.google.com/docs/app-check/ios/debug-provider
  debug,

  /// the default deviceCheck provider. See documentation: https://firebase.google.com/docs/app-check/ios/devicecheck-provider
  deviceCheck,
  // The app attest provider (Firebase recommended). See documentation: https://firebase.google.com/docs/app-check/ios/app-attest-provider
  appAttest,

  /// appAttest provider is only available on iOS 14.0+, macOS 14.0+ so this will fall back to deviceCheck provider if appAtest provider
  /// is not available
  appAttestWithDeviceCheckFallback
}
