part of cloud_firestore_web;

class QueryWeb implements Query {
  final web.Query webQuery;
  final FirestorePlatform _firestore;
  final bool _isCollectionGroup;
  final String _path;
  final List<dynamic> _orderByKeys;
  static const _kChangeTypeAdded = "added";
  static const _kChangeTypeModified = "modified";
  static const _kChangeTypeRemoved = "removed";

  QueryWeb(this._firestore, this._path, this.webQuery,
      {bool isCollectionGroup, List<dynamic> orderByKeys})
      : this._isCollectionGroup = isCollectionGroup ?? false,
        this._orderByKeys = orderByKeys ?? [];

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
  Query endAtDocument(DocumentSnapshot documentSnapshot) {
    assert(webQuery != null && _orderByKeys.isNotEmpty);
    return QueryWeb(
        this._firestore,
        this._path,
        webQuery.endAt(
            fieldValues:
                _orderByKeys.map((key) => documentSnapshot.data[key]).toList()),
        isCollectionGroup: _isCollectionGroup);
  }

  @override
  Query endBefore(List values) => QueryWeb(this._firestore, this._path,
      webQuery != null ? webQuery.endBefore(fieldValues: values) : null,
      isCollectionGroup: _isCollectionGroup);

  @override
  Query endBeforeDocument(DocumentSnapshot documentSnapshot) {
    assert(webQuery != null && _orderByKeys.isNotEmpty);
    return QueryWeb(
        this._firestore,
        this._path,
        webQuery.endBefore(
            fieldValues:
                _orderByKeys.map((key) => documentSnapshot.data[key]).toList()),
        isCollectionGroup: _isCollectionGroup);
  }

  @override
  FirestorePlatform get firestore => _firestore;

  @override
  bool get isCollectionGroup => _isCollectionGroup;

  @override
  Query limit(int length) => QueryWeb(
        this._firestore,
        this._path,
        webQuery != null ? webQuery.limit(length) : null,
        orderByKeys: _orderByKeys,
        isCollectionGroup: _isCollectionGroup,
      );

  @override
  Query orderBy(field, {bool descending = false}) {
    dynamic usableField = field;
    if (field == FieldPath.documentId) {
      usableField = web.FieldPath.documentId();
    }
    return QueryWeb(
      this._firestore,
      this._path,
      webQuery.orderBy(usableField, descending ? "desc" : "asc"),
      orderByKeys: _orderByKeys..add(usableField),
      isCollectionGroup: _isCollectionGroup,
    );
  }

  @override
  String get path => this._path;

  @override
  List<String> get pathComponents => this._path.split("/");

  @override
  CollectionReference reference() => firestore.collection(_path);

  @override
  Query startAfter(List values) => QueryWeb(
      this._firestore, this._path, webQuery.startAfter(fieldValues: values),
      orderByKeys: _orderByKeys, isCollectionGroup: _isCollectionGroup);

  @override
  Query startAfterDocument(DocumentSnapshot documentSnapshot) {
    assert(webQuery != null && _orderByKeys.isNotEmpty);
    return QueryWeb(
        this._firestore,
        this._path,
        webQuery.startAfter(
            fieldValues:
                _orderByKeys.map((key) => documentSnapshot.data[key]).toList()),
        orderByKeys: _orderByKeys,
        isCollectionGroup: _isCollectionGroup);
  }

  @override
  Query startAt(List values) => QueryWeb(
        this._firestore,
        this._path,
        webQuery.startAt(fieldValues: values),
        orderByKeys: _orderByKeys,
        isCollectionGroup: _isCollectionGroup,
      );

  @override
  Query startAtDocument(DocumentSnapshot documentSnapshot) {
    assert(webQuery != null && _orderByKeys.isNotEmpty);
    return QueryWeb(
        this._firestore,
        this._path,
        webQuery.startAt(
            fieldValues:
                _orderByKeys.map((key) => documentSnapshot.data[key]).toList()),
        orderByKeys: _orderByKeys,
        isCollectionGroup: _isCollectionGroup);
  }

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
    dynamic usableField = field;
    if (field == FieldPath.documentId) {
      usableField = web.FieldPath.documentId();
    }
    web.Query query = webQuery;

    if (isEqualTo != null) {
      query = query.where(usableField, "==", isEqualTo);
    }
    if (isLessThan != null) {
      query = query.where(usableField, "<", isLessThan);
    }
    if (isLessThanOrEqualTo != null) {
      query = query.where(usableField, "<=", isLessThanOrEqualTo);
    }
    if (isGreaterThan != null) {
      query = query.where(usableField, ">", isGreaterThan);
    }
    if (isGreaterThanOrEqualTo != null) {
      query = query.where(usableField, ">=", isGreaterThanOrEqualTo);
    }
    if (arrayContains != null) {
      query = query.where(usableField, "array-contains", arrayContains);
    }
    if (arrayContainsAny != null) {
      assert(arrayContainsAny.length <= 10,
          "array contains can have maximum of 10 items");
      query = query.where(usableField, "array-contains-any", arrayContainsAny);
    }
    if (whereIn != null) {
      assert(
          whereIn.length <= 10, "array contains can have maximum of 10 items");
      query = query.where(usableField, "in", whereIn);
    }
    if (isNull != null) {
      assert(
          isNull,
          'isNull can only be set to true. '
          'Use isEqualTo to filter on non-null values.');
      query = query.where(usableField, "==", null);
    }
    return QueryWeb(this._firestore, this._path, query,
        orderByKeys: _orderByKeys, isCollectionGroup: _isCollectionGroup);
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
      case _kChangeTypeAdded:
        return DocumentChangeType.added;
      case _kChangeTypeModified:
        return DocumentChangeType.modified;
      case _kChangeTypeRemoved:
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

  SnapshotMetadata _webMetadataToMetada(web.SnapshotMetadata webMetadata) {
    return SnapshotMetadata(
        webMetadata.hasPendingWrites, webMetadata.fromCache);
  }

  @override
  Map<String, dynamic> get parameters => Map();

  @visibleForTesting
  QueryWeb resetQueryDelegate() =>
      QueryWeb(firestore, pathComponents.join("/"), webQuery);
}
