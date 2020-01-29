part of cloud_firestore_web;

/// Web implementation for firestore [DocumentReferencePlatform]
class DocumentReferenceWeb extends DocumentReferencePlatform {
  /// instance of Firestore from the web plugin
  final web.Firestore firestoreWeb;

  /// instance of DocumentReference from the web plugin
  final web.DocumentReference delegate;

  /// Creates an instance of [CollectionReferenceWeb] which represents path
  /// at [pathComponents] and uses implementation of [firestoreWeb]
  DocumentReferenceWeb(this.firestoreWeb, FirestorePlatform firestore,
      List<String> pathComponents)
      : delegate = firestoreWeb.doc(pathComponents.join("/")),
        super(firestore, pathComponents);

  @override
  Future<void> setData(Map<String, dynamic> data, {bool merge = false}) =>
      delegate.set(
          CodecUtility.encodeMapData(data), web.SetOptions(merge: merge));

  @override
  Future<void> updateData(Map<String, dynamic> data) =>
      delegate.update(data: CodecUtility.encodeMapData(data));

  @override
  Future<DocumentSnapshot> get({Source source = Source.serverAndCache}) async {
    return _fromWebDocumentSnapshotToPlatformDocumentSnapshot(
        await delegate.get(), this.firestore);
  }

  @override
  Future<void> delete() => delegate.delete();

  @override
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) {
    Stream<web.DocumentSnapshot> querySnapshots = delegate.onSnapshot;
    if (includeMetadataChanges) {
      querySnapshots = delegate.onMetadataChangesSnapshot;
    }
    return querySnapshots.map((webSnapshot) =>
        _fromWebDocumentSnapshotToPlatformDocumentSnapshot(
            webSnapshot, this.firestore));
  }
}
