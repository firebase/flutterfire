// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    dartTestOut: 'test/pigeon/test_api.dart',
    dartPackageName: 'firebase_database_platform_interface',
    kotlinOut:
        '../firebase_database/android/src/main/kotlin/io/flutter/plugins/firebase/database/GeneratedAndroidFirebaseDatabase.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.firebase.database',
    ),
    swiftOut:
        '../firebase_database/ios/firebase_database/Sources/firebase_database/FirebaseDatabaseMessages.g.swift',
    cppHeaderOut: '../firebase_database/windows/messages.g.h',
    cppSourceOut: '../firebase_database/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'firebase_database_windows'),
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

@HostApi(dartHostTestHandler: 'TestFirebaseDatabaseHostApi')
abstract class FirebaseDatabaseHostApi {
  @async
  void goOnline();

  @async
  void goOffline();

  @async
  void setPersistenceEnabled(bool enabled);
  
  @async
  void setPersistenceCacheSizeBytes(int cacheSize);

  @async
  void setLoggingEnabled(bool enabled);
  
  @async
  void useDatabaseEmulator(String host, int port);

  @async
  DatabaseReferencePlatform ref([String? path]);

  @async
  void setPersistenceEnabled(bool enabled);

  @async
  void refFromURL(String url);

  @async
  void ref([String? path]);

  @async
  void purgeOutstandingWrites();
  
}