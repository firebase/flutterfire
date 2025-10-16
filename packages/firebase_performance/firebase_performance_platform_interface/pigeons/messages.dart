// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    dartTestOut: 'test/pigeon/test_api.dart',
    dartPackageName: 'firebase_performance_platform_interface',
    kotlinOut:
        '../firebase_performance/android/src/main/kotlin/io/flutter/plugins/firebase/performance/GeneratedAndroidFirebasePerformance.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.firebase.performance',
    ),
    swiftOut:
        '../firebase_performance/ios/firebase_performance/Sources/firebase_performance/FirebasePerformanceMessages.g.swift',
    cppHeaderOut: '../firebase_performance/windows/messages.g.h',
    cppSourceOut: '../firebase_performance/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'firebase_performance_windows'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
enum HttpMethod {
  connect,
  delete,
  get,
  head,
  options,
  patch,
  post,
  put,
  trace,
}

class HttpMetricOptions {
  const HttpMetricOptions({
    required this.url,
    required this.httpMethod,
  });

  final String url;
  final HttpMethod httpMethod;
}

class HttpMetricAttributes {
  const HttpMetricAttributes({
    this.httpResponseCode,
    this.requestPayloadSize,
    this.responsePayloadSize,
    this.responseContentType,
    this.attributes,
  });

  final int? httpResponseCode;
  final int? requestPayloadSize;
  final int? responsePayloadSize;
  final String? responseContentType;
  final Map<String, String>? attributes;
}

class TraceAttributes {
  const TraceAttributes({
    this.metrics,
    this.attributes,
  });

  final Map<String, int>? metrics;
  final Map<String, String>? attributes;
}

@HostApi(dartHostTestHandler: 'TestFirebasePerformanceHostApi')
abstract class FirebasePerformanceHostApi {
  @async
  void setPerformanceCollectionEnabled(bool enabled);

  @async
  bool isPerformanceCollectionEnabled();

  @async
  int startTrace(String name);

  @async
  void stopTrace(int handle, TraceAttributes attributes);

  @async
  int startHttpMetric(HttpMetricOptions options);

  @async
  void stopHttpMetric(int handle, HttpMetricAttributes attributes);
}
