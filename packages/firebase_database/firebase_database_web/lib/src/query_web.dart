// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database_web;

/// An implementation of [QueryPlatform] which proxies calls to js objects
class QueryWeb extends QueryPlatform {
  final database_interop.Database _firebaseDatabase;
  final database_interop.Query _firebaseQuery;

  QueryWeb(
    this._firebaseDatabase,
    DatabasePlatform databasePlatform,
    List<String> pathComponents,
    this._firebaseQuery, {
    Map<String, dynamic> parameters = const <String, dynamic>{},
  }) : super(
          database: databasePlatform,
          pathComponents: pathComponents,
          parameters: parameters,
        );

  @override
  DatabaseReferencePlatform reference() =>
      DatabaseReferenceWeb(_firebaseDatabase, database, pathComponents);

  @override
  String get path => pathComponents.join('/');

  @override
  Future<DataSnapshotPlatform> get() async {
    final snapshot = await _firebaseQuery.get();
    return fromWebSnapshotToPlatformSnapShot(snapshot);
  }

  @override
  Future<DataSnapshotPlatform> once() async {
    return fromWebSnapshotToPlatformSnapShot(
      (await _firebaseQuery.once("value")).snapshot,
    );
  }

  @override
  QueryPlatform startAt(dynamic value, {String? key}) {
    return _withQuery(
      _firebaseQuery.startAt(value, key),
      buildParamsWithStartAt(value, key: key),
    );
  }

  @override
  QueryPlatform endAt(value, {String? key}) {
    return _withQuery(
      _firebaseQuery.endAt(value, key),
      buildParamsWithEndAt(value, key: key),
    );
  }

  @override
  QueryPlatform equalTo(value, {String? key}) {
    return _withQuery(
      _firebaseQuery.equalTo(value, key),
      buildParamsWithEqualTo(value, key: key),
    );
  }

  @override
  QueryPlatform limitToFirst(int limit) {
    return _withQuery(
      _firebaseQuery.limitToFirst(limit),
      buildParamsWithLimitToFirst(limit),
    );
  }

  @override
  QueryPlatform limitToLast(int limit) {
    return _withQuery(
      _firebaseQuery.limitToLast(limit),
      buildParamsWithLimitToLast(limit),
    );
  }

  @override
  QueryPlatform orderByChild(String key) {
    return _withQuery(
      _firebaseQuery.orderByChild(key),
      buildParamsWithOrderByChild(key),
    );
  }

  @override
  QueryPlatform orderByKey() {
    return _withQuery(
      _firebaseQuery.orderByKey(),
      buildParamsWithOrderByKey(),
    );
  }

  @override
  QueryPlatform orderByPriority() {
    return _withQuery(
      _firebaseQuery.orderByPriority(),
      buildParamsWithOrderByPriority(),
    );
  }

  @override
  QueryPlatform orderByValue() {
    return _withQuery(
      _firebaseQuery.orderByValue(),
      buildParamsWithOrderByValue(),
    );
  }

  @override
  Future<void> keepSynced(bool value) async {
    throw UnsupportedError('keepSynced() is not supported on web');
  }

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

  QueryPlatform _withQuery(newQuery, Map<String, dynamic> parameters) {
    return QueryWeb(
      _firebaseDatabase,
      database,
      pathComponents,
      newQuery,
      parameters: parameters,
    );
  }
}
