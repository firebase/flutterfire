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

class TransactionHandler {
  const TransactionHandler({
    required this.transactionKey,
  });

  final int transactionKey;
}

class EventObserver {
  const EventObserver({
    required this.eventType,
    required this.eventChannelNamePrefix,
  });

  final String eventType;
  final String eventChannelNamePrefix;
}

class GetOptions {
  const GetOptions({
    this.source,
    this.serverTimestampBehavior,
  });

  final String? source;
  final String? serverTimestampBehavior;
}

class QueryModifiers {
  const QueryModifiers({
    this.orderBy,
    this.limitToFirst,
    this.limitToLast,
    this.startAt,
    this.endAt,
    this.equalTo,
  });

  final String? orderBy;
  final int? limitToFirst;
  final int? limitToLast;
  final Object? startAt;
  final Object? endAt;
  final Object? equalTo;
}

@HostApi(dartHostTestHandler: 'TestFirebaseDatabaseHostApi')
abstract class FirebaseDatabaseHostApi {
  @async
  void set(Object? value);

  @async
  void setWithPriority(Object? value, Object? priority);

  @async
  void update(Map<String, Object?> value);

  @async
  void setPriority(Object? priority);

  @async
  void remove();

  @async
  void runTransaction(TransactionHandler transactionHandler, bool applyLocally);

  @async
  void goOnline();

  @async
  void goOffline();

  @async
  void purgeOutstandingWrites();

  @async
  void cancel();

  @async
  void observe(EventObserver observer);

  @async
  void get(GetOptions options);

  @async
  void keepSynced(QueryModifiers modifiers, bool value);
  
}
