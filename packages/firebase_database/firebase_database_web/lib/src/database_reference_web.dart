// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database_web;

/// Web implementation for firebase [DatabaseReferencePlatform]
class DatabaseReferenceWeb extends DatabaseReferencePlatform {
  web.DatabaseReference _delegate;
  final web.Database _webDatabase;
  final DatabasePlatform _databasePlatform;
  final List<String> _pathComponents;

  /// Builds an instance of [DatabaseReferenceWeb] delegating to a package:firebase [DatabaseReferencePlatform]
  /// to delegate queries to underlying firebase web plugin
  DatabaseReferenceWeb(
    this._webDatabase,
    this._databasePlatform,
    this._pathComponents,
  )   : _delegate = _pathComponents.isEmpty
            ? _webDatabase.ref("/")
            : _webDatabase.ref(_pathComponents.join("/")),
        super(_databasePlatform, _pathComponents);

  @override
  DatabaseReferencePlatform child(String path) {
    return DatabaseReferenceWeb(_webDatabase, _databasePlatform,
        List<String>.from(_pathComponents)..addAll(path.split("/")));
  }

  @override
  QueryPlatform endAt(value, {String key}) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.endAt(value, key));
  }

  @override
  QueryPlatform equalTo(value, {String key}) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.equalTo(value, key));
  }

  @override
  Future<void> keepSynced(bool value) async {
    throw Exception("keeySynced() not supported on web");
  }

  @override
  String get key => _pathComponents.last;

  @override
  QueryPlatform limitToFirst(int limit) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.limitToFirst(limit));
  }

  @override
  QueryPlatform limitToLast(int limit) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.limitToLast(limit));
  }

  /// Fetch data on the reference once.
  Future<DataSnapshotPlatform> once() async {
    return fromWebSnapshotToPlatformSnapShot(
        (await _delegate.once("value")).snapshot);
  }

  /// Fires when children are added.
  Stream<EventPlatform> get onChildAdded => observe(EventType.childAdded);

  /// Fires when children are removed. `previousChildKey` is null.
  Stream<EventPlatform> get onChildRemoved => observe(EventType.childRemoved);

  /// Fires when children are changed.
  Stream<EventPlatform> get onChildChanged => observe(EventType.childChanged);

  /// Fires when children are moved.
  Stream<EventPlatform> get onChildMoved => observe(EventType.childMoved);

  /// Fires when the data at this location is updated. `previousChildKey` is null.
  Stream<EventPlatform> get onValue => observe(EventType.value);

  @override
  OnDisconnectPlatform onDisconnect() {
    return OnDisconnectWeb._(_delegate.onDisconnect());
  }

  @override
  QueryPlatform orderByChild(String key) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.orderByChild(key));
  }

  @override
  QueryPlatform orderByKey() {
    return QueryWeb(_databasePlatform, _pathComponents, _delegate.orderByKey());
  }

  @override
  QueryPlatform orderByPriority() {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.orderByPriority());
  }

  @override
  QueryPlatform orderByValue() {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.orderByValue());
  }

  @override
  DatabaseReferencePlatform parent() {
    if (_pathComponents.isEmpty) return null;
    return DatabaseReferenceWeb(_webDatabase, _databasePlatform,
        List<String>.from(_pathComponents)..removeLast());
  }

  @override
  String get path => _pathComponents.join("/");

  @override
  DatabaseReferencePlatform push() {
    final String key = PushIdGenerator.generatePushChildName();
    final List<String> childPath = List<String>.from(_pathComponents)..add(key);
    return DatabaseReferenceWeb(_webDatabase, _databasePlatform, childPath);
  }

  @override
  Future<void> remove() {
    return set(null);
  }

  @override
  DatabaseReferencePlatform root() {
    return DatabaseReferenceWeb(_webDatabase, _databasePlatform, <String>[]);
  }

  @override
  Future<TransactionResultPlatform> runTransaction(transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) {
    throw Exception("runTransaction() is not supported on web");
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
  QueryPlatform startAt(value, {String key}) {
    return QueryWeb(
        _databasePlatform, _pathComponents, _delegate.startAt(value, key));
  }

  @override
  Future<void> update(Map<String, dynamic> value) {
    return _delegate.update(value);
  }

  @override
  Stream<EventPlatform> observe(EventType eventType) {
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
        throw Exception("Invalid event type");
    }
  }

  Stream<EventPlatform> _webStreamToPlatformStream(
      Stream<web.QueryEvent> stream) {
    return stream.map(
      (web.QueryEvent event) => fromWebEventToPlatformEvent(event),
    );
  }
}
