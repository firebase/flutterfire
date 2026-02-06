// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// Base interface for pipeline serialization
abstract class PipelineSerializable {
  Map<String, dynamic> toMap();
}

/// Base class for all pipeline expressions
abstract class PipelineExpression implements PipelineSerializable {
  String? _alias;

  /// Assigns an alias to this expression
  PipelineExpression as(String alias) {
    _alias = alias;
    return this;
  }

  /// Creates a descending ordering for this expression
  Ordering descending() {
    return Ordering(this, OrderDirection.desc);
  }

  /// Creates an ascending ordering for this expression
  Ordering ascending() {
    return Ordering(this, OrderDirection.asc);
  }

  String? get alias => _alias;

  String get name;

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
    };
    if (_alias != null) {
      map['alias'] = _alias;
    }
    return map;
  }
}

/// Base class for function expressions
abstract class FunctionExpression extends PipelineExpression {}

/// Represents a field reference in a pipeline expression
class Field extends PipelineExpression {
  final String fieldName;

  Field(this.fieldName);

  @override
  String get name => 'field';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['args'] = {
      'field': fieldName,
    };
    return map;
  }
}

/// Represents a constant literal value in a pipeline expression
class Constant extends PipelineExpression {
  final dynamic literal;

  Constant(this.literal);

  @override
  String get name => 'constant';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['args'] = {
      'literal': literal,
    };
    return map;
  }
}

/// Represents a concatenation function expression
class Concat extends FunctionExpression {
  final List<PipelineExpression> expressions;

  Concat(this.expressions);

  @override
  String get name => 'concat';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['args'] = {
      'expressions': expressions.map((expr) => expr.toMap()).toList(),
    };
    return map;
  }
}

/// Represents an aliased expression wrapper
class AliasedExpression extends PipelineExpression {
  final PipelineExpression expression;

  AliasedExpression(this.expression);

  @override
  String get name => 'alias';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['args'] = {
      'expression': expression.toMap(),
    };
    return map;
  }
}

/// Base class for boolean expressions used in filtering
abstract class BooleanExpression extends PipelineExpression {}

/// Represents a filter expression for pipeline where clauses
class PipelineFilter extends BooleanExpression {
  final Object field;
  final Object? isEqualTo;
  final Object? isNotEqualTo;
  final Object? isLessThan;
  final Object? isLessThanOrEqualTo;
  final Object? isGreaterThan;
  final Object? isGreaterThanOrEqualTo;
  final Object? arrayContains;
  final List<Object>? arrayContainsAny;
  final List<Object>? whereIn;
  final List<Object>? whereNotIn;
  final bool? isNull;
  final bool? isNotNull;
  final BooleanExpression? _andExpression;
  final BooleanExpression? _orExpression;

  PipelineFilter(
    this.field, {
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
    this.isNotNull,
  })  : _andExpression = null,
        _orExpression = null;

  PipelineFilter._internal({
    required BooleanExpression? andExpression,
    required BooleanExpression? orExpression,
  })  : field = '',
        isEqualTo = null,
        isNotEqualTo = null,
        isLessThan = null,
        isLessThanOrEqualTo = null,
        isGreaterThan = null,
        isGreaterThanOrEqualTo = null,
        arrayContains = null,
        arrayContainsAny = null,
        whereIn = null,
        whereNotIn = null,
        isNull = null,
        isNotNull = null,
        _andExpression = andExpression,
        _orExpression = orExpression;

  /// Creates an OR filter combining multiple boolean expressions
  static PipelineFilter or(
    BooleanExpression expression1, [
    BooleanExpression? expression2,
    BooleanExpression? expression3,
    BooleanExpression? expression4,
    BooleanExpression? expression5,
    BooleanExpression? expression6,
    BooleanExpression? expression7,
    BooleanExpression? expression8,
    BooleanExpression? expression9,
    BooleanExpression? expression10,
    BooleanExpression? expression11,
    BooleanExpression? expression12,
    BooleanExpression? expression13,
    BooleanExpression? expression14,
    BooleanExpression? expression15,
    BooleanExpression? expression16,
    BooleanExpression? expression17,
    BooleanExpression? expression18,
    BooleanExpression? expression19,
    BooleanExpression? expression20,
    BooleanExpression? expression21,
    BooleanExpression? expression22,
    BooleanExpression? expression23,
    BooleanExpression? expression24,
    BooleanExpression? expression25,
    BooleanExpression? expression26,
    BooleanExpression? expression27,
    BooleanExpression? expression28,
    BooleanExpression? expression29,
    BooleanExpression? expression30,
  ]) {
    final expressions = <BooleanExpression>[expression1];
    if (expression2 != null) expressions.add(expression2);
    if (expression3 != null) expressions.add(expression3);
    if (expression4 != null) expressions.add(expression4);
    if (expression5 != null) expressions.add(expression5);
    if (expression6 != null) expressions.add(expression6);
    if (expression7 != null) expressions.add(expression7);
    if (expression8 != null) expressions.add(expression8);
    if (expression9 != null) expressions.add(expression9);
    if (expression10 != null) expressions.add(expression10);
    if (expression11 != null) expressions.add(expression11);
    if (expression12 != null) expressions.add(expression12);
    if (expression13 != null) expressions.add(expression13);
    if (expression14 != null) expressions.add(expression14);
    if (expression15 != null) expressions.add(expression15);
    if (expression16 != null) expressions.add(expression16);
    if (expression17 != null) expressions.add(expression17);
    if (expression18 != null) expressions.add(expression18);
    if (expression19 != null) expressions.add(expression19);
    if (expression20 != null) expressions.add(expression20);
    if (expression21 != null) expressions.add(expression21);
    if (expression22 != null) expressions.add(expression22);
    if (expression23 != null) expressions.add(expression23);
    if (expression24 != null) expressions.add(expression24);
    if (expression25 != null) expressions.add(expression25);
    if (expression26 != null) expressions.add(expression26);
    if (expression27 != null) expressions.add(expression27);
    if (expression28 != null) expressions.add(expression28);
    if (expression29 != null) expressions.add(expression29);
    if (expression30 != null) expressions.add(expression30);

    return PipelineFilter._internal(
      orExpression: _combineExpressions(expressions, 'or'),
      andExpression: null,
    );
  }

