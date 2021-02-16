// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A [CollectionReference] object can be used for adding documents, getting
/// [DocumentReference]s, and querying for documents (using the methods
/// inherited from [Query]).
@immutable
class CollectionReference extends Query {
  @override
  // ignore: overridden_fields
  final CollectionReferencePlatform _delegate;

  CollectionReference._(FirebaseFirestore firestore, this._delegate)
      : super._(firestore, _delegate);

  /// Returns the ID of the referenced collection.
  String get id => _delegate.id;

  /// Returns the parent [DocumentReference] of this collection or `null`.
  ///
  /// If this collection is a root collection, `null` is returned.
  DocumentReference? get parent {
    DocumentReferencePlatform? _documentReferencePlatform = _delegate.parent;

    // Only subcollections have a parent
    if (_documentReferencePlatform == null) {
      return null;
    }

    return DocumentReference._(firestore, _documentReferencePlatform);
  }

  /// A string containing the slash-separated path to this  CollectionReference
  /// (relative to the root of the database).
  String get path => _delegate.path;

  /// Returns a `DocumentReference` with an auto-generated ID, after
  /// populating it with provided [data].
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  Future<DocumentReference> add(Map<String, dynamic> data) async {
    final DocumentReference newDocument = doc();
    await newDocument.set(data);
    return newDocument;
  }

  /// Returns a `DocumentReference` with the provided path.
  ///
  /// If no [path] is provided, an auto-generated ID is used.
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  DocumentReference doc([String? path]) {
    if (path != null) {
      assert(path.isNotEmpty, 'a document path must be a non-empty string');
      assert(!path.contains('//'), 'a document path must not contain "//"');
      assert(path != '/', 'a document path must point to a valid document');
    }

    return DocumentReference._(firestore, _delegate.doc(path));
  }

  @override
  bool operator ==(dynamic other) =>
      other is CollectionReference &&
      other.firestore == firestore &&
      other.path == path;

  @override
  int get hashCode => hashValues(firestore, path);

  @override
  String toString() => '$CollectionReference($path)';
}
