// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// Base interface for pipeline serialization
mixin PipelineSerializable {
  Map<String, dynamic> toMap();
}

/// Helper function to convert values to Expression (wraps in Constant if needed)
Expression _toExpression(Object? value) {
  if (value == null) return Constant(null);
  if (value is Expression) return value;
  if (value is List) return Expression.array(value.cast<Object?>());
  if (value is Map) {
    return Expression.map(value.cast<String, Object?>());
  }
  return Constant(value);
}

/// Valid unit strings for timestamp add/subtract/truncate expressions.
const Set<String> _timestampUnits = {
  'microsecond',
  'millisecond',
  'second',
  'minute',
  'hour',
  'day',
};

void _validateTimestampUnit(String unit) {
  if (!_timestampUnits.contains(unit)) {
    throw ArgumentError(
      "Timestamp unit must be one of: 'microsecond', 'millisecond', 'second', "
      "'minute', 'hour', 'day'. Got: '$unit'",
    );
  }
}

/// Validates and normalizes [Expression.switchOn] arguments.
List<Object> _parseSwitchOnParts(List<Object?> parts) {
  final n = parts.length;
  if (n < 2) {
    throw ArgumentError.value(
      parts,
      'parts',
      'switchOn requires at least a condition and a result',
    );
  }
  if (n.isEven) {
    final out = <Object>[];
    for (var i = 0; i < n; i += 2) {
      final c = parts[i];
      final r = parts[i + 1];
      if (c is! BooleanExpression) {
        throw ArgumentError(
          'switchOn position $i: expected BooleanExpression, got ${c.runtimeType}',
        );
      }
      if (r is! Expression) {
        throw ArgumentError(
          'switchOn position ${i + 1}: expected Expression, got ${r.runtimeType}',
        );
      }
      out.add(c);
      out.add(r);
    }
    return out;
  }
  final out = <Object>[];
  for (var i = 0; i < n - 1; i += 2) {
    final c = parts[i];
    final r = parts[i + 1];
    if (c is! BooleanExpression) {
      throw ArgumentError(
        'switchOn position $i: expected BooleanExpression, got ${c.runtimeType}',
      );
    }
    if (r is! Expression) {
      throw ArgumentError(
        'switchOn position ${i + 1}: expected Expression, got ${r.runtimeType}',
      );
    }
    out.add(c);
    out.add(r);
  }
  final d = parts[n - 1];
  if (d is! Expression) {
    throw ArgumentError(
      'switchOn default: expected Expression, got ${d.runtimeType}',
    );
  }
  out.add(d);
  return out;
}

/// Value types for [Expression.isType] and [Expression.isTypeStatic].
enum Type {
  /// `null`
  nullValue('null'),

  /// `array`
  array('array'),

  /// `boolean`
  boolean('boolean'),

  /// `bytes`
  bytes('bytes'),

  /// `timestamp`
  timestamp('timestamp'),

  /// `geo_point`
  geoPoint('geo_point'),

  /// `number`
  number('number'),

  /// `int32`
  int32('int32'),

  /// `int64`
  int64('int64'),

  /// `float64`
  float64('float64'),

  /// `decimal128`
  decimal128('decimal128'),

  /// `map`
  map('map'),

  /// `reference`
  reference('reference'),

  /// `string`
  string('string'),

  /// `vector`
  vector('vector'),

  /// `max_key`
  maxKey('max_key'),

  /// `min_key`
  minKey('min_key'),

  /// `object_id`
  objectId('object_id'),

  /// `regex`
  regex('regex'),

  /// `request_timestamp`
  requestTimestamp('request_timestamp');

  const Type(this.typeValue);

  /// String passed to Firestore for `is_type` (same literals as the JS SDK).
  final String typeValue;
}

/// Base class for all pipeline expressions
abstract class Expression implements PipelineSerializable {
  /// Creates an aliased expression
  AliasedExpression as(String alias) {
    return AliasedExpression(
      alias: alias,
      expression: this,
    );
  }

  /// Creates a descending ordering for this expression
  Ordering descending() {
    return Ordering(this, OrderDirection.desc);
  }

  /// Creates an ascending ordering for this expression
  Ordering ascending() {
    return Ordering(this, OrderDirection.asc);
  }

  // ============================================================================
  // CONDITIONAL / LOGIC OPERATIONS
  // ============================================================================

  /// Returns an alternative expression if this expression is absent
  Expression ifAbsent(Expression elseExpr) {
    return _IfAbsentExpression(this, elseExpr);
  }

  /// Returns an alternative value if this expression is absent
  Expression ifAbsentValue(Object? elseValue) {
    return _IfAbsentExpression(this, _toExpression(elseValue));
  }

  /// Returns an alternative expression if this expression errors
  Expression ifError(Expression catchExpr) {
    return _IfErrorExpression(this, catchExpr);
  }

  /// Returns an alternative value if this expression errors
  Expression ifErrorValue(Object? catchValue) {
    return _IfErrorExpression(this, _toExpression(catchValue));
  }

  /// Checks if this expression is absent (null/undefined)
  // ignore: use_to_and_as_if_applicable
  BooleanExpression isAbsent() {
    return _IsAbsentExpression(this);
  }

  /// Checks if this expression produces an error
  // ignore: use_to_and_as_if_applicable
  BooleanExpression isError() {
    return _IsErrorExpression(this);
  }

  /// Checks if this field expression exists in the document
  // ignore: use_to_and_as_if_applicable
  BooleanExpression exists() {
    return _ExistsExpression(this);
  }

  // ============================================================================
  // TYPE CONVERSION
  // ============================================================================

  /// Casts this expression to a boolean expression
  BooleanExpression asBoolean() {
    return _AsBooleanExpression(this);
  }

  // ============================================================================
  // BITWISE OPERATIONS
  // ============================================================================

  /// Performs bitwise AND with another expression
  Expression bitAnd(Expression bitsOther) {
    return _BitAndExpression(this, bitsOther);
  }

  /// Performs bitwise AND with byte array
  Expression bitAndBytes(List<int> bitsOther) {
    return _BitAndExpression(this, Constant(bitsOther));
  }

  /// Performs bitwise OR with another expression
  Expression bitOr(Expression bitsOther) {
    return _BitOrExpression(this, bitsOther);
  }

  /// Performs bitwise OR with byte array
  Expression bitOrBytes(List<int> bitsOther) {
    return _BitOrExpression(this, Constant(bitsOther));
  }

  /// Performs bitwise XOR with another expression
  Expression bitXor(Expression bitsOther) {
    return _BitXorExpression(this, bitsOther);
  }

  /// Performs bitwise XOR with byte array
  Expression bitXorBytes(List<int> bitsOther) {
    return _BitXorExpression(this, Constant(bitsOther));
  }

  /// Performs bitwise NOT on this expression
  // ignore: use_to_and_as_if_applicable
  Expression bitNot() {
    return _BitNotExpression(this);
  }

  /// Shifts bits left by an expression amount
  Expression bitLeftShift(Expression numberExpr) {
    return _BitLeftShiftExpression(this, numberExpr);
  }

  /// Shifts bits left by a literal amount
  Expression bitLeftShiftLiteral(int number) {
    return _BitLeftShiftExpression(this, Constant(number));
  }

  /// Shifts bits right by an expression amount
  Expression bitRightShift(Expression numberExpr) {
    return _BitRightShiftExpression(this, numberExpr);
  }

  /// Shifts bits right by a literal amount
  Expression bitRightShiftLiteral(int number) {
    return _BitRightShiftExpression(this, Constant(number));
  }

  // ============================================================================
  // DOCUMENT / PATH OPERATIONS
  // ============================================================================

  /// Returns the document ID from this path expression
  // ignore: use_to_and_as_if_applicable
  Expression documentId() {
    return _DocumentIdExpression(this);
  }

  /// Returns the collection ID from this path expression
  // ignore: use_to_and_as_if_applicable
  Expression collectionId() {
    return _CollectionIdExpression(this);
  }

  // ============================================================================
  // MAP OPERATIONS
  // ============================================================================

  /// Gets a value from this map expression by key expression
  Expression mapGet(Expression key) {
    return _MapGetExpression(this, key);
  }

  /// Gets a value from this map expression by literal key
  Expression mapGetLiteral(String key) {
    return _MapGetExpression(this, Constant(key));
  }

  /// Returns a map expression with keys set to the given values (shallow update).
  ///
  /// [key] and [value] are the first pair. [moreKeyValues] must be alternating
  /// keys and values. Setting a value to `null` keeps the key with a null value;
  /// use map APIs that remove keys if you need deletion semantics.
  Expression mapSet(
    Object? key,
    Object? value, [
    List<Object?>? moreKeyValues,
  ]) {
    final pairs = <Expression>[_toExpression(key), _toExpression(value)];
    if (moreKeyValues != null) {
      for (final o in moreKeyValues) {
        pairs.add(_toExpression(o));
      }
    }
    return _MapSetExpression(this, pairs);
  }

  /// Returns an array of `{k, v}` map entries for this map expression.
  // ignore: use_to_and_as_if_applicable
  Expression mapEntries() {
    return _MapEntriesExpression(this);
  }

