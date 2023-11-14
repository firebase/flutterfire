// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// ignore_for_file: one_member_abstracts

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    // We export in the lib folder to expose the class to other packages.
    dartTestOut: 'test/pigeon/test_api.dart',
    javaOut:
        '../cloud_firestore/android/src/main/java/io/flutter/plugins/firebase/firestore/GeneratedAndroidFirebaseFirestore.java',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.firebase.firestore',
      className: 'GeneratedAndroidFirebaseFirestore',
    ),
    objcHeaderOut:
        '../cloud_firestore/ios/Classes/Public/FirestoreMessages.g.h',
    objcSourceOut: '../cloud_firestore/ios/Classes/FirestoreMessages.g.m',
    cppHeaderOut: '../cloud_firestore/windows/messages.g.h',
    cppSourceOut: '../cloud_firestore/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'cloud_firestore_windows'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
class PigeonFirebaseSettings {
  const PigeonFirebaseSettings({
    required this.persistenceEnabled,
    required this.host,
    required this.sslEnabled,
    required this.cacheSizeBytes,
    required this.ignoreUndefinedProperties,
  });

  final bool? persistenceEnabled;
  final String? host;
  final bool? sslEnabled;
  final int? cacheSizeBytes;
  final bool ignoreUndefinedProperties;
}

// We prefix the class name with `Auth` to avoid a conflict with
// other classes in other packages.
class FirestorePigeonFirebaseApp {
  const FirestorePigeonFirebaseApp({
    required this.appName,
    required this.settings,
    required this.databaseURL,
  });

  final String appName;
  final PigeonFirebaseSettings settings;
  final String databaseURL;
}

class PigeonSnapshotMetadata {
  const PigeonSnapshotMetadata({
    required this.hasPendingWrites,
    required this.isFromCache,
  });

  final bool hasPendingWrites;
  final bool isFromCache;
}

class PigeonDocumentSnapshot {
  const PigeonDocumentSnapshot({
    required this.path,
    required this.data,
    required this.metadata,
  });

  final String path;
  final Map<String?, Object?>? data;
  final PigeonSnapshotMetadata metadata;
}

/// An enumeration of document change types.
enum DocumentChangeType {
  /// Indicates a new document was added to the set of documents matching the
  /// query.
  added,

  /// Indicates a document within the query was modified.
  modified,

  /// Indicates a document within the query was removed (either deleted or no
  /// longer matches the query.
  removed,
}

class PigeonDocumentChange {
  const PigeonDocumentChange({
    required this.type,
    required this.document,
    required this.oldIndex,
    required this.newIndex,
  });

  final DocumentChangeType type;
  final PigeonDocumentSnapshot document;
  final int oldIndex;
  final int newIndex;
}

class PigeonQuerySnapshot {
  const PigeonQuerySnapshot({
    required this.documents,
    required this.documentChanges,
    required this.metadata,
  });

  final List<PigeonDocumentSnapshot?> documents;
  final List<PigeonDocumentChange?> documentChanges;
  final PigeonSnapshotMetadata metadata;
}

/// An enumeration of firestore source types.
enum Source {
  /// Causes Firestore to try to retrieve an up-to-date (server-retrieved) snapshot, but fall back to
  /// returning cached data if the server can't be reached.
  serverAndCache,

  /// Causes Firestore to avoid the cache, generating an error if the server cannot be reached. Note
  /// that the cache will still be updated if the server request succeeds. Also note that
  /// latency-compensation still takes effect, so any pending write operations will be visible in the
  /// returned data (merged into the server-provided data).
  server,

  /// Causes Firestore to immediately return a value from the cache, ignoring the server completely
  /// (implying that the returned value may be stale with respect to the value on the server). If
  /// there is no data in the cache to satisfy the `get` call,
  /// [DocumentReference.get] will throw a [FirebaseException] and
  /// [Query.get] will return an empty [QuerySnapshotPlatform] with no documents.
  cache,
}

enum ServerTimestampBehavior {
  /// Return null for [FieldValue.serverTimestamp()] values that have not yet
  none,

  /// Return local estimates for [FieldValue.serverTimestamp()] values that have not yet been set to their final value.
  estimate,

  /// Return the previous value for [FieldValue.serverTimestamp()] values that have not yet been set to their final value.
  previous,
}

/// [AggregateSource] represents the source of data for an [AggregateQuery].
enum AggregateSource {
  /// Indicates that the data should be retrieved from the server.
  server,
}

class PigeonGetOptions {
  const PigeonGetOptions({
    required this.source,
    required this.serverTimestampBehavior,
  });

  final Source source;
  final ServerTimestampBehavior serverTimestampBehavior;
}

enum PigeonTransactionResult {
  success,
  failure,
}

