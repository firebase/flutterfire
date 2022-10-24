// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

/// Represents a query over the data at a particular location.
class Query {
  Query._(this._queryDelegate, [QueryModifiers? modifiers])
      : _modifiers = modifiers ?? QueryModifiers([]) {
    QueryPlatform.verify(_queryDelegate);
  }

  final QueryPlatform _queryDelegate;

  final QueryModifiers _modifiers;

  /// Obtains a [DatabaseReference] corresponding to this query's location.
  DatabaseReference get ref => DatabaseReference._(_queryDelegate.ref);

  /// Gets the most up-to-date result for this query.
  Future<DataSnapshot> get() async {
    return DataSnapshot._(await _queryDelegate.get(_modifiers));
  }

  /// Slash-delimited path representing the database location of this query.
  String get path => _queryDelegate.path;

  /// Listens for exactly one event of the specified event type, and then stops listening.
  /// Defaults to [DatabaseEventType.value] if no [eventType] provided.
  Future<DatabaseEvent> once([
    DatabaseEventType eventType = DatabaseEventType.value,
  ]) async {
    switch (eventType) {
      case DatabaseEventType.childAdded:
        return DatabaseEvent._(
          await _queryDelegate.onChildAdded(_modifiers).first,
        );
      case DatabaseEventType.childRemoved:
        return DatabaseEvent._(
          await _queryDelegate.onChildRemoved(_modifiers).first,
        );
      case DatabaseEventType.childChanged:
        return DatabaseEvent._(
          await _queryDelegate.onChildChanged(_modifiers).first,
        );
      case DatabaseEventType.childMoved:
        return DatabaseEvent._(
          await _queryDelegate.onChildMoved(_modifiers).first,
        );
      case DatabaseEventType.value:
        return DatabaseEvent._(await _queryDelegate.onValue(_modifiers).first);
    }
  }

  /// Fires when children are added.
  Stream<DatabaseEvent> get onChildAdded =>
      _queryDelegate.onChildAdded(_modifiers).map(DatabaseEvent._);

  /// Fires when children are removed. `previousChildKey` is null.
  Stream<DatabaseEvent> get onChildRemoved =>
      _queryDelegate.onChildRemoved(_modifiers).map(DatabaseEvent._);

  /// Fires when children are changed.
  Stream<DatabaseEvent> get onChildChanged =>
      _queryDelegate.onChildChanged(_modifiers).map(DatabaseEvent._);

  /// Fires when children are moved.
  Stream<DatabaseEvent> get onChildMoved =>
      _queryDelegate.onChildMoved(_modifiers).map(DatabaseEvent._);

  /// Fires when the data at this location is updated. `previousChildKey` is null.
  Stream<DatabaseEvent> get onValue =>
      _queryDelegate.onValue(_modifiers).map(DatabaseEvent._);

  /// Create a query constrained to only return child nodes with a value greater
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key greater
  /// than or equal to the given key.
  Query startAt(Object? value, {String? key}) {
    return Query._(
      _queryDelegate,
      _modifiers.start(StartCursorModifier.startAt(value, key)),
    );
  }

  /// Creates a [Query] with the specified starting point (exclusive).
  /// Using [startAt], [startAfter], [endBefore], [endAt] and [equalTo]
  /// allows you to choose arbitrary starting and ending points for your
  /// queries.
  ///
  /// The starting point is exclusive.
  ///
  /// If only a value is provided, children with a value greater than
  /// the specified value will be included in the query.
  /// If a key is specified, then children must have a value greater than
  /// or equal to the specified value and a key name greater than
  /// the specified key.
  Query startAfter(Object? value, {String? key}) {
    return Query._(
      _queryDelegate,
      _modifiers.start(StartCursorModifier.startAfter(value, key)),
    );
  }

  /// Create a query constrained to only return child nodes with a value less
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key less
  /// than or equal to the given key.
  Query endAt(Object? value, {String? key}) {
    return Query._(
      _queryDelegate,
      _modifiers.end(EndCursorModifier.endAt(value, key)),
    );
  }

  /// Creates a [Query] with the specified ending point (exclusive)
  /// The ending point is exclusive. If only a value is provided,
  /// children with a value less than the specified value will be included in
  /// the query. If a key is specified, then children must have a value lesss
  /// than or equal to the specified value and a key name less than the
  /// specified key.
  Query endBefore(Object? value, {String? key}) {
    return Query._(
      _queryDelegate,
      _modifiers.end(EndCursorModifier.endBefore(value, key)),
    );
  }

  /// Create a query constrained to only return child nodes with the given
  /// `value` (and `key`, if provided).
  ///
  /// If a key is provided, there is at most one such child as names are unique.
  Query equalTo(Object? value, {String? key}) {
    return Query._(
      _queryDelegate,
      _modifiers
          .start(StartCursorModifier.startAt(value, key))
          .end(EndCursorModifier.endAt(value, key)),
    );
  }

  /// Create a query with limit and anchor it to the start of the window.
  Query limitToFirst(int limit) {
    return Query._(
      _queryDelegate,
      _modifiers.limit(LimitModifier.limitToFirst(limit)),
    );
  }

  /// Create a query with limit and anchor it to the end of the window.
  Query limitToLast(int limit) {
    return Query._(
      _queryDelegate,
      _modifiers.limit(LimitModifier.limitToLast(limit)),
    );
  }

  /// Generate a view of the data sorted by values of a particular child path.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByChild(String path) {
    assert(
      path.isNotEmpty,
      'The key cannot be empty. Use `orderByValue` instead',
    );
    return Query._(
      _queryDelegate,
      _modifiers.order(OrderModifier.orderByChild(path)),
    );
  }

  /// Generate a view of the data sorted by key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByKey() {
    return Query._(
      _queryDelegate,
      _modifiers.order(
        OrderModifier.orderByKey(),
      ),
    );
  }

  /// Generate a view of the data sorted by value.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByValue() {
    return Query._(
      _queryDelegate,
      _modifiers.order(
        OrderModifier.orderByValue(),
      ),
    );
  }

  /// Generate a view of the data sorted by priority.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByPriority() {
    return Query._(
      _queryDelegate,
      _modifiers.order(
        OrderModifier.orderByPriority(),
      ),
    );
  }

  /// By calling keepSynced(true) on a location, the data for that location will
  /// automatically be downloaded and kept in sync, even when no listeners are
  /// attached for that location. Additionally, while a location is kept synced,
  /// it will not be evicted from the persistent disk cache.
  Future<void> keepSynced(bool value) {
    return _queryDelegate.keepSynced(_modifiers, value);
  }
}
