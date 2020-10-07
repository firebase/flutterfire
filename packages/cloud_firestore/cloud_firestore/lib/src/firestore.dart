// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// The entry point for accessing a [FirebaseFirestore].
///
/// You can get an instance by calling [FirebaseFirestore.instance]. The instance
/// can also be created with a secondary [Firebase] app by calling
/// [FirebaseFirestore.instanceFor], for example:
///
/// ```dart
/// FirebaseApp secondaryApp = Firebase.app('SecondaryApp');
///
/// FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: secondaryApp);
/// ```
class FirebaseFirestore extends FirebasePluginPlatform {
  // Cached and lazily loaded instance of [FirestorePlatform] to avoid
  // creating a [MethodChannelFirestore] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseFirestorePlatform _delegatePackingProperty;

  FirebaseFirestorePlatform get _delegate {
    if (_delegatePackingProperty == null) {
      _delegatePackingProperty =
          FirebaseFirestorePlatform.instanceFor(app: app);
    }
    return _delegatePackingProperty;
  }

  /// The [FirebaseApp] for this current [FirebaseFirestore] instance.
  FirebaseApp app;

  FirebaseFirestore._({this.app})
      : super(app.name, 'plugins.flutter.io/firebase_firestore');

  static final Map<String, FirebaseFirestore> _cachedInstances = {};

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseFirestore get instance {
    return FirebaseFirestore.instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp].
  static FirebaseFirestore instanceFor({FirebaseApp app}) {
    assert(app != null);
    if (_cachedInstances.containsKey(app.name)) {
      return _cachedInstances[app.name];
    }

    FirebaseFirestore newInstance = FirebaseFirestore._(app: app);
    _cachedInstances[app.name] = newInstance;

    return newInstance;
  }

  // ignore: public_member_api_docs
  @Deprecated(
      "Constructing Firestore is deprecated, use 'FirebaseFirestore.instance' or 'FirebaseFirestore.instanceFor' instead")
  factory FirebaseFirestore({FirebaseApp app}) {
    return FirebaseFirestore.instanceFor(app: app);
  }

  /// Gets a [CollectionReference] for the specified Firestore path.
  CollectionReference collection(String collectionPath) {
    assert(collectionPath != null, "a collection path cannot be null");
    assert(collectionPath.isNotEmpty,
        "a collectionPath path must be a non-empty string");
    assert(!collectionPath.contains("//"),
        "a collection path must not contain '//'");
    assert(isValidCollectionPath(collectionPath),
        "a collection path must point to a valid collection.");

    return CollectionReference._(this, _delegate.collection(collectionPath));
  }

  /// Returns a [WriteBatch], used for performing multiple writes as a single
  /// atomic operation.
  ///
  /// Unlike [Transaction]s, [WriteBatch]es are persisted offline and therefore are
  /// preferable when you don’t need to condition your writes on read data.
  WriteBatch batch() {
    return WriteBatch._(this, _delegate.batch());
  }

  /// Clears any persisted data for the current instance.
  Future<void> clearPersistence() {
    return _delegate.clearPersistence();
  }

  /// Enable persistence of Firestore data.
  /// This is a web only method. Use [Settings.persistenceEnabled] for non Web platforms.
  Future<void> enablePersistence() async {
    return _delegate.enablePersistence();
  }

  /// Gets a [Query] for the specified collection group.
  Query collectionGroup(String collectionPath) {
    assert(collectionPath != null, "a collection path cannot be null");
    assert(collectionPath.isNotEmpty,
        "a collection path must be a non-empty string");
    assert(!collectionPath.contains("/"),
        "a collection path passed to collectionGroup() cannot contain '/'");

    return Query._(this, _delegate.collectionGroup(collectionPath));
  }

  /// Instructs [FirebaseFirestore] to disable the network for the instance.
  ///
  /// Once disabled, any writes will only resolve once connection has been
  /// restored. However, the local database will still be updated and any
  /// listeners will still trigger.
  Future<void> disableNetwork() {
    return _delegate.disableNetwork();
  }

  /// Gets a [DocumentReference] for the specified Firestore path.
  DocumentReference doc(String documentPath) {
    assert(documentPath != null, "a document path cannot be null");
    assert(
        documentPath.isNotEmpty, "a document path must be a non-empty string");
    assert(!documentPath.contains("//"),
        "a collection path must not contain '//'");
    assert(isValidDocumentPath(documentPath),
        "a document path must point to a valid document.");

    return DocumentReference._(this, _delegate.doc(documentPath));
  }

