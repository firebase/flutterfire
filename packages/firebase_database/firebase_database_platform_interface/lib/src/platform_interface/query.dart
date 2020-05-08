// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_platform_interface;

/// Represents a query over the data at a particular location.
abstract class QueryPlatform extends PlatformInterface {
  /// The Database instance associated with this query
  final DatabasePlatform database;

  /// The pathComponents associated with this query
  final List<String> pathComponents;

  /// The parameters associated with this query
  final Map<String, dynamic> parameters;

  /// Create a [QueryPlatform] instance
  QueryPlatform({
    @required DatabasePlatform database,
    @required List<String> pathComponents,
    Map<String, dynamic> parameters,
  })  : database = database,
        pathComponents = pathComponents,
        parameters = parameters ??
            Map<String, dynamic>.unmodifiable(<String, dynamic>{}),
        assert(database != null);

  /// Slash-delimited path representing the database location of this query.
  String get path => throw UnimplementedError("path not implemented");

  /// Assigns the proper event type to a stream for [EventPlatform]
  Stream<EventPlatform> observe(EventType eventType) {
    throw UnimplementedError("observe() not implemented");
  }

  /// Listens for a single value event and then stops listening.
  Future<DataSnapshotPlatform> once() async => (await onValue.first).snapshot;

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

  /// Create a query constrained to only return child nodes with a value greater
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key greater
  /// than or equal to the given key.
  QueryPlatform startAt(dynamic value, {String key}) {
    throw UnimplementedError("startAt() not implemented");
  }

  /// Create a query constrained to only return child nodes with a value less
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key less
  /// than or equal to the given key.
  QueryPlatform endAt(dynamic value, {String key}) {
    throw UnimplementedError("endAt() not implemented");
  }

  /// Create a query constrained to only return child nodes with the given
  /// `value` (and `key`, if provided).
  ///
  /// If a key is provided, there is at most one such child as names are unique.
  QueryPlatform equalTo(dynamic value, {String key}) {
    throw UnimplementedError("equalTo() not implemented");
  }

  /// Create a query with limit and anchor it to the start of the window.
  QueryPlatform limitToFirst(int limit) {
    throw UnimplementedError("limitToFirst() not implemented");
  }

  /// Create a query with limit and anchor it to the end of the window.
  QueryPlatform limitToLast(int limit) {
    throw UnimplementedError("limitToLast() not implemented");
  }

  /// Generate a view of the data sorted by values of a particular child key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  QueryPlatform orderByChild(String key) {
    throw UnimplementedError("orderByChild() not implemented");
  }

  /// Generate a view of the data sorted by key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  QueryPlatform orderByKey() {
    throw UnimplementedError("orderByKey() not implemented");
  }

  /// Generate a view of the data sorted by value.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  QueryPlatform orderByValue() {
    throw UnimplementedError("orderByValue() not implemented");
  }

  /// Generate a view of the data sorted by priority.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  QueryPlatform orderByPriority() {
    throw UnimplementedError("orderByPriority() not implemented");
  }

  /// By calling keepSynced(true) on a location, the data for that location will
  /// automatically be downloaded and kept in sync, even when no listeners are
  /// attached for that location. Additionally, while a location is kept synced,
  /// it will not be evicted from the persistent disk cache.
  Future<void> keepSynced(bool value) {
    throw UnimplementedError("keepSynced() not implemented");
  }
}
