// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// The TransactionHandler may be executed multiple times, it should be able
/// to handle multiple executions.
typedef Future<dynamic> TransactionHandler(TransactionPlatform transaction);

/// a [TransactionPlatform] is a set of read and write operations on one or more documents.
abstract class TransactionPlatform {
  // disabling lint as it's only visible for testing
  // ignore: public_member_api_docs
  @visibleForTesting
  TransactionPlatform(this._transactionId, this.firestore);

  int _transactionId;

  /// [FirestorePlatform] instance used for this [TransactionPlatform]
  FirestorePlatform firestore;
  List<Future<dynamic>> _pendingResults = <Future<dynamic>>[];

  /// Reads the document referenced by the provided DocumentReference.
  Future<DocumentSnapshot> get(DocumentReference documentReference) {
    final Future<DocumentSnapshot> result = _get(documentReference);
    _pendingResults.add(result);
    return result;
  }

  Future<DocumentSnapshot> _get(DocumentReference documentReference) async {
    throw UnimplementedError("get() not implemented");
  }

  /// Deletes the document referred to by the provided [documentReference].
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> delete(DocumentReference documentReference) {
    final Future<void> result = _delete(documentReference);
    _pendingResults.add(result);
    return result;
  }

  Future<void> _delete(DocumentReference documentReference) async {
    throw UnimplementedError("delete() not implemented");
  }

  /// Updates fields in the document referred to by [documentReference].
  /// The update will fail if applied to a document that does not exist.
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    final Future<void> result = _update(documentReference, data);
    _pendingResults.add(result);
    return result;
  }

  Future<void> _update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    throw UnimplementedError("updated() not implemented");
  }

  /// Writes to the document referred to by the provided [DocumentReference].
  /// If the document does not exist yet, it will be created. If you pass
  /// SetOptions, the provided data can be merged into the existing document.
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> set(
      DocumentReference documentReference, Map<String, dynamic> data) {
    final Future<void> result = _set(documentReference, data);
    _pendingResults.add(result);
    return result;
  }

  Future<void> _set(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    throw UnimplementedError("set() not implemented");
  }
}
