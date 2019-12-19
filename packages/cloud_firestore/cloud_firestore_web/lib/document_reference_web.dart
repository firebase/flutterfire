part of cloud_firestore_web;

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
          CodecUtility._encodeMapData(data), web.SetOptions(merge: merge));

  @override
  Future<void> updateData(Map<String, dynamic> data) =>
      delegate.update(data: CodecUtility._encodeMapData(data));

  @override
  Future<DocumentSnapshot> get({Source source = Source.serverAndCache}) async {
    //TODO(amr): Honour source by passing it to the delegate
    return _fromWeb(await delegate.get());
  }

  @override
  Future<void> delete() => delegate.delete();

  @override
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) =>
      delegate.onSnapshot.map(_fromWeb);

  DocumentSnapshot _fromWeb(web.DocumentSnapshot webSnapshot) =>
      DocumentSnapshot(
          webSnapshot.ref.path,
          CodecUtility._decodeMapData(webSnapshot.data()),
          SnapshotMetadata(
            webSnapshot.metadata.hasPendingWrites,
            webSnapshot.metadata.fromCache,
          ),
          this.firestore);
}
