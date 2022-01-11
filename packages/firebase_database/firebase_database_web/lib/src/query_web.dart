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

  database_interop.Query _getQueryDelegateInstance(QueryModifiers modifiers) {
    database_interop.Query instance = _queryDelegate;

    modifiers.toIterable().forEach((modifier) {
      if (modifier is LimitModifier) {
        if (modifier.name == 'limitToFirst') {
          instance = instance.limitToFirst(modifier.value);
        }
        if (modifier.name == 'limitToLast') {
          instance = instance.limitToLast(modifier.value);
        }
      }

      if (modifier is StartCursorModifier) {
        if (modifier.name == 'startAt') {
          instance = instance.startAt(modifier.value, modifier.key);
        }
        if (modifier.name == 'startAfter') {
          instance = instance.startAfter(modifier.value, modifier.key);
        }
      }

      if (modifier is EndCursorModifier) {
        if (modifier.name == 'endAt') {
          instance = instance.endAt(modifier.value, modifier.key);
        }
        if (modifier.name == 'endBefore') {
          instance = instance.endBefore(modifier.value, modifier.key);
        }
      }

      if (modifier is OrderModifier) {
        if (modifier.name == 'orderByChild') {
          instance = instance.orderByChild(modifier.path!);
        }
        if (modifier.name == 'orderByKey') {
          instance = instance.orderByKey();
        }
        if (modifier.name == 'orderByValue') {
          instance = instance.orderByValue();
        }
        if (modifier.name == 'orderByPriority') {
          instance = instance.orderByPriority();
        }
      }
    });

    return instance;
  }

  @override
  String get path {
    final refPath = Uri.parse(_queryDelegate.ref.toString()).path;
    return refPath.isEmpty ? '/' : refPath;
  }

  @override
  DatabaseReferencePlatform get ref =>
      DatabaseReferenceWeb(_database, _queryDelegate.ref);

  @override
  Future<DataSnapshotPlatform> get(QueryModifiers modifiers) async {
    try {
      final result = await _getQueryDelegateInstance(modifiers).get();
      return webSnapshotToPlatformSnapshot(ref, result);
    } catch (e, s) {
      throw convertFirebaseDatabaseException(e, s);
    }
  }

  @override
  Future<void> keepSynced(QueryModifiers modifiers, bool value) async {
    throw UnsupportedError('keepSynced() is not supported on web');
  }

  @override
  Stream<DatabaseEventPlatform> observe(
      QueryModifiers modifiers, DatabaseEventType eventType) {
    database_interop.Query instance = _getQueryDelegateInstance(modifiers);

    switch (eventType) {
      case DatabaseEventType.childAdded:
        return _webStreamToPlatformStream(
          eventType,
          instance.onChildAdded,
        );
      case DatabaseEventType.childChanged:
        return _webStreamToPlatformStream(
          eventType,
          instance.onChildChanged,
        );
      case DatabaseEventType.childMoved:
        return _webStreamToPlatformStream(
          eventType,
          instance.onChildMoved,
        );
      case DatabaseEventType.childRemoved:
        return _webStreamToPlatformStream(
          eventType,
          instance.onChildRemoved,
        );
      case DatabaseEventType.value:
        return _webStreamToPlatformStream(eventType, instance.onValue);
      default:
        throw Exception("Invalid event type: $eventType");
    }
  }

  Stream<DatabaseEventPlatform> _webStreamToPlatformStream(
    DatabaseEventType eventType,
    Stream<database_interop.QueryEvent> stream,
  ) {
    return stream
        .map(
      (database_interop.QueryEvent event) => webEventToPlatformEvent(
        ref,
        eventType,
        event,
      ),
    )
        .handleError((e, s) {
      throw convertFirebaseDatabaseException(e, s);
    });
  }
}
