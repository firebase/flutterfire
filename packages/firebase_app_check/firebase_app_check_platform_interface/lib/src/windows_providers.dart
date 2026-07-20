// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Base class for Windows App Check providers.
///
/// On Windows, only the [WindowsDebugProvider] is supported. The Firebase C++
/// SDK does not support platform attestation providers (such as Play Integrity
/// or DeviceCheck) on desktop platforms.
abstract class WindowsAppCheckProvider {
  final String type;
  const WindowsAppCheckProvider(this.type);
}

/// Debug provider for Windows.
///
/// This is the **only** provider available on Windows. Unlike mobile platforms,
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
