// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A [DocumentReference] refers to a document location in a [FirebaseFirestore] database
/// and can be used to write, read, or listen to the location.
///
/// The document at the referenced location may or may not exist.
/// A [DocumentReference] can also be used to create a [CollectionReference]
/// to a subcollection.
class DocumentReference {
  DocumentReferencePlatform _delegate;

  /// The Firestore instance associated with this document reference.
  final FirebaseFirestore firestore;

  DocumentReference._(this.firestore, this._delegate) {
    DocumentReferencePlatform.verifyExtends(_delegate);
  }

  /// This document's given ID within the collection.
  String get id => _delegate.id;

  /// The parent [CollectionReference] of this document.
  CollectionReference get parent =>
      CollectionReference._(firestore, _delegate.parent);

  /// A string representing the path of the referenced document (relative to the
  /// root of the database).
  String get path => _delegate.path;

  /// Gets a [CollectionReference] instance that refers to the collection at the
  /// specified path, relative from this [DocumentReference].
  CollectionReference collection(String collectionPath) {
    assert(collectionPath.isNotEmpty,
        'a collectionPath path must be a non-empty string');
    assert(!collectionPath.contains('//'),
        'a collection path must not contain "//"');
    assert(isValidCollectionPath(collectionPath),
        'a collection path must point to a valid collection.');

    return CollectionReference._(
        firestore, _delegate.collection(collectionPath));
  }

  /// Deletes the current document from the collection.
  Future<void> delete() => _delegate.delete();

  /// Reads the document referenced by this [DocumentReference].
  ///
  /// By providing [options], this method can be configured to fetch results only
  /// from the server, only from the local cache or attempt to fetch results
  /// from the server and fall back to the cache (which is the default).
  Future<DocumentSnapshot> get([GetOptions? options]) async {
    return DocumentSnapshot._(
        firestore, await _delegate.get(options ?? const GetOptions()));
  }

  /// Notifies of document updates at this location.
  ///
  /// An initial event is immediately sent, and further events will be
  /// sent whenever the document is modified.
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) =>
      _delegate.snapshots(includeMetadataChanges: includeMetadataChanges).map(
          (delegateSnapshot) =>
              DocumentSnapshot._(firestore, delegateSnapshot));

  /// Sets data on the document, overwriting any existing data. If the document
  /// does not yet exist, it will be created.
  ///
  /// If [SetOptions] are provided, the data will be merged into an existing
  /// document instead of overwriting.
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) {
    return _delegate.set(
        _CodecUtility.replaceValueWithDelegatesInMap(data)!, options);
  }

  /// Updates data on the document. Data will be merged with any existing
  /// document data.
  ///
  /// If no document exists yet, the update will fail.
  Future<void> update(Map<String, dynamic> data) {
    return _delegate
        .update(_CodecUtility.replaceValueWithDelegatesInMap(data)!);
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(dynamic other) =>
      other is DocumentReference &&
      other.firestore == firestore &&
      other.path == path;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => hashValues(firestore, path);

  @override
  String toString() => '$DocumentReference($path)';
}
