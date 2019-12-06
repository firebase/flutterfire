// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart' show required, visibleForTesting;

import 'src/method_channel_cloud_firestore.dart';

import 'src/types.dart';

export 'src/types.dart';

/// The interface that implementations of `cloud_firestore` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `cloud_firestore` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [CloudFirestorePlatform] methods.
abstract class CloudFirestorePlatform {
  /// Only mock implementations should set this to `true`.
  ///
  /// Mockito mocks implement this class with `implements` which is forbidden
  /// (see class docs). This property provides a backdoor for mocks to skip the
  /// verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;

  /// The default instance of [CloudFirestorePlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [CloudFirestorePlatform] when they register themselves.
  ///
  /// Defaults to [MethodChannelCloudFirestore].
  static CloudFirestorePlatform get instance => _instance;

  static CloudFirestorePlatform _instance = MethodChannelCloudFirestore();

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(CloudFirestorePlatform instance) {
    if (!instance.isMock) {
      try {
        instance._verifyProvidesDefaultImplementations();
      } on NoSuchMethodError catch (_) {
        throw AssertionError(
            'Platform interfaces must not be implemented with `implements`');
      }
    }
    _instance = instance;
  }

  /// This method ensures that [CloudFirestorePlatform] isn't implemented with `implements`.
  ///
  /// See class docs for more details on why using `implements` to implement
  /// [CloudFirestorePlatform] is forbidden.
  ///
  /// This private method is called by the [instance] setter, which should fail
  /// if the provided instance is a class implemented with `implements`.
  void _verifyProvidesDefaultImplementations() {}

  // Actual API 
  // Global
  /// Removes any listener by its handle.
  /// All handles must be unique across al types of listeners.
  Future<void> removeListener(int handle) async {
    throw UnimplementedError('removeListener() is not implemented');
  }

  // Firestore
  Future<void> enablePersistence(String app, {@required bool enable}) async {
    throw UnimplementedError('enablePersistence() is not implemented');
  }

  Future<void> settings(String app, {
      bool persistenceEnabled,
      String host,
      bool sslEnabled,
      int cacheSizeBytes,
    }) async {
    throw UnimplementedError('settings() is not implemented');
  }

  Future<Map<String, dynamic>> runTransaction(String app, {
    @required PlatformTransactionHandler transactionHandler,
    int transactionTimeout,
  }) async {
    throw UnimplementedError('runTransaction() is not implemented');
  }

  // Document Reference
  Future<void> setDocumentReferenceData(String app, {
    @required String path,
    Map<String, dynamic> data,
    // TODO: Type https://firebase.google.com/docs/reference/js/firebase.firestore.SetOptions.html 
    Map<String, dynamic> options,
  }) async {
    throw UnimplementedError('setDocumentReferenceData() is not implemented');
  }

  Future<void> updateDocumentReferenceData(String app, {
    @required String path,
    Map<String, dynamic> data,
  }) async {
    throw UnimplementedError('updateDocumentReferenceData() is not implemented');
  }

  // TODO: Type this return
  Future<Map<String, dynamic>> getDocumentReference(String app, {
    @required String path,
    @required String source,
  }) async {
    throw UnimplementedError('getDocumentReference() is not implemented');
  }

  Future<void> deleteDocumentReference(String app, {
    @required String path,
  }) async {
    throw UnimplementedError('deleteDocumentReference() is not implemented');
  }

  Stream<dynamic> getDocumentReferenceSnapshots(String app, {
    @required String path,
    bool includeMetadataChanges,
  }) {
    throw UnimplementedError('addDocumentReferenceSnapshotListener() is not implemented');
  }

  // Query
  Stream<dynamic> getQuerySnapshots(String app, {
    @required String path,
    bool isCollectionGroup,
    Map<String, dynamic> parameters,
    bool includeMetadataChanges,
  }) {
    throw UnimplementedError('getQuerySnapshots() is not implemented');
  }

  //TODO: Type this return
  Future<Map<dynamic, dynamic>> getQueryDocuments(String app, {
    @required String path,
    bool isCollectionGroup,
    Map<String, dynamic> parameters,
    String source,
  }) async {
    throw UnimplementedError('getQueryDocuments() is not implemented');
  }

  // Transaction
  // TODO: Type this return
  Future<Map<String, dynamic>> getTransaction(String app, {
    @required String path,
    @required int transactionId,
  }) async {
    throw UnimplementedError('getTransaction() is not implemented');
  }

  Future<void> deleteTransaction(String app, {
    @required String path,
    @required int transactionId,
  }) async {
    throw UnimplementedError('deleteTransaction() is not implemented');
  }

  Future<void> updateTransaction(String app, {
    @required String path,
    @required int transactionId,
    Map<String, dynamic> data,
  }) async {
    throw UnimplementedError('updateTransaction() is not implemented');
  }

  Future<void> setTransaction(String app, {
    @required String path,
    @required int transactionId,
    Map<String, dynamic> data,
  }) async {
    throw UnimplementedError('setTransaction() is not implemented');
  }

  // Write Batch
  Future<dynamic> createWriteBatch(String app) async {
    throw UnimplementedError('createWriteBatch() is not implemented');
  }

  Future<void> commitWriteBatch({
    @required dynamic handle,
  }) async {
    throw UnimplementedError('commitWriteBatch() is not implemented');
  }

  Future<void> deleteWriteBatch(String app, {
    @required dynamic handle,
    @required String path,
  }) async {
    throw UnimplementedError('deleteWriteBatch() is not implemented');
  }

  Future<void> setWriteBatchData(String app, {
    @required dynamic handle,
    @required String path,
    Map<String, dynamic> data,
    Map<String, dynamic> options,
  }) async {
    throw UnimplementedError('setWriteBatchData() is not implemented');
  }

  Future<void> updateWriteBatchData(String app, {
    @required dynamic handle,
    @required String path,
    Map<String, dynamic> data,
  }) async {
    throw UnimplementedError('updateWriteBatchData() is not implemented');
  }
}
