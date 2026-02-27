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
  if (value is Expression) return value;
  return Constant(value!);
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

  /// Converts this expression to a string with a format
  Expression toStringWithFormat(Expression format) {
    return _ToStringWithFormatExpression(this, format);
  }

  /// Converts this expression to a string with a literal format
  Expression toStringWithFormatLiteral(String format) {
    return _ToStringWithFormatExpression(this, Constant(format));
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

  /// Returns the keys from this map expression
  // ignore: use_to_and_as_if_applicable
  Expression mapKeys() {
    return _MapKeysExpression(this);
  }

  /// Returns the values from this map expression
  // ignore: use_to_and_as_if_applicable
  Expression mapValues() {
    return _MapValuesExpression(this);
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

  /// Returns the negation of this expression
  // ignore: use_to_and_as_if_applicable
  Expression negate() {
    return _NegateExpression(this);
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

  /// Replaces occurrences of a pattern in this string
  Expression replace(Expression find, Expression replacement) {
    return _ReplaceExpression(this, find, replacement);
  }

  /// Replaces occurrences of a string literal
  Expression replaceLiteral(String find, String replacement) {
    return _ReplaceExpression(this, Constant(find), Constant(replacement));
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

  // ============================================================================
  // ARRAY OPERATIONS
  // ============================================================================

  /// Concatenates this array with another array expression
  Expression arrayConcat(Expression secondArray) {
    return _ArrayConcatExpression(this, secondArray);
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

  /// Extracts a slice from this array
  Expression arraySlice(Expression start, Expression end) {
    return _ArraySliceExpression(this, start, end);
  }

  /// Extracts a slice using literal indices
  Expression arraySliceLiteral(int start, int end) {
    return _ArraySliceExpression(this, Constant(start), Constant(end));
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

  /// Creates a map expression from alternating key-value expressions
  static Expression mapFromPairs(List<Expression> keyValuePairs) {
    return _MapFromPairsExpression(keyValuePairs);
  }

  /// Returns the current timestamp
  static Expression currentTimestamp() {
    return _CurrentTimestampExpression();
  }

  /// Adds time to a timestamp expression
  static Expression timestampAdd(
    Expression timestamp,
    String unit,
    Expression amount,
  ) {
    return _TimestampAddExpression(timestamp, unit, amount);
  }

  /// Adds time to a timestamp with a literal amount
  static Expression timestampAddLiteral(
    Expression timestamp,
    String unit,
    int amount,
  ) {
    return _TimestampAddExpression(timestamp, unit, Constant(amount));
  }

  /// Subtracts time from a timestamp expression
  static Expression timestampSubtract(
    Expression timestamp,
    String unit,
    Expression amount,
  ) {
    return _TimestampSubtractExpression(timestamp, unit, amount);
  }

  /// Subtracts time from a timestamp with a literal amount
  static Expression timestampSubtractLiteral(
    Expression timestamp,
    String unit,
    int amount,
  ) {
    return _TimestampSubtractExpression(timestamp, unit, Constant(amount));
  }

  /// Calculates the difference between two timestamps
  static Expression timestampDiff(
    Expression timestamp1,
    Expression timestamp2,
    String unit,
  ) {
    return _TimestampDiffExpression(timestamp1, timestamp2, unit);
  }

  /// Truncates a timestamp to a specific unit
  static Expression timestampTruncate(
    Expression timestamp,
    String unit,
  ) {
    return _TimestampTruncateExpression(timestamp, unit);
  }

  /// Calculates the distance between two GeoPoint expressions
  static Expression distance(
    Expression geoPoint1,
    Expression geoPoint2,
  ) {
    return _DistanceExpression(geoPoint1, geoPoint2);
  }

  /// Creates a document ID expression from a DocumentReference
  static Expression documentIdFromRef(DocumentReference docRef) {
    return _DocumentIdFromRefExpression(docRef);
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
  static BooleanExpression ifErrorStatic(
    BooleanExpression tryExpr,
    BooleanExpression catchExpr,
  ) {
    return _IfErrorExpression(tryExpr, catchExpr) as BooleanExpression;
  }

  /// Checks if an expression produces an error
  static BooleanExpression isErrorStatic(Expression expr) {
    return _IsErrorExpression(expr);
  }

  /// Negates a boolean expression
  static BooleanExpression not(BooleanExpression expression) {
    return _NotExpression(expression);
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

  /// Negates an expression
  static Expression negateStatic(Expression numericExpr) {
    return _NegateExpression(numericExpr);
  }

  /// Negates a field
  static Expression negateField(String numericField) {
    return _NegateExpression(Field(numericField));
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

  /// Replaces in string
  static Expression replaceStatic(
    Expression stringExpr,
    Expression find,
    Expression replacement,
  ) {
    return _ReplaceExpression(stringExpr, find, replacement);
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

  /// Slices array
  static Expression arraySliceStatic(
    Expression array,
    Expression start,
    Expression end,
  ) {
    return _ArraySliceExpression(array, start, end);
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
        Field(arrayFieldName), _toExpression(element));
  }

  /// Creates a raw/custom function expression
  static Expression rawFunction(
    String name,
    List<Expression> args,
  ) {
    return _RawFunctionExpression(name, args);
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
    return {
      'name': name,
      'args': {
        'value': value,
      },
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

/// Represents a replace function expression
class _ReplaceExpression extends FunctionExpression {
  final Expression expression;
  final Expression find;
  final Expression replacement;

  _ReplaceExpression(this.expression, this.find, this.replacement);

  @override
  String get name => 'replace';

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
      andExpression: null,
      orExpression: _combineExpressions(expressions, 'or'),
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
class _NegateExpression extends FunctionExpression {
  final Expression expression;

  _NegateExpression(this.expression);

  @override
  String get name => 'negate';

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

/// Represents an array slice function expression
class _ArraySliceExpression extends FunctionExpression {
  final Expression array;
  final Expression start;
  final Expression end;

  _ArraySliceExpression(this.array, this.start, this.end);

  @override
  String get name => 'array_slice';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'array': array.toMap(),
        'start': start.toMap(),
        'end': end.toMap(),
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
class _IfErrorExpression extends FunctionExpression {
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

/// Represents a toStringWithFormat function expression
class _ToStringWithFormatExpression extends FunctionExpression {
  final Expression expression;
  final Expression format;

  _ToStringWithFormatExpression(this.expression, this.format);

  @override
  String get name => 'to_string_with_format';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'expression': expression.toMap(),
        'format': format.toMap(),
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

/// Represents a mapKeys function expression
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

/// Represents a mapValues function expression
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

/// Represents a timestampAdd function expression
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

/// Represents a timestampSubtract function expression
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

/// Represents a timestampDiff function expression
class _TimestampDiffExpression extends FunctionExpression {
  final Expression timestamp1;
  final Expression timestamp2;
  final String unit;

  _TimestampDiffExpression(this.timestamp1, this.timestamp2, this.unit);

  @override
  String get name => 'timestamp_diff';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'timestamp1': timestamp1.toMap(),
        'timestamp2': timestamp2.toMap(),
        'unit': unit,
      },
    };
  }
}

/// Represents a timestampTruncate function expression
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

/// Represents a distance function expression
class _DistanceExpression extends FunctionExpression {
  final Expression geoPoint1;
  final Expression geoPoint2;

  _DistanceExpression(this.geoPoint1, this.geoPoint2);

  @override
  String get name => 'distance';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'geo_point1': geoPoint1.toMap(),
        'geo_point2': geoPoint2.toMap(),
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

/// Represents a mapFromPairs expression
class _MapFromPairsExpression extends FunctionExpression {
  final List<Expression> keyValuePairs;

  _MapFromPairsExpression(this.keyValuePairs);

  @override
  String get name => 'map_from_pairs';

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'args': {
        'pairs': keyValuePairs.map((expr) => expr.toMap()).toList(),
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