  /// Returns an array of keys for this map expression.
  // ignore: use_to_and_as_if_applicable
  Expression mapKeys() {
    return _MapKeysExpression(this);
  }

  /// Returns an array of values for this map expression.
  // ignore: use_to_and_as_if_applicable
  Expression mapValues() {
    return _MapValuesExpression(this);
  }

  /// Parent collection or document reference for this document reference expression.
  // ignore: use_to_and_as_if_applicable
  Expression parent() {
    return _ParentExpression(this);
  }

  /// Difference between this timestamp ([end]) and [start], in [unit] (a unit string
  /// or an expression).
  Expression timestampDiff(Expression start, Object unit) {
    return _TimestampDiffExpression(this, start, _toExpression(unit));
  }

  /// Extracts [part] (string or expression) from this timestamp; optional [timezone].
  Expression timestampExtract(Object part, [Object? timezone]) {
    return _TimestampExtractExpression(
      this,
      _toExpression(part),
      timezone == null ? null : _toExpression(timezone),
    );
  }

  /// If this expression is null, evaluates to [replacement].
  Expression ifNull(Expression replacement) {
    return _IfNullExpression(this, replacement);
  }

  /// If this expression is null, evaluates to [replacement].
  Expression ifNullValue(Object? replacement) {
    return _IfNullExpression(this, _toExpression(replacement));
  }

  // ============================================================================
  // ALIASING
  // ============================================================================

  /// Assigns an alias to this expression for use in output
  Selectable alias(String alias) {
    return AliasedExpression(alias: alias, expression: this);
  }

  // ============================================================================
  // ARITHMETIC OPERATIONS
  // ============================================================================

  /// Adds this expression to another expression
  Expression add(Expression other) {
    return _AddExpression(this, other);
  }

  /// Adds a number to this expression
  Expression addNumber(num other) {
    return _AddExpression(this, Constant(other));
  }

  /// Subtracts another expression from this expression
  Expression subtract(Expression other) {
    return _SubtractExpression(this, other);
  }

  /// Subtracts a number from this expression
  Expression subtractNumber(num other) {
    return _SubtractExpression(this, Constant(other));
  }

  /// Multiplies this expression by another expression
  Expression multiply(Expression other) {
    return _MultiplyExpression(this, other);
  }

  /// Multiplies this expression by a number
  Expression multiplyNumber(num other) {
    return _MultiplyExpression(this, Constant(other));
  }

  /// Divides this expression by another expression
  Expression divide(Expression other) {
    return _DivideExpression(this, other);
  }

  /// Divides this expression by a number
  Expression divideNumber(num other) {
    return _DivideExpression(this, Constant(other));
  }

  /// Returns the remainder of dividing this expression by another
  Expression modulo(Expression other) {
    return _ModuloExpression(this, other);
  }

  /// Returns the remainder of dividing this expression by a number
  Expression moduloNumber(num other) {
    return _ModuloExpression(this, Constant(other));
  }

  /// Returns the absolute value of this expression
  // ignore: use_to_and_as_if_applicable
  Expression abs() {
    return _AbsExpression(this);
  }

  /// Truncates this numeric expression toward zero.
  ///
  /// If [decimals] is omitted, truncates to an integer. If provided, truncates to
  /// that many fractional digits (Firestore pipeline `trunc`).
  Expression trunc([Expression? decimals]) {
    return _TruncExpression(this, decimals);
  }

  // ============================================================================
  // COMPARISON OPERATIONS (return BooleanExpression)
  // ============================================================================

  /// Checks if this expression equals another expression
  BooleanExpression equal(Expression other) {
    return _EqualExpression(this, other);
  }

  /// Checks if this expression equals a value
  BooleanExpression equalValue(Object? value) {
    return _EqualExpression(this, _toExpression(value));
  }

  /// Checks if this expression does not equal another expression
  BooleanExpression notEqual(Expression other) {
    return _NotEqualExpression(this, other);
  }

  /// Checks if this expression does not equal a value
  BooleanExpression notEqualValue(Object? value) {
    return _NotEqualExpression(this, _toExpression(value));
  }

  /// Checks if this expression is greater than another expression
  BooleanExpression greaterThan(Expression other) {
    return _GreaterThanExpression(this, other);
  }

  /// Checks if this expression is greater than a value
  BooleanExpression greaterThanValue(Object? value) {
    return _GreaterThanExpression(this, _toExpression(value));
  }

  /// Checks if this expression is greater than or equal to another expression
  BooleanExpression greaterThanOrEqual(Expression other) {
    return _GreaterThanOrEqualExpression(this, other);
  }

  /// Checks if this expression is greater than or equal to a value
  BooleanExpression greaterThanOrEqualValue(Object? value) {
    return _GreaterThanOrEqualExpression(this, _toExpression(value));
  }

  /// Checks if this expression is less than another expression
  BooleanExpression lessThan(Expression other) {
    return _LessThanExpression(this, other);
  }

  /// Checks if this expression is less than a value
  BooleanExpression lessThanValue(Object? value) {
    return _LessThanExpression(this, _toExpression(value));
  }

  /// Checks if this expression is less than or equal to another expression
  BooleanExpression lessThanOrEqual(Expression other) {
    return _LessThanOrEqualExpression(this, other);
  }

  /// Checks if this expression is less than or equal to a value
  BooleanExpression lessThanOrEqualValue(Object? value) {
    return _LessThanOrEqualExpression(this, _toExpression(value));
  }

  // ============================================================================
  // STRING OPERATIONS
  // ============================================================================

  /// Returns the length of this string expression
  // ignore: use_to_and_as_if_applicable
  Expression length() {
    return _LengthExpression(this);
  }

  /// Concatenates this expression with other expressions/values
  Expression concat(List<Object?> others) {
    final expressions = <Expression>[this];
    for (final other in others) {
      expressions.add(_toExpression(other));
    }
    return _ConcatExpression(expressions);
  }

  /// Converts this string expression to lowercase
  Expression toLowerCase() {
    return _ToLowerCaseExpression(this);
  }

  /// Converts this string expression to uppercase
  Expression toUpperCase() {
    return _ToUpperCaseExpression(this);
  }

  /// Extracts a substring from this string expression
  Expression substring(Expression start, Expression end) {
    return _SubstringExpression(this, start, end);
  }

  /// Extracts a substring using literal indices
  Expression substringLiteral(int start, int end) {
    return _SubstringExpression(this, Constant(start), Constant(end));
  }

  /// Replaces all occurrences of a pattern in this string (stringReplaceAll)
  Expression stringReplaceAll(Expression find, Expression replacement) {
    return _StringReplaceAllExpression(this, find, replacement);
  }

  /// Replaces all occurrences of a string literal
  Expression stringReplaceAllLiteral(String find, String replacement) {
    return _StringReplaceAllExpression(
      this,
      Constant(find),
      Constant(replacement),
    );
  }

  /// Splits this string expression by a delimiter
  Expression split(Expression delimiter) {
    return _SplitExpression(this, delimiter);
  }

  /// Splits this string by a literal delimiter
  Expression splitLiteral(String delimiter) {
    return _SplitExpression(this, Constant(delimiter));
  }

  /// Joins array elements with a delimiter
  Expression join(Expression delimiter) {
    return _JoinExpression(this, delimiter);
  }

  /// Joins array elements with a literal delimiter
  Expression joinLiteral(String delimiter) {
    return _JoinExpression(this, Constant(delimiter));
  }

  /// Trims whitespace from this string expression
  // ignore: use_to_and_as_if_applicable
  Expression trim() {
    return _TrimExpression(this);
  }

  /// Returns the first regex match of [pattern] in this string expression.
  Expression regexFind(Object? pattern) {
    return _RegexFindExpression(this, _toExpression(pattern));
  }

  /// Returns all regex matches of [pattern] in this string expression.
  Expression regexFindAll(Object? pattern) {
    return _RegexFindAllExpression(this, _toExpression(pattern));
  }

  /// Replaces the first occurrence of [find] with [replacement].
  Expression stringReplaceOne(Expression find, Expression replacement) {
    return _StringReplaceOneExpression(this, find, replacement);
  }

  /// Replaces the first occurrence of string literals [find] with [replacement].
  Expression stringReplaceOneLiteral(String find, String replacement) {
    return _StringReplaceOneExpression(
      this,
      Constant(find),
      Constant(replacement),
    );
  }

  /// Returns the index of [search] in this string, or an absent/error value if not found.
  Expression stringIndexOf(Object? search) {
    return _StringIndexOfExpression(this, _toExpression(search));
  }

  /// Repeats this string [repetitions] times ([repetitions] may be an [Expression] or number).
  Expression stringRepeat(Object? repetitions) {
    return _StringRepeatExpression(this, _toExpression(repetitions));
  }

  /// Trims leading whitespace, or the characters in [valueToTrim] when given.
  Expression ltrim([Object? valueToTrim]) {
    return valueToTrim == null
        ? _LtrimExpression(this, null)
        : _LtrimExpression(this, _toExpression(valueToTrim));
  }

  /// Trims trailing whitespace, or the characters in [valueToTrim] when given.
  Expression rtrim([Object? valueToTrim]) {
    return valueToTrim == null
        ? _RtrimExpression(this, null)
        : _RtrimExpression(this, _toExpression(valueToTrim));
  }

