// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database_web;

/// Web implementation for firebase [QueryPlatform]
class QueryWeb extends QueryPlatform {
  final database_interop.Database _firebaseDatabase;
  final database_interop.Query _firebaseQuery;

  /// Builds an instance of [QueryWeb] delegating to a package:firebase [QueryPlatform]
  /// to delegate queries to underlying firebase web plugin
  QueryWeb(
    this._firebaseDatabase,
    DatabasePlatform databasePlatform,
    List<String> pathComponents,
    this._firebaseQuery,
  ) : super(
          database: databasePlatform,
          pathComponents: pathComponents,
        );

  /// Create a query constrained to only return child nodes with a value greater
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key greater
  /// than or equal to the given key.
  @override
  QueryPlatform startAt(dynamic value, {String? key}) {
    return QueryWeb(_firebaseDatabase, database, pathComponents,
        _firebaseQuery.startAt(value, key));
  }

  @override
  QueryPlatform endAt(value, {String? key}) {
    return QueryWeb(_firebaseDatabase, database, pathComponents,
        _firebaseQuery.endAt(value, key));
  }

  @override
  QueryPlatform equalTo(value, {String? key}) {
    return QueryWeb(_firebaseDatabase, database, pathComponents,
        _firebaseQuery.equalTo(value, key));
  }

  @override
  QueryPlatform limitToFirst(int limit) {
    return QueryWeb(_firebaseDatabase, database, pathComponents,
        _firebaseQuery.limitToFirst(limit));
  }

  @override
  QueryPlatform limitToLast(int limit) {
    return QueryWeb(_firebaseDatabase, database, pathComponents,
        _firebaseQuery.limitToLast(limit));
  }

  @override
  Future<DataSnapshotPlatform> once() async {
    return fromWebSnapshotToPlatformSnapShot(
        (await _firebaseQuery.once("value")).snapshot);
  }

  @override
  Future<DataSnapshotPlatform> get() async {
    // https://github.com/FirebaseExtended/firebase-dart/issues/400
    throw UnimplementedError("get() is not supported on web");
  }

  /// Generate a view of the data sorted by values of a particular child key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  @override
  QueryPlatform orderByChild(String key) {
    return QueryWeb(_firebaseDatabase, database, pathComponents,
        _firebaseQuery.orderByChild(key));
  }

  /// Generate a view of the data sorted by key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  @override
  QueryPlatform orderByKey() {
    return QueryWeb(_firebaseDatabase, database, pathComponents,
        _firebaseQuery.orderByKey());
  }

  /// Generate a view of the data sorted by priority.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  @override
  QueryPlatform orderByPriority() {
    return QueryWeb(_firebaseDatabase, database, pathComponents,
        _firebaseQuery.orderByValue());
  }

  /// Generate a view of the data sorted by value.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  @override
  QueryPlatform orderByValue() {
    return QueryWeb(_firebaseDatabase, database, pathComponents,
        _firebaseQuery.orderByValue());
  }

  @override
  Future<void> keepSynced(bool value) {
    throw UnsupportedError("keepSynced() not supported on web");
  }

  /// Slash-delimited path representing the database location of this query.
  @override
  String get path => pathComponents.join('/');

  @override
  Stream<EventPlatform> observe(EventType eventType) {
    switch (eventType) {
      case EventType.childAdded:
        return _webStreamToPlatformStream(_firebaseQuery.onChildAdded);
      case EventType.childChanged:
        return _webStreamToPlatformStream(_firebaseQuery.onChildChanged);
      case EventType.childMoved:
        return _webStreamToPlatformStream(_firebaseQuery.onChildMoved);
      case EventType.childRemoved:
        return _webStreamToPlatformStream(_firebaseQuery.onChildRemoved);
      case EventType.value:
        return _webStreamToPlatformStream(_firebaseQuery.onValue);
      default:
        throw Exception("Invalid event type: $eventType");
    }
  }

  Stream<EventPlatform> _webStreamToPlatformStream(
      Stream<database_interop.QueryEvent> stream) {
    return stream.map((database_interop.QueryEvent event) =>
        fromWebEventToPlatformEvent(event));
  }

  /// Obtains a DatabaseReference corresponding to this query's location.
  @override
  DatabaseReferencePlatform reference() =>
      DatabaseReferenceWeb(_firebaseDatabase, database, pathComponents);
}
