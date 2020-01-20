part of firebase_database_web;

class DatabaseReferenceWeb implements DatabaseReference {
  final firebase.Database _webDatabase;
  final DatabasePlatform _databasePlatform;
  final List<String> _pathComponents;
  firebase.Query queryDelegate;

  DatabaseReferenceWeb(
    this._webDatabase,
    this._databasePlatform,
    this._pathComponents,
  ) : queryDelegate = _webDatabase.ref(_pathComponents.join("/"));

  @override
  DatabaseReference child(String path) {
    return DatabaseReferenceWeb(_webDatabase, _databasePlatform,
        List<String>.from(_pathComponents)..addAll(path.split("/")));
  }

  @override
  Query endAt(value, {String key}) {
    return QueryWeb(
        _databasePlatform, _pathComponents, queryDelegate.endAt(value, key));
  }

  @override
  Query equalTo(value, {String key}) {
    return QueryWeb(
        _databasePlatform, _pathComponents, queryDelegate.equalTo(value, key));
  }

  @override
  Future<void> keepSynced(bool value) {
    throw UnsupportedError("keeySynced() not supported on web");
  }

  @override
  String get key => _pathComponents.last;

  @override
  Query limitToFirst(int limit) {
    return QueryWeb(
        _databasePlatform, _pathComponents, queryDelegate.limitToFirst(limit));
  }

  @override
  Query limitToLast(int limit) {
    return QueryWeb(
        _databasePlatform, _pathComponents, queryDelegate.limitToLast(limit));
  }

  /// Listens for a single value event and then stops listening.
  Future<DataSnapshot> once() async => (await onValue.first).snapshot;

  /// Fires when children are added.
  Stream<Event> get onChildAdded => observe(EventType.childAdded);

  /// Fires when children are removed. `previousChildKey` is null.
  Stream<Event> get onChildRemoved => observe(EventType.childRemoved);

  /// Fires when children are changed.
  Stream<Event> get onChildChanged => observe(EventType.childChanged);

  /// Fires when children are moved.
  Stream<Event> get onChildMoved => observe(EventType.childMoved);

  /// Fires when the data at this location is updated. `previousChildKey` is null.
  Stream<Event> get onValue => observe(EventType.value);

  @override
  OnDisconnect onDisconnect() {
    return _webDatabase.ref(path).onDisconnect();
  }

  @override
  Query orderByChild(String key) {
    return QueryWeb(
        _databasePlatform, _pathComponents, queryDelegate.orderByChild(key));
  }

  @override
  Query orderByKey() {
    return QueryWeb(
        _databasePlatform, _pathComponents, queryDelegate.orderByKey());
  }

  @override
  Query orderByPriority() {
    return QueryWeb(
        _databasePlatform, _pathComponents, queryDelegate.orderByPriority());
  }

  @override
  Query orderByValue() {
    return QueryWeb(
        _databasePlatform, _pathComponents, queryDelegate.orderByValue());
  }

  @override
  DatabaseReference parent() {
    if (_pathComponents.isEmpty) return null;
    return DatabaseReferenceWeb(_webDatabase, _databasePlatform,
        List<String>.from(_pathComponents)..removeLast());
  }

  @override
  String get path => _pathComponents.join("/");

  @override
  DatabaseReference push() {
    final String key = PushIdGenerator.generatePushChildName();
    final List<String> childPath = List<String>.from(_pathComponents)..add(key);
    return DatabaseReferenceWeb(_webDatabase, _databasePlatform, childPath);
  }

  @override
  Future<void> remove() {
    return set(null);
  }

  @override
  DatabaseReference root() {
    return DatabaseReferenceWeb(_webDatabase, _databasePlatform, <String>[]);
  }

  @override
  Future<TransactionResult> runTransaction(transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) {
    // TODO: implement runTransaction
    return null;
  }

  @override
  Future<void> set(value, {priority}) {
    if (priority != null) {
      return _webDatabase.ref(path).setWithPriority(value, priority);
    } else {
      return _webDatabase.ref(path).set(value);
    }
  }

  @override
  Future<void> setPriority(priority) {
    return _webDatabase.ref(path).setPriority(priority);
  }

  @override
  Query startAt(value, {String key}) {
    return QueryWeb(
        _databasePlatform, _pathComponents, queryDelegate.startAt(value, key));
  }

  @override
  Future<void> update(Map<String, dynamic> value) {
    return _webDatabase.ref(path).update(value);
  }

  @override
  Stream<Event> observe(EventType eventType) {
    // TODO: implement observe
    return null;
  }
}