  /// Returns the Firestore value type of this expression as a string (e.g.
  /// `int64`, `timestamp`). Possible values align with [Type].
  // ignore: use_to_and_as_if_applicable
  Expression type() {
    return _TypeExpression(this);
  }

  /// Whether this expression evaluates to the given backend [Type].
  // ignore: use_to_and_as_if_applicable
  BooleanExpression isType(Type valueType) {
    return _IsTypeExpression(this, valueType);
  }

  // ============================================================================
  // ARRAY OPERATIONS
  // ============================================================================

  /// Concatenates this array with another array expression
  Expression arrayConcat(Object? secondArray) {
    return _ArrayConcatExpression(this, _toExpression(secondArray));
  }

  /// Concatenates this array with multiple arrays/values
  Expression arrayConcatMultiple(List<Object?> otherArrays) {
    final expressions = <Expression>[this];
    for (final other in otherArrays) {
      expressions.add(_toExpression(other));
    }
    return _ArrayConcatMultipleExpression(expressions);
  }

  /// Checks if this array contains an element expression
  BooleanExpression arrayContainsElement(Expression element) {
    return _ArrayContainsExpression(this, element);
  }

  /// Checks if this array contains a value
  BooleanExpression arrayContainsValue(Object? element) {
    return _ArrayContainsExpression(this, _toExpression(element));
  }

  /// Checks if this array contains any of the given values or expressions
  BooleanExpression arrayContainsAny(List<Object?> values) {
    return _ArrayContainsAnyExpression(
      this,
      values.map(_toExpression).toList(),
    );
  }

  /// Checks if this array contains all of the given values or expressions
  BooleanExpression arrayContainsAll(List<Object?> values) {
    return _ArrayContainsAllValuesExpression(
      this,
      values.map(_toExpression).toList(),
    );
  }

  /// Checks if this array contains all elements of [arrayExpression]
  /// (e.g. [arrayExpression] can be [Expression.array] of fields/literals).
  BooleanExpression arrayContainsAllFrom(Expression arrayExpression) {
    return _ArrayContainsAllExpression(this, arrayExpression);
  }

  /// Returns the length of this array expression
  // ignore: use_to_and_as_if_applicable
  Expression arrayLength() {
    return _ArrayLengthExpression(this);
  }

  /// Reverses this array expression
  // ignore: use_to_and_as_if_applicable
  Expression arrayReverse() {
    return _ArrayReverseExpression(this);
  }

  /// Returns the sum of numeric elements in this array
  // ignore: use_to_and_as_if_applicable
  Expression arraySum() {
    return _ArraySumExpression(this);
  }

  /// First element of this array expression.
  // ignore: use_to_and_as_if_applicable
  Expression arrayFirst() {
    return _ArrayFirstExpression(this);
  }

  /// First [n] elements of this array expression.
  Expression arrayFirstN(Object? n) {
    return _ArrayFirstNExpression(this, _toExpression(n));
  }

  /// Last element of this array expression.
  // ignore: use_to_and_as_if_applicable
  Expression arrayLast() {
    return _ArrayLastExpression(this);
  }

  /// Last [n] elements of this array expression.
  Expression arrayLastN(Object? n) {
    return _ArrayLastNExpression(this, _toExpression(n));
  }

  /// Maximum element of this array (per-document), not the aggregate [maximum] accumulator.
  // ignore: use_to_and_as_if_applicable
  Expression arrayMaximum() {
    return _ArrayMaximumExpression(this);
  }

  /// The [n] largest elements of this array.
  Expression arrayMaximumN(Object? n) {
    return _ArrayMaximumNExpression(this, _toExpression(n));
  }

  /// Minimum element of this array (per-document), not the aggregate [minimum] accumulator.
  // ignore: use_to_and_as_if_applicable
  Expression arrayMinimum() {
    return _ArrayMinimumExpression(this);
  }

  /// The [n] smallest elements of this array.
  Expression arrayMinimumN(Object? n) {
    return _ArrayMinimumNExpression(this, _toExpression(n));
  }

  /// Index of the first occurrence of [element] in this array.
  Expression arrayIndexOf(Object? element) {
    return _ArrayIndexOfExpression(this, _toExpression(element), isLast: false);
  }

  /// Index of the last occurrence of [element] in this array.
  Expression arrayLastIndexOf(Object? element) {
    return _ArrayIndexOfExpression(this, _toExpression(element), isLast: true);
  }

  /// Array of all indices where [element] occurs in this array.
  Expression arrayIndexOfAll(Object? element) {
    return _ArrayIndexOfAllExpression(this, _toExpression(element));
  }

  // ============================================================================
  // AGGREGATE FUNCTIONS
  // ============================================================================

  /// Creates a sum aggregation function from this expression
  // ignore: use_to_and_as_if_applicable
  PipelineAggregateFunction sum() {
    return Sum(this);
  }

  /// Creates an average aggregation function from this expression
  // ignore: use_to_and_as_if_applicable
  PipelineAggregateFunction average() {
    return Average(this);
  }

  /// Creates a count aggregation function from this expression
  // ignore: use_to_and_as_if_applicable
  PipelineAggregateFunction count() {
    return Count(this);
  }

  /// Creates a count distinct aggregation function from this expression
  // ignore: use_to_and_as_if_applicable
  PipelineAggregateFunction countDistinct() {
    return CountDistinct(this);
  }

  /// Creates a minimum aggregation function from this expression
  // ignore: use_to_and_as_if_applicable
  PipelineAggregateFunction minimum() {
    return Minimum(this);
  }

  /// Creates a maximum aggregation function from this expression
  // ignore: use_to_and_as_if_applicable
  PipelineAggregateFunction maximum() {
    return Maximum(this);
  }

  /// Aggregate: first value across inputs. See [First].
  // ignore: use_to_and_as_if_applicable
  PipelineAggregateFunction first() {
    return First(this);
  }

  /// Aggregate: last value across inputs. See [Last].
  // ignore: use_to_and_as_if_applicable
  PipelineAggregateFunction last() {
    return Last(this);
  }

  /// Aggregate: collect values into an array. See [ArrayAgg].
  // ignore: use_to_and_as_if_applicable
  PipelineAggregateFunction arrayAgg() {
    return ArrayAgg(this);
  }

  /// Aggregate: collect distinct values into an array. See [ArrayAggDistinct].
  // ignore: use_to_and_as_if_applicable
  PipelineAggregateFunction arrayAggDistinct() {
    return ArrayAggDistinct(this);
  }

  String get name;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  // ============================================================================
  // STATIC FACTORY METHODS
  // ============================================================================

  /// Creates a constant expression from a string value
  static Expression constantString(String value) => Constant(value);

  /// Creates a constant expression from a number value
  static Expression constantNumber(num value) => Constant(value);

  /// Creates a constant expression from a boolean value
  static Expression constantBoolean(bool value) => Constant(value);

  /// Creates a constant expression from a DateTime value
  static Expression constantDateTime(DateTime value) => Constant(value);

  /// Creates a constant expression from a Timestamp value
  static Expression constantTimestamp(Timestamp value) => Constant(value);

  /// Creates a constant expression from a GeoPoint value
  static Expression constantGeoPoint(GeoPoint value) => Constant(value);

  /// Creates a constant expression from a Blob value
  static Expression constantBlob(Blob value) => Constant(value);

  /// Creates a constant expression from a DocumentReference value
  static Expression constantDocumentReference(DocumentReference value) =>
      Constant(value);

  /// Creates a constant expression from a byte array value
  static Expression constantBytes(List<int> value) => Constant(value);

  /// Creates a constant expression from a VectorValue value
  static Expression constantVector(VectorValue value) => Constant(value);

  /// Creates a constant expression from any value (convenience)
  ///
  /// Valid types: String, num, bool, DateTime, Timestamp, GeoPoint, List<int> (byte[]),
  /// Blob, DocumentReference, VectorValue
  static Expression constant(Object? value) {
    if (value == null) {
      return Constant(null);
    }
    // Validate that the value is one of the accepted types
    if (value is! String &&
        value is! num &&
        value is! bool &&
        value is! DateTime &&
        value is! Timestamp &&
        value is! GeoPoint &&
        value is! List<int> &&
        value is! Blob &&
        value is! DocumentReference &&
        value is! VectorValue) {
      throw ArgumentError(
        'Constant value must be one of: String, num, bool, DateTime, Timestamp, '
        'GeoPoint, List<int> (byte[]), Blob, DocumentReference, or VectorValue. '
        'Got: ${value.runtimeType}',
      );
    }
    return Constant(value);
  }

  /// Creates a field reference expression from a field path string
  static Field field(String fieldPath) => Field(fieldPath);

  /// Creates a field reference expression from a FieldPath object
  static Field fieldPath(FieldPath fieldPath) => Field(fieldPath.toString());

  /// Creates a null value expression
  static Expression nullValue() => _NullExpression();

  /// Creates a conditional (ternary) expression
  static Expression conditional(
    BooleanExpression condition,
    Expression thenExpr,
    Expression elseExpr,
  ) {
    return _ConditionalExpression(condition, thenExpr, elseExpr);
  }

