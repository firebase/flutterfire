// ignore_for_file: require_trailing_commas
// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_util' show setProperty;

import 'package:cloud_firestore_web/src/interop/firestore_interop.dart'
    as interop;
import 'package:cloud_firestore_web/src/interop/utils/utils.dart';

/// Converts Dart serialized pipeline expressions/stage args into JS pipeline
/// types by calling the pipelines interop API (field, constant, equal, and,
/// ascending, etc.) that mirrors the Firebase JS SDK.
class PipelineExpressionConverterWeb {
  PipelineExpressionConverterWeb(this._pipelines);

  final interop.PipelinesJsImpl _pipelines;

  static const _kName = 'name';
  static const _kArgs = 'args';
  static const _kLeft = 'left';
  static const _kRight = 'right';
  static const _kExpression = 'expression';
  static const _kField = 'field';
  static const _kAlias = 'alias';
  static const _kValue = 'value';

  // ── Value expressions ─────────────────────────────────────────────────────

  /// Converts a serialized value expression to a JS Expression.
  interop.ExpressionJsImpl toExpression(Map<String, dynamic> map) {
    final name = map[_kName] as String?;
    final argsMap = _argsOf(map);
    switch (name) {
      case 'field':
        return _pipelines.field(((argsMap[_kField] as String?) ?? '').toJS);
      case 'add':
        return _binaryArithmetic(argsMap, (l, r) => l.add(r));
      case 'subtract':
        return _binaryArithmetic(argsMap, (l, r) => l.subtract(r));
      case 'multiply':
        return _binaryArithmetic(argsMap, (l, r) => l.multiply(r));
      case 'divide':
        return _binaryArithmetic(argsMap, (l, r) => l.divide(r));
      case 'modulo':
        return _binaryArithmetic(argsMap, (l, r) => l.modulo(r));
      case 'constant':
      case 'null':
        return _pipelines.constant(jsify(argsMap[_kValue])!);
      default:
        throw UnsupportedError('Unsupported expression: $name');
    }
  }

  // ── Boolean expressions ───────────────────────────────────────────────────

  /// Converts a serialized boolean expression to a JS BooleanExpression.
  ///
  /// Returns null if [map] is not a recognized boolean expression.
  JSAny? toBooleanExpression(Map<String, dynamic> map) {
    final name = map[_kName] as String?;
    final argsMap = _argsOf(map);
    switch (name) {
      case 'equal':
        return _pipelines.equal(
            _expr(argsMap, _kLeft), _expr(argsMap, _kRight));
      case 'not_equal':
        return _pipelines.notEqual(
            _expr(argsMap, _kLeft), _expr(argsMap, _kRight));
      case 'greater_than':
        return _pipelines.greaterThan(
            _expr(argsMap, _kLeft), _expr(argsMap, _kRight));
      case 'greater_than_or_equal':
        return _pipelines.greaterThanOrEqual(
            _expr(argsMap, _kLeft), _expr(argsMap, _kRight));
      case 'less_than':
        return _pipelines.lessThan(
            _expr(argsMap, _kLeft), _expr(argsMap, _kRight));
      case 'less_than_or_equal':
        return _pipelines.lessThanOrEqual(
            _expr(argsMap, _kLeft), _expr(argsMap, _kRight));
      case 'not':
        return _pipelines.not(_expr(argsMap, _kExpression));
      case 'exists':
        return _pipelines.exists(_expr(argsMap, _kExpression));
      case 'is_absent':
        return _pipelines.isAbsent(_expr(argsMap, _kExpression));
      case 'is_error':
        return _pipelines.isError(_expr(argsMap, _kExpression));
      case 'array_contains':
        return _pipelines.arrayContains(
            _expr(argsMap, 'array'), _expr(argsMap, 'element'));
      case 'filter':
        return _buildFilterExpression(argsMap);
      default:
        return null;
    }
  }

  // ── Stage options ─────────────────────────────────────────────────────────

  /// Converts orderings list to JS SortStageOptions.
  ///
  /// Each item shape: `{ expression: Map, order_direction: 'asc' | 'desc' }`.
  JSAny toSortOptions(List<dynamic> orderings) {
    final list = <JSAny>[];
    for (final o in orderings) {
      final m = o is Map<String, dynamic> ? o : <String, dynamic>{};
      final expr = m[_kExpression];
      if (expr == null) continue;
      final exprJs = toExpression(expr as Map<String, dynamic>);
      final dir = m['order_direction'] as String?;
      list.add(dir == 'desc'
          ? _pipelines.descending(exprJs)
          : _pipelines.ascending(exprJs));
    }
    if (list.isEmpty) {
      throw UnsupportedError(
        'Pipeline sort() on web requires the Firebase JS pipeline expression API '
        '(ascending, descending). Ensure the pipelines module is loaded.',
      );
    }
    final obj = JSObject.new;
    setProperty(obj, 'orderings', list.toJS);
    return obj as JSAny;
  }

