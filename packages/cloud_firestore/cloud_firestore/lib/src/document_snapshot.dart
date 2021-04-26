// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

abstract class _DocumentSnapshotInterface<T> {
  /// This document's given ID for this snapshot.
  String get id;

  /// Returns the [DocumentReference] of this snapshot.
  DocumentReference get reference;

  /// Metadata about this document concerning its source and if it has local
  /// modifications.
  SnapshotMetadata get metadata;

  /// Returns `true` if the document exists.
  bool get exists;

  /// Contains all the data of this document snapshot.
  T? data();
}

/// A [DocumentSnapshot] contains data read from a document in your [FirebaseFirestore]
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
class DocumentSnapshot
    implements _DocumentSnapshotInterface<Map<String, dynamic>> {
  DocumentSnapshot._(this._firestore, this._delegate) {
    DocumentSnapshotPlatform.verifyExtends(_delegate);
  }

  final FirebaseFirestore _firestore;
  final DocumentSnapshotPlatform _delegate;

  @override
  String get id => _delegate.id;

  @override
  late final DocumentReference reference =
      _firestore.doc(_delegate.reference.path);

  @override
  late final SnapshotMetadata metadata = SnapshotMetadata._(_delegate.metadata);

  @override
  bool get exists => _delegate.exists;

  @override
  Map<String, dynamic>? data() {
    // TODO(rrousselGit): can we cache the result, to avoid deserializing it on every read?
    return _CodecUtility.replaceDelegatesWithValueInMap(
      _delegate.data(),
      _firestore,
    );
  }

  /// {@template firestore.documentsnapshot.get}
  /// Gets a nested field by [String] or [FieldPath] from this [DocumentSnapshot].
  ///
  /// Data can be accessed by providing a dot-notated path or [FieldPath]
  /// which recursively finds the specified data. If no data could be found
  /// at the specified path, a [StateError] will be thrown.
  /// {@endtemplate}
  dynamic get(dynamic field) {
    return _CodecUtility.valueDecode(_delegate.get(field), _firestore);
  }

  /// {@macro firestore.documentsnapshot.get}
  dynamic operator [](dynamic field) => get(field);
}

/// A [DocumentSnapshot] contains data read from a document in your [FirebaseFirestore]
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
class WithConverterDocumentSnapshot<T>
    implements _DocumentSnapshotInterface<T> {
  WithConverterDocumentSnapshot._(
    this._originalDocumentSnapshot,
    this._fromFirebase,
  );

  final DocumentSnapshot _originalDocumentSnapshot;
  final FromFirebase<T> _fromFirebase;

  @override
  T? data() {
    final json = _originalDocumentSnapshot.data();

    if (json == null) return null;
    return _fromFirebase(json);
  }

  @override
  bool get exists => _originalDocumentSnapshot.exists;

  @override
  String get id => _originalDocumentSnapshot.id;

  @override
  SnapshotMetadata get metadata => _originalDocumentSnapshot.metadata;

  @override
  DocumentReference get reference => _originalDocumentSnapshot.reference;
}
