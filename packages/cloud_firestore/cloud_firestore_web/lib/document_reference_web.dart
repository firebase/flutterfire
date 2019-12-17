part of cloud_firestore_web;

class DocumentReferenceWeb extends DocumentReference {
  final web.Firestore firestoreWeb;
  final web.DocumentReference delegate;
  DocumentReferenceWeb(this.firestoreWeb,FirestorePlatform firestore, List<String> pathComponents)
      : delegate = firestoreWeb.doc(pathComponents.join("/")),super(firestore, pathComponents);

  @override
  Future<void> setData(Map<String, dynamic> data, {bool merge = false}) {
    return delegate.set(data, web.SetOptions(merge: merge));
  }

  @override
  Future<void> updateData(Map<String, dynamic> data) {
    return delegate.update(data: data);
  }

  @override
  Future<DocumentSnapshot> get({Source source = Source.serverAndCache}) async {
    return _fromWeb(await delegate.get());
  }

  @override
  Future<void> delete() {
    return delegate.delete();
  }

  @override
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) {
    return delegate
        .onSnapshot
        .map((web.DocumentSnapshot webSnapshot) => _fromWeb(webSnapshot));
  }
  
  DocumentSnapshot _fromWeb(web.DocumentSnapshot webSnapshot) => DocumentSnapshot(
      webSnapshot.ref.path,
      webSnapshot.data(),
      SnapshotMetadata(
        webSnapshot.metadata.hasPendingWrites,
        webSnapshot.metadata.fromCache,
      ),
      this.firestore);
}
