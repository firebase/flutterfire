// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

/// Represents a query over the data at a particular location.
class Query {
  final platform.Query delegate;

  Query({
    this.delegate,
    @required List<String> pathComponents,
    Map<String, dynamic> parameters,
  })  : _pathComponents = pathComponents,
        _parameters = parameters ??
            Map<String, dynamic>.unmodifiable(<String, dynamic>{}),
        assert(delegate != null);

  final List<String> _pathComponents;
  final Map<String, dynamic> _parameters;

  /// Slash-delimited path representing the database location of this query.
  String get path => _pathComponents.join('/');

  Query _copyWithParameters(Map<String, dynamic> parameters) {
    return Query(
      delegate: delegate,
      pathComponents: _pathComponents,
      parameters: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(_parameters)..addAll(parameters),
      ),
    );
  }

  Map<String, dynamic> buildArguments() {
    return delegate.buildArguments();
  }

  /// Listens for a single value event and then stops listening.
  Future<DataSnapshot> once() async => (await onValue.first).snapshot;

  /// Fires when children are added.
  Stream<Event> get onChildAdded => delegate.observe(EventType.childAdded);

  /// Fires when children are removed. `previousChildKey` is null.
  Stream<Event> get onChildRemoved => delegate.observe(EventType.childRemoved);

  /// Fires when children are changed.
  Stream<Event> get onChildChanged => delegate.observe(EventType.childChanged);

  /// Fires when children are moved.
  Stream<Event> get onChildMoved => delegate.observe(EventType.childMoved);

  /// Fires when the data at this location is updated. `previousChildKey` is null.
  Stream<Event> get onValue => delegate.observe(_EventType.value);

  /// Create a query constrained to only return child nodes with a value greater
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key greater
  /// than or equal to the given key.
  Query startAt(dynamic value, {String key}) {
    return Query(delegate: delegate.startAt(value, key: key));
  }

  /// Create a query constrained to only return child nodes with a value less
  /// than or equal to the given value, using the given orderBy directive or
  /// priority as default, and optionally only child nodes with a key less
  /// than or equal to the given key.
  Query endAt(dynamic value, {String key}) {
    assert(!_parameters.containsKey('endAt'));
    assert(value is String ||
        value is bool ||
        value is double ||
        value is int ||
        value == null);
    final Map<String, dynamic> parameters = <String, dynamic>{'endAt': value};
    if (key != null) parameters['endAtKey'] = key;
    return _copyWithParameters(parameters);
  }

  /// Create a query constrained to only return child nodes with the given
  /// `value` (and `key`, if provided).
  ///
  /// If a key is provided, there is at most one such child as names are unique.
  Query equalTo(dynamic value, {String key}) {
    assert(!_parameters.containsKey('equalTo'));
    assert(value is String ||
        value is bool ||
        value is double ||
        value is int ||
        value == null);
    final Map<String, dynamic> parameters = <String, dynamic>{'equalTo': value};
    if (key != null) parameters['equalToKey'] = key;
    return _copyWithParameters(parameters);
  }

  /// Create a query with limit and anchor it to the start of the window.
  Query limitToFirst(int limit) {
    assert(!_parameters.containsKey('limitToFirst'));
    return _copyWithParameters(<String, dynamic>{'limitToFirst': limit});
  }

  /// Create a query with limit and anchor it to the end of the window.
  Query limitToLast(int limit) {
    assert(!_parameters.containsKey('limitToLast'));
    return _copyWithParameters(<String, dynamic>{'limitToLast': limit});
  }

  /// Generate a view of the data sorted by values of a particular child key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByChild(String key) {
    assert(key != null);
    assert(!_parameters.containsKey('orderBy'));
    return _copyWithParameters(
      <String, dynamic>{'orderBy': 'child', 'orderByChildKey': key},
    );
  }

  /// Generate a view of the data sorted by key.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByKey() {
    assert(!_parameters.containsKey('orderBy'));
    return _copyWithParameters(<String, dynamic>{'orderBy': 'key'});
  }

  /// Generate a view of the data sorted by value.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByValue() {
    assert(!_parameters.containsKey('orderBy'));
    return _copyWithParameters(<String, dynamic>{'orderBy': 'value'});
  }

  /// Generate a view of the data sorted by priority.
  ///
  /// Intended to be used in combination with [startAt], [endAt], or
  /// [equalTo].
  Query orderByPriority() {
    assert(!_parameters.containsKey('orderBy'));
    return _copyWithParameters(<String, dynamic>{'orderBy': 'priority'});
  }

  /// Obtains a DatabaseReference corresponding to this query's location.
  DatabaseReference reference() =>
      DatabaseReference._(delegate, _pathComponents);
}
