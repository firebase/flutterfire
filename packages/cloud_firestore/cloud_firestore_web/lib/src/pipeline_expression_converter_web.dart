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

  /// Converts a serialized value expression to JS Expression (field, constant only).
  /// For boolean expressions (equal, not_equal, and, or, etc.) use [toBooleanExpression].
  interop.ExpressionJsImpl toExpression(Map<String, dynamic> map) {
    final name = map['name'] as String?;
    final args = map['args'];
    final argsMap = args is Map<String, dynamic> ? args : <String, dynamic>{};

    switch (name) {
      case 'field':
        final path = (argsMap['field'] as String?) ?? '';
        return _pipelines.field(path.toJS);
      case 'add':
        final leftJsExpr =
            toExpression(argsMap['left'] as Map<String, dynamic>);
        final rightJsExpr =
            toExpression(argsMap['right'] as Map<String, dynamic>);
        return leftJsExpr.add(rightJsExpr);
      case 'constant':
      case 'null':
        final value = argsMap['value'];
        if (value == null) {
          throw UnsupportedError(
            'constant(null) is not supported on web; use a non-null value.',
          );
        }
        return _pipelines.constant(jsify(value)!);
      // return _pipelines.constant(value.toJS);
      default:
        return throw UnsupportedError(
          'Unsupported expression: $name',
        );
    }
  }

  /// Converts a serialized boolean expression to JS BooleanExpression for where().
  /// Handles equal, not_equal, comparisons, and, or, not, exists, is_absent, is_error, array_contains.
  /// Sub-expressions (e.g. left/right of equal) can be value expressions or nested boolean expressions.
  /// Returns null if [map] is not a recognized boolean or value expression.
  JSAny? toBooleanExpression(Map<String, dynamic> map) {
    final name = map['name'] as String?;
    final args = map['args'];
    final argsMap = args is Map<String, dynamic> ? args : <String, dynamic>{};

    JSAny leftJs(Map<String, dynamic> left) => toExpression(left);
    JSAny rightJs(Map<String, dynamic> right) => toExpression(right);

    switch (name) {
      case 'equal':
        return _pipelines.equal(leftJs(argsMap['left'] as Map<String, dynamic>),
            rightJs(argsMap['right'] as Map<String, dynamic>));
      case 'not_equal':
        return _pipelines.notEqual(
            leftJs(argsMap['left'] as Map<String, dynamic>),
            rightJs(argsMap['right'] as Map<String, dynamic>));
      case 'greater_than':
        return _pipelines.greaterThan(
            leftJs(argsMap['left'] as Map<String, dynamic>),
            rightJs(argsMap['right'] as Map<String, dynamic>));
      case 'greater_than_or_equal':
        return _pipelines.greaterThanOrEqual(
            leftJs(argsMap['left'] as Map<String, dynamic>),
            rightJs(argsMap['right'] as Map<String, dynamic>));
      case 'less_than':
        return _pipelines.lessThan(
            leftJs(argsMap['left'] as Map<String, dynamic>),
            rightJs(argsMap['right'] as Map<String, dynamic>));
      case 'less_than_or_equal':
        return _pipelines.lessThanOrEqual(
            leftJs(argsMap['left'] as Map<String, dynamic>),
            rightJs(argsMap['right'] as Map<String, dynamic>));
      case 'filter':
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
      case 'not':
        return _pipelines
            .not(leftJs(argsMap['expression'] as Map<String, dynamic>));
      case 'exists':
        return _pipelines
            .exists(leftJs(argsMap['expression'] as Map<String, dynamic>));
      case 'is_absent':
        return _pipelines
            .isAbsent(leftJs(argsMap['expression'] as Map<String, dynamic>));
      case 'is_error':
        return _pipelines
            .isError(leftJs(argsMap['expression'] as Map<String, dynamic>));
      case 'array_contains':
        return _pipelines.arrayContains(
            leftJs(argsMap['array'] as Map<String, dynamic>),
            rightJs(argsMap['element'] as Map<String, dynamic>));
      default:
        return null;
    }
  }

  /// Converts orderings list to JS SortStageOptions. Each item: { expression, order_direction }.
  JSAny toSortOptions(List<dynamic> orderings) {
    final list = <JSAny>[];
    for (final o in orderings) {
      final m = o is Map<String, dynamic> ? o : <String, dynamic>{};
      final expr = m['expression'];
      final dir = m['order_direction'] as String?;
      if (expr == null) continue;
      final exprJs = toExpression(expr as Map<String, dynamic>);
      final ordering = (dir == 'desc')
          ? _pipelines.descending(exprJs)
          : _pipelines.ascending(exprJs);
      list.add(ordering);
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

  /// Converts add_fields expressions (Selectable[]) to JS AddFieldsStageOptions.
  JSAny toAddFieldsOptions(List<dynamic> expressions) {
    final list = <JSAny>[];
    for (final e in expressions) {
      print('e: $e');
      final sel =
          toSelectable(e is Map<String, dynamic> ? e : <String, dynamic>{});
      if (sel != null) list.add(sel);
    }

    return interop.AddFieldsOptionsJsImpl()..fields = list.toJS;
  }

  /// Converts a single expression map to a JS Selectable (field or aliased).
  JSAny? toSelectable(Map<String, dynamic> map) {
    final name = map['name'] as String?;
    final args = map['args'];
    final argsMap = args is Map<String, dynamic> ? args : <String, dynamic>{};
    if (name == 'field') {
      final path = (argsMap['field'] as String?) ?? '';
      return _pipelines.field(path.toJS);
    }
    if (name == 'alias') {
      final alias = argsMap['alias'] as String?;
      final expression = argsMap['expression'];
      if (alias == null || expression == null) return null;
      final exprJs = toExpression(expression as Map<String, dynamic>);
      if (exprJs == null) return null;
      // return _pipelines.aliased(exprJs, alias.toJS);
      return exprJs.asAlias(alias.toJS);
    }
    final exprJs = toExpression(map);
    return exprJs;
  }

  /// Converts select stage expressions to JS SelectStageOptions.
  JSAny toSelectOptions(List<dynamic> expressions) {
    final list = <JSAny>[];
    for (final e in expressions) {
      final sel =
          toSelectable(e is Map<String, dynamic> ? e : <String, dynamic>{});
      if (sel != null) list.add(sel);
    }
    if (list.isEmpty) {
      throw UnsupportedError(
        'Pipeline select() on web requires the Firebase JS pipeline expression API.',
      );
    }
    final obj = JSObject.new;
    setProperty(obj, 'selections', list.toJS);
    return obj as JSAny;
  }

  /// Converts distinct stage groups to JS DistinctStageOptions.
  JSAny toDistinctOptions(List<dynamic> expressions) {
    final list = <JSAny>[];
    for (final e in expressions) {
      final sel =
          toSelectable(e is Map<String, dynamic> ? e : <String, dynamic>{});
      if (sel != null) list.add(sel);
    }
    if (list.isEmpty) {
      throw UnsupportedError(
        'Pipeline distinct() on web requires the Firebase JS pipeline expression API.',
      );
    }
    final obj = JSObject.new;
    setProperty(obj, 'groups', list.toJS);
    return obj as JSAny;
  }

  /// Converts aggregate stage args to JS AggregateStageOptions.
  /// Input shape: { aggregate_functions: [...] } or { aggregate_stage: { aggregate_functions: [...] } } or { accumulators: [...] }.
  /// Each list item is an aliased aggregate: { name: 'alias', args: { alias: String, aggregate_function: { name, args?: { expression } } } }.
  interop.AggregateStageOptionsJsImpl toAggregateOptions(
      Map<String, dynamic> map) {
    final aggregateFunctions = _getAggregateFunctionsList(map);
    if (aggregateFunctions.isEmpty) {
      throw UnsupportedError(
        'Pipeline aggregate() on web requires aggregate_functions.',
      );
    }

    final accumulators = <JSAny>[];
    for (final item in aggregateFunctions) {
      final aliased = _asStringKeyMap(item);
      if (aliased == null) continue;

      final args = _asStringKeyMap(aliased['args']) ?? {};
      final alias = args['alias'] ?? aliased['alias'];
      if (alias is! String) continue;

      final aggregateFn = _asStringKeyMap(args['aggregate_function']) ??
          _asStringKeyMap(args['aggregate']) ??
          _asStringKeyMap(aliased['aggregate_function']);
      if (aggregateFn == null) continue;

      final name = aggregateFn['name'] as String?;
      if (name == null) continue;

      final fnArgs = _asStringKeyMap(aggregateFn['args']) ?? {};
      final expressionMap = _asStringKeyMap(fnArgs['expression']) ??
          _asStringKeyMap(aggregateFn['expression']);

      JSAny? exprJs;
      if (name != 'count_all') {
        if (expressionMap == null) continue;
        exprJs = toExpression(expressionMap);
        if (exprJs == null) continue;
      }

      final fn = _buildAggregateFunction(name, exprJs);
      if (fn == null) continue;

      accumulators.add(fn.asAlias(alias.toJS));
    }

    if (accumulators.isEmpty) {
      throw UnsupportedError(
        'Pipeline aggregate() on web requires the Firebase JS pipeline expression API '
        '(sum, average, count, etc.).',
      );
    }

    final options = interop.AggregateStageOptionsJsImpl();
    options.accumulators = accumulators.toJS;
    return options;
  }

  /// Returns the aggregate_functions list from [map] (top-level, under aggregate_stage, or as accumulators).
  static List<dynamic> _getAggregateFunctionsList(Map<String, dynamic> map) {
    final list = map['aggregate_functions'];
    if (list is List && list.isNotEmpty) return list;

    final stage = _asStringKeyMap(map['aggregate_stage']);
    final fromStage = stage?['aggregate_functions'];
    if (fromStage is List && fromStage.isNotEmpty) return fromStage;

    final accumulators = map['accumulators'];
    if (accumulators is List && accumulators.isNotEmpty) return accumulators;

    return [];
  }

  static Map<String, dynamic>? _asStringKeyMap(dynamic value) =>
      value is Map<String, dynamic> ? value : null;

  /// Builds one aggregate function (sum, average, count_all, etc.) from serialized [name] and optional [exprJs].
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

  /// Converts sample stage args to JS (number or SampleStageOptions).
  /// Dart PipelineSample.toMap() returns { type: 'size', value: n } or { type: 'percentage', value: p }.
  JSAny toSampleOptions(dynamic args) {
    if (args is num) return args.toInt().toJS;
    if (args is Map<String, dynamic>) {
      final type = args['type'] as String?;
      final value = args['value'];
      if (type == 'size' && value != null) return (value as num).toInt().toJS;
      final n = args['documents'] as int? ?? args['count'] as int?;
      if (n != null) return n.toJS;
      return (args['documents'] as num?)?.toInt().toJS ?? 0.toJS;
    }
    return 0.toJS;
  }

  /// Converts unnest stage args to JS UnnestStageOptions.
  /// Dart uses 'expression' (Selectable/Expression toMap).
  JSAny toUnnestOptions(Map<String, dynamic> map) {
    final selectable = map['selectable'] ?? map['expression'] ?? map['field'];
    final indexField = map['index_field'] as String?;
    if (selectable == null) {
      throw UnsupportedError(
        'Pipeline unnest() on web requires selectable or field.',
      );
    }
    final sel = selectable is Map<String, dynamic>
        ? toSelectable(selectable)
        : toExpression({
            'name': 'field',
            'args': {'field': selectable.toString()}
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
          : (e is Map ? e['field'] ?? e['path'] : null)?.toString();
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
    final exprJs = toExpression(expression);
    if (exprJs == null) {
      throw UnsupportedError(
        'Pipeline replaceWith() on web requires the Firebase JS pipeline expression API.',
      );
    }
    final obj = JSObject.new;
    setProperty(obj, 'expression', exprJs);
    return obj as JSAny;
  }

  /// Converts find_nearest args to JS FindNearestStageOptions.
  JSAny toFindNearestOptions(Map<String, dynamic> map) {
    final vectorField =
        (map['vector_field'] as String?) ?? (map['field'] as String?);
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
}
