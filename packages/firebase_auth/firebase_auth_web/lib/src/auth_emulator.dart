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

String? persistedAuthEmulatorOrigin({
  required String? localOrigin,
  required String? sessionOrigin,
}) {
  return localOrigin ?? sessionOrigin;
}

/// Origin stored for a debug launch, or null.
///
/// Release builds do not read storage. A blocked page throws SecurityError
/// from localStorage and sessionStorage, which must not fail startup.
String? debugAuthEmulatorOrigin({
  required bool isDebugMode,
  required String? Function() readLocal,
  required String? Function() readSession,
}) {
  if (!isDebugMode) {
    return null;
  }
  try {
    return persistedAuthEmulatorOrigin(
      localOrigin: readLocal(),
      sessionOrigin: readSession(),
    );
  } catch (_) {
    return null;
  }
}

/// Writes the emulator origin in debug builds.
///
/// A blocked page throws SecurityError from localStorage. That must not fail
/// a connect that already succeeded.
void rememberDebugAuthEmulatorOrigin({
  required bool isDebugMode,
  required void Function() write,
}) {
  if (!isDebugMode) {
    return;
  }
  try {
    write();
  } catch (_) {}
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

bool shouldRememberRequestedOriginAfterFailedConnect({
  required String requestedOrigin,
  required String? connectedOrigin,
}) {
  return connectedOrigin != requestedOrigin;
}

/// What to print when `connectAuthEmulator` is refused.
///
/// JS SDK 13.2 returns without throwing when this instance is already on
/// [requestedOrigin]. A thrown error means it is on production or another
/// origin, and hot restart keeps that instance.
String authEmulatorConnectTooLateMessage({
  required String appName,
  required String requestedOrigin,
  required String? connectedOrigin,
}) {
  if (connectedOrigin == requestedOrigin) {
    return 'Auth emulator is already configured at $requestedOrigin for $appName and kept across hot reload.\n'
        "To use production Auth, clear this site's storage and restart without the emulator.";
  }
  final String current = connectedOrigin ?? 'production';
  return 'Auth for $appName is on $current, not $requestedOrigin.\n'
      'The emulator will apply after a full page reload. Hot restart keeps this Auth instance.\n'
      "To use production Auth, clear this site's storage and restart without the emulator.";
}

bool shouldThrowDebugEmulatorConnectFailure({
  required bool isDebugMode,
  required String? connectedOrigin,
}) {
  return isDebugMode && connectedOrigin == null;
}
