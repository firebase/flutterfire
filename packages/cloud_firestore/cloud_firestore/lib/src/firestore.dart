// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// The entry point for accessing a Firestore.
///
/// You can get an instance by calling [Firestore.instance].
class Firestore {
  final platform.FirestorePlatform _delegate;

  Firestore({FirebaseApp app, platform.FirestorePlatform delegate})
      : _delegate = delegate ?? platform.FirestorePlatform.instance;

  static MethodChannel get channel => platform.MethodChannelFirestore.channel;

  static Firestore get instance =>
      Firestore(delegate: platform.FirestorePlatform.instance);

  String appName() => _delegate.appName();

  WriteBatch batch() => WriteBatch._(_delegate.batch());

  CollectionReference collection(String path) {
    assert(path != null);
    return CollectionReference._(_delegate.collection(path));
  }

  Query collectionGroup(String path) =>
      Query._(_delegate.collectionGroup(path));

  DocumentReference document(String path) =>
      DocumentReference._(_delegate.document(path));

  @deprecated
  Future<void> enablePersistence(bool enable) =>
      _delegate.enablePersistence(enable);

  Future<Map<String, dynamic>> runTransaction(
      TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) {
    return _delegate.runTransaction(
        (platformTransaction) =>
            transactionHandler(Transaction._(platformTransaction)),
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
