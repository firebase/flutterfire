// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

typedef FromFirestore<T> = T Function(
  DocumentSnapshot snapshot,
  SnapshotOptions? options,
);
typedef ToFirestore<T> = Map<String, Object?> Function(
  T value,
  SetOptions? options,
);

/// Options that configure how data is retrieved from a DocumentSnapshot
/// (e.g. the desired behavior for server timestamps that have not yet been set to their final value).
///
/// Currently unsupported by FlutterFire, but exposed to avoid breaking changes
/// in the future once this class is supported.
@sealed
class SnapshotOptions {}

abstract class _DocumentSnapshotInterface<T, DocumentReferenceType> {
  /// This document's given ID for this snapshot.
  String get id;

  /// Returns the reference of this snapshot.
  DocumentReferenceType get reference;

  /// Metadata about this document concerning its source and if it has local
  /// modifications.
  SnapshotMetadata get metadata;

  /// Returns `true` if the document exists.
  bool get exists;

  /// Contains all the data of this document snapshot.
  T? data([SnapshotOptions? options]);
}

/// A [DocumentSnapshot] contains data read from a document in your [FirebaseFirestore]
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
class DocumentSnapshot
    implements
        _DocumentSnapshotInterface<Map<String, dynamic>, DocumentReference> {
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
  Map<String, dynamic>? data([SnapshotOptions? options]) {
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
    implements
        _DocumentSnapshotInterface<T, WithConverterDocumentReference<T>> {
  WithConverterDocumentSnapshot._(
    this._originalDocumentSnapshot,
    this._fromFirestore,
    this._toFirestore,
  );

  final DocumentSnapshot _originalDocumentSnapshot;
  final FromFirestore<T> _fromFirestore;
  final ToFirestore<T> _toFirestore;

  @override
  T? data([SnapshotOptions? options]) {
    if (!_originalDocumentSnapshot.exists) return null;

    return _fromFirestore(_originalDocumentSnapshot, options);
  }

  @override
  bool get exists => _originalDocumentSnapshot.exists;

  @override
  String get id => _originalDocumentSnapshot.id;

  @override
  SnapshotMetadata get metadata => _originalDocumentSnapshot.metadata;

  @override
  WithConverterDocumentReference<T> get reference =>
      WithConverterDocumentReference<T>._(
        _originalDocumentSnapshot.reference,
        _fromFirestore,
        _toFirestore,
      );
}
