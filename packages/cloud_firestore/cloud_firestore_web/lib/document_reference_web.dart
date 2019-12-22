part of cloud_firestore_web;

/// Web implementation for firestore [DocumentReference]
class DocumentReferenceWeb extends DocumentReference {
  final web.Firestore firestoreWeb;
  final web.DocumentReference delegate;

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
    return _fromWeb(await delegate.get());
  }

  @override
  Future<void> delete() => delegate.delete();

  @override
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) {
    Stream<web.DocumentSnapshot> querySnapshots = delegate.onSnapshot;
    if (includeMetadataChanges) {
      querySnapshots = delegate.onMetadataChangesSnapshot;
    }
    return querySnapshots.map(_fromWeb);
  }

  /// Builds [DocumentSnapshot] instance form web snapshot instance
  DocumentSnapshot _fromWeb(web.DocumentSnapshot webSnapshot) =>
      DocumentSnapshot(
          webSnapshot.ref.path,
          CodecUtility.decodeMapData(webSnapshot.data()),
          SnapshotMetadata(
            webSnapshot.metadata.hasPendingWrites,
            webSnapshot.metadata.fromCache,
          ),
          this.firestore);
}
