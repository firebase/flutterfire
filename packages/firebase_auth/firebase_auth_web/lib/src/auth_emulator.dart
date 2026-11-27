// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

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

/// Pending [sessionOrigin] wins over a successful [localOrigin].
String? persistedAuthEmulatorOrigin({
  required String? localOrigin,
  required String? sessionOrigin,
}) {
  return sessionOrigin ?? localOrigin;
}

/// Stored emulator origin when [persistOrigin] is true, or null.
///
/// When [persistOrigin] is false, storage is not read. A blocked page throws
/// SecurityError from localStorage and sessionStorage, which must not fail
/// startup.
String? debugAuthEmulatorOrigin({
  required bool persistOrigin,
  required String? Function() readLocal,
  required String? Function() readSession,
}) {
  if (!persistOrigin) {
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

/// Writes the emulator origin when [persistOrigin] is true.
///
/// A blocked page throws SecurityError from localStorage. That must not fail
/// a connect that already succeeded.
void rememberDebugAuthEmulatorOrigin({
  required bool persistOrigin,
  required void Function() write,
}) {
  if (!persistOrigin) {
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
  required bool persistOrigin,
  required String? storedOrigin,
}) {
  return persistOrigin &&
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
/// The JS SDK returns without throwing when this instance is already on
/// [requestedOrigin]. A thrown error means it is on production or another
/// origin, and hot restart keeps that instance.
String authEmulatorConnectTooLateMessage({
  required String appName,
  required String requestedOrigin,
  required String? connectedOrigin,
}) {
  final String current = connectedOrigin ?? 'production';
  return 'Auth for $appName is on $current, not $requestedOrigin.\n'
      'The emulator will apply after a full page reload. Hot restart keeps this Auth instance.\n'
      "To use production Auth, clear this site's storage and restart without the emulator.";
}

bool shouldThrowDebugEmulatorConnectFailure({
  required bool persistOrigin,
  required String requestedOrigin,
  required String? connectedOrigin,
}) {
  return persistOrigin && connectedOrigin != requestedOrigin;
}

/// Reapplies a stored emulator origin before Auth restores a persisted user.
///
/// No-op unless [FirebaseAuthPlatform.persistWebEmulatorOrigin] is true, [hostname]
/// is a loopback host, and storage holds an origin.
void applyPersistedAuthEmulatorOrigin({
  required String appName,
  required String hostname,
  required String? Function(String storageKey) readLocal,
  required String? Function(String storageKey) readSession,
  required void Function(String origin) connect,
  required String? Function() connectedOrigin,
  required void Function(String origin) rememberReached,
  required void Function(String message) log,
}) {
  final String storageKey = authEmulatorOriginStorageKey(appName);
  final bool persistOrigin = FirebaseAuthPlatform.persistWebEmulatorOrigin;
  final String? emulatorOrigin = debugAuthEmulatorOrigin(
    persistOrigin: persistOrigin,
    readLocal: () => readLocal(storageKey),
    readSession: () => readSession(storageKey),
  );
  if (!shouldReusePersistedAuthEmulator(
        hostname: hostname,
        persistOrigin: persistOrigin,
        storedOrigin: emulatorOrigin,
      ) ||
      emulatorOrigin == null) {
    return;
  }
  try {
    connect(emulatorOrigin);
    rememberReached(emulatorOrigin);
    log(
      'Using previously configured Auth emulator at $emulatorOrigin for $appName.\n'
      'This emulator setting is kept after the browser closes.\n'
      "To use production Auth, clear this site's storage and restart without the emulator.",
    );
  } catch (e) {
    if (e.toString().contains('sooner')) {
      log(
        authEmulatorConnectTooLateMessage(
          appName: appName,
          requestedOrigin: emulatorOrigin,
          connectedOrigin: connectedOrigin(),
        ),
      );
    } else {
      rethrow;
    }
  }
}
