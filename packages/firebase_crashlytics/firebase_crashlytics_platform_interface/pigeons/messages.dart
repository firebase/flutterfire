// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    // Exported via lib/test.dart so firebase_crashlytics package tests can mock it.
    // `melos run generate:pigeon` rewrites the generated `flutter_test` import
    // to `package:firebase_core_platform_interface/test_binding.dart`, because
    // `flutter_test` cannot be a dependency of a published package.
    dartTestOut: 'lib/src/pigeon/test_api.dart',
    dartPackageName: 'firebase_crashlytics_platform_interface',
    kotlinOut:
        '../firebase_crashlytics/android/src/main/kotlin/io/flutter/plugins/firebase/crashlytics/generated/GeneratedAndroidFirebaseCrashlytics.g.kt',
    kotlinOptions: KotlinOptions(
      // Separate package so Pigeon's FlutterError does not collide with
      // io.flutter.plugins.firebase.crashlytics.FlutterError (Crashlytics
      // console exception type).
      package: 'io.flutter.plugins.firebase.crashlytics.generated',
    ),
    swiftOut:
        '../firebase_crashlytics/ios/firebase_crashlytics/Sources/firebase_crashlytics/FirebaseCrashlyticsMessages.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
class CrashlyticsStackFrame {
  const CrashlyticsStackFrame({
    this.className,
    required this.method,
    required this.file,
    required this.line,
  });

  /// Dart reserved word `class`; native maps this to the historical "class" key.
  final String? className;
  final String method;
  final String file;
  final String line;
}

class RecordErrorRequest {
  const RecordErrorRequest({
    required this.exception,
    required this.information,
    this.reason,
    required this.fatal,
    required this.buildId,
    required this.loadingUnits,
    required this.stackTraceElements,
  });

  final String exception;
  final String information;
  final String? reason;
  final bool fatal;
  final String buildId;
  final List<String> loadingUnits;
  final List<CrashlyticsStackFrame> stackTraceElements;
}

@HostApi(dartHostTestHandler: 'TestFirebaseCrashlyticsHostApi')
abstract class FirebaseCrashlyticsHostApi {
  @async
  bool checkForUnsentReports();

  @async
  void crash();

  @async
  void deleteUnsentReports();

  @async
  bool didCrashOnPreviousExecution();

  @async
  void recordError(RecordErrorRequest request);

  @async
  void log(String message);

  @async
  void sendUnsentReports();

  @async
  bool setCrashlyticsCollectionEnabled(bool enabled);

  @async
  void setUserIdentifier(String identifier);

  @async
  void setCustomKey(String key, String value);
}
