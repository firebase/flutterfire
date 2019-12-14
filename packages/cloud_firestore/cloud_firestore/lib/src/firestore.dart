// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// The entry point for accessing a Firestore.
///
/// You can get an instance by calling [Firestore.instance].
class Firestore {
  Firestore({FirebaseApp app}) : app = app ?? FirebaseApp.instance;

  /// The platform instance that talks to the native side of the plugin.
  @visibleForTesting
  static final FirestorePlatform platform = FirestorePlatform.instance ?? (FirestorePlatform.instance = MethodChannelFirestore(FirestoreMessageCodec()));

  /// Gets the instance of Firestore for the default Firebase app.
  static final Firestore instance = Firestore();

  /// The [FirebaseApp] instance to which this [FirebaseDatabase] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.
  final FirebaseApp app;

  @override
  bool operator ==(dynamic o) => o is Firestore && o.app == app;

  @override
  int get hashCode => app.hashCode;

  /// Gets a [CollectionReference] for the specified Firestore path.
  CollectionReference collection(String path) {
    assert(path != null);
    return CollectionReference._(this, path.split('/'));
  }

  /// Gets a [Query] for the specified collection group.
  Query collectionGroup(String path) {
    assert(path != null);
    assert(!path.contains("/"), "Collection IDs must not contain '/'.");
    return Query._(
      firestore: this,
      isCollectionGroup: true,
      pathComponents: path.split('/'),
    );
  }

  /// Gets a [DocumentReference] for the specified Firestore path.
  DocumentReference document(String path) {
    assert(path != null);
    return DocumentReference._(this, path.split('/'));
  }

  /// Creates a write batch, used for performing multiple writes as a single
  /// atomic operation.
  ///
  /// Unlike transactions, write batches are persisted offline and therefore are
  /// preferable when you don’t need to condition your writes on read data.
  WriteBatch batch() => WriteBatch._(this);

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
      {Duration timeout = const Duration(seconds: 5)}) async {
    assert(timeout.inMilliseconds > 0,
        'Transaction timeout must be more than 0 milliseconds');

    // Wrap the user-supplied [TransactionHandler] into something that can be passed to the Platform implementation.
    final PlatformTransactionHandler handler = (PlatformTransaction platformTransaction) async {
      Transaction transaction = Transaction(platformTransaction.transactionId, this);
      final dynamic result = await transactionHandler(transaction);
      await transaction._finish();
      return result;
    };

    final Map<String, dynamic> result = await Firestore.platform.transaction.run(
      app.name,
      updateFunction: handler,
      transactionTimeout: timeout.inMilliseconds,
    );

    return result ?? <String, dynamic>{};
  }

  @deprecated
  Future<void> enablePersistence(bool enable) {
    assert(enable != null);
    return Firestore.platform.enablePersistence(app.name, enable: enable);
  }

  Future<void> settings(
      {bool persistenceEnabled,
      String host,
      bool sslEnabled,
      int cacheSizeBytes}) {

    return Firestore.platform.settings(app.name, 
        persistenceEnabled: persistenceEnabled,
        host: host,
        sslEnabled: sslEnabled,
        cacheSizeBytes: cacheSizeBytes,
      );
  }
}
