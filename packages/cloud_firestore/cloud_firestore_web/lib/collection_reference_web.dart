part of cloud_firestore_web;

class CollectionReferenceWeb implements CollectionReference {
  final web.Firestore webFirestore;
  final FirestorePlatform _firestorePlatform;
  final List<String> pathComponents;
  final QueryWeb queryDelegate;

  CollectionReferenceWeb(
      this._firestorePlatform, this.webFirestore, this.pathComponents)
      : queryDelegate = QueryWeb(_firestorePlatform, pathComponents.join("/"),
            webCollection: webFirestore.collection(pathComponents.join("/")));

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
    await newDocument.setData(FieldValueWeb._serverDelegates(data));
    return newDocument;
  }

  @override
  Map<String, dynamic> buildArguments() => queryDelegate.buildArguments();

  @override
  Query endAt(List values) => queryDelegate.endAt(values);

  @override
  Query endAtDocument(DocumentSnapshot documentSnapshot) =>
      queryDelegate.endAtDocument(documentSnapshot);

  @override
  Query endBefore(List values) => queryDelegate.endBefore(values);

  @override
  Query endBeforeDocument(DocumentSnapshot documentSnapshot) =>
      queryDelegate.endBeforeDocument(documentSnapshot);

  @override
  FirestorePlatform get firestore => _firestorePlatform;

  @override
  Future<QuerySnapshot> getDocuments({Source source = Source.serverAndCache}) =>
      queryDelegate.getDocuments(source: source);

  @override
  String get id => pathComponents.isEmpty ? null : pathComponents.last;

  @override
  bool get isCollectionGroup => false;

  @override
  Query limit(int length) => queryDelegate.limit(length);

  @override
  Query orderBy(field, {bool descending = false}) =>
      queryDelegate.orderBy(field, descending: descending);

  @override
  Map<String, dynamic> get parameters => queryDelegate.parameters;

  @override
  String get path => pathComponents.join("/");

  @override
  CollectionReference reference() => queryDelegate.reference();

  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) =>
      queryDelegate.snapshots(includeMetadataChanges: includeMetadataChanges);

  @override
  Query startAfter(List values) => queryDelegate.startAfter(values);

  @override
  Query startAfterDocument(DocumentSnapshot documentSnapshot) =>
      queryDelegate.startAfterDocument(documentSnapshot);

  @override
  Query startAt(List values) => queryDelegate.startAt(values);

  @override
  Query startAtDocument(DocumentSnapshot documentSnapshot) =>
      queryDelegate.startAtDocument(documentSnapshot);

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
      queryDelegate.where(field,
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
