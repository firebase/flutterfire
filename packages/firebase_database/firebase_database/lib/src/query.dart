// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

/// Represents a query over the data at a particular location.
class Query {
  Query._(this._queryPlatform);

  final QueryPlatform _queryPlatform;

  /// Slash-delimited path representing the database location of this query.
  String get path => _queryPlatform.path;

  Map<String, dynamic> buildArguments() {
    return _queryPlatform.buildArguments();
  }

  /// Listens for a single value event and then stops listening.
  Future<DataSnapshot> once() async =>
      DataSnapshot._(await _queryPlatform.once());

  /// Gets the most up-to-date result for this query.
  Future<DataSnapshot> get() async {
    return DataSnapshot._(await _queryPlatform.get());
  }

  /// Fires when children are added.
  Stream<Event> get onChildAdded => _queryPlatform.onChildAdded
      .handleError((error) => DatabaseError._(error))
      .map((item) => Event._(item));

  /// Fires when children are removed. `previousChildKey` is null.
  Stream<Event> get onChildRemoved => _queryPlatform.onChildRemoved
      .handleError((error) => DatabaseError._(error))
      .map((item) => Event._(item));

  /// Fires when children are changed.
  Stream<Event> get onChildChanged => _queryPlatform.onChildChanged
      .handleError((error) => DatabaseError._(error))
      .map((item) => Event._(item));

  /// Fires when children are moved.
  Stream<Event> get onChildMoved => _queryPlatform.onChildMoved
      .handleError((error) => DatabaseError._(error))
      .map((item) => Event._(item));

  /// Fires when the data at this location is updated. `previousChildKey` is null.
  Stream<Event> get onValue => _queryPlatform.onValue
      .handleError((error) => DatabaseError._(error))
      .map((item) => Event._(item));

  /// Create a query constrained to only return child nodes with a value greater
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key greater
  /// than or equal to the given key.
  Query startAt(dynamic value, {String? key}) {
    return Query._(_queryPlatform.startAt(value, key: key));
  }

  /// Create a query constrained to only return child nodes with a value less
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key less
  /// than or equal to the given key.
  Query endAt(dynamic value, {String? key}) {
    return Query._(_queryPlatform.endAt(value, key: key));
  }

  /// Create a query constrained to only return child nodes with the given
  /// `value` (and `key`, if provided).
  ///
  /// If a key is provided, there is at most one such child as names are unique.
  Query equalTo(dynamic value, {String? key}) {
    return Query._(_queryPlatform.equalTo(value, key: key));
  }

  /// Create a query with limit and anchor it to the start of the window.
  Query limitToFirst(int limit) {
    return Query._(_queryPlatform.limitToFirst(limit));
  }

  /// Create a query with limit and anchor it to the end of the window.
  Query limitToLast(int limit) {
    return Query._(_queryPlatform.limitToLast(limit));
  }

  /// Generate a view of the data sorted by values of a particular child key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByChild(String key) {
    return Query._(_queryPlatform.orderByChild(key));
  }

  /// Generate a view of the data sorted by key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByKey() {
    return Query._(_queryPlatform.orderByKey());
  }

  /// Generate a view of the data sorted by value.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByValue() {
    return Query._(_queryPlatform.orderByValue());
  }

  /// Generate a view of the data sorted by priority.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByPriority() {
    return Query._(_queryPlatform.orderByPriority());
  }

  /// Obtains a [DatabaseReference] corresponding to this query's location.
  DatabaseReference get ref => DatabaseReference._(_queryPlatform.ref);

  /// By calling keepSynced(true) on a location, the data for that location will
  /// automatically be downloaded and kept in sync, even when no listeners are
  /// attached for that location. Additionally, while a location is kept synced,
  /// it will not be evicted from the persistent disk cache.
  Future<void> keepSynced(bool value) {
    return _queryPlatform.keepSynced(value);
  }
}
