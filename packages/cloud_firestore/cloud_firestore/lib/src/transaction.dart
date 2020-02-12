// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// The [TransactionHandler] may be executed multiple times; it should be able
/// to handle multiple executions.
typedef Future<dynamic> TransactionHandler(Transaction transaction);

class Transaction {
  final Firestore _firestore;

  Transaction._(this._delegate, this._firestore) {
    platform.TransactionPlatform.verifyExtends(_delegate);
  }

  platform.TransactionPlatform _delegate;

  // ignore: unused_element
  Future<void> _finish() => _delegate.finish();

  /// Reads the document referenced by the provided DocumentReference.
  Future<DocumentSnapshot> get(DocumentReference documentReference) async {
    final result = await _delegate.get(documentReference._delegate);
    if (result != null) {
      return DocumentSnapshot._(result, _firestore);
    } else {
      return null;
    }
  }

  /// Deletes the document referred to by the provided [documentReference].
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> delete(DocumentReference documentReference) {
    return _delegate.delete(documentReference._delegate);
  }

  /// Updates fields in the document referred to by [documentReference].
  /// The update will fail if applied to a document that does not exist.
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    return _delegate.update(documentReference._delegate,
        _CodecUtility.replaceValueWithDelegatesInMap(data));
  }

  /// Writes to the document referred to by the provided [DocumentReference].
  /// If the document does not exist yet, it will be created. If you pass
  /// SetOptions, the provided data can be merged into the existing document.
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> set(
      DocumentReference documentReference, Map<String, dynamic> data) {
    return _delegate.set(documentReference._delegate,
        _CodecUtility.replaceValueWithDelegatesInMap(data));
  }
}
