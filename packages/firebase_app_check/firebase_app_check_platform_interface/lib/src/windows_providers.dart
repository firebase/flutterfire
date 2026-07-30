// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Base class for Windows App Check providers.
///
/// The Firebase C++ SDK does not ship native platform attestation providers
/// (such as Play Integrity or DeviceCheck) on desktop, so Windows supports
/// [WindowsDebugProvider] for development and [WindowsCustomProvider] for
/// production builds that mint tokens via a backend.
abstract class WindowsAppCheckProvider {
  final String type;
  const WindowsAppCheckProvider(this.type);
}

/// Carries a minted App Check token and its expiry.
class CustomAppCheckToken {
  /// Creates a custom App Check token result.
  const CustomAppCheckToken({
    required this.token,
    required this.expireTimeMillis,
  });

  /// The App Check token string to send with Firebase requests.
  final String token;

  /// Absolute expiry as Unix epoch milliseconds (UTC).
  final int expireTimeMillis;
}

/// Custom provider for Windows production builds.
///
/// When activated, the Windows C++ plugin registers a custom
/// `AppCheckProvider` that calls [fetchToken] each time the Firebase SDK needs
/// a fresh App Check token. The callback is expected to call a backend service
/// (typically a Cloud Function with `enforceAppCheck: false`) that mints a
/// valid App Check token using the Firebase Admin SDK, then return both the
/// token and its expiry.
///
/// Register the callback before any Firebase operations that require App Check:
///
/// ```dart
/// await FirebaseAppCheck.instance.activate(
///   providerWindows: WindowsCustomProvider(
///     fetchToken: () async {
///       // Call your backend, e.g. a callable Cloud Function that uses
///       // admin.appCheck().createToken(windowsAppId).
///       final response = await myBackend.mintAppCheckToken();
///       return CustomAppCheckToken(
///         token: response.token,
///         expireTimeMillis: response.expireTimeMillis,
///       );
///     },
///   ),
/// );
/// ```
class WindowsCustomProvider extends WindowsAppCheckProvider {
  /// Creates a Windows custom provider.
  const WindowsCustomProvider({
    required this.fetchToken,
  }) : super('custom');

  /// Callback invoked when the native Firebase SDK needs a fresh token.
  final Future<CustomAppCheckToken> Function() fetchToken;
}

/// Debug provider for Windows.
///
/// Intended for development and local testing only. Unlike mobile platforms,
/// the desktop C++ SDK does **not** auto-generate a debug token. You must
/// supply one explicitly.
///
/// ## Setup
///
/// 1. Generate a debug token (a UUID v4) — for example using an online
///    generator or a CLI tool.
/// 2. Register it in the **Firebase Console** under
///    *App Check → Apps → Manage debug tokens*.
/// 3. Pass it here via [debugToken], **or** set the `APP_CHECK_DEBUG_TOKEN`
///    environment variable before launching your app.
///
/// If neither a [debugToken] nor the environment variable is provided,
/// `getToken()` will fail with an `invalid-configuration` error.
///
/// **Do not ship the debug provider or debug tokens in production builds.**
class WindowsDebugProvider extends WindowsAppCheckProvider {
  /// Creates a Windows debug provider.
  ///
  /// [debugToken] is the debug token registered in the Firebase Console.
  /// If omitted, the C++ SDK falls back to the `APP_CHECK_DEBUG_TOKEN`
  /// environment variable.
  const WindowsDebugProvider({this.debugToken}) : super('debug');

  /// The debug token for this provider.
  final String? debugToken;
}
