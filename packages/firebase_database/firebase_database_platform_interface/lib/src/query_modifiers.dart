// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Represents the available modifiers of a Query instance.
class QueryModifiers {
  /// Constructs a new [QueryModifiers] instance with a given modifier list.
  QueryModifiers(this._modifiers);

  final List<QueryModifier> _modifiers;

  LimitModifier? get _limit {
    final ofType = _modifiers.whereType<LimitModifier>();
    if (ofType.isEmpty) return null;
    return ofType.first;
  }

  OrderModifier? get _order {
    final ofType = _modifiers.whereType<OrderModifier>();
    if (ofType.isEmpty) return null;
    return ofType.first;
  }

  StartCursorModifier? get _start {
    final ofType = _modifiers.whereType<StartCursorModifier>();
    if (ofType.isEmpty) return null;
    return ofType.first;
  }

  EndCursorModifier? get _end {
    final ofType = _modifiers.whereType<EndCursorModifier>();
    if (ofType.isEmpty) return null;
    return ofType.first;
  }

  /// Transforms the instance into an ordered serializable list.
  List<Map<String, Object?>> toList() {
    return _modifiers.map((m) => m.toMap()).toList(growable: false);
  }

  /// Returns the current ordered modifiers list.
  Iterable<QueryModifier> toIterable() {
    return _modifiers;
  }

  /// Creates a start cursor modifier.
  QueryModifiers start(StartCursorModifier modifier) {
    assert(
      _start == null,
      'A starting point was already set (by another call to `startAt`, `startAfter`, or `equalTo`)',
    );
    _assertCursorValue(modifier.value);
    return _add(modifier).._validate();
  }

  /// Creates an end cursor modifier.
  QueryModifiers end(EndCursorModifier modifier) {
    assert(
      _end == null,
      'A ending point was already set (by another call to `endAt`, `endBefore` or `equalTo`)',
    );
    _assertCursorValue(modifier.value);
    return _add(modifier).._validate();
  }

  /// Creates an limitTo modifier.
  QueryModifiers limit(LimitModifier modifier) {
    assert(
      _limit == null,
      'A limit was already set (by another call to `limitToFirst` or `limitToLast`)',
    );
    assert(modifier.value >= 0);
    return _add(modifier).._validate();
  }

  /// Creates an orderBy modifier.
  QueryModifiers order(OrderModifier modifier) {
    assert(
      _order == null,
      'An order has already been set, you cannot combine multiple order by calls',
    );
    return _add(modifier).._validate();
  }

  /// Adds a modifier, validates and returns a new [QueryModifiers] instance.
  QueryModifiers _add(QueryModifier modifier) {
    return QueryModifiers([..._modifiers, modifier]);
  }

  /// Validates the current modifiers.
  void _validate() {
    if (_order?.name == 'orderByKey') {
      if (_start != null) {
        assert(
          _start!.key == null,
          'When ordering by key, you may only pass a value argument with no key to `startAt`, `endAt`, or `equalTo`',
        );
        assert(
          _start!.value is String,
          'When ordering by key, you may only pass a value argument as a String to `startAt`, `endAt`, or `equalTo`',
        );
      }

      if (_end != null) {
        assert(
          _end!.key == null,
          'When ordering by key, you may only pass a value argument with no key to `startAt`, `endAt`, or `equalTo`',
        );
        assert(
          _end!.value is String,
          'When ordering by key, you may only pass a value argument as a String to `startAt`, `endAt`, or `equalTo`',
        );
      }
    }

    if (_order?.name == 'orderByPriority') {
      if (_start != null) {
        _assertPriorityValue(_start!.value);
      }
      if (_end != null) {
        _assertPriorityValue(_end!.value);
      }
    }
  }

  /// Asserts a query modifier value is a valid type.
  void _assertCursorValue(Object? value) {
    assert(
      value is String || value is bool || value is num || value == null,
      'value must be a String, Boolean, Number or null.',
    );
  }

  /// Asserts a given value is a valid priority.
  void _assertPriorityValue(Object? value) {
    assert(
      value == null || value is String || value is num,
      'When ordering by priority, the first value of an order must be a valid priority value (null, String or Number)',
    );
  }
}

/// A single interface for all modifiers to implement.
abstract class QueryModifier {
  /// Constructs a new [QueryModifier] instance.
  QueryModifier(this.name);

  /// The modifier name, e.g. startAt, endBefore, limitToLast etc.
  final String name;

  /// Converts the modifier into a serializable map.
  Map<String, dynamic> toMap();
}

/// A modifier representing a limit query.
class LimitModifier implements QueryModifier {
  LimitModifier._(this.name, this.value);

  /// Creates a new `limitToFirst` modifier with a limit.
  LimitModifier.limitToFirst(int limit) : this._('limitToFirst', limit);

  /// Creates a new `limitToLast` modifier with a limit.
  LimitModifier.limitToLast(int limit) : this._('limitToLast', limit);

  /// The limit value applied to the query.
  final int value;

  @override
  final String name;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'type': 'limit', 'name': name, 'limit': value};
  }
}

/// A modifier representing a start cursor query.
class StartCursorModifier extends _CursorModifier {
  StartCursorModifier._(String name, Object? value, String? key)
      : super(name, value, key);

  /// Creates a new `startAt` modifier with an optional key.
  StartCursorModifier.startAt(Object? value, String? key)
      : this._('startAt', value, key);

  /// Creates a new `startAfter` modifier with an optional key.
  StartCursorModifier.startAfter(Object? value, String? key)
      : this._('startAfter', value, key);
}

/// A modifier representing a end cursor query.
class EndCursorModifier extends _CursorModifier {
  EndCursorModifier._(String name, Object? value, String? key)
      : super(name, value, key);

  /// Creates a new `endAt` modifier with an optional key.
  EndCursorModifier.endAt(Object? value, String? key)
      : this._('endAt', value, key);

  /// Creates a new `endBefore` modifier with an optional key.
  EndCursorModifier.endBefore(Object? value, String? key)
      : this._('endBefore', value, key);
}

/// Underlying cursor query modifier for start and end points.
class _CursorModifier implements QueryModifier {
  _CursorModifier(this.name, this.value, this.key);

  @override
  final String name;

  /// The value to identify what value the cursor should target.
  final Object? value;

  /// An optional key for the cursor query.
  final String? key;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': 'cursor',
      'name': name,
      if (value != null) 'value': value,
      if (key != null) 'key': key,
    };
  }
}

/// A modifier representing an order modifier.
class OrderModifier implements QueryModifier {
  OrderModifier._(this.name, this.path);

  /// Creates a new `orderByChild` modifier with path.
  OrderModifier.orderByChild(String path) : this._('orderByChild', path);

  /// Creates a new `orderByKey` modifier.
  OrderModifier.orderByKey() : this._('orderByKey', null);

  /// Creates a new `orderByValue` modifier.
  OrderModifier.orderByValue() : this._('orderByValue', null);

  /// Creates a new `orderByPriority` modifier.
  OrderModifier.orderByPriority() : this._('orderByPriority', null);

  @override
  final String name;

  /// A path value when ordering by a child path.
  final String? path;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': 'orderBy',
      'name': name,
      if (path != null) 'path': path,
    };
  }
}
