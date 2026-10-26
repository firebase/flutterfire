// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dart_cloud_functions/dart_cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Whether the emulator ports are forwarded to the device with `adb reverse`.
///
/// The Android emulator reaches your computer at `10.0.2.2`, so on Android the
/// plugins map `localhost` to that address. A physical phone can't use it.
/// Instead, forward the ports over USB and run with
/// `--dart-define=ADB_REVERSE=true`, which keeps `localhost` as is:
///
/// ```sh
/// adb reverse tcp:5001 tcp:5001  # Functions emulator
/// adb reverse tcp:9099 tcp:9099  # Auth emulator
/// flutter run -d <device-id> --dart-define=ADB_REVERSE=true
/// ```
const bool adbReverse =
    // ignore: do_not_use_environment
    bool.fromEnvironment('ADB_REVERSE');

/// Whether the plugins map `localhost` to `10.0.2.2` on Android.
///
/// A getter, not a constant: as a constant it would be `true` in normal
/// builds, which the analyzer flags as a redundant default argument.
bool get automaticHostMapping => !adbReverse;

/// The emulator host for URLs the plugins don't rewrite, such as a callable's
/// explicit URL.
String get emulatorUrlHost {
  final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  return isAndroid && automaticHostMapping ? '10.0.2.2' : 'localhost';
}

/// Points the `cloud_functions` plugin at the local Functions emulator.
void connectFunctionsEmulator(FirebaseFunctions functions) {
  functions.useFunctionsEmulator(
    'localhost',
    5001,
    automaticHostMapping: automaticHostMapping,
  );
}

/// Points `dart_cloud_functions` at the local Functions emulator.
void connectDartFunctionsEmulator(DartFirebaseFunctions functions) {
  functions.useFunctionsEmulator(
    'localhost',
    5001,
    automaticHostMapping: automaticHostMapping,
  );
}

/// Points Firebase Auth at the local Auth emulator.
Future<void> connectAuthEmulator() {
  return FirebaseAuth.instance.useAuthEmulator(
    'localhost',
    9099,
    automaticHostMapping: automaticHostMapping,
  );
}
