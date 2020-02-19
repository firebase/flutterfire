// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// The entry point for accessing a Firestore.
///
/// You can get an instance by calling [Firestore.instance].
class Firestore {
  // Cached and lazily loaded instance of [FirestorePlatform] to avoid
  // creating a [MethodChannelFirestore] when not needed or creating an
  // instance with the default app before a user specifies an app.
  platform.FirestorePlatform _delegatePackingProperty;

  platform.FirestorePlatform get _delegate {
    if (_delegatePackingProperty == null) {
      _delegatePackingProperty = platform.FirestorePlatform.instance;
    }
    return _delegatePackingProperty;
  }

  Firestore({FirebaseApp app})
      : _delegatePackingProperty = app != null
            ? platform.FirestorePlatform.instanceFor(app: app)
            : platform.FirestorePlatform.instance;

  /// Gets the instance of Firestore for the default Firebase app.
  static Firestore get instance => Firestore();

  /// The [FirebaseApp] instance to which this [Firestore] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.
  FirebaseApp get app => _delegate.app;

  /// Creates a write batch, used for performing multiple writes as a single
  /// atomic operation.
  ///
  /// Unlike transactions, write batches are persisted offline and therefore are
  /// preferable when you don’t need to condition your writes on read data.
  WriteBatch batch() => WriteBatch._(_delegate.batch());

  /// Gets a [CollectionReference] for the specified Firestore path.
  CollectionReference collection(String path) {
    assert(path != null);
    return CollectionReference._(_delegate.collection(path), this);
  }

  /// Gets a [Query] for the specified collection group.
  Query collectionGroup(String path) =>
      Query._(_delegate.collectionGroup(path), this);

  /// Gets a [DocumentReference] for the specified Firestore path.
  DocumentReference document(String path) =>
      DocumentReference._(_delegate.document(path), this);

  @Deprecated('Use the persistenceEnabled parameter of the [settings] method')
  Future<void> enablePersistence(bool enable) =>
      _delegate.enablePersistence(enable);

  /// Executes the given TransactionHandler and then attempts to commit the
  /// changes applied within an atomic transaction.
  ///
  /// In the TransactionHandler, a set of reads and writes can be performed
  /// atomically using the Transaction object passed to the TransactionHandler.
  /// After the TransactionHandler is run, Firestore will attempt to apply the
  /// changes to the server. If any of the data read has been modified outside
  /// of this transaction since being read, then the transaction will be
  /// retried by executing the updateBlock again. If the transaction still
  /// fails after 5 retries, then the transaction will fail.
  ///
  /// The TransactionHandler may be executed multiple times, it should be able
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
      {Duration timeout = const Duration(seconds: 5)}) {
    return _delegate.runTransaction(
        (platformTransaction) =>
            transactionHandler(Transaction._(platformTransaction, this)),
        timeout: timeout);
  }

  Future<void> settings(
          {bool persistenceEnabled,
          String host,
          bool sslEnabled,
          int cacheSizeBytes}) =>
      _delegate.settings(
          persistenceEnabled: persistenceEnabled,
          host: host,
          sslEnabled: sslEnabled,
          cacheSizeBytes: cacheSizeBytes);
}
