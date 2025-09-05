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

class FirebaseApp {
  const FirebaseApp({
    required this.appName,
    this.databaseURL,
    this.persistenceEnabled,
    this.cacheSizeBytes,
    this.loggingEnabled,
    this.emulatorHost,
    this.emulatorPort,
  });

  final String appName;
  final String? databaseURL;
  final bool? persistenceEnabled;
  final int? cacheSizeBytes;
  final bool? loggingEnabled;
  final String? emulatorHost;
  final int? emulatorPort;
}

class DatabaseReference {
  const DatabaseReference({
    required this.path,
  });

  final String path;
}

class DatabaseTransactionHandler {
  const DatabaseTransactionHandler({
    required this.transactionKey,
  });

  final int transactionKey;
}

class EventObserver {
  const EventObserver({
    required this.path,
    required this.eventType,
    required this.eventChannelNamePrefix,
    required this.modifiers,
  });

  final String path;
  final String eventType;
  final String eventChannelNamePrefix;
  final List<Map<String, Object?>> modifiers;
}

class GetOptions {
  const GetOptions({
    required this.path,
    required this.modifiers,
    this.source,
    this.serverTimestampBehavior,
  });

  final String path;
  final List<Map<String, Object?>> modifiers;
  final String? source;
  final String? serverTimestampBehavior;
}

class KeepSyncedOptions {
  const KeepSyncedOptions({
    required this.path,
    required this.modifiers,
    required this.value,
  });

  final String path;
  final List<Map<String, Object?>> modifiers;
  final bool value;
}

class OnDisconnectOptions {
  const OnDisconnectOptions({
    required this.path,
    this.value,
    this.priority,
  });

  final String path;
  final Object? value;
  final Object? priority;
}

class SetOptions {
  const SetOptions({
    required this.path,
    this.value,
    this.priority,
  });

  final String path;
  final Object? value;
  final Object? priority;
}

class UpdateOptions {
  const UpdateOptions({
    required this.path,
    required this.value,
  });

  final String path;
  final Map<String, Object?> value;
}

class SetPriorityOptions {
  const SetPriorityOptions({
    required this.path,
    required this.priority,
  });

  final String path;
  final Object priority;
}

class RemoveOptions {
  const RemoveOptions({
    required this.path,
  });

  final String path;
}

class TransactionOptions {
  const TransactionOptions({
    required this.path,
    required this.transactionHandler,
    required this.applyLocally,
  });

  final String path;
  final DatabaseTransactionHandler transactionHandler;
  final bool applyLocally;
}

class DataSnapshot {
  const DataSnapshot({
    required this.snapshot,
  });

  final Map<String, Object?> snapshot;
}

@HostApi(dartHostTestHandler: 'TestFirebaseDatabaseHostApi')
abstract class FirebaseDatabaseHostApi {
  @async
  void set(SetOptions options);

  @async
  void setWithPriority(SetOptions options);

  @async
  void update(UpdateOptions options);

  @async
  void setPriority(SetPriorityOptions options);

  @async
  void remove(RemoveOptions options);

  @async
  void runTransaction(TransactionOptions options);

  @async
  void goOnline(FirebaseApp app);

  @async
  void goOffline(FirebaseApp app);

  @async
  void purgeOutstandingWrites(FirebaseApp app);

  @async
  void cancel(FirebaseApp app);

  @async
  String observe(EventObserver observer);

  @async
  DataSnapshot get(GetOptions options);

  @async
  void keepSynced(KeepSyncedOptions options);

  @async
  void onDisconnectSet(OnDisconnectOptions options);

  @async
  void onDisconnectSetWithPriority(OnDisconnectOptions options);

  @async
  void onDisconnectUpdate(UpdateOptions options);

  @async
  void onDisconnectRemove(RemoveOptions options);

  @async
  void onDisconnectCancel(DatabaseReference reference);
}
