part of cloud_firestore_web;

class WriteBatchWeb implements WriteBatch {
  final web.WriteBatch _delegate;

  WriteBatchWeb._(this._delegate);

  @override
  Future<void> commit() async {
    await _delegate.commit();
  }

  @override
  void delete(DocumentReference document) {
    assert(document is DocumentReferenceWeb);
    _delegate.delete((document as DocumentReferenceWeb).delegate);
  }

  @override
  void setData(DocumentReference document, Map<String, dynamic> data,
      {bool merge = false}) {
    assert(document is DocumentReferenceWeb);
    _delegate.set(
        (document as DocumentReferenceWeb).delegate,
        FieldValueWeb._serverDelegates(data),
        merge ? web.SetOptions(merge: merge) : null);
  }

  @override
  void updateData(DocumentReference document, Map<String, dynamic> data) {
    assert(document is DocumentReferenceWeb);
    _delegate.set((document as DocumentReferenceWeb).delegate,
        FieldValueWeb._serverDelegates(data));
  }
}
