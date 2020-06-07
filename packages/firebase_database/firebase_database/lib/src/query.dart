// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

/// Represents a query over the data at a particular location.
class Query {
  final platform.QueryPlatform delegate;

  Query({
    this.delegate,
    @required List<String> pathComponents,
  })  : _pathComponents = pathComponents,
        assert(delegate != null);

  final List<String> _pathComponents;

  /// Slash-delimited path representing the database location of this query.
  String get path => _pathComponents.join('/');

  /// Listens for a single value event and then stops listening.
  Future<DataSnapshot> once() async {
    return DataSnapshot._(await delegate.once());
  }

  /// Fires when children are added.
  Stream<Event> get onChildAdded => delegate
      .observe(platform.EventType.childAdded)
      .handleError((error) => DatabaseError._(error))
      .map((item) => Event._(item));

  /// Fires when children are removed. `previousChildKey` is null.
  Stream<Event> get onChildRemoved => delegate
      .observe(platform.EventType.childRemoved)
      .handleError((error) => DatabaseError._(error))
      .map((item) => Event._(item));

  /// Fires when children are changed.
  Stream<Event> get onChildChanged => delegate
      .observe(platform.EventType.childChanged)
      .handleError((error) => DatabaseError._(error))
      .map((item) => Event._(item));

  /// Fires when children are moved.
  Stream<Event> get onChildMoved => delegate
      .observe(platform.EventType.childMoved)
      .handleError((error) => DatabaseError._(error))
      .map((item) => Event._(item));

  /// Fires when the data at this location is updated. `previousChildKey` is null.
  Stream<Event> get onValue => delegate
      .observe(platform.EventType.value)
      .handleError((error) => DatabaseError._(error))
      .map((item) => Event._(item));

  /// Create a query constrained to only return child nodes with a value greater
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key greater
  /// than or equal to the given key.
  Query startAt(dynamic value, {String key}) {
    return Query(
        delegate: delegate.startAt(value, key: key),
        pathComponents: _pathComponents);
  }

  /// Create a query constrained to only return child nodes with a value less
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key less
  /// than or equal to the given key.
  Query endAt(dynamic value, {String key}) {
    return Query(
        delegate: delegate.endAt(value, key: key),
        pathComponents: _pathComponents);
  }

  /// Create a query constrained to only return child nodes with the given
  /// `value` (and `key`, if provided).
  ///
  /// If a key is provided, there is at most one such child as names are unique.
  Query equalTo(dynamic value, {String key}) {
    return Query(
        delegate: delegate.equalTo(value, key: key),
        pathComponents: _pathComponents);
  }

  /// Create a query with limit and anchor it to the start of the window.
  Query limitToFirst(int limit) {
    return Query(
        delegate: delegate.limitToFirst(limit),
        pathComponents: _pathComponents);
  }

  /// Create a query with limit and anchor it to the end of the window.
  Query limitToLast(int limit) {
    return Query(
        delegate: delegate.limitToLast(limit), pathComponents: _pathComponents);
  }

  /// Generate a view of the data sorted by values of a particular child key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByChild(String key) {
    return Query(
        delegate: delegate.orderByChild(key), pathComponents: _pathComponents);
  }

  /// Generate a view of the data sorted by key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByKey() {
    return Query(
        delegate: delegate.orderByKey(), pathComponents: _pathComponents);
  }

  /// Generate a view of the data sorted by value.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByValue() {
    return Query(
        delegate: delegate.orderByValue(), pathComponents: _pathComponents);
  }

  /// Generate a view of the data sorted by priority.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByPriority() {
    return Query(
        delegate: delegate.orderByPriority(), pathComponents: _pathComponents);
  }

  /// Obtains a DatabaseReference corresponding to this query's location.
  DatabaseReference reference() =>
      DatabaseReference._(delegate, _pathComponents);

  Future<void> keepSynced(bool value) {
    return delegate.keepSynced(value);
  }
}
