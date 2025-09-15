// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

abstract class AndroidAppCheckProvider {
  final String type;
  const AndroidAppCheckProvider(this.type);
}

/// Debug provider for Android.
///
/// No further configuration in your Android code required. You simply need to
/// copy/paste the debug token from the console when you run the app and add the
/// token to your Firebase console.
///
/// If you set the [debugToken] here, it will be used when activating the provider.
///
/// See documentation: https://firebase.google.com/docs/app-check/android/debug-provider
class AndroidDebugProvider extends AndroidAppCheckProvider {
  /// Creates an Android debug provider with an optional debug token.
  ///
  /// The [debugToken] can be set here or passed separately to the activate method.
  const AndroidDebugProvider({this.debugToken}) : super('debug');

  /// The debug token for this provider.
  final String? debugToken;
}

/// Play Integrity provider for Android (Firebase recommended).
///
/// See documentation: https://firebase.google.com/docs/app-check/android/play-integrity-provider
class AndroidPlayIntegrityProvider extends AndroidAppCheckProvider {
  const AndroidPlayIntegrityProvider() : super('playIntegrity');
}
