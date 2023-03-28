import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

class _FilterQuery {
  _FilterQuery(this._field, this._operator, this._value);

  final FieldPath _field;
  final String _operator;
  final Object _value;

  Map<String, Object> build() {
    return <String, Object>{
      'fieldPath': _field.toString(),
      'op': _operator,
      'value': _value,
    };
  }
}

class Filter {
  late final _FilterQuery _filterQuery;

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

  Map<String, Object> build() {
    return _filterQuery.build();
  }
}
