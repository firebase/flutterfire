part of cloud_firestore_web;

class CollectionReferenceWeb implements CollectionReference {
  final web.Firestore webFirestore;
  final FirestorePlatform _firestorePlatform;
  final List<String> pathComponents;
  final QueryWeb _queryDelegate;

  CollectionReferenceWeb(
      this._firestorePlatform, this.webFirestore, this.pathComponents)
      : _queryDelegate = QueryWeb(_firestorePlatform, pathComponents.join("/"),
            webFirestore.collection(pathComponents.join("/")));

  @override
  DocumentReference parent() {
    if (pathComponents.length < 2) {
      return null;
    }
    return DocumentReferenceWeb(
      webFirestore,
      firestore,
      (List<String>.from(pathComponents)..removeLast()),
    );
  }

  @override
  DocumentReference document([String path]) {
    List<String> childPath;
    if (path == null) {
      final String key = AutoIdGenerator.autoId();
      childPath = List<String>.from(pathComponents)..add(key);
    } else {
      childPath = List<String>.from(pathComponents)..addAll(path.split(('/')));
    }
    return DocumentReferenceWeb(
      webFirestore,
      firestore,
      childPath,
    );
  }

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async {
    final DocumentReference newDocument = document();
    await newDocument.setData(data);
    return newDocument;
  }

  @override
  Map<String, dynamic> buildArguments() => _queryDelegate.buildArguments();

  @override
  Query endAt(List values) => _queryDelegate.endAt(values);

  @override
  Query endAtDocument(DocumentSnapshot documentSnapshot) =>
      _queryDelegate.endAtDocument(documentSnapshot);

  @override
  Query endBefore(List values) => _queryDelegate.endBefore(values);

  @override
  Query endBeforeDocument(DocumentSnapshot documentSnapshot) =>
      _queryDelegate.endBeforeDocument(documentSnapshot);

  @override
  FirestorePlatform get firestore => _firestorePlatform;

  @override
  Future<QuerySnapshot> getDocuments({Source source = Source.serverAndCache}) =>
      _queryDelegate.getDocuments(source: source);

  @override
  String get id => pathComponents.isEmpty ? null : pathComponents.last;

  @override
  bool get isCollectionGroup => false;

  @override
  Query limit(int length) => _queryDelegate.limit(length);

  @override
  Query orderBy(field, {bool descending = false}) =>
      _queryDelegate.orderBy(field, descending: descending);

  @override
  Map<String, dynamic> get parameters => _queryDelegate.parameters;

  @override
  String get path => pathComponents.join("/");

  @override
  CollectionReference reference() => _queryDelegate.reference();

  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) =>
      _queryDelegate.snapshots(includeMetadataChanges: includeMetadataChanges);

  @override
  Query startAfter(List values) => _queryDelegate.startAfter(values);

  @override
  Query startAfterDocument(DocumentSnapshot documentSnapshot) =>
      _queryDelegate.startAfterDocument(documentSnapshot);

  @override
  Query startAt(List values) => _queryDelegate.startAt(values);

  @override
  Query startAtDocument(DocumentSnapshot documentSnapshot) =>
      _queryDelegate.startAtDocument(documentSnapshot);

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
          bool isNull}) =>
      _queryDelegate.where(field,
          isEqualTo: isEqualTo,
          isLessThan: isLessThan,
          isLessThanOrEqualTo: isLessThanOrEqualTo,
          isGreaterThan: isGreaterThan,
          isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
          arrayContains: arrayContains,
          arrayContainsAny: arrayContainsAny,
          whereIn: whereIn,
          isNull: isNull);
}
