// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A [WriteBatch] is a series of write operations to be performed as one unit.
///
/// Operations done on a [WriteBatch] do not take effect until you [commit()].
///
/// Once committed, no further operations can be performed on the [WriteBatch],
/// nor can it be committed again.
class WriteBatch {
  final FirebaseFirestore _firestore;
  final WriteBatchPlatform _delegate;

  WriteBatch._(this._firestore, this._delegate) {
    WriteBatchPlatform.verifyExtends(_delegate);
  }

  /// Commits all of the writes in this write batch as a single atomic unit.
  ///
  /// Calling this method prevents any future operations from being added.
  Future<void> commit() => _delegate.commit();

  /// Deletes the document referred to by [document].
  void delete(DocumentReference document) {
    assert(document != null);
    assert(document.firestore == _firestore,
        "the document provided is from a different Firestore instance");
    return _delegate.delete(document.path);
  }

  /// Writes to the document referred to by [document].
  ///
  /// If the document does not yet exist, it will be created.
  ///
  /// If [SetOptions] are provided, the data will be merged into an existing
  /// document instead of overwriting.
  void set(DocumentReference document, Map<String, dynamic> data,
      [SetOptions options]) {
    assert(document != null);
    assert(data != null);
    assert(document.firestore == _firestore,
        "the document provided is from a different Firestore instance");
    return _delegate.set(document.path,
        _CodecUtility.replaceValueWithDelegatesInMap(data), options);
  }

  @Deprecated("Deprecated in favor of `.set`")
  // ignore: public_member_api_docs
  void setData(DocumentReference document, Map<String, dynamic> data,
      [SetOptions options]) {
    return set(document, data, options);
  }

  /// Updates a given [document].
  ///
  /// If the document does not yet exist, an exception will be thrown.
  void update(DocumentReference document, Map<String, dynamic> data) {
    assert(document != null);
    assert(data != null);
    assert(document.firestore == _firestore,
        "the document provided is from a different Firestore instance");
    return _delegate.update(
        document.path, _CodecUtility.replaceValueWithDelegatesInMap(data));
  }

  @Deprecated("Deprecated in favor of `.update`")
  // ignore: public_member_api_docs
  void updateData(DocumentReference document, Map<String, dynamic> data) {
    return update(document, data);
  }
}
