import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

class _FilterObject {
  Map<String, Object> build() {
    throw UnimplementedError();
  }
}

class _FilterQuery extends _FilterObject {
  _FilterQuery(this._field, this._operator, this._value);

  final FieldPath _field;
  final String _operator;
  final Object _value;

  @override
  Map<String, Object> build() {
    return <String, Object>{
      'fieldPath': _field.toString(),
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

class Filter {
  late final _FilterQuery? _filterQuery;
  late final _FilterOperator? _filterOperator;

  Filter._(this._filterQuery, this._filterOperator)
      : assert(
          (_filterQuery != null && _filterOperator == null) ||
              (_filterQuery == null && _filterOperator != null),
          'Exactly one operator must be specified',
        );

  Filter(
    Object field, {
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
        assert(field is String || field is FieldPath) {
    final _field =
        field is String ? FieldPath.fromString(field) : field as FieldPath;

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
    if (isNull != null) return '==';
    throw Exception('Exactly one operator must be specified');
  }

  Object _getValue(
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
    if (isNull != null) return isNull;
    throw Exception('Exactly one operator must be specified');
  }

  // Number of OR operation is limited on the server side
  // We let here 10 as a limit
  static Filter or(
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
      ],
    );
  }

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
              filter._filterQuery!
            else if (filter != null && filter._filterOperator != null)
              filter._filterOperator!,
        ],
      ),
    );
  }
}
