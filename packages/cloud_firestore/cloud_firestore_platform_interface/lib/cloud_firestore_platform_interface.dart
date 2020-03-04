// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cloud_firestore_platform_interface;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/method_channel/method_channel_firestore.dart';

import 'src/platform_interface/collection_reference.dart';
import 'src/platform_interface/document_reference.dart';
import 'src/platform_interface/query.dart';
import 'src/platform_interface/transaction.dart';
import 'src/platform_interface/write_batch.dart';

// Shared types
export 'src/blob.dart';
export 'src/document_snapshot.dart';
export 'src/field_path.dart';
export 'src/geo_point.dart';
export 'src/snapshot_metadata.dart';
export 'src/source.dart';
export 'src/timestamp.dart';

// Platform interface parts
export 'src/platform_interface/collection_reference.dart';
export 'src/platform_interface/document_change.dart';
export 'src/platform_interface/document_reference.dart';
export 'src/platform_interface/field_value.dart';
export 'src/platform_interface/field_value_factory.dart';
export 'src/platform_interface/query.dart';
export 'src/platform_interface/query_snapshot.dart';
export 'src/platform_interface/transaction.dart';
export 'src/platform_interface/write_batch.dart';

/// Defines an interface to work with [FirestorePlatform] on web and mobile
abstract class FirestorePlatform extends PlatformInterface {
  /// The app associated with this Firestore instance.
  final FirebaseApp app;

  /// Create an instance using [app]
  FirestorePlatform({FirebaseApp app})
      : app = app ?? FirebaseApp.instance,
        super(token: _token);

  static final Object _token = Object();

  /// Create an instance using [app] using the existing implementation
  factory FirestorePlatform.instanceFor({FirebaseApp app}) {
    return FirestorePlatform.instance.withApp(app);
  }

  /// The current default [FirestorePlatform] instance.
  ///
  /// It will always default to [MethodChannelFirestore]
  /// if no web implementation was provided.
  static FirestorePlatform get instance {
    if (_instance == null) {
      _instance = MethodChannelFirestore();
    }
    return _instance;
  }

  static FirestorePlatform _instance;

  /// Sets the [FirestorePlatform.instance]
  static set instance(FirestorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Create a new [FirestorePlatform] with a [FirebaseApp] instance
  FirestorePlatform withApp(FirebaseApp app) {
    throw UnimplementedError("withApp() not implemented");
  }

  /// Gets a [CollectionReferencePlatform] for the specified Firestore path.
  CollectionReferencePlatform collection(String path) {
    throw UnimplementedError('collection() is not implemented');
  }

  /// Gets a [QueryPlatform] for the specified collection group.
  QueryPlatform collectionGroup(String path) {
    throw UnimplementedError('collectionGroup() is not implemented');
  }

  /// Gets a [DocumentReferencePlatform] for the specified Firestore path.
  DocumentReferencePlatform document(String path) {
    throw UnimplementedError('document() is not implemented');
  }

  /// Creates a write batch, used for performing multiple writes as a single
  /// atomic operation.
  ///
  /// Unlike transactions, write batches are persisted offline and therefore are
  /// preferable when you don’t need to condition your writes on read data.
  WriteBatchPlatform batch() {
    throw UnimplementedError('batch() is not implemented');
  }

  /// Executes the given [TransactionHandler] and then attempts to commit the
  /// changes applied within an atomic transaction.
  ///
  /// In the [TransactionHandler], a set of reads and writes can be performed
  /// atomically using the [MethodChannelTransaction] object passed to the [TransactionHandler].
  /// After the [TransactionHandler] is run, Firestore will attempt to apply the
  /// changes to the server. If any of the data read has been modified outside
  /// of this transaction since being read, then the transaction will be
  /// retried by executing the updateBlock again. If the transaction still
  /// fails after 5 retries, then the transaction will fail.
  ///
  /// The [TransactionHandler] may be executed multiple times, it should be able
  /// to handle multiple executions.
  ///
  /// Data accessed with the transaction will not reflect local changes that
  /// have not been committed. For this reason, it is required that all
  /// reads are performed before any writes. Transactions must be performed
  /// while online. Otherwise, reads will fail, and the final commit will fail.
  ///
  /// By default transactions are limited to 5 seconds of execution time. This
  /// timeout can be adjusted by setting the timeout parameter.
  Future<Map<String, dynamic>> runTransaction(
      TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) async {
    throw UnimplementedError('runTransaction() is not implemented');
  }

  @deprecated
  // Suppressing due to deprecation
  // ignore: public_member_api_docs
  Future<void> enablePersistence(bool enable) async {
    throw UnimplementedError('enablePersistence() is not implemented');
  }

  /// Setup [FirestorePlatform] with settings.
  ///
  /// If [sslEnabled] has a non-null value, the [host] must have non-null value as well.
  ///
  /// If [cacheSizeBytes] is `null`, then default values are used.
  Future<void> settings(
      {bool persistenceEnabled,
      String host,
      bool sslEnabled,
      int cacheSizeBytes}) async {
    throw UnimplementedError('settings() is not implemented');
  }

  @override
  int get hashCode => app.name.hashCode;

  @override
  bool operator ==(dynamic o) => o is FirestorePlatform && o.app == app;
}
