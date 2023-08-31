// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// Contains the results of a query.
/// It can contain zero or more [DocumentSnapshot] objects.
abstract class QuerySnapshotChanges<T extends Object?> {
  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as Added changes.
  List<DocumentChange<T>> get docChanges;

  /// Returns the [SnapshotMetadata] for this snapshot.
  SnapshotMetadata get metadata;

  /// Returns the size (number of documents) of this snapshot.
  int get size;
}

/// Contains the results of a query.
/// It can contain zero or more [DocumentSnapshot] objects.
class _JsonQuerySnapshotChanges
    implements QuerySnapshotChanges<Map<String, dynamic>> {
  _JsonQuerySnapshotChanges(this._firestore, this._delegate) {
    QuerySnapshotChangesPlatform.verify(_delegate);
  }

  final FirebaseFirestore _firestore;
  final QuerySnapshotChangesPlatform _delegate;

  @override
  List<DocumentChange<Map<String, dynamic>>> get docChanges {
    return _delegate.docChanges.map((documentDelegate) {
      return _JsonDocumentChange(_firestore, documentDelegate);
    }).toList();
  }

  @override
  SnapshotMetadata get metadata => SnapshotMetadata._(_delegate.metadata);

  @override
  int get size => _delegate.size;
}

/// Contains the results of a query.
/// It can contain zero or more [DocumentSnapshot] objects.
class _WithConverterQuerySnapshotChanges<T extends Object?>
    implements QuerySnapshotChanges<T> {
  _WithConverterQuerySnapshotChanges(
    this._originalQuerySnapshotChanges,
    this._fromFirestore,
    this._toFirestore,
  );

  final QuerySnapshotChanges<Map<String, dynamic>>
      _originalQuerySnapshotChanges;
  final FromFirestore<T> _fromFirestore;
  final ToFirestore<T> _toFirestore;

  @override
  List<DocumentChange<T>> get docChanges {
    return [
      for (final change in _originalQuerySnapshotChanges.docChanges)
        _WithConverterDocumentChange<T>(
          change,
          _fromFirestore,
          _toFirestore,
        ),
    ];
  }

  @override
  SnapshotMetadata get metadata => _originalQuerySnapshotChanges.metadata;

  @override
  int get size => _originalQuerySnapshotChanges.size;
}
