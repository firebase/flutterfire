// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A [DocumentReference] refers to a document location in a Firestore database
/// and can be used to write, read, or listen to the location.
///
/// The document at the referenced location may or may not exist.
/// A [DocumentReference] can also be used to create a [CollectionReference]
/// to a subcollection.
class DocumentReference {
  platform.DocumentReferencePlatform _delegate;

  /// The Firestore instance associated with this document reference
  final Firestore firestore;

  DocumentReference._(this._delegate, this.firestore) {
    platform.DocumentReferencePlatform.verifyExtends(_delegate);
  }

  @override
  bool operator ==(dynamic o) =>
      o is DocumentReference && o.firestore == firestore && o.path == path;

  @override
  int get hashCode => hashList(_delegate.path.split("/"));

  /// Parent returns the containing [CollectionReference].
  CollectionReference parent() {
    return CollectionReference._(_delegate.parent(), firestore);
  }

  /// Slash-delimited path representing the database location of this query.
  String get path => _delegate.path;

  /// This document's given or generated ID in the collection.
  String get documentID => _delegate.documentID;

  /// Writes to the document referred to by this [DocumentReference].
  ///
  /// If the document does not yet exist, it will be created.
  ///
  /// If [merge] is true, the provided data will be merged into an
  /// existing document instead of overwriting.
  Future<void> setData(Map<String, dynamic> data, {bool merge = false}) {
    return _delegate.setData(_CodecUtility.replaceValueWithDelegatesInMap(data),
        merge: merge);
  }

  /// Updates fields in the document referred to by this [DocumentReference].
  ///
  /// Values in [data] may be of any supported Firestore type as well as
  /// special sentinel [FieldValue] type.
  ///
  /// If no document exists yet, the update will fail.
  Future<void> updateData(Map<String, dynamic> data) {
    return _delegate
        .updateData(_CodecUtility.replaceValueWithDelegatesInMap(data));
  }

  /// Reads the document referenced by this [DocumentReference].
  ///
  /// If no document exists, the read will return null.
  Future<DocumentSnapshot> get({
    platform.Source source = platform.Source.serverAndCache,
  }) async {
    return DocumentSnapshot._(await _delegate.get(source: source), firestore);
  }

  /// Deletes the document referred to by this [DocumentReference].
  Future<void> delete() => _delegate.delete();

  /// Returns the reference of a collection contained inside of this
  /// document.
  CollectionReference collection(String collectionPath) {
    return firestore.collection(
      <String>[path, collectionPath].join('/'),
    );
  }

  /// Notifies of documents at this location
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) =>
      _delegate
          .snapshots(includeMetadataChanges: includeMetadataChanges)
          .map((snapshot) => DocumentSnapshot._(snapshot, firestore));
}