  /// Creates a conditional expression with literal values
  static Expression conditionalValues(
    BooleanExpression condition,
    Object? thenValue,
    Object? elseValue,
  ) {
    return _ConditionalExpression(
      condition,
      _toExpression(thenValue),
      _toExpression(elseValue),
    );
  }

  /// Creates an array expression from elements
  static Expression array(List<Object?> elements) {
    return _ArrayExpression(
      elements.map(_toExpression).toList(),
    );
  }

  /// Creates a map expression from key-value pairs
  static Expression map(Map<String, Object?> data) {
    return _MapExpression(data.map((k, v) => MapEntry(k, _toExpression(v))));
  }

  /// Returns the current timestamp
  static Expression currentTimestamp() {
    return _CurrentTimestampExpression();
  }

  /// Adds time to a timestamp expression.
  ///
  /// [unit] must be one of: `microsecond`, `millisecond`, `second`, `minute`,
  /// `hour`, `day`.
  static Expression timestampAdd(
    Expression timestamp,
    String unit,
    Expression amount,
  ) {
    _validateTimestampUnit(unit);
    return _TimestampAddExpression(timestamp, unit, amount);
  }

  /// Adds time to a timestamp with a literal amount.
  ///
  /// [unit] must be one of: `microsecond`, `millisecond`, `second`, `minute`,
  /// `hour`, `day`.
  static Expression timestampAddLiteral(
    Expression timestamp,
    String unit,
    int amount,
  ) {
    _validateTimestampUnit(unit);
    return _TimestampAddExpression(timestamp, unit, Constant(amount));
  }

  /// Subtracts time from a timestamp expression.
  ///
  /// [unit] must be one of: `microsecond`, `millisecond`, `second`, `minute`,
  /// `hour`, `day`.
  static Expression timestampSubtract(
    Expression timestamp,
    String unit,
    Expression amount,
  ) {
    _validateTimestampUnit(unit);
    return _TimestampSubtractExpression(timestamp, unit, amount);
  }

  /// Subtracts time from a timestamp with a literal amount.
  ///
  /// [unit] must be one of: `microsecond`, `millisecond`, `second`, `minute`,
  /// `hour`, `day`.
  static Expression timestampSubtractLiteral(
    Expression timestamp,
    String unit,
    int amount,
  ) {
    _validateTimestampUnit(unit);
    return _TimestampSubtractExpression(timestamp, unit, Constant(amount));
  }

  /// Truncates a timestamp to a specific unit.
  ///
  /// [unit] must be one of: `microsecond`, `millisecond`, `second`, `minute`,
  /// `hour`, `day`.
  static Expression timestampTruncate(
    Expression timestamp,
    String unit,
  ) {
    _validateTimestampUnit(unit);
    return _TimestampTruncateExpression(timestamp, unit);
  }

  /// Difference between [end] and [start] timestamps in [unit] (string or expression).
  static Expression timestampDiffStatic(
    Expression end,
    Expression start,
    Object unit,
  ) {
    return end.timestampDiff(start, unit);
  }

  /// Creates a document ID expression from a DocumentReference
  static Expression documentIdFromRef(DocumentReference docRef) {
    return _DocumentIdFromRefExpression(docRef);
  }

  /// Parent collection or document reference of a constant [docRef].
  static Expression parentFromRef(DocumentReference docRef) {
    return _ParentFromDocumentRefExpression(docRef);
  }

  /// First non-null argument among operands (short-circuit).
  static Expression coalesce(
    Expression first,
    Object second, [
    List<Object?>? more,
  ]) {
    final expressions = <Expression>[first, _toExpression(second)];
    if (more != null) {
      for (final o in more) {
        expressions.add(_toExpression(o));
      }
    }
    return _CoalesceExpression(expressions);
  }

  /// Switch: first matching [BooleanExpression] condition wins.
  ///
  /// [parts] alternates condition, result, ... If [parts] has odd length, the last
  /// value is a default [Expression] when no condition matches.
  static Expression switchOn(List<Object?> parts) {
    return _SwitchOnExpression(_parseSwitchOnParts(parts));
  }

  /// Checks if a value is in a list (IN operator)
  static BooleanExpression equalAny(
    Expression value,
    List<Object?> values,
  ) {
    return _EqualAnyExpression(value, values.map(_toExpression).toList());
  }

  /// Checks if a value is not in a list (NOT IN operator)
  static BooleanExpression notEqualAny(
    Expression value,
    List<Object?> values,
  ) {
    return _NotEqualAnyExpression(value, values.map(_toExpression).toList());
  }

  /// Checks if a field exists in the document
  static BooleanExpression existsField(String fieldName) {
    return _ExistsExpression(Field(fieldName));
  }

  /// Returns an expression if another is absent
  static Expression ifAbsentStatic(
    Expression ifExpr,
    Expression elseExpr,
  ) {
    return _IfAbsentExpression(ifExpr, elseExpr);
  }

  /// Returns a value if an expression is absent
  static Expression ifAbsentValueStatic(
    Expression ifExpr,
    Object? elseValue,
  ) {
    return _IfAbsentExpression(ifExpr, _toExpression(elseValue));
  }

  /// Checks if an expression is absent
  static BooleanExpression isAbsentStatic(Expression value) {
    return _IsAbsentExpression(value);
  }

  /// Checks if a field is absent
  static BooleanExpression isAbsentField(String fieldName) {
    return _IsAbsentExpression(Field(fieldName));
  }

  /// Returns an expression if another errors
  static Expression ifErrorStatic(
    Expression tryExpr,
    Expression catchExpr,
  ) {
    return _IfErrorExpression(tryExpr, catchExpr);
  }

  /// Checks if an expression produces an error
  static BooleanExpression isErrorStatic(Expression expr) {
    return _IsErrorExpression(expr);
  }

  /// Negates a boolean expression
  static BooleanExpression not(BooleanExpression expression) {
    return _NotExpression(expression);
  }

  /// Combines boolean expressions with a logical XOR
  static BooleanExpression xor(
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
    return _XorExpression(expressions);
  }

  /// Combines boolean expressions with a logical AND
  static BooleanExpression and(
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
    return _AndExpression(expressions);
  }

  /// Combines boolean expressions with a logical OR
  static BooleanExpression or(
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
    return _OrExpression(expressions);
  }

  /// Combines boolean expressions with a logical NOR
  static BooleanExpression nor(
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
    return _NorExpression(expressions);
  }

  /// Joins array elements with a delimiter
  static Expression joinStatic(
    Expression arrayExpression,
    Expression delimiterExpression,
  ) {
    return _JoinExpression(arrayExpression, delimiterExpression);
  }

  /// Joins array elements with a literal delimiter
  static Expression joinStaticLiteral(
    Expression arrayExpression,
    String delimiter,
  ) {
    return _JoinExpression(arrayExpression, Constant(delimiter));
  }

  /// Joins a field's array with a delimiter
  static Expression joinField(
    String arrayFieldName,
    String delimiter,
  ) {
    return _JoinExpression(Field(arrayFieldName), Constant(delimiter));
  }

  /// Concatenates arrays
  static Expression arrayConcatStatic(
    Expression firstArray,
    Expression secondArray,
    List<Object?>? otherArrays,
  ) {
    final expressions = <Expression>[firstArray, secondArray];
    if (otherArrays != null) {
      for (final other in otherArrays) {
        expressions.add(_toExpression(other));
      }
    }
    return _ArrayConcatMultipleExpression(expressions);
  }

  /// Returns the length of an expression
  static Expression lengthStatic(Expression expr) {
    return _LengthExpression(expr);
  }

  /// Returns the length of a field
  static Expression lengthField(String fieldName) {
    return _LengthExpression(Field(fieldName));
  }

  /// Returns the absolute value of an expression
  static Expression absStatic(Expression numericExpr) {
    return _AbsExpression(numericExpr);
  }

  /// Returns the absolute value of a field
  static Expression absField(String numericField) {
    return _AbsExpression(Field(numericField));
  }

  /// Adds two expressions
  static Expression addStatic(
    Expression first,
    Expression second,
  ) {
    return _AddExpression(first, second);
  }

  /// Adds an expression and a number
  static Expression addStaticNumber(
    Expression first,
    num second,
  ) {
    return _AddExpression(first, Constant(second));
  }

  /// Adds a field and an expression
  static Expression addField(
    String numericFieldName,
    Expression second,
  ) {
    return _AddExpression(Field(numericFieldName), second);
  }

  /// Adds a field and a number
  static Expression addFieldNumber(
    String numericFieldName,
    num second,
  ) {
    return _AddExpression(Field(numericFieldName), Constant(second));
  }

  /// Subtracts two expressions
  static Expression subtractStatic(
    Expression minuend,
    Expression subtrahend,
  ) {
    return _SubtractExpression(minuend, subtrahend);
  }

  /// Multiplies two expressions
  static Expression multiplyStatic(
    Expression multiplicand,
    Expression multiplier,
  ) {
    return _MultiplyExpression(multiplicand, multiplier);
  }

  /// Divides two expressions
  static Expression divideStatic(
    Expression dividend,
    Expression divisor,
  ) {
    return _DivideExpression(dividend, divisor);
  }