  /// Converts a single expression map to a JS Selectable (field or aliased).
  JSAny? toSelectable(Map<String, dynamic> map) {
    final name = map[_kName] as String?;
    final argsMap = _argsOf(map);
    if (name == 'field') {
      return _pipelines.field(((argsMap[_kField] as String?) ?? '').toJS);
    }
    if (name == _kAlias) {
      final alias = argsMap[_kAlias] as String?;
      final expression = argsMap[_kExpression];
      if (alias == null || expression == null) return null;
      return toExpression(expression as Map<String, dynamic>)
          .asAlias(alias.toJS);
    }
    return toExpression(map);
  }

  /// Converts add_fields expressions to JS AddFieldsStageOptions.
  JSAny toAddFieldsOptions(List<dynamic> expressions) =>
      interop.AddFieldsOptionsJsImpl()
        ..fields = _toSelectableList(expressions).toJS;

  /// Converts select stage expressions to JS SelectStageOptions.
  JSAny toSelectOptions(List<dynamic> expressions) =>
      interop.SelectStageOptionsJsImpl()
        ..selections = _toSelectableList(expressions).toJS;

  /// Converts distinct stage groups to JS DistinctStageOptions.
  JSAny toDistinctOptions(List<dynamic> expressions) {
    final list = _toSelectableList(expressions);
    if (list.isEmpty) {
      throw UnsupportedError(
        'Pipeline distinct() on web requires the Firebase JS pipeline expression API.',
      );
    }
    final obj = JSObject.new;
    setProperty(obj, 'groups', list.toJS);
    return obj as JSAny;
  }

  // ── Aggregate ─────────────────────────────────────────────────────────────

  /// Converts args for the 'aggregate' stage to JS AggregateStageOptions.
  ///
  /// Expects [map] to contain an [aggregate_functions] list.
  interop.AggregateStageOptionsJsImpl toAggregateOptionsFromFunctions(
      Map<String, dynamic> map) {
    final list = map['aggregate_functions'] as List<dynamic>;
    return _buildAccumulators(list);
  }

  /// Converts args for the 'aggregate_with_options' stage to JS AggregateStageOptions.
  ///
  /// Expects [map] to contain an [aggregate_stage] map with [accumulators]
  /// and optionally [groups].
  interop.AggregateStageOptionsJsImpl toAggregateOptionsFromStageAndOptions(
      Map<String, dynamic> map) {
    final stage = map['aggregate_stage'] as Map<String, dynamic>;
    final list = stage['accumulators'] as List<dynamic>;
    final groups = stage['groups'] as List<dynamic>?;
    return _buildAccumulators(list, groups: groups);
  }

  // ── Other stage options ───────────────────────────────────────────────────

  /// Converts sample stage args to JS (integer count or SampleStageOptions).
  ///
  /// Dart serializes as `{ type: 'size', value: n }` or a raw number.
  JSAny toSampleOptions(dynamic args) {
    if (args is num) return args.toInt().toJS;
    if (args is Map<String, dynamic>) {
      final type = args['type'] as String?;
      final value = args[_kValue];
      if (type == 'size' && value != null) return (value as num).toInt().toJS;
      final n = args['documents'] as int? ?? args['count'] as int?;
      if (n != null) return n.toJS;
      return (args['documents'] as num?)?.toInt().toJS ?? 0.toJS;
    }
    return 0.toJS;
  }

  /// Converts unnest stage args to JS UnnestStageOptions.
  JSAny toUnnestOptions(Map<String, dynamic> map) {
    final selectable = map['selectable'] ?? map[_kExpression] ?? map[_kField];
    if (selectable == null) {
      throw UnsupportedError(
          'Pipeline unnest() on web requires selectable or field.');
    }
    final indexField = map['index_field'] as String?;
    final sel = selectable is Map<String, dynamic>
        ? toSelectable(selectable)
        : toExpression({
            _kName: 'field',
            _kArgs: {_kField: selectable.toString()}
          });
    if (sel == null) {
      throw UnsupportedError(
        'Pipeline unnest() on web requires the Firebase JS pipeline expression API.',
      );
    }
    final obj = JSObject.new;
    setProperty(obj, 'selectable', sel);
    if (indexField != null) setProperty(obj, 'indexField', indexField.toJS);
    return obj as JSAny;
  }

  /// Converts remove_fields field paths to JS RemoveFieldsStageOptions.
  JSAny toRemoveFieldsOptions(List<dynamic> fieldPaths) {
    final paths = <JSString>[];
    for (final e in fieldPaths) {
      final s = e is String
          ? e
          : (e is Map ? e[_kField] ?? e['path'] : null)?.toString();
      if (s != null) paths.add(s.toJS);
    }
    if (paths.isEmpty) {
      throw UnsupportedError(
        'Pipeline removeFields() on web requires at least one field path.',
      );
    }
    final obj = JSObject.new;
    setProperty(obj, 'fields', paths.toJS);
    return obj as JSAny;
  }

  /// Converts replace_with expression to JS ReplaceWithStageOptions.
  JSAny toReplaceWithOptions(Map<String, dynamic> expression) {
    final obj = JSObject.new;
    setProperty(obj, _kExpression, toExpression(expression));
    return obj as JSAny;
  }

