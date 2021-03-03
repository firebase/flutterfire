// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A [DocumentSnapshot] contains data read from a document in your [FirebaseFirestore]
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
class DocumentSnapshot {
  final FirebaseFirestore _firestore;
  final DocumentSnapshotPlatform _delegate;

  DocumentSnapshot._(this._firestore, this._delegate) {
    DocumentSnapshotPlatform.verifyExtends(_delegate);
  }

  /// This document's given ID for this snapshot.
  String get id => _delegate.id;

  /// Returns the [DocumentReference] of this snapshot.
  DocumentReference get reference => _firestore.doc(_delegate.reference.path);

  /// Metadata about this [DocumentSnapshot] concerning its source and if it has local
  /// modifications.
  SnapshotMetadata get metadata => SnapshotMetadata._(_delegate.metadata);

  /// Returns `true` if the [DocumentSnapshot] exists.
  bool get exists => _delegate.exists;

  /// Contains all the data of this [DocumentSnapshot].
  Map<String, dynamic>? data() {
    return _CodecUtility.replaceDelegatesWithValueInMap(
        _delegate.data(), _firestore);
  }

  /// Gets a nested field by [String] or [FieldPath] from this [DocumentSnapshot].
  ///
  /// Data can be accessed by providing a dot-notated path or [FieldPath]
  /// which recursively finds the specified data. If no data could be found
  /// at the specified path, a [StateError] will be thrown.
  dynamic get(dynamic field) =>
      _CodecUtility.valueDecode(_delegate.get(field), _firestore);

  /// Gets a nested field by [String] or [FieldPath] from this [DocumentSnapshot].
  ///
  /// Data can be accessed by providing a dot-notated path or [FieldPath]
  /// which recursively finds the specified data. If no data could be found
  /// at the specified path, a [StateError] will be thrown.
  dynamic operator [](dynamic field) => get(field);
}
