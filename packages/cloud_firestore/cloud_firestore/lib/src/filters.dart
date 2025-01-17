// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

class _FilterObject {
  Map<String, Object?> build() {
    throw UnimplementedError();
  }
}

class _FilterQuery extends _FilterObject {
  _FilterQuery(this._field, this._operator, this._value)
      : assert(_field is FieldPathType || _field is FieldPath);

  final Object _field;
  final String _operator;
  final Object? _value;

  @override
  Map<String, Object?> build() {
    return <String, Object?>{
      'fieldPath': _field,
      'op': _operator,
      'value': _value,
    };
  }
}

class _FilterOperator extends _FilterObject {
  _FilterOperator(this._operator, this._queries);

  final String _operator;
  final List<_FilterObject> _queries;

  @override
  Map<String, Object> build() {
    return <String, Object>{
      'op': _operator,
      'queries': _queries.map((e) => e.build()).toList(),
    };
  }
}

/// A [Filter] represents a restriction on one or more field values and can be used to refine
/// the results of a [Query].
class Filter extends FilterPlatformInterface {
  late final _FilterQuery? _filterQuery;
  late final _FilterOperator? _filterOperator;

  Filter._(this._filterQuery, this._filterOperator)
      : assert(
          (_filterQuery != null && _filterOperator == null) ||
              (_filterQuery == null && _filterOperator != null),
          'Exactly one operator must be specified',
        );

  /// A [Filter] represents a restriction on one or more field values and can be used to refine
  /// the results of a [Query].
  ///
  /// Only one operator can be specified at a time.
  Filter(
    /// The field or [FieldPath] to filter on.
    Object field, {
    /// Creates a new filter for checking that the given field is equal to the given value.
    Object? isEqualTo,

    /// Creates a new filter for checking that the given field is not equal to the given value.
    Object? isNotEqualTo,

    /// Creates a new filter for checking that the given field is less than the given value.
    Object? isLessThan,

    /// Creates a new filter for checking that the given field is less than or equal to the given value.
    Object? isLessThanOrEqualTo,

    /// Creates a new filter for checking that the given field is greater than the given value.
    Object? isGreaterThan,

    /// Creates a new filter for checking that the given field is greater than or equal to the given value.
    Object? isGreaterThanOrEqualTo,

    /// Creates a new filter for checking that the given array field contains the given value.
    Object? arrayContains,

    /// Creates a new filter for checking that the given array field contains any of the given values.
    Iterable<Object?>? arrayContainsAny,

    /// Creates a new filter for checking that the given field equals any of the given values.
    Iterable<Object?>? whereIn,

    /// Creates a new filter for checking that the given field does not equal any of the given values.
    Iterable<Object?>? whereNotIn,

    /// Creates a new filter for checking that the given field is null.
    bool? isNull,
  })  : assert(
          () {
            final operators = [
              isEqualTo,
              isNotEqualTo,
              isLessThan,
              isLessThanOrEqualTo,
              isGreaterThan,
              isGreaterThanOrEqualTo,
              arrayContains,
              arrayContainsAny,
              whereIn,
              whereNotIn,
              isNull,
            ];
            final operatorsUsed = operators.where((e) => e != null).length;
            return operatorsUsed == 1;
          }(),
          'Exactly one operator must be specified',
        ),
        assert(
          field is String || field is FieldPath || field is FieldPathType,
        ) {
    final _field = (field is String ? FieldPath.fromString(field) : field);

    _filterQuery = _FilterQuery(
      _field,
      _getOperator(
        isEqualTo,
        isNotEqualTo,
        isLessThan,
        isLessThanOrEqualTo,
        isGreaterThan,
        isGreaterThanOrEqualTo,
        arrayContains,
        arrayContainsAny,
        whereIn,
        whereNotIn,
        isNull,
      ),
      _CodecUtility.valueEncode(
        _getValue(
          isEqualTo,
          isNotEqualTo,
          isLessThan,
          isLessThanOrEqualTo,
          isGreaterThan,
          isGreaterThanOrEqualTo,
          arrayContains,
          arrayContainsAny,
          whereIn,
          whereNotIn,
          isNull,
        ),
      ),
    );
    _filterOperator = null;
  }

  String _getOperator(
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  ) {
    if (isEqualTo != null) return '==';
    if (isNotEqualTo != null) return '!=';
    if (isLessThan != null) return '<';
    if (isLessThanOrEqualTo != null) return '<=';
    if (isGreaterThan != null) return '>';
    if (isGreaterThanOrEqualTo != null) return '>=';
    if (arrayContains != null) return 'array-contains';
    if (arrayContainsAny != null) return 'array-contains-any';
    if (whereIn != null) return 'in';
    if (whereNotIn != null) return 'not-in';
    if (isNull != null) {
      if (isNull) {
        return '==';
      } else {
        return '!=';
      }
    }
    throw Exception('Exactly one operator must be specified');
  }

