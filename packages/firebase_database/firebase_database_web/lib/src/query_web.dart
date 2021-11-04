// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database_web;

/// An implementation of [QueryPlatform] which proxies calls to js objects
class QueryWeb extends QueryPlatform {
  final DatabasePlatform _database;
  final database_interop.Query _queryDelegate;

  QueryWeb(
    this._database,
    this._queryDelegate,
  ) : super(database: _database);

  @override
  DatabaseReferencePlatform get ref =>
      DatabaseReferenceWeb(_database, _queryDelegate.ref);

  @override
  Future<DataSnapshotPlatform> get() async {
    return webSnapshotToPlatformSnapshot(ref, await _queryDelegate.get());
  }

  @override
  QueryPlatform startAt(Object? value, {String? key}) {
    return QueryWeb(_database, _queryDelegate.startAt(value, key));
  }

  @override
  QueryPlatform startAfter(Object? value, {String? key}) {
    return QueryWeb(_database, _queryDelegate.startAfter(value, key));
  }

  @override
  QueryPlatform endAt(Object? value, {String? key}) {
    return QueryWeb(_database, _queryDelegate.endAt(value, key));
  }

  @override
  QueryPlatform endBefore(Object? value, {String? key}) {
    return QueryWeb(_database, _queryDelegate.endBefore(value, key));
  }

  @override
  QueryPlatform equalTo(Object? value, {String? key}) {
    return QueryWeb(_database, _queryDelegate.equalTo(value, key));
  }

  @override
  QueryPlatform limitToFirst(int limit) {
    return QueryWeb(_database, _queryDelegate.limitToFirst(limit));
  }

  @override
  QueryPlatform limitToLast(int limit) {
    return QueryWeb(_database, _queryDelegate.limitToLast(limit));
  }

  @override
  QueryPlatform orderByChild(String key) {
    return QueryWeb(_database, _queryDelegate.orderByChild(key));
  }

  @override
  QueryPlatform orderByKey() {
    return QueryWeb(_database, _queryDelegate.orderByKey());
  }

  @override
  QueryPlatform orderByPriority() {
    return QueryWeb(_database, _queryDelegate.orderByPriority());
  }

  @override
  QueryPlatform orderByValue() {
    return QueryWeb(_database, _queryDelegate.orderByValue());
  }

  @override
  Future<void> keepSynced(bool value) async {
    throw UnsupportedError('keepSynced() is not supported on web');
  }

  @override
  Stream<DatabaseEventPlatform> observe(DatabaseEventType eventType) {
    switch (eventType) {
      case DatabaseEventType.childAdded:
        return _webStreamToPlatformStream(
          eventType,
          _queryDelegate.onChildAdded,
        );
      case DatabaseEventType.childChanged:
        return _webStreamToPlatformStream(
          eventType,
          _queryDelegate.onChildChanged,
        );
      case DatabaseEventType.childMoved:
        return _webStreamToPlatformStream(
          eventType,
          _queryDelegate.onChildMoved,
        );
      case DatabaseEventType.childRemoved:
        return _webStreamToPlatformStream(
          eventType,
          _queryDelegate.onChildRemoved,
        );
      case DatabaseEventType.value:
        return _webStreamToPlatformStream(eventType, _queryDelegate.onValue);
      default:
        throw Exception("Invalid event type: $eventType");
    }
  }

  Stream<DatabaseEventPlatform> _webStreamToPlatformStream(
    DatabaseEventType eventType,
    Stream<database_interop.QueryEvent> stream,
  ) {
    return stream.map(
      (database_interop.QueryEvent event) => webEventToPlatformEvent(
        ref,
        eventType,
        event,
      ),
    );
  }
}
