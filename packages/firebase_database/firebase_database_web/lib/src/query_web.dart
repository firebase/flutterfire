// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../firebase_database_web.dart';

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

  final Map<String, int> _streamHashCodeMap = {};

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

  String _createHashCode(
    QueryModifiers modifiers,
    DatabaseEventType eventType,
    String appName,
  ) {
    String hashCode = '0';
    if (kDebugMode) {
      hashCode = Object.hashAll([
        appName,
        path,
        ...modifiers
            .toList()
            .map((e) => const DeepCollectionEquality().hash(e)),
        eventType.index,
      ]).toString();
      // Need to track as the same properties to create hash could be used multiple times
      if (_streamHashCodeMap.containsKey(hashCode)) {
        int count = _streamHashCodeMap[hashCode] ?? 0;
        final updatedCount = count + 1;
        _streamHashCodeMap[hashCode] = updatedCount;
        hashCode = '$hashCode-$updatedCount';
      } else {
        // initial stream
        _streamHashCodeMap[hashCode] = 0;
        hashCode = '$hashCode-0';
      }
    }
    return hashCode;
  }

  @override
  Stream<DatabaseEventPlatform> observe(
      QueryModifiers modifiers, DatabaseEventType eventType) {
    database_interop.Query instance = _getQueryDelegateInstance(modifiers);
    final appName =
        _database.app != null ? _database.app!.name : Firebase.app().name;

    // Purely for unsubscribing purposes in debug mode on "hot restart"
    // if not running in debug mode, hashCode won't be used
    String hashCode = _createHashCode(modifiers, eventType, appName);

    switch (eventType) {
      case DatabaseEventType.childAdded:
        return _webStreamToPlatformStream(
          eventType,
          instance.onChildAdded(
            appName,
            hashCode,
          ),
        );
      case DatabaseEventType.childChanged:
        return _webStreamToPlatformStream(
          eventType,
          instance.onChildChanged(
            appName,
            hashCode,
          ),
        );
      case DatabaseEventType.childMoved:
        return _webStreamToPlatformStream(
          eventType,
          instance.onChildMoved(
            appName,
            hashCode,
          ),
        );
      case DatabaseEventType.childRemoved:
        return _webStreamToPlatformStream(
          eventType,
          instance.onChildRemoved(
            appName,
            hashCode,
          ),
        );
      case DatabaseEventType.value:
        return _webStreamToPlatformStream(
          eventType,
          instance.onValue(
            appName,
            hashCode,
          ),
        );
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
