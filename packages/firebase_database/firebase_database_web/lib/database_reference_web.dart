part of firebase_database_web;

class DatabaseReferenceWeb extends DatabaseReference {
  firebase.DatabaseReference _delegate;
  final firebase.Database _webDatabase;
  final DatabasePlatform _databasePlatform;
  final List<String> _pathComponents;

  DatabaseReferenceWeb(
    this._webDatabase,
    this._databasePlatform,
    this._pathComponents,
  )   : _delegate = _pathComponents.isEmpty
            ? _webDatabase.ref("/")
            : _webDatabase.ref(_pathComponents.join("/")),
        super(_databasePlatform, _pathComponents);

  @override
  DatabaseReference child(String path) {
    return DatabaseReferenceWeb(_webDatabase, _databasePlatform,
        List<String>.from(_pathComponents)..addAll(path.split("/")));
  }

  @override
  Query endAt(value, {String key}) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.endAt(value, key));
  }

  @override
  Query equalTo(value, {String key}) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.equalTo(value, key));
  }

  @override
  Future<void> keepSynced(bool value) {
    print("keeySynced() not supported on web");
  }

  @override
  String get key => _pathComponents.last;

  @override
  Query limitToFirst(int limit) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.limitToFirst(limit));
  }

  @override
  Query limitToLast(int limit) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.limitToLast(limit));
  }

  /// Fetch data on the reference once.
  Future<DataSnapshot> once() async {
    return DataSnapshotWeb._((await _delegate.once("value")).snapshot);
  }

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
    return OnDisconnectWeb._(_delegate.onDisconnect());
  }

  @override
  Query orderByChild(String key) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.orderByChild(key));
  }

  @override
  Query orderByKey() {
    return QueryWeb(_databasePlatform, _pathComponents, _delegate.orderByKey());
  }

  @override
  Query orderByPriority() {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.orderByPriority());
  }

  @override
  Query orderByValue() {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.orderByValue());
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
    if (priority == null) {
      return _delegate.set(value);
    } else {
      return _delegate.setWithPriority(value, priority);
    }
  }

  @override
  Future<void> setPriority(priority) {
    return _delegate.setPriority(priority);
  }

  @override
  Query startAt(value, {String key}) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.startAt(value, key));
  }

  @override
  Future<void> update(Map<String, dynamic> value) {
    return _delegate.update(value);
  }

  @override
  Stream<Event> observe(EventType eventType) {
    switch (eventType) {
      case EventType.childAdded:
        return _webStreamToPlatformStream(_delegate.onChildAdded);
        break;
      case EventType.childChanged:
        return _webStreamToPlatformStream(_delegate.onChildChanged);
        break;
      case EventType.childMoved:
        return _webStreamToPlatformStream(_delegate.onChildMoved);
        break;
      case EventType.childRemoved:
        return _webStreamToPlatformStream(_delegate.onChildRemoved);
        break;
      case EventType.value:
        return _webStreamToPlatformStream(_delegate.onValue);
        break;
      default:
    }
  }

  Stream<Event> _webStreamToPlatformStream(Stream<firebase.QueryEvent> stream) {
    return stream.map(
      (firebase.QueryEvent event) => EventWeb._(event),
    );
  }
}
