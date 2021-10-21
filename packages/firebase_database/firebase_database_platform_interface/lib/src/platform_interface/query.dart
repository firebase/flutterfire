// ignore_for_file: require_trailing_commas
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

  static final Object _token = Object();

  /// Create a [QueryPlatform] instance
  QueryPlatform({
    required this.database,
    required this.pathComponents,
    this.parameters = const <String, dynamic>{},
  }) : super(token: _token);

  /// Slash-delimited path representing the database location of this query.
  String get path => throw UnimplementedError('path not implemented');

  /// Assigns the proper event type to a stream for [EventPlatform]
  Stream<EventPlatform> observe(EventType eventType) {
    throw UnimplementedError('observe() not implemented');
  }

  Map<String, dynamic> buildArguments() {
    return <String, dynamic>{
      ...parameters,
      'path': path,
    };
  }

  /// Listens for a single value event and then stops listening.
  Future<DataSnapshotPlatform> once() async => (await onValue.first).snapshot;

  /// Gets the most up-to-date result for this query.
  Future<DataSnapshotPlatform> get() {
    throw UnimplementedError('get() not implemented');
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

  /// Create a query constrained to only return child nodes with a value greater
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key greater
  /// than or equal to the given key.
  QueryPlatform startAt(dynamic value, {String? key}) {
    throw UnimplementedError('startAt() not implemented');
  }

  /// Create a query constrained to only return child nodes with a value less
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key less
  /// than or equal to the given key.
  QueryPlatform endAt(dynamic value, {String? key}) {
    throw UnimplementedError('endAt() not implemented');
  }

  /// Create a query constrained to only return child nodes with the given
  /// `value` (and `key`, if provided).
  ///
  /// If a key is provided, there is at most one such child as names are unique.
  QueryPlatform equalTo(dynamic value, {String? key}) {
    throw UnimplementedError('equalTo() not implemented');
  }

  /// Create a query with limit and anchor it to the start of the window.
  QueryPlatform limitToFirst(int limit) {
    throw UnimplementedError('limitToFirst() not implemented');
  }

  /// Create a query with limit and anchor it to the end of the window.
  QueryPlatform limitToLast(int limit) {
    throw UnimplementedError('limitToLast() not implemented');
  }

  /// Generate a view of the data sorted by values of a particular child key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  QueryPlatform orderByChild(String key) {
    throw UnimplementedError('orderByChild() not implemented');
  }

  /// Generate a view of the data sorted by key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  QueryPlatform orderByKey() {
    throw UnimplementedError('orderByKey() not implemented');
  }

  /// Generate a view of the data sorted by value.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  QueryPlatform orderByValue() {
    throw UnimplementedError('orderByValue() not implemented');
  }

  /// Generate a view of the data sorted by priority.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  QueryPlatform orderByPriority() {
    throw UnimplementedError('orderByPriority() not implemented');
  }

  /// By calling keepSynced(true) on a location, the data for that location will
  /// automatically be downloaded and kept in sync, even when no listeners are
  /// attached for that location. Additionally, while a location is kept synced,
  /// it will not be evicted from the persistent disk cache.
  Future<void> keepSynced(bool value) {
    throw UnimplementedError('keepSynced() not implemented');
  }

  /// Obtains a DatabaseReference corresponding to this query's location.
  DatabaseReferencePlatform reference() {
    throw UnimplementedError('reference() not implemented');
  }

  /// generate new parameters for the query by adding the startAt information.
  Map<String, dynamic> buildParamsWithStartAt(dynamic value, {String? key}) {
    assert(!this.parameters.containsKey('startAt'));
    assert(value is String ||
        value is bool ||
        value is double ||
        value is int ||
        value == null);
    final Map<String, dynamic> parameters = <String, dynamic>{'startAt': value};
    if (key != null) parameters['startAtKey'] = key;

    return Map<String, dynamic>.unmodifiable(
      Map<String, dynamic>.from(this.parameters)..addAll(parameters),
    );
  }

  /// generate new parameters for the query by adding the endAt information.
  Map<String, dynamic> buildParamsWithEndAt(dynamic value, {String? key}) {
    assert(!this.parameters.containsKey('endAt'));
    assert(value is String ||
        value is bool ||
        value is double ||
        value is int ||
        value == null);
    final Map<String, dynamic> parameters = <String, dynamic>{'endAt': value};
    if (key != null) parameters['endAtKey'] = key;

    return Map<String, dynamic>.unmodifiable(
      Map<String, dynamic>.from(this.parameters)..addAll(parameters),
    );
  }

  /// generate new parameters for the query by adding the equalTo information.
  Map<String, dynamic> buildParamsWithEqualTo(dynamic value, {String? key}) {
    assert(!this.parameters.containsKey('equalTo'));
    assert(value is String ||
        value is bool ||
        value is double ||
        value is int ||
        value == null);
    final Map<String, dynamic> parameters = <String, dynamic>{'equalTo': value};
    if (key != null) parameters['equalToKey'] = key;

    return Map<String, dynamic>.unmodifiable(
      Map<String, dynamic>.from(this.parameters)..addAll(parameters),
    );
  }

  /// generate new parameters for the query by adding the limitToFirst information.
  Map<String, dynamic> buildParamsWithLimitToFirst(int limit) {
    assert(!parameters.containsKey('limitToFirst'));

    return Map<String, dynamic>.unmodifiable(
      Map<String, dynamic>.from(parameters)
        ..addAll(
          <String, dynamic>{'limitToFirst': limit},
        ),
    );
  }

  /// generate new parameters for the query by adding the limitToLast information.
  Map<String, dynamic> buildParamsWithLimitToLast(int limit) {
    assert(!parameters.containsKey('limitToLast'));

    return Map<String, dynamic>.unmodifiable(
      Map<String, dynamic>.from(parameters)
        ..addAll(
          <String, dynamic>{'limitToLast': limit},
        ),
    );
  }

  /// generate new parameters for the query by adding the orderByChild information.
  Map<String, dynamic> buildParamsWithOrderByChild(String key) {
    assert(!parameters.containsKey('orderBy'));

    return Map<String, dynamic>.unmodifiable(
      Map<String, dynamic>.from(parameters)
        ..addAll(
          <String, dynamic>{'orderBy': 'child', 'orderByChildKey': key},
        ),
    );
  }

  /// generate new parameters for the query by adding the orderByKey information.
  Map<String, dynamic> buildParamsWithOrderByKey() {
    assert(!parameters.containsKey('orderBy'));

    return Map<String, dynamic>.unmodifiable(
      Map<String, dynamic>.from(parameters)
        ..addAll(
          <String, dynamic>{'orderBy': 'key'},
        ),
    );
  }

  /// generate new parameters for the query by adding the orderByValue information.
  Map<String, dynamic> buildParamsWithOrderByValue() {
    assert(!parameters.containsKey('orderBy'));

    return Map<String, dynamic>.unmodifiable(
      Map<String, dynamic>.from(parameters)
        ..addAll(
          <String, dynamic>{'orderBy': 'value'},
        ),
    );
  }

  /// generate new parameters for the query by adding the orderByPriority information.
  Map<String, dynamic> buildParamsWithOrderByPriority() {
    assert(!parameters.containsKey('orderBy'));

    return Map<String, dynamic>.unmodifiable(
      Map<String, dynamic>.from(parameters)
        ..addAll(
          <String, dynamic>{'orderBy': 'priority'},
        ),
    );
  }
}
