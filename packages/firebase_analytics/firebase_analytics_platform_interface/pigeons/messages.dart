// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    dartTestOut: 'test/pigeon/test_api.dart',
    dartPackageName: 'firebase_analytics_platform_interface',
    kotlinOut:
        '../firebase_analytics/android/src/main/kotlin/io/flutter/plugins/firebase/analytics/GeneratedAndroidFirebaseAnalytics.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.firebase.analytics',
    ),
    swiftOut:
        '../firebase_analytics/ios/firebase_analytics/Sources/firebase_analytics/FirebaseAnalyticsMessages.g.swift',
    cppHeaderOut: '../firebase_analytics/windows/messages.g.h',
    cppSourceOut: '../firebase_analytics/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'firebase_analytics_windows'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
class AnalyticsEvent {
  const AnalyticsEvent({
    required this.name,
    required this.parameters,
  });

  final String name;
  final Map<String?, Object?>? parameters;
}

@HostApi(dartHostTestHandler: 'TestFirebaseAnalyticsHostApi')
abstract class FirebaseAnalyticsHostApi {
  @async
  void logEvent(Map<String, Object?> event);

  @async
  void setUserId(String? userId);

  @async
  void setUserProperty(String name, String? value);

  @async
  void setAnalyticsCollectionEnabled(bool enabled);

  @async
  void resetAnalyticsData();

  @async
  void setSessionTimeoutDuration(int timeout);

  @async
  void setConsent(Map<String, bool?> consent);

  @async
  void setDefaultEventParameters(Map<String, Object?>? parameters);

  @async
  String? getAppInstanceId();

  @async
  int? getSessionId();

  @async
  void initiateOnDeviceConversionMeasurement(Map<String, String?> arguments);
}
