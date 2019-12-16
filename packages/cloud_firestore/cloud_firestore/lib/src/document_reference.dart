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
  platform.MethodChannelDocumentReference _delegate;
  DocumentReference._(this.firestore, List<String> pathComponents)
      : _pathComponents = pathComponents,
  _delegate = platform.MethodChannelDocumentReference(platform.FirestorePlatform.instance, pathComponents),
        assert(firestore != null);

  /// The Firestore instance associated with this document reference
  final Firestore firestore;

  final List<String> _pathComponents;

  @override
  bool operator ==(dynamic o) =>
      o is DocumentReference && o.firestore == firestore && o.path == path;

  @override
  int get hashCode => hashList(_pathComponents);

  /// Parent returns the containing [CollectionReference].
  CollectionReference parent() {
    return CollectionReference._(
      firestore,
      (List<String>.from(_pathComponents)..removeLast()),
    );
  }

  /// Slash-delimited path representing the database location of this query.
  String get path => _pathComponents.join('/');

  /// This document's given or generated ID in the collection.
  String get documentID => _pathComponents.last;

  /// Writes to the document referred to by this [DocumentReference].
  ///
  /// If the document does not yet exist, it will be created.
  ///
  /// If [merge] is true, the provided data will be merged into an
  /// existing document instead of overwriting.
  Future<void> setData(Map<String, dynamic> data, {bool merge = false}) {
    return _delegate.setData(data,merge: merge);
  }

  /// Updates fields in the document referred to by this [DocumentReference].
  ///
  /// Values in [data] may be of any supported Firestore type as well as
  /// special sentinel [FieldValue] type.
  ///
  /// If no document exists yet, the update will fail.
  Future<void> updateData(Map<String, dynamic> data) {
    return _delegate.updateData(data);
  }

  /// Reads the document referenced by this [DocumentReference].
  ///
  /// If no document exists, the read will return null.
  Future<DocumentSnapshot> get({Source source = Source.serverAndCache}) async {
    return DocumentSnapshot._(
      await _delegate.get(source: _fromPlatformSource(source)),
      firestore,
    );
  }

  platform.Source _fromPlatformSource(Source platformSource) {
    switch(platformSource) {
      case Source.cache:
        return platform.Source.cache;
      case Source.server:
        return platform.Source.server;
      case Source.serverAndCache:
        return platform.Source.serverAndCache;
      default:
        throw ArgumentError("Invalid source value");

    }
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
      _delegate.snapshots(includeMetadataChanges: includeMetadataChanges)
      .map((snapshot) => DocumentSnapshot._(snapshot, firestore));
}
