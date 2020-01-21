// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_platform_interface;

/// Represents a query over the data at a particular location.
abstract class Query {
  final DatabasePlatform _database;
  final List<String> _pathComponents;
  final Map<String, dynamic> _parameters;
  Query({
    @required DatabasePlatform database,
    @required List<String> pathComponents,
    Map<String, dynamic> parameters,
  })  : _database = database,
        _pathComponents = pathComponents,
        _parameters = parameters ??
            Map<String, dynamic>.unmodifiable(<String, dynamic>{}),
        assert(database != null);

  /// Slash-delimited path representing the database location of this query.
  String get path => throw UnimplementedError("path not implemented");

  Map<String, dynamic> buildArguments() {
    throw UnimplementedError("_copyWithParameters() not implemented");
  }

  Stream<Event> observe(EventType eventType) {
    throw UnimplementedError("observe() not implemented");
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

  /// Create a query constrained to only return child nodes with a value greater
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key greater
  /// than or equal to the given key.
  Query startAt(dynamic value, {String key}) {
    throw UnimplementedError("startAt() not implemented");
  }

  /// Create a query constrained to only return child nodes with a value less
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key less
  /// than or equal to the given key.
  Query endAt(dynamic value, {String key}) {
    throw UnimplementedError("endAt() not implemented");
  }

  /// Create a query constrained to only return child nodes with the given
  /// `value` (and `key`, if provided).
  ///
  /// If a key is provided, there is at most one such child as names are unique.
  Query equalTo(dynamic value, {String key}) {
    throw UnimplementedError("equalTo() not implemented");
  }

  /// Create a query with limit and anchor it to the start of the window.
  Query limitToFirst(int limit) {
    throw UnimplementedError("limitToFirst() not implemented");
  }

  /// Create a query with limit and anchor it to the end of the window.
  Query limitToLast(int limit) {
    throw UnimplementedError("limitToLast() not implemented");
  }

  /// Generate a view of the data sorted by values of a particular child key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByChild(String key) {
    throw UnimplementedError("orderByChild() not implemented");
  }

  /// Generate a view of the data sorted by key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByKey() {
    throw UnimplementedError("orderByKey() not implemented");
  }

  /// Generate a view of the data sorted by value.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByValue() {
    throw UnimplementedError("orderByValue() not implemented");
  }

  /// Generate a view of the data sorted by priority.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByPriority() {
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
