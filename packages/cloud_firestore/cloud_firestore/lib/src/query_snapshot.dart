// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

abstract class _QuerySnapshot<DocumentSnapshot> {
  /// Gets a list of all the documents included in this snapshot.
  List<DocumentSnapshot> get docs;

  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as Added changes.
  List<DocumentChange> get docChanges;

  /// Returns the [SnapshotMetadata] for this snapshot.
  SnapshotMetadata get metadata;

  /// Returns the size (number of documents) of this snapshot.
  int get size;
}

/// Contains the results of a query.
/// It can contain zero or more [DocumentSnapshot] objects.
class QuerySnapshot implements _QuerySnapshot<QueryDocumentSnapshot> {
  QuerySnapshot._(this._firestore, this._delegate) {
    QuerySnapshotPlatform.verifyExtends(_delegate);
  }

  final FirebaseFirestore _firestore;
  final QuerySnapshotPlatform _delegate;

  @override
  List<QueryDocumentSnapshot> get docs => _delegate.docs
      .map((documentDelegate) =>
          QueryDocumentSnapshot._(_firestore, documentDelegate))
      .toList();

  @override
  List<DocumentChange> get docChanges => _delegate.docChanges
      .map((documentDelegate) => DocumentChange._(_firestore, documentDelegate))
      .toList();

  @override
  SnapshotMetadata get metadata => SnapshotMetadata._(_delegate.metadata);

  @override
  int get size => _delegate.size;
}

/// Contains the results of a query.
/// It can contain zero or more [DocumentSnapshot] objects.
class WithConverterQuerySnapshot<T>
    implements _QuerySnapshot<WithConverterQueryDocumentSnapshot<T>> {
  WithConverterQuerySnapshot._(this._originalQuerySnapshot, this._fromFirebase);

  final QuerySnapshot _originalQuerySnapshot;
  final FromFirebase<T> _fromFirebase;

  @override
  List<WithConverterQueryDocumentSnapshot<T>> get docs {
    return [
      for (final snapshot in _originalQuerySnapshot.docs)
        WithConverterQueryDocumentSnapshot<T>._(
          snapshot,
          _fromFirebase,
        ),
    ];
  }

  @override
  List<DocumentChange> get docChanges => _originalQuerySnapshot.docChanges;

  @override
  SnapshotMetadata get metadata => _originalQuerySnapshot.metadata;

  @override
  int get size => _originalQuerySnapshot.size;
}
