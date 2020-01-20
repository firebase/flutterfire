part of firebase_database_web;

class QueryWeb implements Query {
  final DatabasePlatform _databasePlatform;
  final firebase.Query _query;
  final List<String> _pathComponents;

  QueryWeb(
    DatabasePlatform databasePlatform,
    List<String> pathComponents,
    firebase.Query query,
  )   : _databasePlatform = databasePlatform,
        _pathComponents = pathComponents,
        _query = query ??
            databasePlatform.reference().child(pathComponents.join("/"));

  @override
  Query endAt(value, {String key}) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _query.endAt(value, key));
  }

  @override
  Query equalTo(value, {String key}) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _query.equalTo(value, key));
  }

  @override
  Future<void> keepSynced(bool value) {
    throw UnsupportedError("keeySynced() not supported on web");
  }

  @override
  Query limitToFirst(int limit) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _query.limitToFirst(limit));
  }

  @override
  Query limitToLast(int limit) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _query.limitToLast(limit));
  }

  @override

  /// Generate a view of the data sorted by values of a particular child key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByChild(String key) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _query.orderByChild(key));
  }

  @override

  /// Generate a view of the data sorted by key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByKey() {
    return QueryWeb(_databasePlatform, _pathComponents, _query.orderByKey());
  }

  @override

  /// Generate a view of the data sorted by priority.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByPriority() {
    return QueryWeb(_databasePlatform, _pathComponents, _query.orderByValue());
  }

  @override

  /// Generate a view of the data sorted by value.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByValue() {
    return QueryWeb(_databasePlatform, _pathComponents, _query.orderByValue());
  }

  @override

  /// Slash-delimited path representing the database location of this query.
  String get path => _pathComponents.join('/');

  /// Create a query constrained to only return child nodes with a value greater
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key greater
  /// than or equal to the given key.
  Query startAt(dynamic value, {String key}) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _query.startAt(value, key));
  }

  @override
  Stream<Event> observe(EventType eventType) {
    // TODO: implement observe
    return null;
  }

  @override
  // TODO: implement onChildAdded
  Stream<Event> get onChildAdded => null;

  @override
  // TODO: implement onChildChanged
  Stream<Event> get onChildChanged => null;

  @override
  // TODO: implement onChildMoved
  Stream<Event> get onChildMoved => null;

  @override
  // TODO: implement onChildRemoved
  Stream<Event> get onChildRemoved => null;

  @override
  // TODO: implement onValue
  Stream<Event> get onValue => null;

  @override
  Future<DataSnapshot> once() {
    // TODO: implement once
    return null;
  }
}