  /// Creates an AND filter combining multiple boolean expressions
  static PipelineFilter and(
    BooleanExpression expression1, [
    BooleanExpression? expression2,
    BooleanExpression? expression3,
    BooleanExpression? expression4,
    BooleanExpression? expression5,
    BooleanExpression? expression6,
    BooleanExpression? expression7,
    BooleanExpression? expression8,
    BooleanExpression? expression9,
    BooleanExpression? expression10,
    BooleanExpression? expression11,
    BooleanExpression? expression12,
    BooleanExpression? expression13,
    BooleanExpression? expression14,
    BooleanExpression? expression15,
    BooleanExpression? expression16,
    BooleanExpression? expression17,
    BooleanExpression? expression18,
    BooleanExpression? expression19,
    BooleanExpression? expression20,
    BooleanExpression? expression21,
    BooleanExpression? expression22,
    BooleanExpression? expression23,
    BooleanExpression? expression24,
    BooleanExpression? expression25,
    BooleanExpression? expression26,
    BooleanExpression? expression27,
    BooleanExpression? expression28,
    BooleanExpression? expression29,
    BooleanExpression? expression30,
  ]) {
    final expressions = <BooleanExpression>[expression1];
    if (expression2 != null) expressions.add(expression2);
    if (expression3 != null) expressions.add(expression3);
    if (expression4 != null) expressions.add(expression4);
    if (expression5 != null) expressions.add(expression5);
    if (expression6 != null) expressions.add(expression6);
    if (expression7 != null) expressions.add(expression7);
    if (expression8 != null) expressions.add(expression8);
    if (expression9 != null) expressions.add(expression9);
    if (expression10 != null) expressions.add(expression10);
    if (expression11 != null) expressions.add(expression11);
    if (expression12 != null) expressions.add(expression12);
    if (expression13 != null) expressions.add(expression13);
    if (expression14 != null) expressions.add(expression14);
    if (expression15 != null) expressions.add(expression15);
    if (expression16 != null) expressions.add(expression16);
    if (expression17 != null) expressions.add(expression17);
    if (expression18 != null) expressions.add(expression18);
    if (expression19 != null) expressions.add(expression19);
    if (expression20 != null) expressions.add(expression20);
    if (expression21 != null) expressions.add(expression21);
    if (expression22 != null) expressions.add(expression22);
    if (expression23 != null) expressions.add(expression23);
    if (expression24 != null) expressions.add(expression24);
    if (expression25 != null) expressions.add(expression25);
    if (expression26 != null) expressions.add(expression26);
    if (expression27 != null) expressions.add(expression27);
    if (expression28 != null) expressions.add(expression28);
    if (expression29 != null) expressions.add(expression29);
    if (expression30 != null) expressions.add(expression30);

    return PipelineFilter._internal(
      andExpression: _combineExpressions(expressions, 'and'),
      orExpression: null,
    );
  }

  static BooleanExpression _combineExpressions(
    List<BooleanExpression> expressions,
    String operator,
  ) {
    if (expressions.length == 1) return expressions.first;

    // Create a nested structure for multiple expressions
    BooleanExpression result = expressions.first;
    for (int i = 1; i < expressions.length; i++) {
      if (operator == 'and') {
        result = PipelineFilter.and(result, expressions[i]);
      } else {
        result = PipelineFilter.or(result, expressions[i]);
      }
    }
    return result;
  }

  @override
  String get name => 'filter';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    if (_andExpression != null) {
      map['args'] = {
        'operator': 'and',
        'expressions': [_andExpression.toMap()],
      };
      return map;
    }

    if (_orExpression != null) {
      map['args'] = {
        'operator': 'or',
        'expressions': [_orExpression.toMap()],
      };
      return map;
    }

    final args = <String, dynamic>{};
    if (field is String) {
      args['field'] = field;
    } else if (field is Field) {
      args['field'] = (field as Field).fieldName;
    }

    if (isEqualTo != null) args['isEqualTo'] = isEqualTo;
    if (isNotEqualTo != null) args['isNotEqualTo'] = isNotEqualTo;
    if (isLessThan != null) args['isLessThan'] = isLessThan;
    if (isLessThanOrEqualTo != null) {
      args['isLessThanOrEqualTo'] = isLessThanOrEqualTo;
    }
    if (isGreaterThan != null) args['isGreaterThan'] = isGreaterThan;
    if (isGreaterThanOrEqualTo != null) {
      args['isGreaterThanOrEqualTo'] = isGreaterThanOrEqualTo;
    }
    if (arrayContains != null) args['arrayContains'] = arrayContains;
    if (arrayContainsAny != null) {
      args['arrayContainsAny'] = arrayContainsAny;
    }
    if (whereIn != null) args['whereIn'] = whereIn;
    if (whereNotIn != null) args['whereNotIn'] = whereNotIn;
    if (isNull != null) args['isNull'] = isNull;
    if (isNotNull != null) args['isNotNull'] = isNotNull;

    map['args'] = args;
    return map;
  }
}
