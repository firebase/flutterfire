// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class QueryModifiers {
  QueryModifiers(this._modifiers);

  final List<QueryModifier> _modifiers;

  LimitModifier? _limit;
  OrderModifier? _order;
  StartCursorModifier? _start;
  EndCursorModifier? _end;

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
    _start = modifier;
    return _add(modifier);
  }

  /// Creates an end cursor modifier.
  QueryModifiers end(EndCursorModifier modifier) {
    assert(
      _end == null,
      'A ending point was already set (by another call to `endAt`, `endBefore` or `equalTo`)',
    );
    _assertCursorValue(modifier.value);
    _end = modifier;
    return _add(modifier);
  }

  /// Creates an limitTo modifier.
  QueryModifiers limit(LimitModifier modifier) {
    assert(
      _limit == null,
      'A limit was already set (by another call to `limitToFirst` or `limitToLast`)',
    );
    assert(modifier.value >= 0);
    _limit = modifier;
    return _add(modifier);
  }

  /// Creates an orderBy modifier.
  QueryModifiers order(OrderModifier modifier) {
    assert(
      _order == null,
      'An order has already been set, you cannot combine multiple order by calls',
    );
    _order = modifier;
    return _add(modifier);
  }

  /// Adds a modifier, validates and returns a new [QueryModifiers] instance.
  QueryModifiers _add(QueryModifier modifier) {
    _modifiers.add(modifier);
    _validate();
    return QueryModifiers(_modifiers);
  }

  /// Validates the current modifiers.
  void _validate() {
    if (_order?.name == 'orderByKey') {
      assert(
        _start?.key == null && _end?.key == null,
        'When ordering by key, you may only pass a value argument to `startAt`, `endAt`, or `equalTo`',
      );

      assert(
        (_start != null && _start!.value is! String) ||
            (_end != null && _end!.value is! String),
        'When ordering by key, you may only pass a value argument to `startAt`, `endAt`, or `equalTo`',
      );
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

abstract class QueryModifier {
  QueryModifier(this.name);

  final String name;

  Map<String, dynamic> toMap();
}

class LimitModifier implements QueryModifier {
  LimitModifier._(this.name, this.value);

  LimitModifier.limitToFirst(int limit) : this._('limitToFirst', limit);

  LimitModifier.limitToLast(int limit) : this._('limitToLast', limit);

  final int value;

  @override
  final String name;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'type': 'limit', 'name': name, 'limit': value};
  }
}

class StartCursorModifier extends _CursorModifier {
  StartCursorModifier._(String name, Object? value, String? key)
      : super(name, value, key);

  StartCursorModifier.startAt(Object? value, String? key)
      : this._('startAt', value, key);

  StartCursorModifier.startAfter(Object? value, String? key)
      : this._('startAfter', value, key);
}

class EndCursorModifier extends _CursorModifier {
  EndCursorModifier._(String name, Object? value, String? key)
      : super(name, value, key);

  EndCursorModifier.endAt(Object? value, String? key)
      : this._('endAt', value, key);

  EndCursorModifier.endBefore(Object? value, String? key)
      : this._('endBefore', value, key);
}

class _CursorModifier implements QueryModifier {
  _CursorModifier(this.name, this.value, this.key);

  @override
  final String name;

  final Object? value;

  final String? key;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'type': 'cursor', 'name': name, 'key': key};
  }
}

class OrderModifier implements QueryModifier {
  OrderModifier._(this.name, this.path);

  OrderModifier.orderByChild(String path) : this._('orderByChild', path);

  OrderModifier.orderByKey() : this._('orderByKey', null);

  OrderModifier.orderByValue() : this._('orderByValue', null);

  OrderModifier.orderByPriority() : this._('orderByPriority', null);

  @override
  final String name;

  final String? path;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'type': 'orderBy', 'name': name, 'path': path};
  }
}