  /// Returns modulo of two expressions
  static Expression moduloStatic(
    Expression dividend,
    Expression divisor,
  ) {
    return _ModuloExpression(dividend, divisor);
  }

  /// Compares two expressions for equality
  static BooleanExpression equalStatic(
    Expression left,
    Expression right,
  ) {
    return _EqualExpression(left, right);
  }

  /// Compares expression with value for equality
  static BooleanExpression equalStaticValue(
    Expression left,
    Object? right,
  ) {
    return _EqualExpression(left, _toExpression(right));
  }

  /// Compares field with value for equality
  static BooleanExpression equalField(
    String fieldName,
    Object? value,
  ) {
    return _EqualExpression(Field(fieldName), _toExpression(value));
  }

  /// Compares two expressions for inequality
  static BooleanExpression notEqualStatic(
    Expression left,
    Expression right,
  ) {
    return _NotEqualExpression(left, right);
  }

  /// Compares expression with value for inequality
  static BooleanExpression notEqualStaticValue(
    Expression left,
    Object? right,
  ) {
    return _NotEqualExpression(left, _toExpression(right));
  }

  /// Greater than comparison
  static BooleanExpression greaterThanStatic(
    Expression left,
    Expression right,
  ) {
    return _GreaterThanExpression(left, right);
  }

  /// Greater than comparison with value
  static BooleanExpression greaterThanStaticValue(
    Expression left,
    Object? right,
  ) {
    return _GreaterThanExpression(left, _toExpression(right));
  }

  /// Greater than comparison for field
  static BooleanExpression greaterThanField(
    String fieldName,
    Object? value,
  ) {
    return _GreaterThanExpression(Field(fieldName), _toExpression(value));
  }

  /// Greater than or equal comparison
  static BooleanExpression greaterThanOrEqualStatic(
    Expression left,
    Expression right,
  ) {
    return _GreaterThanOrEqualExpression(left, right);
  }

  /// Less than comparison
  static BooleanExpression lessThanStatic(
    Expression left,
    Expression right,
  ) {
    return _LessThanExpression(left, right);
  }

  /// Less than comparison with value
  static BooleanExpression lessThanStaticValue(
    Expression left,
    Object? right,
  ) {
    return _LessThanExpression(left, _toExpression(right));
  }

  /// Less than comparison for field
  static BooleanExpression lessThanField(
    String fieldName,
    Object? value,
  ) {
    return _LessThanExpression(Field(fieldName), _toExpression(value));
  }

  /// Less than or equal comparison
  static BooleanExpression lessThanOrEqualStatic(
    Expression left,
    Expression right,
  ) {
    return _LessThanOrEqualExpression(left, right);
  }

  /// Concatenates expressions
  static Expression concatStatic(
    Expression first,
    Expression second,
    List<Object?>? others,
  ) {
    final expressions = <Expression>[first, second];
    if (others != null) {
      for (final other in others) {
        expressions.add(_toExpression(other));
      }
    }
    return _ConcatExpression(expressions);
  }

  /// Converts to lowercase
  static Expression toLowerCaseStatic(Expression stringExpr) {
    return _ToLowerCaseExpression(stringExpr);
  }

  /// Converts field to lowercase
  static Expression toLowerCaseField(String stringField) {
    return _ToLowerCaseExpression(Field(stringField));
  }

  /// Converts to uppercase
  static Expression toUpperCaseStatic(Expression stringExpr) {
    return _ToUpperCaseExpression(stringExpr);
  }

  /// Converts field to uppercase
  static Expression toUpperCaseField(String stringField) {
    return _ToUpperCaseExpression(Field(stringField));
  }

  /// Trims whitespace
  static Expression trimStatic(Expression stringExpr) {
    return _TrimExpression(stringExpr);
  }

  /// Trims field whitespace
  static Expression trimField(String stringField) {
    return _TrimExpression(Field(stringField));
  }

  /// Extracts substring
  static Expression substringStatic(
    Expression stringExpr,
    Expression start,
    Expression end,
  ) {
    return _SubstringExpression(stringExpr, start, end);
  }

  /// Replaces all occurrences in string (stringReplaceAll)
  static Expression stringReplaceAllStatic(
    Expression stringExpr,
    Expression find,
    Expression replacement,
  ) {
    return _StringReplaceAllExpression(stringExpr, find, replacement);
  }

  /// Splits string
  static Expression splitStatic(
    Expression stringExpr,
    Expression delimiter,
  ) {
    return _SplitExpression(stringExpr, delimiter);
  }

  /// Reverses array
  static Expression arrayReverseStatic(Expression array) {
    return _ArrayReverseExpression(array);
  }

  /// Reverses field array
  static Expression arrayReverseField(String arrayFieldName) {
    return _ArrayReverseExpression(Field(arrayFieldName));
  }

  /// Sums array
  static Expression arraySumStatic(Expression array) {
    return _ArraySumExpression(array);
  }

  /// Sums field array
  static Expression arraySumField(String arrayFieldName) {
    return _ArraySumExpression(Field(arrayFieldName));
  }

  /// Gets array length
  static Expression arrayLengthStatic(Expression array) {
    return _ArrayLengthExpression(array);
  }

  /// Gets field array length
  static Expression arrayLengthField(String arrayFieldName) {
    return _ArrayLengthExpression(Field(arrayFieldName));
  }

  /// Checks array contains
  static BooleanExpression arrayContainsElementStatic(
    Expression array,
    Expression element,
  ) {
    return _ArrayContainsExpression(array, element);
  }

  /// Checks field array contains
  static BooleanExpression arrayContainsField(
    String arrayFieldName,
    Object? element,
  ) {
    return _ArrayContainsExpression(
      Field(arrayFieldName),
      _toExpression(element),
    );
  }

  /// Checks if [array] contains all elements of [arrayExpression]
  /// (e.g. [arrayExpression] can be [Expression.array] of fields/literals).
  static BooleanExpression arrayContainsAllWithExpression(
    Expression array,
    Expression arrayExpression,
  ) {
    return _ArrayContainsAllExpression(array, arrayExpression);
  }

  /// Checks if [array] contains all of the specified [values].
  static BooleanExpression arrayContainsAllValues(
    Expression array,
    List<Object?> values,
  ) {
    return _ArrayContainsAllValuesExpression(
      array,
      values.map(_toExpression).toList(),
    );
  }

  /// Checks if the array field [arrayFieldName] contains all elements of
  /// [arrayExpression].
  static BooleanExpression arrayContainsAllField(
    String arrayFieldName,
    Expression arrayExpression,
  ) {
    return arrayContainsAllWithExpression(
      Field(arrayFieldName),
      arrayExpression,
    );
  }

  /// Creates a raw/custom function expression
  static Expression rawFunction(
    String name,
    List<Expression> args,
  ) {
    return _RawFunctionExpression(name, args);
  }

  /// A random value between 0 (inclusive) and 1 (exclusive) per evaluation
  /// (Firestore pipeline `rand`).
  static Expression rand() {
    return _RandExpression();
  }

  /// Same as [Expression.isType] but usable as a static helper for any [expression].
  static BooleanExpression isTypeStatic(
    Expression expression,
    Type valueType,
  ) {
    return _IsTypeExpression(expression, valueType);
  }
}

/// Base class for function expressions
abstract class FunctionExpression extends Expression {}

/// Base class for selectable expressions (can be used in select stage)
abstract class Selectable extends Expression {
  String get aliasName;
  Expression get expression;
}

/// Represents an aliased expression wrapper
class AliasedExpression extends Selectable {
  final String _alias;

  @override
  String get aliasName => _alias;

  @override
  final Expression expression;

  AliasedExpression({
    required String alias,
    required this.expression,
  }) : _alias = alias;

  @override
  String get name => 'alias';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'alias': _alias,
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents a field reference in a pipeline expression
class Field extends Selectable {
  final String fieldName;

  Field(this.fieldName);

  @override
  String get name => 'field';

  @override
  String get aliasName => fieldName;

  @override
  Expression get expression => this;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'field': fieldName,
      },
    };
  }
}

/// Represents a null value expression
class _NullExpression extends Expression {
  _NullExpression();

  @override
  String get name => 'null';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'value': null,
      },
    };
  }
}

/// Represents a constant value in a pipeline expression
///
/// Valid types: String, num, bool, DateTime, Timestamp, GeoPoint, List<int> (byte[]),
/// Blob, DocumentReference, VectorValue, or null
class Constant extends Expression {
  final Object? value;

  Constant(this.value) {
    if (value != null) {
      // Validate that the value is one of the accepted types
      if (value is! String &&
          value is! num &&
          value is! bool &&
          value is! DateTime &&
          value is! Timestamp &&
          value is! GeoPoint &&
          value is! List<int> &&
          value is! Blob &&
          value is! DocumentReference &&
          value is! VectorValue) {
        throw ArgumentError(
          'Constant value must be one of: String, num, bool, DateTime, Timestamp, '
          'GeoPoint, List<int> (byte[]), Blob, DocumentReference, or VectorValue. '
          'Got: ${value.runtimeType}',
        );
      }
    }
  }

  @override
  String get name => 'constant';

