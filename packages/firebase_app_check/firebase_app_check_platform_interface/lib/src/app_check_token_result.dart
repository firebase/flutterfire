// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// An App Check token and its associated metadata.
class AppCheckTokenResult {
  /// Creates an App Check token result.
  const AppCheckTokenResult({
    required this.token,
    this.expirationTime,
  });

  /// The App Check token JWT string.
  final String token;

  /// The time when the App Check token expires.
  ///
  /// This is `null` on platforms whose native SDK does not expose token
  /// expiration metadata.
  final DateTime? expirationTime;

  @override
  String toString() {
    return '$AppCheckTokenResult(token: $token, expirationTime: $expirationTime)';
  }
}
