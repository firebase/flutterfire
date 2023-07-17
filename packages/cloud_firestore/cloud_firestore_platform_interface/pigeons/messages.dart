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
    objcHeaderOut: '../cloud_firestore/ios/Classes/messages.g.h',
    objcSourceOut: '../cloud_firestore/ios/Classes/messages.g.m',
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

class PigeonFirebaseApp {
  const PigeonFirebaseApp({
    required this.appName,
    required this.settings,
  });

  final String appName;
  final PigeonFirebaseSettings settings;
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

enum ChangeType {
  /// Indicates a new document was added to the set of documents matching the query.
  added,

  /// Indicates a document within the query was modified.
  modified,

  /// Indicates a document within the query was removed (either deleted or no longer matches the
  /// query.
  removed
}

class PigeonDocumentChange {
  const PigeonDocumentChange({
    required this.type,
    required this.document,
    required this.oldIndex,
    required this.newIndex,
  });

  final ChangeType type;
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

class PigeonGetOptions {
  const PigeonGetOptions({
    required this.source,
    required this.serverTimestampBehavior,
  });

  final Source source;
  final ServerTimestampBehavior serverTimestampBehavior;
}

@HostApi(dartHostTestHandler: 'TestFirebaseFirestoreHostApi')
abstract class FirebaseFirestoreHostApi {
  @async
  String loadBundle(
    PigeonFirebaseApp app,
    Uint8List bundle,
  );

  @async
  PigeonQuerySnapshot namedQueryGet(
    PigeonFirebaseApp app,
    String name,
    PigeonGetOptions options,
  );
}
