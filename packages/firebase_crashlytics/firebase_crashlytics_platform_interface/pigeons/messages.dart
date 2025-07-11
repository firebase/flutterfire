// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    dartTestOut: 'test/pigeon/test_api.dart',
    dartPackageName: 'firebase_crashlytics_platform_interface',
    kotlinOut:
        '../firebase_crashlytics/android/src/main/kotlin/io/flutter/plugins/firebase/crashlytics/GeneratedAndroidFirebaseCrashlytics.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.firebase.crashlytics',
    ),
    swiftOut:
        '../firebase_crashlytics/ios/firebase_crashlytics/Sources/firebase_crashlytics/FirebaseCrashlyticsMessages.g.swift',
    cppHeaderOut: '../firebase_crashlytics/windows/messages.g.h',
    cppSourceOut: '../firebase_crashlytics/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'firebase_crashlytics_windows'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)

/// Represents all methods for the Firebase Crashlytics plugin.
@HostApi(dartHostTestHandler: 'TestFirebaseCrashlyticsHostApi')
abstract class CrashlyticsHostApi {
  /// Records a non-fatal error.
  @async
  void recordError(Map<String, Object?> arguments);

  /// Sets a custom key-value pair.
  @async
  void setCustomKey(Map<String, Object?> arguments);

  /// Sets the user identifier.
  @async
  void setUserIdentifier(Map<String, Object?> arguments);

  /// Logs a message.
  @async
  void log(Map<String, Object?> arguments);

  /// Enables/disables automatic data collection.
  @async
  Map<String, bool>? setCrashlyticsCollectionEnabled(
      Map<String, bool> arguments);

  /// Check for unsent reports.
  @async
  Map<String, Object?> checkForUnsentReports();

  /// Send any unsent reports.
  @async
  void sendUnsentReports();

  /// Delete any unsent reports.
  @async
  void deleteUnsentReports();

  /// Check if app crashed on previous execution.
  @async
  Map<String, Object?> didCrashOnPreviousExecution();

  /// Force a crash for testing.
  @async
  void crash();
}
