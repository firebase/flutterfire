part of cloud_firestore_web;

/// A web specific for [Transaction]
class TransactionWeb implements Transaction {
  final web.Transaction _webTransaction;
  @override
  FirestorePlatform firestore;

  // ignore: public_member_api_docs
  @visibleForTesting
  TransactionWeb(this._webTransaction, this.firestore);

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
    return _fromWebDocumentSnapshotToPlatformDocumentSnapshot(
        webSnapshot, this.firestore);
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

  @override
  Future<void> finish() {
    return Future.value();
  }
}
