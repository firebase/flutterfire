// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

abstract class AppleAppCheckProvider {
  final String type;
  const AppleAppCheckProvider(this.type);
}

/// Debug provider for Apple platforms.
///
/// No further configuration in your iOS code required. You simply need to
/// copy/paste the debug token from the console when you run the app and add the
/// token to your Firebase console.
///
/// If you set the [debugToken] here, it will be used when activating the provider.
///
/// See documentation: https://firebase.google.com/docs/app-check/ios/debug-provider
class AppleDebugProvider extends AppleAppCheckProvider {
  /// Creates an Apple debug provider with an optional debug token.
  ///
  /// The [debugToken] can be set here or passed separately to the activate method.
  /// You have to re-run app after changing debug token.
  const AppleDebugProvider({this.debugToken}) : super('debug');

  /// The debug token for this provider.
  final String? debugToken;
}

/// Device Check provider for Apple platforms.
///
/// The default provider for iOS and macOS.
///
/// See documentation: https://firebase.google.com/docs/app-check/ios/devicecheck-provider
class AppleDeviceCheckProvider extends AppleAppCheckProvider {
  const AppleDeviceCheckProvider() : super('deviceCheck');
}

/// App Attest provider for Apple platforms (Firebase recommended).
///
/// Only available on iOS 14.0+, macOS 14.0+.
///
/// See documentation: https://firebase.google.com/docs/app-check/ios/app-attest-provider
class AppleAppAttestProvider extends AppleAppCheckProvider {
  const AppleAppAttestProvider() : super('appAttest');
}

/// App Attest provider with Device Check fallback for Apple platforms.
///
/// App Attest provider is only available on iOS 14.0+, macOS 14.0+ so this will
/// fall back to Device Check provider if App Attest provider is not available.
class AppleAppAttestWithDeviceCheckFallbackProvider
    extends AppleAppCheckProvider {
  const AppleAppAttestWithDeviceCheckFallbackProvider()
      : super('appAttestWithDeviceCheckFallback');
}