  /// Converts find_nearest args to JS FindNearestStageOptions.
  JSAny toFindNearestOptions(Map<String, dynamic> map) {
    final vectorField =
        (map['vector_field'] as String?) ?? (map[_kField] as String?);
    final vectorValue = map['vector_value'] as List<dynamic>?;
    final distanceMeasure = (map['distance_measure'] as String?) ?? 'cosine';
    final limit = map['limit'] as int?;
    if (vectorField == null || vectorValue == null) {
      throw UnsupportedError(
        'Pipeline findNearest() on web requires vector_field and vector_value.',
      );
    }
    final obj = JSObject.new;
    setProperty(obj, 'vectorField', vectorField.toJS);
    setProperty(obj, 'vectorValue',
        jsify(vectorValue.map((e) => (e as num).toDouble()).toList()));
    setProperty(obj, 'distanceMeasure', distanceMeasure.toJS);
    if (limit != null) setProperty(obj, 'limit', limit.toJS);
    return obj as JSAny;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Extracts and safe-casts the 'args' sub-map from an expression map.
  static Map<String, dynamic> _argsOf(Map<String, dynamic> map) {
    final a = map[_kArgs];
    return a is Map<String, dynamic> ? a : const {};
  }

  /// Resolves [key] from [argsMap] as a value expression.
  JSAny _expr(Map<String, dynamic> argsMap, String key) =>
      toExpression(argsMap[key] as Map<String, dynamic>);

  interop.ExpressionJsImpl _binaryArithmetic(
    Map<String, dynamic> argsMap,
    interop.ExpressionJsImpl Function(
            interop.ExpressionJsImpl left, interop.ExpressionJsImpl right)
        op,
  ) =>
      op(
        toExpression(argsMap[_kLeft] as Map<String, dynamic>),
        toExpression(argsMap[_kRight] as Map<String, dynamic>),
      );

  JSAny? _buildFilterExpression(Map<String, dynamic> argsMap) {
    final operator = argsMap['operator'] as String?;
    final expressions = argsMap['expressions'] as List<dynamic>?;
    if (expressions == null || expressions.isEmpty) return null;
    final jsList = expressions
        .map((e) => toExpression(e as Map<String, dynamic>))
        .toList();
    if (jsList.length == 1) return jsList.single;
    JSAny result = jsList[0];
    for (var i = 1; i < jsList.length; i++) {
      result = operator == 'and'
          ? _pipelines.and(result, jsList[i])
          : _pipelines.or(result, jsList[i]);
    }
    return result;
  }

  List<JSAny> _toSelectableList(List<dynamic> expressions) => expressions
      .map((e) =>
          toSelectable(e is Map<String, dynamic> ? e : <String, dynamic>{}))
      .whereType<JSAny>()
      .toList();

  interop.AggregateStageOptionsJsImpl _buildAccumulators(
    List<dynamic> items, {
    List<dynamic>? groups,
  }) {
    final accumulators = items
        .map((item) => _parseAccumulator(item as Map<String, dynamic>))
        .whereType<JSAny>()
        .toList();

    if (accumulators.isEmpty) {
      throw UnsupportedError(
        'Pipeline aggregate() on web requires at least one valid accumulator.',
      );
    }

    final opts = interop.AggregateStageOptionsJsImpl()
      ..accumulators = accumulators.toJS;
    if (groups != null && groups.isNotEmpty) {
      opts.groups = _toSelectableList(groups).toJS;
    }
    return opts;
  }

  JSAny? _parseAccumulator(Map<String, dynamic> item) {
    final args = item[_kArgs] as Map<String, dynamic>;
    final alias = args[_kAlias] as String?;
    final aggregateFn = args['aggregate_function'] as Map<String, dynamic>?;
    if (alias == null || aggregateFn == null) return null;
    final fnName = aggregateFn[_kName] as String?;
    if (fnName == null) return null;
    final expressionMap = (aggregateFn[_kArgs]
        as Map<String, dynamic>?)?[_kExpression] as Map<String, dynamic>?;
    final exprJs = expressionMap != null ? toExpression(expressionMap) : null;
    return _buildAggregateFunction(fnName, exprJs)?.asAlias(alias.toJS);
  }

  /// Builds one JS aggregate function from a serialized [name] and optional [exprJs].
  interop.AggregateFunctionJsImpl? _buildAggregateFunction(
      String name, JSAny? exprJs) {
    switch (name) {
      case 'count_all':
        return _pipelines.countAll();
      case 'sum':
        return exprJs != null ? _pipelines.sum(exprJs) : null;
      case 'average':
        return exprJs != null ? _pipelines.average(exprJs) : null;
      case 'count':
        return exprJs != null ? _pipelines.count(exprJs) : null;
      case 'count_distinct':
        return exprJs != null ? _pipelines.countDistinct(exprJs) : null;
      case 'minimum':
        return exprJs != null ? _pipelines.minimum(exprJs) : null;
      case 'maximum':
        return exprJs != null ? _pipelines.maximum(exprJs) : null;
      default:
        return null;
    }
  }
}
