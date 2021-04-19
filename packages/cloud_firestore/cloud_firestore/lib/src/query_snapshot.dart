// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// Contains the results of a query.
/// It can contain zero or more [DocumentSnapshot] objects.
class QuerySnapshot {
  final FirebaseFirestore _firestore;
  final QuerySnapshotPlatform _delegate;

  QuerySnapshot._(this._firestore, this._delegate) {
    QuerySnapshotPlatform.verifyExtends(_delegate);
  }

  /// Gets a list of all the documents included in this snapshot.
  List<QueryDocumentSnapshot> get docs => _delegate.docs
      .map((documentDelegate) =>
          QueryDocumentSnapshot._(_firestore, documentDelegate))
      .toList();

  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as Added changes.
  List<DocumentChange> get docChanges => _delegate.docChanges
      .map((documentDelegate) => DocumentChange._(_firestore, documentDelegate))
      .toList();

  /// Returns the [SnapshotMetadata] for this snapshot.
  SnapshotMetadata get metadata => SnapshotMetadata._(_delegate.metadata);

  /// Returns the size (number of documents) of this snapshot.
  int get size => _delegate.size;
}
