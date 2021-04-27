// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

typedef FromFirebase<T> = T Function(Map<String, Object?> json);
typedef ToFirebase<T> = Map<String, Object?> Function(T value);

/// A [CollectionReference] object can be used for adding documents, getting
/// [DocumentReference]s, and querying for documents (using the methods
/// inherited from [Query]).
@immutable
abstract class _CollectionReference<T, DocRef> {
  /// Returns the ID of the referenced collection.
  String get id;

  /// Returns the parent [DocumentReference] of this collection or `null`.
  ///
  /// If this collection is a root collection, `null` is returned.
  // This always returns a DocumentReference even when using withConverter
  // because we do not know what is the correct type for the parent doc.
  DocumentReference? get parent;

  /// A string containing the slash-separated path to this  CollectionReference
  /// (relative to the root of the database).
  String get path;

  /// Returns a `DocumentReference` with an auto-generated ID, after
  /// populating it with provided [data].
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  Future<DocRef> add(T data);
}

/// A [CollectionReference] object can be used for adding documents, getting
/// [DocumentReference]s, and querying for documents (using the methods
/// inherited from [Query]).
@immutable
class CollectionReference extends Query
    implements _CollectionReference<Map<String, dynamic>, DocumentReference> {
  CollectionReference._(
    FirebaseFirestore firestore,
    CollectionReferencePlatform _delegate,
  ) : super._(firestore, _delegate);

  @override
  CollectionReferencePlatform get _delegate =>
      super._delegate as CollectionReferencePlatform;

  @override
  String get id => _delegate.id;

  @override
  DocumentReference? get parent {
    DocumentReferencePlatform? _documentReferencePlatform = _delegate.parent;

    // Only subcollections have a parent
    if (_documentReferencePlatform == null) {
      return null;
    }

    return DocumentReference._(firestore, _documentReferencePlatform);
  }

  @override
  String get path => _delegate.path;

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async {
    final DocumentReference newDocument = doc();
    await newDocument.set(data);
    return newDocument;
  }

  /// {@template cloud_firestore.collection_reference.doc}
  /// Returns a `DocumentReference` with the provided path.
  ///
  /// If no [path] is provided, an auto-generated ID is used.
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  /// {@endtemplate}
  DocumentReference doc([String? path]) {
    if (path != null) {
      assert(path.isNotEmpty, 'a document path must be a non-empty string');
      assert(!path.contains('//'), 'a document path must not contain "//"');
      assert(path != '/', 'a document path must point to a valid document');
    }

    return DocumentReference._(firestore, _delegate.doc(path));
  }

  /// Transforms a [CollectionReference] to manipulate a custom object instead
  /// of a `Map<String, dynamic>`.
  ///
  /// This makes both read and write operations type-safe.
  ///
  /// ```dart
  /// final modelsRef = FirebaseFirestore
  ///     .instance
  ///     .collection('models')
  ///     .withConverter<Model>(
  ///       fromFirebase: (json) => <Model>.fromJson(json),
  ///       toFirebase: (model) => model.toJson(),
  ///     );
  ///
  /// Future<void> main() async {
  ///   // Writes now take a Model as parameter instead of a Map
  ///   await modelsRef.add(Model());
  ///
  ///   // Reads now return a Model instead of a Map
  ///   final Model model = await modelsRef.doc('123').get().then((s) => s.data());
  /// }
  /// ```
  WithConverterCollectionReference<T> withConverter<T>({
    required FromFirebase<T> fromFirebase,
    required ToFirebase<T> toFirebase,
  }) {
    return WithConverterCollectionReference._(this, fromFirebase, toFirebase);
  }

  @override
  bool operator ==(Object other) =>
      other is CollectionReference &&
      other.firestore == firestore &&
      other.path == path;

  @override
  int get hashCode => hashValues(firestore, path);

  @override
  String toString() => '$CollectionReference($path)';
}

/// A [CollectionReference] object can be used for adding documents, getting
/// [DocumentReference]s, and querying for documents (using the methods
/// inherited from [Query]).
@immutable
class WithConverterCollectionReference<T> extends WithConverterQuery<T>
    implements _CollectionReference<T, WithConverterDocumentReference<T>> {
  WithConverterCollectionReference._(
    CollectionReference collectionReference,
    FromFirebase<T> fromFirebase,
    ToFirebase<T> toFirebase,
  ) : super._(collectionReference, fromFirebase, toFirebase);

  CollectionReference get _originalCollectionReferenceQuery =>
      super._originalQuery as CollectionReference;

  @override
  String get id => _originalCollectionReferenceQuery.id;

  @override
  DocumentReference? get parent => _originalCollectionReferenceQuery.parent;

  @override
  String get path => _originalCollectionReferenceQuery.path;

  @override
  Future<WithConverterDocumentReference<T>> add(T data) async {
    final snapshot =
        await _originalCollectionReferenceQuery.add(_toFirebase(data));

    return WithConverterDocumentReference<T>._(
      snapshot,
      _fromFirebase,
      _toFirebase,
    );
  }

  /// {@macro cloud_firestore.collection_reference.doc}
  WithConverterDocumentReference<T> doc([String? path]) {
    return WithConverterDocumentReference<T>._(
      _originalCollectionReferenceQuery.doc(path),
      _fromFirebase,
      _toFirebase,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WithConverterCollectionReference<T> &&
      other.runtimeType == runtimeType &&
      other._originalCollectionReferenceQuery ==
          _originalCollectionReferenceQuery &&
      other._fromFirebase == _fromFirebase &&
      other._toFirebase == _toFirebase;

  @override
  int get hashCode => hashValues(
        runtimeType,
        _originalCollectionReferenceQuery,
        _fromFirebase,
        _toFirebase,
      );

  @override
  String toString() => 'WithConverterCollectionReference<$T>($path)';
}
