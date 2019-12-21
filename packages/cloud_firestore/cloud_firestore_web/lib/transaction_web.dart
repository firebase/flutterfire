part of cloud_firestore_web;

class TransactionWeb implements Transaction {
  final web.Transaction _webTransaction;
  @override
  FirestorePlatform firestore;

  TransactionWeb._(this._webTransaction, this.firestore);

  @override
  String get appName => firestore.appName();

  @override
  Future<void> delete(DocumentReference documentReference) async {
    assert(documentReference is DocumentReferenceWeb);
    await _webTransaction
        .delete((documentReference as DocumentReferenceWeb).delegate);
  }

  @override
  Future<DocumentSnapshot> get(DocumentReference documentReference) async {
    assert(documentReference is DocumentReferenceWeb);
    final webSnapshot = await _webTransaction
        .get((documentReference as DocumentReferenceWeb).delegate);
    return _fromWeb(webSnapshot);
  }

  @override
  Future<void> set(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    assert(documentReference is DocumentReferenceWeb);
    await _webTransaction.set(
        (documentReference as DocumentReferenceWeb).delegate,
        CodecUtility.encodeMapData(data));
  }

  @override
  Future<void> update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    assert(documentReference is DocumentReferenceWeb);
    await _webTransaction.update(
        (documentReference as DocumentReferenceWeb).delegate,
        data: CodecUtility.encodeMapData(data));
  }

  DocumentSnapshot _fromWeb(web.DocumentSnapshot webSnapshot) =>
      DocumentSnapshot(
          webSnapshot.ref.path,
          CodecUtility.decodeMapData(webSnapshot.data()),
          SnapshotMetadata(
            webSnapshot.metadata.hasPendingWrites,
            webSnapshot.metadata.fromCache,
          ),
          this.firestore);

  @override
  Future<void> finish() {
    return Future.value();
  }
}
