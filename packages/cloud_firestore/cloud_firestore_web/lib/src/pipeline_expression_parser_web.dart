// ignore_for_file: require_trailing_commas
// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    show Blob, GeoPoint, Timestamp, VectorValue;
import 'package:cloud_firestore_web/src/interop/firestore_interop.dart'
    as interop;
import 'package:cloud_firestore_web/src/interop/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';

/// Converts Dart serialized pipeline expressions/stage args into JS pipeline
/// types by calling the pipelines interop API (field, constant, equal, and,
/// ascending, etc.) that mirrors the Firebase JS SDK.
class PipelineExpressionParserWeb {
  PipelineExpressionParserWeb(this._pipelines, this._jsFirestore);

  final interop.PipelinesJsImpl _pipelines;
  final interop.FirestoreJsImpl _jsFirestore;

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
        return _pipelines.constant(_constantValueToJs(argsMap[_kValue]));
      case 'concat':
        final expressions = argsMap['expressions'] as List<dynamic>?;
        if (expressions == null || expressions.isEmpty) {
          throw UnsupportedError('concat requires at least one expression');
        }
        interop.ExpressionJsImpl result =
            toExpression(expressions[0] as Map<String, dynamic>);
        for (var i = 1; i < expressions.length; i++) {
          result = result
              .concat(toExpression(expressions[i] as Map<String, dynamic>));
        }
        return result;
      case 'length':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .length();
      case 'to_lower_case':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .toLower();
      case 'to_upper_case':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .toUpper();
      case 'trim':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .trim();
      case 'as_boolean':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .asBoolean();
      case 'is_error':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .isError();
      case 'is_absent':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .isAbsent();
      case 'substring':
        return _pipelines.substring(
          _expr(argsMap, _kExpression),
          _expr(argsMap, 'start'),
          _expr(argsMap, 'end'),
        );
      case 'string_replace_all':
        return _pipelines.stringReplaceAll(
          _expr(argsMap, _kExpression),
          _expr(argsMap, 'find'),
          _expr(argsMap, 'replacement'),
        );
      case 'split':
        return _pipelines.split(
          _expr(argsMap, _kExpression),
          _expr(argsMap, 'delimiter'),
        );
      case 'join':
        return _pipelines.join(
          _expr(argsMap, _kExpression),
          _expr(argsMap, 'delimiter'),
        );
      case 'if_absent':
        return _pipelines.ifAbsent(
          _expr(argsMap, _kExpression),
          _expr(argsMap, 'else'),
        );
      case 'if_error':
        return _pipelines.ifError(
          _expr(argsMap, _kExpression),
          _expr(argsMap, 'catch'),
        );
      case 'conditional':
        return _pipelines.conditional(
          toBooleanExpression(argsMap['condition'] as Map<String, dynamic>)!,
          _expr(argsMap, 'then'),
          _expr(argsMap, 'else'),
        );
      case 'document_id':
        final pathArg = argsMap[_kExpression];
        return _pipelines
            .documentId(toExpression(pathArg as Map<String, dynamic>));
      case 'document_id_from_ref':
        final path = argsMap['doc_ref'] as String?;
        if (path == null || path.isEmpty) {
          throw ArgumentError(
              "document_id_from_ref requires a non-empty 'doc_ref' path");
        }
        final docRef = interop.doc(_jsFirestore as JSAny, path.toJS);
        return _pipelines.documentId(docRef);
      case 'collection_id':
        return _pipelines.collectionId(_expr(argsMap, _kExpression));
      case 'map_get':
        {
          final keyExprMap = argsMap['key'] as Map<String, dynamic>?;
          if (keyExprMap == null) {
            throw ArgumentError("map_get requires a 'key' argument");
          }
          final keyString = _constantStringFromExpression(keyExprMap);
          if (keyString == null) {
            throw UnsupportedError(
                'mapGet on web only supports a constant string key ');
          }
          return _pipelines.mapGet(
            _expr(argsMap, 'map'),
            keyString.toJS,
          );
        }
      case 'map_keys':
        return _pipelines.mapKeys(_expr(argsMap, _kExpression));
      case 'map_values':
        return _pipelines.mapValues(_expr(argsMap, _kExpression));
      case 'current_timestamp':
        return _pipelines.currentTimestamp();
      case 'timestamp_add':
        return _pipelines.timestampAdd(
          _expr(argsMap, 'timestamp'),
          (argsMap['unit'] as String).toJS,
          _expr(argsMap, 'amount'),
        );
      case 'timestamp_subtract':
        return _pipelines.timestampSubtract(
          _expr(argsMap, 'timestamp'),
          (argsMap['unit'] as String).toJS,
          _expr(argsMap, 'amount'),
        );
      case 'timestamp_truncate':
        final tz = argsMap['timezone'] as String?;
        return _pipelines.timestampTruncate(
          _expr(argsMap, 'timestamp'),
          (argsMap['unit'] as String).toJS,
          tz?.toJS,
        );
      case 'abs':
        return _pipelines.abs(_expr(argsMap, _kExpression));
      case 'array_length':
        return _pipelines.arrayLength(_expr(argsMap, _kExpression));
      case 'array_sum':
        return _pipelines.arraySum(_expr(argsMap, _kExpression));
      case 'array_concat':
        return _pipelines.arrayConcat(
          _expr(argsMap, 'first'),
          _expr(argsMap, 'second'),
        );
      case 'array_concat_multiple':
        final arrays = argsMap['arrays'] as List<dynamic>?;
        if (arrays == null || arrays.length < 2) {
          throw UnsupportedError(
              'array_concat_multiple requires at least two arrays');
        }
        var arrResult = _pipelines.arrayConcat(
          toExpression(arrays[0] as Map<String, dynamic>),
          toExpression(arrays[1] as Map<String, dynamic>),
        );
        for (var i = 2; i < arrays.length; i++) {
          arrResult = _pipelines.arrayConcat(
            arrResult,
            toExpression(arrays[i] as Map<String, dynamic>),
          );
        }
        return arrResult;
      case 'array_reverse':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .arrayReverse();
      case 'array':
        final elements = argsMap['elements'] as List<dynamic>?;
        if (elements == null) {
          throw UnsupportedError('array requires elements');
        }
        final jsElements = elements
            .map((e) => toExpression(e as Map<String, dynamic>))
            .toList()
            .toJS;
        return _pipelines.array(jsElements);
      case 'array_contains':
        return _jsArrayContains(argsMap) as interop.ExpressionJsImpl;
      case 'array_contains_any':
        final js = _jsArrayContainsAny(argsMap);
        if (js == null) {
          throw UnsupportedError('array_contains_any requires values');
        }
        return js as interop.ExpressionJsImpl;
      case 'array_contains_all':
        final js = _jsArrayContainsAll(argsMap);
        if (js == null) {
          throw UnsupportedError(
            'array_contains_all requires values or array_expression',
          );
        }
        return js as interop.ExpressionJsImpl;
      case 'equal_any':
        final js = _jsEqualAny(argsMap);
        if (js == null) throw UnsupportedError('equal_any requires values');
        return js as interop.ExpressionJsImpl;
      case 'not_equal_any':
        final js = _jsNotEqualAny(argsMap);
        if (js == null) {
          throw UnsupportedError('not_equal_any requires values');
        }
        return js as interop.ExpressionJsImpl;
      case 'map':
        final data = argsMap['data'] as Map<String, dynamic>?;
        if (data == null) {
          throw UnsupportedError('map requires data');
        }
        final m = <String, dynamic>{};
        for (final entry in data.entries) {
          m[entry.key] = toExpression(entry.value as Map<String, dynamic>);
        }
        return _pipelines.map(jsify(m)! as JSObject);
      case 'map_set':
        final kv = argsMap['key_values'] as List<dynamic>?;
        if (kv == null || kv.isEmpty || kv.length.isOdd) {
          throw UnsupportedError(
              'map_set requires key_values with even length');
        }
        var cur = _expr(argsMap, 'map') as interop.ExpressionJsImpl;
        for (var i = 0; i < kv.length; i += 2) {
          cur = cur.mapSet(
            toExpression(kv[i] as Map<String, dynamic>),
            toExpression(kv[i + 1] as Map<String, dynamic>),
          );
        }
        return cur;
      case 'map_entries':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .mapEntries();
      case 'regex_find':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .regexFind(_expr(argsMap, 'pattern'));
      case 'regex_find_all':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .regexFindAll(_expr(argsMap, 'pattern'));
      case 'string_replace_one':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .stringReplaceOne(
          _expr(argsMap, 'find'),
          _expr(argsMap, 'replacement'),
        );
      case 'string_index_of':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .stringIndexOf(_expr(argsMap, 'search'));
      case 'string_repeat':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .stringRepeat(_expr(argsMap, 'repetitions'));
      case 'ltrim':
        {
          final expr = _expr(argsMap, _kExpression) as interop.ExpressionJsImpl;
          final v = argsMap['value'];
          if (v == null) return expr.ltrim();
          return expr.ltrim(toExpression(v as Map<String, dynamic>));
        }
      case 'rtrim':
        {
          final expr = _expr(argsMap, _kExpression) as interop.ExpressionJsImpl;
          final v = argsMap['value'];
          if (v == null) return expr.rtrim();
          return expr.rtrim(toExpression(v as Map<String, dynamic>));
        }
      case 'type':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .type();
      case 'trunc':
        {
          final expr = _expr(argsMap, _kExpression) as interop.ExpressionJsImpl;
          final dec = argsMap['decimals'];
          if (dec == null) return expr.trunc();
          return expr.trunc(toExpression(dec as Map<String, dynamic>));
        }
      case 'rand':
        return _pipelines.rand();
      case 'array_first':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .arrayFirst();
      case 'array_first_n':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .arrayFirstN(_expr(argsMap, 'n'));
      case 'array_last':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .arrayLast();
      case 'array_last_n':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .arrayLastN(_expr(argsMap, 'n'));
      case 'maximum':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .arrayMaximum();
      case 'maximum_n':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .arrayMaximumN(_expr(argsMap, 'n'));
      case 'minimum':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .arrayMinimum();
      case 'minimum_n':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .arrayMinimumN(_expr(argsMap, 'n'));
      case 'array_index_of':
        {
          final base = _expr(argsMap, _kExpression) as interop.ExpressionJsImpl;
          final el = _expr(argsMap, 'element');
          final occMap = argsMap['occurrence'] as Map<String, dynamic>?;
          final occ = _constantStringFromExpression(occMap ?? {});
          if (occ == 'last') {
            return base.arrayLastIndexOf(el);
          }
          if (occ == 'first') {
            return base.arrayIndexOf(el);
          }
          throw UnsupportedError(
            'array_index_of requires occurrence constant first or last',
          );
        }
      case 'array_index_of_all':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .arrayIndexOfAll(_expr(argsMap, 'element'));
      default:
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unsupported-expression',
          message:
              "The pipeline expression '$name' is not supported on the web "
              'platform. The Firebase JS SDK may not expose this expression.',
        );
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
      case 'and':
      case 'or':
      case 'xor':
        final exprMaps = argsMap['expressions'] as List<dynamic>?;
        if (exprMaps == null || exprMaps.isEmpty) return null;
        final exprs = exprMaps
            .map((e) => toBooleanExpression(e as Map<String, dynamic>))
            .whereType<JSAny>()
            .toList();
        if (exprs.isEmpty) return null;
        var result = exprs.first;
        for (var i = 1; i < exprs.length; i++) {
          if (name == 'and') {
            result = _pipelines.and(result, exprs[i]);
          } else if (name == 'or') {
            result = _pipelines.or(result, exprs[i]);
          } else {
            result = _pipelines.xor(result, exprs[i]);
          }
        }
        return result;
      case 'not':
        final expr = argsMap[_kExpression] as Map<String, dynamic>;
        final boolExpr = toBooleanExpression(expr);
        if (boolExpr == null) {
          throw UnsupportedError('not requires a boolean expression');
        }
        return _pipelines.not(boolExpr);
      case 'exists':
        return _pipelines.exists(_expr(argsMap, _kExpression));
      case 'is_absent':
        return (_expr(argsMap, _kExpression) as interop.ExpressionJsImpl)
            .isAbsent();
      case 'is_error':
        return _pipelines.isError(_expr(argsMap, _kExpression));
      case 'array_contains':
        return _jsArrayContains(argsMap);
      case 'array_contains_any':
        return _jsArrayContainsAny(argsMap);
      case 'array_contains_all':
        return _jsArrayContainsAll(argsMap);
      case 'equal_any':
        return _jsEqualAny(argsMap);
      case 'not_equal_any':
        return _jsNotEqualAny(argsMap);
      case 'filter':
        return _buildFilterExpression(argsMap);
      case 'is_type':
        final typeStr = argsMap['type'] as String?;
        if (typeStr == null) {
          throw UnsupportedError("is_type requires string 'type'");
        }
        return _pipelines.isTypeExpr(
          _expr(argsMap, _kExpression),
          typeStr.toJS,
        );
      default:
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unsupported-boolean-expression',
          message: "The boolean expression '$name' is not supported on the web "
              'platform. The Firebase JS SDK may not expose this expression.',
        );
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
    return interop.SortStageOptionsJsImpl()..orderings = list.toJS;
  }

  /// Converts a single expression map to a JS Selectable (field or aliased).
  JSAny toSelectable(Map<String, dynamic> map) {
    final name = map[_kName] as String?;
    final argsMap = _argsOf(map);
    if (name == 'field') {
      return _pipelines.field(((argsMap[_kField] as String?) ?? '').toJS);
    }
    if (name == _kAlias) {
      final alias = argsMap[_kAlias] as String;
      final expression = argsMap[_kExpression];
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
    return interop.DistinctStageOptionsJsImpl()..groups = list.toJS;
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
  JSAny toSampleOptions(Map<String, dynamic> map) {
    final args = map['type'] as String;
    if (args == 'size') {
      final value = map['value'] as num;
      return interop.SampleStageOptionsJsImpl()..documents = value.toInt().toJS;
    } else {
      final value = map['value'] as num;
      return interop.SampleStageOptionsJsImpl()
        ..percentage = value.toDouble().toJS;
    }
  }

  /// Converts unnest stage args to JS UnnestStageOptions.
  JSAny toUnnestOptions(Map<String, dynamic> map) {
    final expression = map[_kExpression] as Map<String, dynamic>;
    final indexField = map['index_field'] as String?;
    final sel = toSelectable(expression);
    return interop.UnnestStageOptionsJsImpl()
      ..selectable = sel
      ..indexField = indexField?.toJS;
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
    return interop.RemoveFieldsStageOptionsJsImpl()..fields = paths.toJS;
  }

  /// Converts replace_with expression to JS ReplaceWithStageOptions.
  JSAny toReplaceWithOptions(Map<String, dynamic> expression) {
    return interop.ReplaceWithStageOptionsJsImpl()
      ..map = toExpression(expression);
  }

  /// Converts find_nearest args to JS FindNearestStageOptions.
  interop.FindNearestStageOptionsJsImpl toFindNearestOptions(
      Map<String, dynamic> map) {
    final vectorField =
        (map['vector_field'] as String?) ?? (map[_kField] as String?);
    final vectorValue = map['vector_value'] as List<dynamic>?;
    final distanceMeasure = (map['distance_measure'] as String?) ?? 'cosine';
    final limit = map['limit'] as int?;
    final distanceField = map['distance_field'] as String?;
    if (vectorField == null || vectorValue == null) {
      throw UnsupportedError(
        'Pipeline findNearest() on web requires vector_field and vector_value.',
      );
    }
    final doubles = vectorValue.map((e) => (e as num).toDouble()).toList();
    final opts = interop.FindNearestStageOptionsJsImpl()
      ..field = _pipelines.field(vectorField.toJS)
      ..vectorValue = interop.vector(doubles.jsify()! as JSArray)
      ..distanceMeasure = distanceMeasure.toJS;
    if (limit != null) opts.limit = limit.toJS;
    if (distanceField != null) opts.distanceField = distanceField.toJS;
    return opts;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Converts a [Constant] value to the correct JS type for the pipelines API.
  ///
  /// Each Dart type accepted by [Constant] is mapped to the corresponding
  /// Firestore JS SDK interop type so that the JS SDK receives a properly typed
  /// value (e.g. a JS `Timestamp`, `GeoPoint`, or `Bytes` object) rather than
  /// a plain JS primitive or an unrecognised object.
  JSAny? _constantValueToJs(Object? value) {
    if (value == null) return null;
    if (value is String) return value.toJS;
    if (value is bool) return value.toJS;
    if (value is int) return value.toJS;
    if (value is double) return value.toJS;
    if (value is DateTime) {
      return interop.TimestampJsImpl.fromMillis(
          value.millisecondsSinceEpoch.toJS) as JSAny;
    }

    if (value is Timestamp) {
      // Use seconds + nanoseconds directly to preserve sub-millisecond precision.
      return interop.TimestampJsImpl(value.seconds.toJS, value.nanoseconds.toJS)
          as JSAny;
    }
    if (value is GeoPoint) {
      return interop.GeoPointJsImpl(value.latitude.toJS, value.longitude.toJS)
          as JSAny;
    }
    if (value is Blob) {
      return interop.BytesJsImpl.fromUint8Array(value.bytes.toJS) as JSAny;
    }
    if (value is List<int>) {
      return interop.BytesJsImpl.fromUint8Array(Uint8List.fromList(value).toJS)
          as JSAny;
    }
    if (value is VectorValue) {
      return interop.vector(value.toArray().jsify()! as JSArray) as JSAny;
    }
    if (value is Map) {
      final path = value['path'] as String;
      return interop.doc(_jsFirestore as JSAny, path.toJS) as JSAny;
    }
    return jsify(value);
  }

  /// Extracts and safe-casts the 'args' sub-map from an expression map.
  static Map<String, dynamic> _argsOf(Map<String, dynamic> map) {
    final a = map[_kArgs];
    return a is Map<String, dynamic> ? a : const {};
  }

  /// Returns the string value if [exprMap] is a constant string expression;
  /// otherwise null.
  String? _constantStringFromExpression(Map<String, dynamic> exprMap) {
    if ((exprMap[_kName] as String?) != 'constant') return null;
    final args = _argsOf(exprMap);
    final value = args[_kValue];
    return value is String ? value : null;
  }

  /// Resolves [key] from [argsMap] as a value expression.
  JSAny _expr(Map<String, dynamic> argsMap, String key) =>
      toExpression(argsMap[key] as Map<String, dynamic>);

  JSAny _jsArrayContains(Map<String, dynamic> argsMap) =>
      _pipelines.arrayContains(
        _expr(argsMap, 'array'),
        _expr(argsMap, 'element'),
      );

  JSAny? _jsArrayContainsAny(Map<String, dynamic> argsMap) {
    final valuesMaps = argsMap['values'] as List<dynamic>?;
    if (valuesMaps == null || valuesMaps.isEmpty) return null;
    final valuesJs = valuesMaps
        .map((v) => toExpression(v as Map<String, dynamic>))
        .toList()
        .toJS;
    return _pipelines.arrayContainsAny(_expr(argsMap, 'array'), valuesJs);
  }

  JSAny? _jsArrayContainsAll(Map<String, dynamic> argsMap) {
    final arrayExpr = _expr(argsMap, 'array');
    final valuesArg = argsMap['values'] as List<dynamic>?;
    final arrayExpressionArg = argsMap['array_expression'];
    if (valuesArg != null && valuesArg.isNotEmpty) {
      final valuesJs = valuesArg
          .map((v) => toExpression(v as Map<String, dynamic>))
          .toList()
          .toJS;
      return _pipelines.arrayContainsAll(arrayExpr, valuesJs);
    }
    if (arrayExpressionArg != null) {
      return _pipelines.arrayContainsAll(
        arrayExpr,
        toExpression(arrayExpressionArg as Map<String, dynamic>),
      );
    }
    return null;
  }

  JSAny? _jsEqualAny(Map<String, dynamic> argsMap) {
    final valuesMaps = argsMap['values'] as List<dynamic>?;
    if (valuesMaps == null || valuesMaps.isEmpty) return null;
    final valuesJs = valuesMaps
        .map((v) => toExpression(v as Map<String, dynamic>))
        .toList()
        .toJS;
    return _pipelines.equalAny(_expr(argsMap, 'value'), valuesJs);
  }

  JSAny? _jsNotEqualAny(Map<String, dynamic> argsMap) {
    final valuesMaps = argsMap['values'] as List<dynamic>?;
    if (valuesMaps == null || valuesMaps.isEmpty) return null;
    final valuesJs = valuesMaps
        .map((v) => toExpression(v as Map<String, dynamic>))
        .toList()
        .toJS;
    return _pipelines.notEqualAny(_expr(argsMap, 'value'), valuesJs);
  }

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
      case 'first':
        return exprJs != null ? _pipelines.first(exprJs) : null;
      case 'last':
        return exprJs != null ? _pipelines.last(exprJs) : null;
      case 'array_agg':
        return exprJs != null ? _pipelines.arrayAgg(exprJs) : null;
      case 'array_agg_distinct':
        return exprJs != null ? _pipelines.arrayAggDistinct(exprJs) : null;
      default:
        return null;
    }
  }
}
