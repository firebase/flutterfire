// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// The TransactionHandler may be executed multiple times, it should be able
/// to handle multiple executions.
typedef Future<dynamic> TransactionHandler(TransactionPlatform transaction);

/// a [TransactionPlatform] is a set of read and write operations on one or more documents.
abstract class TransactionPlatform extends PlatformInterface {
  // disabling lint as it's only visible for testing
  // ignore: public_member_api_docs
  @visibleForTesting
  TransactionPlatform(this._transactionId, this.firestore) : super(token: _token);

  static final Object _token = Object();

  int _transactionId;

  /// [FirestorePlatform] instance used for this [TransactionPlatform]
  FirestorePlatform firestore;
  List<Future<dynamic>> _pendingResults = <Future<dynamic>>[];

  /// executes all the pending operations on the transaction
  Future<void> finish() => Future.wait<void>(_pendingResults);

  /// Reads the document referenced by the provided DocumentReference.
  Future<DocumentSnapshot> get(DocumentReferencePlatform documentReference) {
    final Future<DocumentSnapshot> result = _get(documentReference);
    _pendingResults.add(result);
    return result;
  }

  Future<DocumentSnapshot> _get(DocumentReferencePlatform documentReference) async {
    throw UnimplementedError("get() not implemented");
  }

  /// Deletes the document referred to by the provided [documentReference].
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> delete(DocumentReferencePlatform documentReference) {
    final Future<void> result = _delete(documentReference);
    _pendingResults.add(result);
    return result;
  }

  Future<void> _delete(DocumentReferencePlatform documentReference) async {
    throw UnimplementedError("delete() not implemented");
  }

  /// Updates fields in the document referred to by [documentReference].
  /// The update will fail if applied to a document that does not exist.
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> update(
      DocumentReferencePlatform documentReference, Map<String, dynamic> data) async {
    final Future<void> result = _update(documentReference, data);
    _pendingResults.add(result);
    return result;
  }

  Future<void> _update(
      DocumentReferencePlatform documentReference, Map<String, dynamic> data) async {
    throw UnimplementedError("updated() not implemented");
  }

  /// Writes to the document referred to by the provided [DocumentReferencePlatform].
  /// If the document does not exist yet, it will be created. If you pass
  /// SetOptions, the provided data can be merged into the existing document.
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> set(
      DocumentReferencePlatform documentReference, Map<String, dynamic> data) {
    final Future<void> result = _set(documentReference, data);
    _pendingResults.add(result);
    return result;
  }

  Future<void> _set(
      DocumentReferencePlatform documentReference, Map<String, dynamic> data) async {
    throw UnimplementedError("set() not implemented");
  }
}
