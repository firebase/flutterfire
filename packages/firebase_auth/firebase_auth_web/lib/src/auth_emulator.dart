// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Loopback hosts where a persisted Auth emulator origin may be reapplied
/// during plugin initialization after a full page reload.
bool isAuthEmulatorDebugHost(String hostname) {
  return hostname == 'localhost' ||
      hostname == '127.0.0.1' ||
      hostname == '[::1]';
}

/// Origin string passed to the JS SDK `connectAuthEmulator`.
String authEmulatorOrigin(String host, int port) => 'http://$host:$port';

/// Storage key for a persisted emulator origin, per Firebase app.
String authEmulatorOriginStorageKey(String appName) =>
    '$appName-firebaseEmulatorOrigin';

/// [localOrigin] when set, otherwise [sessionOrigin].
String? persistedAuthEmulatorOrigin({
  required String? localOrigin,
  required String? sessionOrigin,
}) {
  return localOrigin ?? sessionOrigin;
}

/// Whether plugin init should call `connectAuthEmulator` from the stored
/// origin before Auth finishes restoring a persisted user.
bool shouldReusePersistedAuthEmulator({
  required String hostname,
  required bool isDebugMode,
  required String? storedOrigin,
}) {
  return isDebugMode &&
      storedOrigin != null &&
      isAuthEmulatorDebugHost(hostname);
}

/// Whether `connectAuthEmulator` can be skipped because **this** JS Auth
/// instance is already using [requestedOrigin].
///
/// A matching sessionStorage value is not enough: after a full page reload
/// the Auth instance is new and still points at production until
/// `connectAuthEmulator` runs again.
bool shouldSkipConnectAuthEmulator({
  required String requestedOrigin,
  required String? connectedEmulatorOrigin,
}) {
  return connectedEmulatorOrigin != null &&
      connectedEmulatorOrigin == requestedOrigin;
}

/// Whether a failed connect should still store [requestedOrigin] for the next
/// launch. A matching connected origin needs no rewrite.
bool shouldRememberRequestedOriginAfterFailedConnect({
  required String requestedOrigin,
  required String? connectedOrigin,
}) {
  return connectedOrigin != requestedOrigin;
}
