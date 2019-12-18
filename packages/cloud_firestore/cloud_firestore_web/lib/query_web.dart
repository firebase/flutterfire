part of cloud_firestore_web;

class QueryWeb implements Query {
  final web.Query webQuery;
  final FirestorePlatform _firestore;
  final bool _isCollectionGroup;
  final String _path;

  QueryWeb(this._firestore, this._path, this.webQuery, {bool isCollectionGroup})
      : this._isCollectionGroup = isCollectionGroup ?? false;

  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) {
    assert(webQuery != null);
    return webQuery.onSnapshot.map(_webQuerySnapshotToQuerySnapshot);
  }

  @override
  Future<QuerySnapshot> getDocuments(
      {Source source = Source.serverAndCache}) async {
    assert(webQuery != null);
    return _webQuerySnapshotToQuerySnapshot(await webQuery.get());
  }

  @override
  Map<String, dynamic> buildArguments() => Map();

  @override
  Query endAt(List values) => QueryWeb(this._firestore, this._path,
      webQuery != null ? webQuery.endAt(fieldValues: values) : null,
      isCollectionGroup: _isCollectionGroup);

  @override
  Query endAtDocument(DocumentSnapshot documentSnapshot) =>
      QueryWeb(this._firestore, this._path,
          _generateOrderByQuery(documentSnapshot).endAt(fieldValues: documentSnapshot.data.values), isCollectionGroup: _isCollectionGroup);

  @override
  Query endBefore(List values) => QueryWeb(this._firestore, this._path,
          webQuery != null ? webQuery.endBefore(fieldValues: values) : null, isCollectionGroup: _isCollectionGroup);

  @override
  Query endBeforeDocument(DocumentSnapshot documentSnapshot) =>
      QueryWeb(this._firestore, this._path,
          _generateOrderByQuery(documentSnapshot).endBefore(fieldValues: documentSnapshot.data.values), isCollectionGroup: _isCollectionGroup);

  @override
  FirestorePlatform get firestore => _firestore;

  @override
  bool get isCollectionGroup => _isCollectionGroup;

  @override
  Query limit(int length) => QueryWeb(this._firestore, this._path, webQuery != null ? webQuery.limit(length) : null,isCollectionGroup: _isCollectionGroup,);

  @override
  Query orderBy(field, {bool descending = false}) => QueryWeb(
        this._firestore,
        this._path,
        webQuery.orderBy(field, descending ? "desc" : "asc"),
        isCollectionGroup: _isCollectionGroup,
      );

  @override
  String get path => this._path;

  @override
  List<String> get pathComponents => this._path.split("/");

  @override
  CollectionReference reference() => firestore.collection(_path);

  @override
  Query startAfter(List values) => QueryWeb(
        this._firestore,
        this._path,
        webQuery.startAfter(fieldValues: values),
    isCollectionGroup: _isCollectionGroup
      );

  @override
  Query startAfterDocument(DocumentSnapshot documentSnapshot) =>
      QueryWeb(this._firestore, this._path,
          _generateOrderByQuery(documentSnapshot)
              .startAfter(fieldValues: documentSnapshot.data.values),isCollectionGroup: _isCollectionGroup);

  @override
  Query startAt(List values) => QueryWeb(
        this._firestore,
        this._path,
        webQuery.startAt(fieldValues: values) ,
        isCollectionGroup: _isCollectionGroup,
      );

  @override
  Query startAtDocument(DocumentSnapshot documentSnapshot) =>
      QueryWeb(this._firestore, this._path,
          _generateOrderByQuery(documentSnapshot)
              .startAt(fieldValues: documentSnapshot.data.values), isCollectionGroup: _isCollectionGroup);

  @override
  Query where(field,
      {isEqualTo,
      isLessThan,
      isLessThanOrEqualTo,
      isGreaterThan,
      isGreaterThanOrEqualTo,
      arrayContains,
      List arrayContainsAny,
      List whereIn,
      bool isNull}) {
    assert(field is String || field is FieldPath,
        'Supported [field] types are [String] and [FieldPath].');
    assert(webQuery != null);

    web.Query query = webQuery;

    if (isEqualTo != null) {
      query = query.where(field, "==", isEqualTo);
    }
    if (isLessThan != null) {
      query = query.where(field, "<", isLessThan);
    }
    if (isLessThanOrEqualTo != null) {
      query = query.where(field, "<=", isLessThanOrEqualTo);
    }
    if (isGreaterThan != null) {
      query = query.where(field, ">", isGreaterThan);
    }
    if (isGreaterThanOrEqualTo != null) {
      query = query.where(field, ">=", isGreaterThanOrEqualTo);
    }
    if (arrayContains != null) {
      query = query.where(field, "array-contains", arrayContains);
    }
    if (arrayContainsAny != null) {
      assert(arrayContainsAny.length <= 10,
          "array contains can have maximum of 10 items");
      query = query.where(field, "array-contains-any", arrayContainsAny);
    }
    if (whereIn != null) {
      assert(
          whereIn.length <= 10, "array contains can have maximum of 10 items");
      query = query.where(field, "in", whereIn);
    }
    if (isNull != null) {
      assert(
          isNull,
          'isNull can only be set to true. '
          'Use isEqualTo to filter on non-null values.');
      query = query.where(field, "==", null);
    }
    return QueryWeb(this._firestore, this._path, query, isCollectionGroup: _isCollectionGroup);
  }

  QuerySnapshot _webQuerySnapshotToQuerySnapshot(
      web.QuerySnapshot webSnapshot) {
    return QuerySnapshot(
        webSnapshot.docs.map(_webDocumentSnapshotToDocumentSnapshot).toList(),
        webSnapshot.docChanges().map(_webChangeToChange).toList(),
        _webMetadataToMetada(webSnapshot.metadata));
  }

  DocumentChange _webChangeToChange(web.DocumentChange webChange) {
    return DocumentChange(
        _fromString(webChange.type),
        webChange.oldIndex,
        webChange.newIndex,
        _webDocumentSnapshotToDocumentSnapshot(webChange.doc));
  }

  DocumentChangeType _fromString(String item) {
    switch (item.toLowerCase()) {
      case "added":
        return DocumentChangeType.added;
      case "modified":
        return DocumentChangeType.modified;
      case "removed":
        return DocumentChangeType.removed;
      default:
        throw ArgumentError("Invalid type");
    }
  }

  DocumentSnapshot _webDocumentSnapshotToDocumentSnapshot(
      web.DocumentSnapshot webSnapshot) {
    return DocumentSnapshot(
        webSnapshot.ref.path,
        webSnapshot.data(),
        SnapshotMetadata(webSnapshot.metadata.hasPendingWrites,
            webSnapshot.metadata.fromCache),
        this._firestore);
  }

  web.Query _generateOrderByQuery(DocumentSnapshot webSnapshot) {
    assert(webQuery != null);
    web.Query query = webQuery;
    webSnapshot.data.keys.forEach((key) => query = query.orderBy(key));
    return query;
  }

  SnapshotMetadata _webMetadataToMetada(web.SnapshotMetadata webMetadata) {
    return SnapshotMetadata(
        webMetadata.hasPendingWrites, webMetadata.fromCache);
  }

  @override
  Map<String, dynamic> get parameters => Map();
}
