part of cloud_firestore_platform_interface;

/// A [DocumentReference] refers to a document location in a Firestore database
/// and can be used to write, read, or listen to the location.
///
/// The document at the referenced location may or may not exist.
/// A [DocumentReference] can also be used to create a [CollectionReference]
/// to a subcollection.
abstract class DocumentReference {
  DocumentReference(this.firestore, this._pathComponents);

  /// The Firestore instance associated with this document reference
  final FirestorePlatform firestore;
  final List<String> _pathComponents;

  @override
  bool operator ==(dynamic o) =>
      o is DocumentReference && o.firestore == firestore && o.path == path;

  @override
  int get hashCode => hashList(_pathComponents);

  /// Parent returns the containing [CollectionReference].
  CollectionReference parent() {
    final parentPathComponents = List<String>.from(_pathComponents)
      ..removeLast();
    return firestore.collection(
      parentPathComponents.join("/"),
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
    throw UnimplementedError("setData() is not implemented");
  }

  /// Updates fields in the document referred to by this [DocumentReference].
  ///
  /// Values in [data] may be of any supported Firestore type as well as
  /// special sentinel [FieldValue] type.
  ///
  /// If no document exists yet, the update will fail.
  Future<void> updateData(Map<String, dynamic> data) {
    throw UnimplementedError("updateData() is not implemented");
  }

  /// Reads the document referenced by this [DocumentReference].
  ///
  /// If no document exists, the read will return null.
  Future<DocumentSnapshot> get({Source source = Source.serverAndCache}) async {
    throw UnimplementedError("get() is not implemented");
  }

  /// Deletes the document referred to by this [DocumentReference].
  Future<void> delete() {
    throw UnimplementedError("delete() is not implemented");
  }

  /// Returns the reference of a collection contained inside of this
  /// document.
  CollectionReference collection(String collectionPath) {
    return firestore.collection('$path/$collectionPath');
  }

  /// Notifies of documents at this location
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) {
    throw UnimplementedError("snapshots() is not implemented");
  }
}
