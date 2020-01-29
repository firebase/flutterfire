part of cloud_firestore_web;

/// A web specific for [Transaction]
class TransactionWeb implements TransactionPlatform {
  final web.Transaction _webTransaction;
  @override
  FirestorePlatform firestore;

  // ignore: public_member_api_docs
  @visibleForTesting
  TransactionWeb(this._webTransaction, this.firestore);

  @override
  Future<void> delete(DocumentReferencePlatform documentReference) async {
    assert(documentReference is DocumentReferenceWeb);
    await _webTransaction
        .delete((documentReference as DocumentReferenceWeb).delegate);
  }

  @override
  Future<DocumentSnapshot> get(DocumentReferencePlatform documentReference) async {
    assert(documentReference is DocumentReferenceWeb);
    final webSnapshot = await _webTransaction
        .get((documentReference as DocumentReferenceWeb).delegate);
    return _fromWebDocumentSnapshotToPlatformDocumentSnapshot(
        webSnapshot, this.firestore);
  }

  @override
  Future<void> set(
      DocumentReferencePlatform documentReference, Map<String, dynamic> data) async {
    assert(documentReference is DocumentReferenceWeb);
    await _webTransaction.set(
        (documentReference as DocumentReferenceWeb).delegate,
        CodecUtility.encodeMapData(data));
  }

  @override
  Future<void> update(
      DocumentReferencePlatform documentReference, Map<String, dynamic> data) async {
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
