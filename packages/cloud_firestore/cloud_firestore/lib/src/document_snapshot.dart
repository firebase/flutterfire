// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A DocumentSnapshot contains data read from a document in your Firestore
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
class DocumentSnapshot {
  platform.DocumentSnapshotPlatform _delegate;
  final Firestore _firestore;

  DocumentSnapshot._(this._delegate, this._firestore);

  /// The reference that produced this snapshot
  DocumentReference get reference =>
      _firestore.document(_delegate.reference.path);

  /// Contains all the data of this snapshot
  Map<String, dynamic> get data =>
      _CodecUtility.replaceDelegatesWithValueInMap(_delegate.data, _firestore);

  /// Metadata about this snapshot concerning its source and if it has local
  /// modifications.
  SnapshotMetadata get metadata => SnapshotMetadata._(_delegate.metadata);

  /// Reads individual values from the snapshot
  dynamic operator [](String key) => data[key];

  /// Returns the ID of the snapshot's document
  String get documentID => _delegate.documentID;

  /// Returns `true` if the document exists.
  bool get exists => data != null;
}