  @Deprecated("Deprecated in favor of `.doc()`")
  // ignore: public_member_api_docs
  DocumentReference document(String documentPath) => doc(documentPath);

  /// Enables the network for this instance. Any pending local-only writes
  /// will be written to the remote servers.
  Future<void> enableNetwork() {
    return _delegate.enableNetwork();
  }

  /// Returns a [Stream] which is called each time all of the active listeners
  /// have been synchronised.
  Stream<void> snapshotsInSync() {
    return _delegate.snapshotsInSync();
  }

  /// Executes the given [TransactionHandler] and then attempts to commit the
  /// changes applied within an atomic transaction.
  ///
  /// In the [TransactionHandler], a set of reads and writes can be performed
  /// atomically using the [Transaction] object passed to the [TransactionHandler].
  /// After the [TransactionHandler] is run, [FirebaseFirestore] will attempt to apply the
  /// changes to the server. If any of the data read has been modified outside
  /// of this [Transaction] since being read, then the transaction will be
  /// retried by executing the provided [TransactionHandler] again. If the transaction still
  /// fails after 5 retries, then the transaction will fail.s
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
  Future<T> runTransaction<T>(TransactionHandler<T> transactionHandler,
      {Duration timeout = const Duration(seconds: 30)}) async {
    assert(transactionHandler != null, "transactionHandler cannot be null");

    T output;
    await _delegate.runTransaction((transaction) async {
      output = await transactionHandler(Transaction._(this, transaction));
    }, timeout: timeout);

    return output;
  }

  /// Specifies custom settings to be used to configure this [FirebaseFirestore] instance.
  ///
  /// You must set these before invoking any other methods on this [FirebaseFirestore] instance.
  set settings(Settings settings) {
    _delegate.settings = settings;
  }

  /// The current [Settings] for this [FirebaseFirestore] instance.
  Settings get settings {
    return _delegate.settings;
  }

  /// Terminates this [FirebaseFirestore] instance.
  ///
  /// After calling [terminate()] only the [clearPersistence()] method may be used.
  /// Any other method will throw a [FirebaseException].
  ///
  /// Termination does not cancel any pending writes, and any promises that are
  /// awaiting a response from the server will not be resolved. If you have
  /// persistence enabled, the next time you start this instance, it will resume
  ///  sending these writes to the server.
  ///
  /// Note: Under normal circumstances, calling [terminate()] is not required.
  /// This method is useful only when you want to force this instance to release
  ///  all of its resources or in combination with [clearPersistence()] to ensure
  ///  that all local state is destroyed between test runs.
  Future<void> terminate() {
    return _delegate.terminate();
  }

  /// Waits until all currently pending writes for the active user have been
  /// acknowledged by the backend.
  ///
  /// The returned Future resolves immediately if there are no outstanding writes.
  /// Otherwise, the Promise waits for all previously issued writes (including
  /// those written in a previous app session), but it does not wait for writes
  /// that were added after the method is called. If you want to wait for
  /// additional writes, call [waitForPendingWrites] again.
  ///
  /// Any outstanding [waitForPendingWrites] calls are rejected during user changes.
  Future<void> waitForPendingWrites() {
    return _delegate.waitForPendingWrites();
  }

  @override
  bool operator ==(dynamic o) =>
      o is FirebaseFirestore && o.app.name == app.name;

  @override
  int get hashCode => hash2(app.name, app.options);

  @override
  String toString() => '$FirebaseFirestore(app: ${app.name})';
}

/// Extends the [FirebaseFirestore] class to allow for deprecated usage of
/// using [Firebase] directly.
@Deprecated("Class Firestore is deprecated, use 'FirebaseFirestore' instead.")
class Firestore extends FirebaseFirestore {
  // ignore: public_member_api_docs
  @Deprecated(
      "Constructing Firestore is deprecated, use 'FirebaseFirestore.instance' or 'FirebaseFirestore.instanceFor' instead")
  factory Firestore({FirebaseApp app}) {
    return FirebaseFirestore.instanceFor(app: app);
  }

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseFirestore get instance {
    return FirebaseFirestore.instance;
  }

  /// Returns an instance using a specified [FirebaseApp].
  static FirebaseFirestore instanceFor({FirebaseApp app}) {
    return FirebaseFirestore.instanceFor(app: app);
  }
}