enum PigeonTransactionType {
  get,
  update,
  set,
  // To prevent collide on C++ side, we use `deleteType` instead of `delete`.
  deleteType,
}

class PigeonDocumentOption {
  const PigeonDocumentOption({
    required this.merge,
    required this.mergeFields,
  });

  final bool? merge;
  final List<List<String?>?>? mergeFields;
}

class PigeonTransactionCommand {
  const PigeonTransactionCommand({
    required this.type,
    required this.path,
    required this.data,
    this.option,
  });

  final PigeonTransactionType type;
  final String path;
  final Map<String?, Object?>? data;
  final PigeonDocumentOption? option;
}

class DocumentReferenceRequest {
  const DocumentReferenceRequest({
    required this.path,
    this.data,
    this.option,
    this.source,
    this.serverTimestampBehavior,
  });
  final String path;
  final Map<Object?, Object?>? data;
  final PigeonDocumentOption? option;
  final Source? source;
  final ServerTimestampBehavior? serverTimestampBehavior;
}

class PigeonQueryParameters {
  const PigeonQueryParameters({
    this.where,
    this.orderBy,
    this.limit,
    this.startAt,
    this.startAfter,
    this.endAt,
    this.endBefore,
    this.limitToLast,
    this.filters,
  });

  final List<List<Object?>?>? where;
  final List<List<Object?>?>? orderBy;
  final int? limit;
  final int? limitToLast;
  final List<Object?>? startAt;
  final List<Object?>? startAfter;
  final List<Object?>? endAt;
  final List<Object?>? endBefore;
  final Map<String?, Object?>? filters;
}

@HostApi(dartHostTestHandler: 'TestFirebaseFirestoreHostApi')
abstract class FirebaseFirestoreHostApi {
  @async
  String loadBundle(
    FirestorePigeonFirebaseApp app,
    Uint8List bundle,
  );

  @async
  PigeonQuerySnapshot namedQueryGet(
    FirestorePigeonFirebaseApp app,
    String name,
    PigeonGetOptions options,
  );

  @async
  void clearPersistence(
    FirestorePigeonFirebaseApp app,
  );

  @async
  void disableNetwork(
    FirestorePigeonFirebaseApp app,
  );

  @async
  void enableNetwork(
    FirestorePigeonFirebaseApp app,
  );

  @async
  void terminate(
    FirestorePigeonFirebaseApp app,
  );

  @async
  void waitForPendingWrites(
    FirestorePigeonFirebaseApp app,
  );

  @async
  void setIndexConfiguration(
    FirestorePigeonFirebaseApp app,
    String indexConfiguration,
  );

  @async
  void setLoggingEnabled(
    bool loggingEnabled,
  );

  @async
  String snapshotsInSyncSetup(
    FirestorePigeonFirebaseApp app,
  );

  @async
  String transactionCreate(
    FirestorePigeonFirebaseApp app,
    int timeout,
    int maxAttempts,
  );

  @async
  void transactionStoreResult(
    String transactionId,
    PigeonTransactionResult resultType,
    List<PigeonTransactionCommand?>? commands,
  );

  @async
  PigeonDocumentSnapshot transactionGet(
    FirestorePigeonFirebaseApp app,
    String transactionId,
    String path,
  );

  @async
  void documentReferenceSet(
    FirestorePigeonFirebaseApp app,
    DocumentReferenceRequest request,
  );

  @async
  void documentReferenceUpdate(
    FirestorePigeonFirebaseApp app,
    DocumentReferenceRequest request,
  );

  @async
  PigeonDocumentSnapshot documentReferenceGet(
    FirestorePigeonFirebaseApp app,
    DocumentReferenceRequest request,
  );

  @async
  void documentReferenceDelete(
    FirestorePigeonFirebaseApp app,
    DocumentReferenceRequest request,
  );

  @async
  PigeonQuerySnapshot queryGet(
    FirestorePigeonFirebaseApp app,
    String path,
    bool isCollectionGroup,
    PigeonQueryParameters parameters,
    PigeonGetOptions options,
  );

  @async
  double aggregateQueryCount(
    FirestorePigeonFirebaseApp app,
    String path,
    PigeonQueryParameters parameters,
    AggregateSource source,
    bool isCollectionGroup,
  );

  @async
  void writeBatchCommit(
    FirestorePigeonFirebaseApp app,
    List<PigeonTransactionCommand?> writes,
  );

  @async
  String querySnapshot(
    FirestorePigeonFirebaseApp app,
    String path,
    bool isCollectionGroup,
    PigeonQueryParameters parameters,
    PigeonGetOptions options,
    bool includeMetadataChanges,
  );

  @async
  String documentReferenceSnapshot(
    FirestorePigeonFirebaseApp app,
    DocumentReferenceRequest parameters,
    bool includeMetadataChanges,
  );
}