  @override
  Map<String, dynamic> toMap() {
    Object? serializedValue = value;
    if (value is DocumentReference) {
      serializedValue = {'path': (value! as DocumentReference).path};
    }
    return {
      'name': name,
      'args': {'value': serializedValue},
    };
  }
}

/// Represents a concatenation function expression
class Concat extends FunctionExpression {
  final List<Expression> expressions;

  Concat(this.expressions);

  @override
  String get name => 'concat';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expressions': expressions.map((expr) => expr.toMap()).toList(),
      },
    };
  }
}

/// Represents a concat function expression (internal)
class _ConcatExpression extends FunctionExpression {
  final List<Expression> expressions;

  _ConcatExpression(this.expressions);

  @override
  String get name => 'concat';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expressions': expressions.map((expr) => expr.toMap()).toList(),
      },
    };
  }
}

/// Represents a length function expression
class _LengthExpression extends FunctionExpression {
  final Expression expression;

  _LengthExpression(this.expression);

  @override
  String get name => 'length';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents a toLowerCase function expression
class _ToLowerCaseExpression extends FunctionExpression {
  final Expression expression;

  _ToLowerCaseExpression(this.expression);

  @override
  String get name => 'to_lower_case';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents a toUpperCase function expression
class _ToUpperCaseExpression extends FunctionExpression {
  final Expression expression;

  _ToUpperCaseExpression(this.expression);

  @override
  String get name => 'to_upper_case';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents a substring function expression
class _SubstringExpression extends FunctionExpression {
  final Expression expression;
  final Expression start;
  final Expression end;

  _SubstringExpression(this.expression, this.start, this.end);

  @override
  String get name => 'substring';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'start': start.toMap(),
        'end': end.toMap(),
      },
    };
  }
}

/// Represents a string_replace_all function expression
class _StringReplaceAllExpression extends FunctionExpression {
  final Expression expression;
  final Expression find;
  final Expression replacement;

  _StringReplaceAllExpression(this.expression, this.find, this.replacement);

  @override
  String get name => 'string_replace_all';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'find': find.toMap(),
        'replacement': replacement.toMap(),
      },
    };
  }
}

/// Represents a split function expression
class _SplitExpression extends FunctionExpression {
  final Expression expression;
  final Expression delimiter;

  _SplitExpression(this.expression, this.delimiter);

  @override
  String get name => 'split';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'delimiter': delimiter.toMap(),
      },
    };
  }
}

/// Represents a join function expression
class _JoinExpression extends FunctionExpression {
  final Expression expression;
  final Expression delimiter;

  _JoinExpression(this.expression, this.delimiter);

  @override
  String get name => 'join';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'delimiter': delimiter.toMap(),
      },
    };
  }
}

/// Represents a trim function expression
class _TrimExpression extends FunctionExpression {
  final Expression expression;

  _TrimExpression(this.expression);

  @override
  String get name => 'trim';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Base class for boolean expressions used in filtering
abstract class BooleanExpression extends Expression {}

// ============================================================================
// PATTERN DEMONSTRATION - Concrete Function Expression Classes
// ============================================================================

/// Represents an addition function expression
class _AddExpression extends FunctionExpression {
  final Expression left;
  final Expression right;

  _AddExpression(this.left, this.right);

  @override
  String get name => 'add';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents a subtraction function expression
class _SubtractExpression extends FunctionExpression {
  final Expression left;
  final Expression right;

  _SubtractExpression(this.left, this.right);

  @override
  String get name => 'subtract';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents an equality comparison function expression
class _EqualExpression extends BooleanExpression {
  final Expression left;
  final Expression right;

  _EqualExpression(this.left, this.right);

  @override
  String get name => 'equal';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents a greater-than comparison function expression
class _GreaterThanExpression extends BooleanExpression {
  final Expression left;
  final Expression right;

  _GreaterThanExpression(this.left, this.right);

  @override
  String get name => 'greater_than';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents a multiply function expression
class _MultiplyExpression extends FunctionExpression {
  final Expression left;
  final Expression right;

  _MultiplyExpression(this.left, this.right);

  @override
  String get name => 'multiply';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents a divide function expression
class _DivideExpression extends FunctionExpression {
  final Expression left;
  final Expression right;

  _DivideExpression(this.left, this.right);

  @override
  String get name => 'divide';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents a modulo function expression
class _ModuloExpression extends FunctionExpression {
  final Expression left;
  final Expression right;

  _ModuloExpression(this.left, this.right);

  @override
  String get name => 'modulo';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents an absolute value function expression
class _AbsExpression extends FunctionExpression {
  final Expression expression;

  _AbsExpression(this.expression);

  @override
  String get name => 'abs';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents a negation function expression
/// Represents a not-equal comparison function expression
class _NotEqualExpression extends BooleanExpression {
  final Expression left;
  final Expression right;

  _NotEqualExpression(this.left, this.right);

  @override
  String get name => 'not_equal';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents a greater-than-or-equal comparison function expression
class _GreaterThanOrEqualExpression extends BooleanExpression {
  final Expression left;
  final Expression right;

  _GreaterThanOrEqualExpression(this.left, this.right);

  @override
  String get name => 'greater_than_or_equal';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents a less-than comparison function expression
class _LessThanExpression extends BooleanExpression {
  final Expression left;
  final Expression right;

  _LessThanExpression(this.left, this.right);

  @override
  String get name => 'less_than';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents a less-than-or-equal comparison function expression
class _LessThanOrEqualExpression extends BooleanExpression {
  final Expression left;
  final Expression right;

  _LessThanOrEqualExpression(this.left, this.right);

  @override
  String get name => 'less_than_or_equal';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

// ============================================================================
// ARRAY OPERATION EXPRESSION CLASSES
// ============================================================================

/// Represents an array concat function expression
class _ArrayConcatExpression extends FunctionExpression {
  final Expression firstArray;
  final Expression secondArray;

  _ArrayConcatExpression(this.firstArray, this.secondArray);

  @override
  String get name => 'array_concat';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'first': firstArray.toMap(),
        'second': secondArray.toMap(),
      },
    };
  }
}

/// Represents an array concat multiple function expression
class _ArrayConcatMultipleExpression extends FunctionExpression {
  final List<Expression> arrays;

  _ArrayConcatMultipleExpression(this.arrays);

  @override
  String get name => 'array_concat_multiple';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'arrays': arrays.map((expr) => expr.toMap()).toList(),
      },
    };
  }
}

/// Represents an array contains function expression
class _ArrayContainsExpression extends BooleanExpression {
  final Expression array;
  final Expression element;

  _ArrayContainsExpression(this.array, this.element);

  @override
  String get name => 'array_contains';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'array': array.toMap(),
        'element': element.toMap(),
      },
    };
  }
}

/// Represents an arrayContainsAny function expression
class _ArrayContainsAnyExpression extends BooleanExpression {
  final Expression array;
  final List<Expression> values;

  _ArrayContainsAnyExpression(this.array, this.values);

  @override
  String get name => 'array_contains_any';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'array': array.toMap(),
        'values': values.map((v) => v.toMap()).toList(),
      },
    };
  }
}

/// Represents an arrayContainsAll function expression (array + list of values)
class _ArrayContainsAllValuesExpression extends BooleanExpression {
  final Expression array;
  final List<Expression> values;

  _ArrayContainsAllValuesExpression(this.array, this.values);

  @override
  String get name => 'array_contains_all';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'array': array.toMap(),
        'values': values.map((v) => v.toMap()).toList(),
      },
    };
  }
}

/// Represents an arrayContainsAll function expression (array + array expression)
class _ArrayContainsAllExpression extends BooleanExpression {
  final Expression array;
  final Expression arrayExpression;

  _ArrayContainsAllExpression(this.array, this.arrayExpression);

  @override
  String get name => 'array_contains_all';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'array': array.toMap(),
        'array_expression': arrayExpression.toMap(),
      },
    };
  }
}

/// Represents an array length function expression
class _ArrayLengthExpression extends FunctionExpression {
  final Expression expression;

  _ArrayLengthExpression(this.expression);

  @override
  String get name => 'array_length';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents an array reverse function expression
class _ArrayReverseExpression extends FunctionExpression {
  final Expression expression;

  _ArrayReverseExpression(this.expression);

  @override
  String get name => 'array_reverse';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents an array sum function expression
class _ArraySumExpression extends FunctionExpression {
  final Expression expression;

  _ArraySumExpression(this.expression);

  @override
  String get name => 'array_sum';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

// ============================================================================
// CONDITIONAL / LOGIC OPERATION EXPRESSION CLASSES
// ============================================================================

/// Represents an ifAbsent function expression
class _IfAbsentExpression extends FunctionExpression {
  final Expression expression;
  final Expression elseExpr;

  _IfAbsentExpression(this.expression, this.elseExpr);

  @override
  String get name => 'if_absent';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'else': elseExpr.toMap(),
      },
    };
  }
}

/// Represents an ifError function expression
class _IfErrorExpression extends Expression {
  final Expression expression;
  final Expression catchExpr;

  _IfErrorExpression(this.expression, this.catchExpr);

  @override
  String get name => 'if_error';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'catch': catchExpr.toMap(),
      },
    };
  }
}

