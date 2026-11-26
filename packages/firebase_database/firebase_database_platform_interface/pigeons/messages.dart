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
class DatabasePigeonSettings {
  const DatabasePigeonSettings({
    this.persistenceEnabled,
    this.cacheSizeBytes,
    this.loggingEnabled,
    this.emulatorHost,
    this.emulatorPort,
  });

  final bool? persistenceEnabled;
  final int? cacheSizeBytes;
  final bool? loggingEnabled;
  final String? emulatorHost;
  final int? emulatorPort;
}

class DatabasePigeonFirebaseApp {
  const DatabasePigeonFirebaseApp({
    required this.appName,
    required this.databaseURL,
    required this.settings,
  });

  final String appName;
  final String? databaseURL;
  final DatabasePigeonSettings settings;
}

class DatabaseReferencePlatform {
  const DatabaseReferencePlatform({required this.path});

  final String path;
}

class DatabaseReferenceRequest {
  const DatabaseReferenceRequest({
    required this.path,
    this.value,
    this.priority,
  });

  final String path;
  final Object? value;
  final Object? priority;
}

class UpdateRequest {
  const UpdateRequest({required this.path, required this.value});

  final String path;
  final Map<String, Object?> value;
}

class TransactionRequest {
  const TransactionRequest({
    required this.path,
    required this.transactionKey,
    required this.applyLocally,
  });

  final String path;
  final int transactionKey;
  final bool applyLocally;
}

class QueryRequest {
  const QueryRequest({required this.path, required this.modifiers, this.value});

  final String path;
  final List<Map<String, Object?>> modifiers;
  final bool? value;
}

@HostApi(dartHostTestHandler: 'TestFirebaseDatabaseHostApi')
abstract class FirebaseDatabaseHostApi {
  @asyncCallback
  void goOnline(DatabasePigeonFirebaseApp app);

  @asyncCallback
  void goOffline(DatabasePigeonFirebaseApp app);

  @asyncCallback
  void setPersistenceEnabled(DatabasePigeonFirebaseApp app, bool enabled);

  @asyncCallback
  void setPersistenceCacheSizeBytes(
    DatabasePigeonFirebaseApp app,
    int cacheSize,
  );

  @asyncCallback
  void setLoggingEnabled(DatabasePigeonFirebaseApp app, bool enabled);

  @asyncCallback
  void useDatabaseEmulator(
    DatabasePigeonFirebaseApp app,
    String host,
    int port,
  );

  @asyncCallback
  DatabaseReferencePlatform ref(DatabasePigeonFirebaseApp app, [String? path]);

  @asyncCallback
  DatabaseReferencePlatform refFromURL(
    DatabasePigeonFirebaseApp app,
    String url,
  );

  @asyncCallback
  void purgeOutstandingWrites(DatabasePigeonFirebaseApp app);

  // DatabaseReference methods
  @asyncCallback
  void databaseReferenceSet(
    DatabasePigeonFirebaseApp app,
    DatabaseReferenceRequest request,
  );

  @asyncCallback
  void databaseReferenceSetWithPriority(
    DatabasePigeonFirebaseApp app,
    DatabaseReferenceRequest request,
  );

  @asyncCallback
  void databaseReferenceUpdate(
    DatabasePigeonFirebaseApp app,
    UpdateRequest request,
  );

  @asyncCallback
  void databaseReferenceSetPriority(
    DatabasePigeonFirebaseApp app,
    DatabaseReferenceRequest request,
  );

  @asyncCallback
  void databaseReferenceRunTransaction(
    DatabasePigeonFirebaseApp app,
    TransactionRequest request,
  );

  @asyncCallback
  Map<String, Object?> databaseReferenceGetTransactionResult(
    DatabasePigeonFirebaseApp app,
    int transactionKey,
  );

  // OnDisconnect methods
  @asyncCallback
  void onDisconnectSet(
    DatabasePigeonFirebaseApp app,
    DatabaseReferenceRequest request,
  );

  @asyncCallback
  void onDisconnectSetWithPriority(
    DatabasePigeonFirebaseApp app,
    DatabaseReferenceRequest request,
  );

  @asyncCallback
  void onDisconnectUpdate(DatabasePigeonFirebaseApp app, UpdateRequest request);

  @asyncCallback
  void onDisconnectCancel(DatabasePigeonFirebaseApp app, String path);

  // Query methods
  @asyncCallback
  String queryObserve(DatabasePigeonFirebaseApp app, QueryRequest request);

  @asyncCallback
  void queryKeepSynced(DatabasePigeonFirebaseApp app, QueryRequest request);

  @asyncCallback
  Map<String, Object?> queryGet(
    DatabasePigeonFirebaseApp app,
    QueryRequest request,
  );
}

class TransactionHandlerResult {
  const TransactionHandlerResult({
    this.value,
    required this.aborted,
    required this.exception,
  });

  final Object? value;
  final bool aborted;
  final bool exception;
}

@FlutterApi()
// ignore: one_member_abstracts
abstract class FirebaseDatabaseFlutterApi {
  @asyncCallback
  TransactionHandlerResult callTransactionHandler(
    int transactionKey,
    Object? snapshotValue,
  );
}