  Object? _getValue(
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  ) {
    if (isEqualTo != null) return isEqualTo;
    if (isNotEqualTo != null) return isNotEqualTo;
    if (isLessThan != null) return isLessThan;
    if (isLessThanOrEqualTo != null) return isLessThanOrEqualTo;
    if (isGreaterThan != null) return isGreaterThan;
    if (isGreaterThanOrEqualTo != null) return isGreaterThanOrEqualTo;
    if (arrayContains != null) return arrayContains;
    if (arrayContainsAny != null) return arrayContainsAny;
    if (whereIn != null) return whereIn;
    if (whereNotIn != null) return whereNotIn;
    if (isNull != null) {
      if (isNull == true) {
        return null;
      } else {
        return null;
      }
    }
    throw Exception('Exactly one operator must be specified');
  }

  /// Creates a new filter that is a disjunction of the given filters.
  ///
  /// A disjunction filter includes a document if it satisfies any of the given filters.
  static Filter or(
    Filter filter1,
    Filter filter2,
    // Number of OR operation is limited on the server side
    // We let here 30 as a limit
    [
    Filter? filter3,
    Filter? filter4,
    Filter? filter5,
    Filter? filter6,
    Filter? filter7,
    Filter? filter8,
    Filter? filter9,
    Filter? filter10,
    Filter? filter11,
    Filter? filter12,
    Filter? filter13,
    Filter? filter14,
    Filter? filter15,
    Filter? filter16,
    Filter? filter17,
    Filter? filter18,
    Filter? filter19,
    Filter? filter20,
    Filter? filter21,
    Filter? filter22,
    Filter? filter23,
    Filter? filter24,
    Filter? filter25,
    Filter? filter26,
    Filter? filter27,
    Filter? filter28,
    Filter? filter29,
    Filter? filter30,
  ]) {
    return _generateFilter(
      'OR',
      [
        filter1,
        filter2,
        filter3,
        filter4,
        filter5,
        filter6,
        filter7,
        filter8,
        filter9,
        filter10,
        filter11,
        filter12,
        filter13,
        filter14,
        filter15,
        filter16,
        filter17,
        filter18,
        filter19,
        filter20,
        filter21,
        filter22,
        filter23,
        filter24,
        filter25,
        filter26,
        filter27,
        filter28,
        filter29,
        filter30,
      ],
    );
  }

  /// Creates a new filter that is a conjunction of the given filters.
  ///
  /// A conjunction filter includes document if it satisfies all of the given filters.
  static Filter and(
    Filter filter1,
    Filter filter2, [
    Filter? filter3,
    Filter? filter4,
    Filter? filter5,
    Filter? filter6,
    Filter? filter7,
    Filter? filter8,
    Filter? filter9,
    Filter? filter10,
    Filter? filter11,
    Filter? filter12,
    Filter? filter13,
    Filter? filter14,
    Filter? filter15,
    Filter? filter16,
    Filter? filter17,
    Filter? filter18,
    Filter? filter19,
    Filter? filter20,
    Filter? filter21,
    Filter? filter22,
    Filter? filter23,
    Filter? filter24,
    Filter? filter25,
    Filter? filter26,
    Filter? filter27,
    Filter? filter28,
    Filter? filter29,
    Filter? filter30,
  ]) {
    return _generateFilter(
      'AND',
      [
        filter1,
        filter2,
        filter3,
        filter4,
        filter5,
        filter6,
        filter7,
        filter8,
        filter9,
        filter10,
        filter11,
        filter12,
        filter13,
        filter14,
        filter15,
        filter16,
        filter17,
        filter18,
        filter19,
        filter20,
        filter21,
        filter22,
        filter23,
        filter24,
        filter25,
        filter26,
        filter27,
        filter28,
        filter29,
        filter30,
      ],
    );
  }

  static Filter _generateFilter(
    String operator,
    List<Filter?> filters,
  ) {
    assert(
      () {
        final filtersUsed = filters.where((e) => e != null).length;
        return filtersUsed >= 2;
      }(),
      'At least two filters must be specified',
    );
    return Filter._(
      null,
      _FilterOperator(
        operator,
        [
          for (final filter in filters)
            if (filter != null && filter._filterQuery != null)
              filter._filterQuery
            else if (filter != null && filter._filterOperator != null)
              filter._filterOperator,
        ],
      ),
    );
  }

  /// Returns a map representation of this filter.
  @override
  Map<String, Object?> toJson() {
    if (_filterOperator != null) {
      return _filterOperator.build();
    } else if (_filterQuery != null) {
      return _filterQuery.build();
    }
    throw Exception('Exactly one operator must be specified');
  }
}