/// Represents an isAbsent function expression
class _IsAbsentExpression extends BooleanExpression {
  final Expression expression;

  _IsAbsentExpression(this.expression);

  @override
  String get name => 'is_absent';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents an isError function expression
class _IsErrorExpression extends BooleanExpression {
  final Expression expression;

  _IsErrorExpression(this.expression);

  @override
  String get name => 'is_error';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents an exists function expression
class _ExistsExpression extends BooleanExpression {
  final Expression expression;

  _ExistsExpression(this.expression);

  @override
  String get name => 'exists';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents a not (negation) function expression
class _NotExpression extends BooleanExpression {
  final BooleanExpression expression;

  _NotExpression(this.expression);

  @override
  String get name => 'not';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

class _XorExpression extends BooleanExpression {
  final List<BooleanExpression> expressions;

  _XorExpression(this.expressions);

  @override
  String get name => 'xor';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expressions': expressions.map((e) => e.toMap()).toList(),
      },
    };
  }
}

class _AndExpression extends BooleanExpression {
  final List<BooleanExpression> expressions;

  _AndExpression(this.expressions);

  @override
  String get name => 'and';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expressions': expressions.map((e) => e.toMap()).toList(),
      },
    };
  }
}

class _OrExpression extends BooleanExpression {
  final List<BooleanExpression> expressions;

  _OrExpression(this.expressions);

  @override
  String get name => 'or';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expressions': expressions.map((e) => e.toMap()).toList(),
      },
    };
  }
}

/// Represents a conditional (ternary) function expression
class _ConditionalExpression extends FunctionExpression {
  final BooleanExpression condition;
  final Expression thenExpr;
  final Expression elseExpr;

  _ConditionalExpression(this.condition, this.thenExpr, this.elseExpr);

  @override
  String get name => 'conditional';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'condition': condition.toMap(),
        'then': thenExpr.toMap(),
        'else': elseExpr.toMap(),
      },
    };
  }
}

// ============================================================================
// TYPE CONVERSION EXPRESSION CLASSES
// ============================================================================

/// Represents an asBoolean function expression
class _AsBooleanExpression extends BooleanExpression {
  final Expression expression;

  _AsBooleanExpression(this.expression);

  @override
  String get name => 'as_boolean';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

// ============================================================================
// BITWISE OPERATION EXPRESSION CLASSES
// ============================================================================

/// Represents a bitAnd function expression
class _BitAndExpression extends FunctionExpression {
  final Expression left;
  final Expression right;

  _BitAndExpression(this.left, this.right);

  @override
  String get name => 'bit_and';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents a bitOr function expression
class _BitOrExpression extends FunctionExpression {
  final Expression left;
  final Expression right;

  _BitOrExpression(this.left, this.right);

  @override
  String get name => 'bit_or';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents a bitXor function expression
class _BitXorExpression extends FunctionExpression {
  final Expression left;
  final Expression right;

  _BitXorExpression(this.left, this.right);

  @override
  String get name => 'bit_xor';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'left': left.toMap(),
        'right': right.toMap(),
      },
    };
  }
}

/// Represents a bitNot function expression
class _BitNotExpression extends FunctionExpression {
  final Expression expression;

  _BitNotExpression(this.expression);

  @override
  String get name => 'bit_not';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents a bitLeftShift function expression
class _BitLeftShiftExpression extends FunctionExpression {
  final Expression expression;
  final Expression amount;

  _BitLeftShiftExpression(this.expression, this.amount);

  @override
  String get name => 'bit_left_shift';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'amount': amount.toMap(),
      },
    };
  }
}

/// Represents a bitRightShift function expression
class _BitRightShiftExpression extends FunctionExpression {
  final Expression expression;
  final Expression amount;

  _BitRightShiftExpression(this.expression, this.amount);

  @override
  String get name => 'bit_right_shift';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'amount': amount.toMap(),
      },
    };
  }
}

// ============================================================================
// DOCUMENT / PATH OPERATION EXPRESSION CLASSES
// ============================================================================

/// Represents a documentId function expression
class _DocumentIdExpression extends FunctionExpression {
  final Expression expression;

  _DocumentIdExpression(this.expression);

  @override
  String get name => 'document_id';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents a collectionId function expression
class _CollectionIdExpression extends FunctionExpression {
  final Expression expression;

  _CollectionIdExpression(this.expression);

  @override
  String get name => 'collection_id';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Represents a documentIdFromRef function expression
class _DocumentIdFromRefExpression extends FunctionExpression {
  final DocumentReference docRef;

  _DocumentIdFromRefExpression(this.docRef);

  @override
  String get name => 'document_id_from_ref';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'doc_ref': docRef.path,
      },
    };
  }
}

// ============================================================================
// MAP OPERATION EXPRESSION CLASSES
// ============================================================================

/// Represents a mapGet function expression
class _MapGetExpression extends FunctionExpression {
  final Expression map;
  final Expression key;

  _MapGetExpression(this.map, this.key);

  @override
  String get name => 'map_get';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'map': map.toMap(),
        'key': key.toMap(),
      },
    };
  }
}

// ============================================================================
// TIMESTAMP OPERATION EXPRESSION CLASSES
// ============================================================================

/// Represents a currentTimestamp function expression
class _CurrentTimestampExpression extends FunctionExpression {
  _CurrentTimestampExpression();

  @override
  String get name => 'current_timestamp';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}

/// Represents a timestamp_add function expression.
/// Unit must be one of: microsecond, millisecond, second, minute, hour, day.
class _TimestampAddExpression extends FunctionExpression {
  final Expression timestamp;
  final String unit;
  final Expression amount;

  _TimestampAddExpression(this.timestamp, this.unit, this.amount);

  @override
  String get name => 'timestamp_add';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'timestamp': timestamp.toMap(),
        'unit': unit,
        'amount': amount.toMap(),
      },
    };
  }
}

/// Represents a timestamp_subtract function expression.
/// Unit must be one of: microsecond, millisecond, second, minute, hour, day.
class _TimestampSubtractExpression extends FunctionExpression {
  final Expression timestamp;
  final String unit;
  final Expression amount;

  _TimestampSubtractExpression(this.timestamp, this.unit, this.amount);

  @override
  String get name => 'timestamp_subtract';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'timestamp': timestamp.toMap(),
        'unit': unit,
        'amount': amount.toMap(),
      },
    };
  }
}

/// Represents a timestamp_truncate function expression.
/// Unit must be one of: microsecond, millisecond, second, minute, hour, day.
class _TimestampTruncateExpression extends FunctionExpression {
  final Expression timestamp;
  final String unit;

  _TimestampTruncateExpression(this.timestamp, this.unit);

  @override
  String get name => 'timestamp_truncate';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'timestamp': timestamp.toMap(),
        'unit': unit,
      },
    };
  }
}

// ============================================================================
// SPECIAL OPERATION EXPRESSION CLASSES
// ============================================================================

/// Represents an equalAny (IN) function expression
class _EqualAnyExpression extends BooleanExpression {
  final Expression value;
  final List<Expression> values;

  _EqualAnyExpression(this.value, this.values);

  @override
  String get name => 'equal_any';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'value': value.toMap(),
        'values': values.map((expr) => expr.toMap()).toList(),
      },
    };
  }
}

/// Represents a notEqualAny (NOT IN) function expression
class _NotEqualAnyExpression extends BooleanExpression {
  final Expression value;
  final List<Expression> values;

  _NotEqualAnyExpression(this.value, this.values);

  @override
  String get name => 'not_equal_any';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'value': value.toMap(),
        'values': values.map((expr) => expr.toMap()).toList(),
      },
    };
  }
}

/// Represents an array expression
class _ArrayExpression extends FunctionExpression {
  final List<Expression> elements;

  _ArrayExpression(this.elements);

  @override
  String get name => 'array';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'elements': elements.map((expr) => expr.toMap()).toList(),
      },
    };
  }
}

/// Represents a map expression
class _MapExpression extends FunctionExpression {
  final Map<String, Expression> data;

  _MapExpression(this.data);

  @override
  String get name => 'map';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'data': data.map((k, v) => MapEntry(k, v.toMap())),
      },
    };
  }
}

/// Serialized pipeline function `map_set` (map plus alternating key/value pairs).
class _MapSetExpression extends FunctionExpression {
  final Expression map;
  final List<Expression> keyValues;

  _MapSetExpression(this.map, this.keyValues) {
    if (keyValues.isEmpty || keyValues.length.isOdd) {
      throw ArgumentError('mapSet requires one or more key/value pairs');
    }
  }

  @override
  String get name => 'map_set';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'map': map.toMap(),
        'key_values': keyValues.map((e) => e.toMap()).toList(),
      },
    };
  }
}

/// Serialized pipeline function `map_entries`.
class _MapEntriesExpression extends FunctionExpression {
  final Expression expression;

  _MapEntriesExpression(this.expression);

  @override
  String get name => 'map_entries';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `map_keys`.
class _MapKeysExpression extends FunctionExpression {
  final Expression expression;

  _MapKeysExpression(this.expression);

  @override
  String get name => 'map_keys';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `map_values`.
class _MapValuesExpression extends FunctionExpression {
  final Expression expression;

