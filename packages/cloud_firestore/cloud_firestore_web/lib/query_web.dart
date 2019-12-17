part of cloud_firestore_web;

class QueryWeb implements Query {
  final web.CollectionReference webCollection;
  final web.Query webQuery;
  final FirestorePlatform _firestore;
  final bool _isCollectionGroup;
  final String _path;

  QueryWeb(this._firestore, this._path,
      {bool isCollectionGroup, this.webCollection, this.webQuery})
      : this._isCollectionGroup = isCollectionGroup ?? false;

  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) {
    assert(webQuery != null || webCollection != null);
    Stream<web.QuerySnapshot> webSnapshots;
    if (webQuery != null) {
      webSnapshots = webQuery.onSnapshot;
    } else if (webCollection != null) {
      webSnapshots = webCollection.onSnapshot;
    }
    return webSnapshots.map(_webQuerySnapshotToQuerySnapshot);
  }

  @override
  Future<QuerySnapshot> getDocuments(
      {Source source = Source.serverAndCache}) async {
    assert(webQuery != null || webCollection != null);
    web.QuerySnapshot webDocuments;
    if (webQuery != null) {
      webDocuments = await webQuery.get();
    } else if (webCollection != null) {
      webDocuments = await webCollection.get();
    }
    return _webQuerySnapshotToQuerySnapshot(webDocuments);
  }

  @override
  Map<String, dynamic> buildArguments() {
    return null;
  }

  @override
  Query endAt(List values) => QueryWeb(this._firestore, this._path,
      webQuery: webQuery ?? webQuery.endAt(fieldValues: values),
      webCollection: webCollection ?? webCollection.endAt(fieldValues: values));

  @override
  Query endAtDocument(DocumentSnapshot documentSnapshot) =>
      QueryWeb(this._firestore, this._path,
          webQuery: _generateOrderByQuery(documentSnapshot)
              .endAt(fieldValues: documentSnapshot.data.values));

  @override
  Query endBefore(List values) => QueryWeb(this._firestore, this._path,
      webQuery: webQuery ?? webQuery.endBefore(fieldValues: values),
      webCollection:
          webCollection ?? webCollection.endBefore(fieldValues: values));

  @override
  Query endBeforeDocument(DocumentSnapshot documentSnapshot) =>
      QueryWeb(this._firestore, this._path,
          webQuery: _generateOrderByQuery(documentSnapshot)
              .endBefore(fieldValues: documentSnapshot.data.values));

  @override
  FirestorePlatform get firestore => _firestore;

  @override
  bool get isCollectionGroup => _isCollectionGroup;

  @override
  Query limit(int length) => QueryWeb(this._firestore, this._path,
      webQuery: webQuery ?? webQuery.limit(length),
      webCollection: webCollection ?? webCollection.limit(length));

  @override
  Query orderBy(field, {bool descending = false}) => QueryWeb(
        this._firestore,
        this._path,
        webQuery:
            webQuery ?? webQuery.orderBy(field, descending ? "desc" : "asc"),
        webCollection: webCollection ??
            webCollection.orderBy(field, descending ? "desc" : "asc"),
      );

  @override
  Map<String, dynamic> get parameters => null;

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
        webQuery: webQuery ?? webQuery.startAfter(fieldValues: values),
        webCollection:
            webCollection ?? webCollection.startAfter(fieldValues: values),
      );

  @override
  Query startAfterDocument(DocumentSnapshot documentSnapshot) =>
      QueryWeb(this._firestore, this._path,
          webQuery: _generateOrderByQuery(documentSnapshot)
              .startAfter(fieldValues: documentSnapshot.data.values));

  @override
  Query startAt(List values) => QueryWeb(
        this._firestore,
        this._path,
        webQuery: webQuery ?? webQuery.startAt(fieldValues: values),
        webCollection:
            webCollection ?? webCollection.startAt(fieldValues: values),
      );

  @override
  Query startAtDocument(DocumentSnapshot documentSnapshot) =>
      QueryWeb(this._firestore, this._path,
          webQuery: _generateOrderByQuery(documentSnapshot)
              .startAt(fieldValues: documentSnapshot.data.values));

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
    assert(webQuery != null || webCollection != null);
    web.Query query;
    if (webQuery != null) {
      query = webQuery;
    } else if (webCollection != null) {
      query = webCollection;
    }
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
    return QueryWeb(this._firestore, this._path, webQuery: query);
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
        _fromString(webChange.type), webChange.oldIndex, webChange.newIndex,
        _webDocumentSnapshotToDocumentSnapshot(webChange.doc));
  }

  DocumentChangeType _fromString(String item) {
    switch(item.toLowerCase()) {
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
    assert(webQuery != null || webCollection != null);
    web.Query query;
    if (webQuery != null) {
      query = webQuery;
    } else if (webCollection != null) {
      query = webCollection;
    }
    webSnapshot.data.keys.forEach((key) => query = query.orderBy(key));
    return query.endAt(fieldValues: webSnapshot.data.values);
  }

  SnapshotMetadata _webMetadataToMetada(web.SnapshotMetadata webMetadata) {
    return SnapshotMetadata(
        webMetadata.hasPendingWrites, webMetadata.fromCache);
  }
}
