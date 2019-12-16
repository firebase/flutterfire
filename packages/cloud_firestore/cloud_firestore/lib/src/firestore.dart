// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// The entry point for accessing a Firestore.
///
/// You can get an instance by calling [Firestore.instance].
class Firestore {
  platform.MethodChannelFirestore _platfromFirestore;

  Firestore({FirebaseApp app})
      : _platfromFirestore = platform.MethodChannelFirestore(app: app);

  static MethodChannel get channel => platform.MethodChannelFirestore.channel;

  String appName() => _platfromFirestore.appName();

  WriteBatch batch() => WriteBatch._();

  CollectionReference collection(String path) {
    assert(path != null);
    return CollectionReference._(this, path.split('/'));
  }

  Query collectionGroup(String path) =>
      Query._(delegate: _platfromFirestore.collectionGroup(path));

  DocumentReference document(String path) =>
      DocumentReference._(this, path.split("/"));

  Future<void> enablePersistence(bool enable) =>
      _platfromFirestore.enablePersistence(enable);

  Future<Map<String, dynamic>> runTransaction(transactionHandler,
          {Duration timeout = const Duration(seconds: 5)}) =>
      _platfromFirestore.runTransaction(transactionHandler, timeout: timeout);

  Future<void> settings(
          {bool persistenceEnabled,
          String host,
          bool sslEnabled,
          int cacheSizeBytes}) =>
      _platfromFirestore.settings(
          persistenceEnabled: persistenceEnabled,
          host: host,
          sslEnabled: sslEnabled,
          cacheSizeBytes: cacheSizeBytes);
}