  _MapValuesExpression(this.expression);

  @override
  String get name => 'map_values';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `parent` (expression operand).
class _ParentExpression extends FunctionExpression {
  final Expression expression;

  _ParentExpression(this.expression);

  @override
  String get name => 'parent';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `parent` ([DocumentReference] constant).
class _ParentFromDocumentRefExpression extends FunctionExpression {
  final DocumentReference docRef;

  _ParentFromDocumentRefExpression(this.docRef);

  @override
  String get name => 'parent';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'doc_ref': docRef.path,
      },
    };
  }
}

/// Serialized pipeline function `timestamp_diff`.
class _TimestampDiffExpression extends FunctionExpression {
  final Expression end;
  final Expression start;
  final Expression unit;

  _TimestampDiffExpression(this.end, this.start, this.unit);

  @override
  String get name => 'timestamp_diff';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'end': end.toMap(),
        'start': start.toMap(),
        'unit': unit.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `timestamp_extract`.
class _TimestampExtractExpression extends FunctionExpression {
  final Expression timestamp;
  final Expression part;
  final Expression? timezone;

  _TimestampExtractExpression(this.timestamp, this.part, this.timezone);

  @override
  String get name => 'timestamp_extract';

  @override
  Map<String, dynamic> toMap() {
    final args = <String, dynamic>{
      'timestamp': timestamp.toMap(),
      'part': part.toMap(),
    };
    final tz = timezone;
    if (tz != null) {
      args['timezone'] = tz.toMap();
    }
    return {
      'name': name,
      'args': args,
    };
  }
}

/// Serialized pipeline function `if_null`.
class _IfNullExpression extends FunctionExpression {
  final Expression expression;
  final Expression replacement;

  _IfNullExpression(this.expression, this.replacement);

  @override
  String get name => 'if_null';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'replacement': replacement.toMap(),
      },
    };
  }
}

class _NorExpression extends BooleanExpression {
  final List<BooleanExpression> expressions;

  _NorExpression(this.expressions);

  @override
  String get name => 'nor';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expressions': expressions.map((e) => e.toMap()).toList(),
      },
    };
  }
}

/// Serialized pipeline function `switch_on`.
class _SwitchOnExpression extends FunctionExpression {
  final List<Object> parts;

  _SwitchOnExpression(this.parts);

  @override
  String get name => 'switch_on';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expressions': parts.map((p) => (p as Expression).toMap()).toList(),
      },
    };
  }
}

/// Serialized pipeline function `coalesce`.
class _CoalesceExpression extends FunctionExpression {
  final List<Expression> expressions;

  _CoalesceExpression(this.expressions);

  @override
  String get name => 'coalesce';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expressions': expressions.map((e) => e.toMap()).toList(),
      },
    };
  }
}

/// Serialized pipeline function `regex_find`.
class _RegexFindExpression extends FunctionExpression {
  final Expression expression;
  final Expression pattern;

  _RegexFindExpression(this.expression, this.pattern);

  @override
  String get name => 'regex_find';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'pattern': pattern.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `regex_find_all`.
class _RegexFindAllExpression extends FunctionExpression {
  final Expression expression;
  final Expression pattern;

  _RegexFindAllExpression(this.expression, this.pattern);

  @override
  String get name => 'regex_find_all';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'pattern': pattern.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `string_replace_one`.
class _StringReplaceOneExpression extends FunctionExpression {
  final Expression expression;
  final Expression find;
  final Expression replacement;

  _StringReplaceOneExpression(this.expression, this.find, this.replacement);

  @override
  String get name => 'string_replace_one';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'find': find.toMap(),
        'replacement': replacement.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `string_index_of`.
class _StringIndexOfExpression extends FunctionExpression {
  final Expression expression;
  final Expression search;

  _StringIndexOfExpression(this.expression, this.search);

  @override
  String get name => 'string_index_of';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'search': search.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `string_repeat`.
class _StringRepeatExpression extends FunctionExpression {
  final Expression expression;
  final Expression repetitions;

  _StringRepeatExpression(this.expression, this.repetitions);

  @override
  String get name => 'string_repeat';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'repetitions': repetitions.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `ltrim`.
class _LtrimExpression extends FunctionExpression {
  final Expression expression;
  final Expression? value;

  _LtrimExpression(this.expression, this.value);

  @override
  String get name => 'ltrim';

  @override
  Map<String, dynamic> toMap() {
    final args = <String, dynamic>{
      'expression': expression.toMap(),
    };
    if (value != null) {
      args['value'] = value!.toMap();
    }
    return {
      'name': name,
      'args': args,
    };
  }
}

/// Serialized pipeline function `rtrim`.
class _RtrimExpression extends FunctionExpression {
  final Expression expression;
  final Expression? value;

  _RtrimExpression(this.expression, this.value);

  @override
  String get name => 'rtrim';

  @override
  Map<String, dynamic> toMap() {
    final args = <String, dynamic>{
      'expression': expression.toMap(),
    };
    if (value != null) {
      args['value'] = value!.toMap();
    }
    return {
      'name': name,
      'args': args,
    };
  }
}

/// Serialized pipeline function `type` (runtime type name of the value).
class _TypeExpression extends FunctionExpression {
  final Expression expression;

  _TypeExpression(this.expression);

  @override
  String get name => 'type';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Serialized pipeline boolean function `is_type`.
class _IsTypeExpression extends BooleanExpression {
  final Expression expression;
  final Type valueType;

  _IsTypeExpression(this.expression, this.valueType);

  @override
  String get name => 'is_type';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'type': valueType.typeValue,
      },
    };
  }
}

/// Serialized pipeline function `trunc`.
class _TruncExpression extends FunctionExpression {
  final Expression expression;
  final Expression? decimals;

  _TruncExpression(this.expression, this.decimals);

  @override
  String get name => 'trunc';

  @override
  Map<String, dynamic> toMap() {
    final args = <String, dynamic>{
      'expression': expression.toMap(),
    };
    if (decimals != null) {
      args['decimals'] = decimals!.toMap();
    }
    return {
      'name': name,
      'args': args,
    };
  }
}

/// Serialized pipeline function `rand`.
class _RandExpression extends FunctionExpression {
  _RandExpression();

  @override
  String get name => 'rand';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': <String, dynamic>{},
    };
  }
}

/// Serialized pipeline function `array_first`.
class _ArrayFirstExpression extends FunctionExpression {
  final Expression expression;

  _ArrayFirstExpression(this.expression);

  @override
  String get name => 'array_first';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `array_first_n`.
class _ArrayFirstNExpression extends FunctionExpression {
  final Expression expression;
  final Expression n;

  _ArrayFirstNExpression(this.expression, this.n);

  @override
  String get name => 'array_first_n';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'n': n.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `array_last`.
class _ArrayLastExpression extends FunctionExpression {
  final Expression expression;

  _ArrayLastExpression(this.expression);

  @override
  String get name => 'array_last';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `array_last_n`.
class _ArrayLastNExpression extends FunctionExpression {
  final Expression expression;
  final Expression n;

  _ArrayLastNExpression(this.expression, this.n);

  @override
  String get name => 'array_last_n';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'n': n.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `maximum` on an array value (not the aggregate).
class _ArrayMaximumExpression extends FunctionExpression {
  final Expression expression;

  _ArrayMaximumExpression(this.expression);

  @override
  String get name => 'maximum';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `maximum_n`.
class _ArrayMaximumNExpression extends FunctionExpression {
  final Expression expression;
  final Expression n;

  _ArrayMaximumNExpression(this.expression, this.n);

  @override
  String get name => 'maximum_n';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'n': n.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `minimum` on an array value (not the aggregate).
class _ArrayMinimumExpression extends FunctionExpression {
  final Expression expression;

  _ArrayMinimumExpression(this.expression);

  @override
  String get name => 'minimum';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `minimum_n`.
class _ArrayMinimumNExpression extends FunctionExpression {
  final Expression expression;
  final Expression n;

  _ArrayMinimumNExpression(this.expression, this.n);

  @override
  String get name => 'minimum_n';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'n': n.toMap(),
      },
    };
  }
}

/// Serialized pipeline function `array_index_of` (first or last occurrence).
class _ArrayIndexOfExpression extends FunctionExpression {
  final Expression expression;
  final Expression element;
  final bool isLast;

  _ArrayIndexOfExpression(
    this.expression,
    this.element, {
    required this.isLast,
  });

  @override
  String get name => 'array_index_of';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'element': element.toMap(),
        'occurrence': Constant(isLast ? 'last' : 'first').toMap(),
      },
    };
  }
}

/// Serialized pipeline function `array_index_of_all`.
class _ArrayIndexOfAllExpression extends FunctionExpression {
  final Expression expression;
  final Expression element;

  _ArrayIndexOfAllExpression(this.expression, this.element);

  @override
  String get name => 'array_index_of_all';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'element': element.toMap(),
      },
    };
  }
}

/// Represents a raw function expression
class _RawFunctionExpression extends FunctionExpression {
  final String functionName;
  final List<Expression> args;

  _RawFunctionExpression(this.functionName, this.args);

  @override
  String get name => functionName;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': args.map((expr) => expr.toMap()).toList(),
    };
  }
}
