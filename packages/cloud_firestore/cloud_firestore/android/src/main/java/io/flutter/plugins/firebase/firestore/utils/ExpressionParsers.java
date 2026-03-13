/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils;

import android.util.Log;
import androidx.annotation.NonNull;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.pipeline.AggregateFunction;
import com.google.firebase.firestore.pipeline.AggregateOptions;
import com.google.firebase.firestore.pipeline.AggregateStage;
import com.google.firebase.firestore.pipeline.AliasedAggregate;
import com.google.firebase.firestore.pipeline.BooleanExpression;
import com.google.firebase.firestore.pipeline.Expression;
import com.google.firebase.firestore.pipeline.FindNearestStage;
import com.google.firebase.firestore.pipeline.Selectable;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Handles parsing of all expression types from Dart map representations to Android SDK objects. */
class ExpressionParsers {
  private static final String TAG = "ExpressionParsers";

  private final FirebaseFirestore firestore;

  ExpressionParsers(@NonNull FirebaseFirestore firestore) {
    this.firestore = firestore;
  }

  /** Binary operation on two expressions. Used instead of BiFunction for API 23 compatibility. */
  private interface BinaryExpressionOp<R> {
    R apply(Expression left, Expression right);
  }

  /** Parses an expression from a map representation. */
  @SuppressWarnings("unchecked")
  Expression parseExpression(@NonNull Map<String, Object> expressionMap) {
    String name = (String) expressionMap.get("name");
    if (name == null) {
      // Might be a field reference directly (legacy format)
      if (expressionMap.containsKey("field_name")) {
        String fieldName = (String) expressionMap.get("field_name");
        return Expression.field(fieldName);
      }
      // Check for field in args (current format)
      Map<String, Object> argsCheck = (Map<String, Object>) expressionMap.get("args");
      if (argsCheck != null && argsCheck.containsKey("field")) {
        String fieldName = (String) argsCheck.get("field");
        return Expression.field(fieldName);
      }
      throw new IllegalArgumentException("Expression must have a 'name' field");
    }

    Map<String, Object> args = (Map<String, Object>) expressionMap.get("args");
    if (args == null) {
      args = new HashMap<>();
    }

    switch (name) {
      case "field":
        {
          String fieldName = (String) args.get("field");
          if (fieldName == null) {
            throw new IllegalArgumentException("Field expression must have a 'field' argument");
          }
          return Expression.field(fieldName);
        }
      case "constant":
        {
          Object value = args.get("value");
          if (value instanceof Map) {
            @SuppressWarnings("unchecked")
            Map<String, Object> valueMap = (Map<String, Object>) value;
            String path = (String) valueMap.get("path");
            return Expression.constant(firestore.document(path));
          }
          return ExpressionHelpers.parseConstantValue(value);
        }
      case "alias":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          String alias = (String) args.get("alias");
          Expression expr = parseExpression(exprMap);
          return expr.alias(alias);
        }
        // Comparison operations
      case "equal":
        return parseBinaryComparison(args, (left, right) -> left.equal(right));
      case "not_equal":
        return parseBinaryComparison(args, (left, right) -> left.notEqual(right));
      case "greater_than":
        return parseBinaryComparison(args, (left, right) -> left.greaterThan(right));
      case "greater_than_or_equal":
        return parseBinaryComparison(args, (left, right) -> left.greaterThanOrEqual(right));
      case "less_than":
        return parseBinaryComparison(args, (left, right) -> left.lessThan(right));
      case "less_than_or_equal":
        return parseBinaryComparison(args, (left, right) -> left.lessThanOrEqual(right));
        // Arithmetic operations
      case "add":
        return parseBinaryOperation(args, (left, right) -> left.add(right));
      case "subtract":
        return parseBinaryOperation(args, (left, right) -> left.subtract(right));
      case "multiply":
        return parseBinaryOperation(args, (left, right) -> left.multiply(right));
      case "divide":
        return parseBinaryOperation(args, (left, right) -> left.divide(right));
      case "modulo":
        return parseBinaryOperation(args, (left, right) -> left.mod(right));
        // Logic operations
      case "and":
        {
          List<Map<String, Object>> exprMaps = (List<Map<String, Object>>) args.get("expressions");
          return ExpressionHelpers.parseAndExpression(exprMaps, this);
        }
      case "or":
        {
          List<Map<String, Object>> exprMaps = (List<Map<String, Object>>) args.get("expressions");
          return ExpressionHelpers.parseOrExpression(exprMaps, this);
        }
      case "xor":
        {
          List<Map<String, Object>> exprMaps = (List<Map<String, Object>>) args.get("expressions");
          return ExpressionHelpers.parseXorExpression(exprMaps, this);
        }
      case "not":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          BooleanExpression expr = parseBooleanExpression(exprMap);
          return Expression.not(expr);
        }
        // String / array value expressions
      case "concat":
        {
          List<Map<String, Object>> exprMaps = (List<Map<String, Object>>) args.get("expressions");
          if (exprMaps == null || exprMaps.size() < 2) {
            throw new IllegalArgumentException("concat requires at least two expressions");
          }
          Expression first = parseExpression(exprMaps.get(0));
          Expression second = parseExpression(exprMaps.get(1));
          if (exprMaps.size() == 2) {
            return Expression.concat(first, second);
          }
          Object[] others = new Object[exprMaps.size() - 2];
          for (int i = 2; i < exprMaps.size(); i++) {
            others[i - 2] = parseExpression(exprMaps.get(i));
          }
          return Expression.concat(first, second, others);
        }
      case "length":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          return Expression.length(parseExpression(exprMap));
        }
      case "to_lower_case":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          return Expression.toLower(parseExpression(exprMap));
        }
      case "to_upper_case":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          return Expression.toUpper(parseExpression(exprMap));
        }
      case "trim":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          return Expression.trim(parseExpression(exprMap));
        }
      case "substring":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          Map<String, Object> startMap = (Map<String, Object>) args.get("start");
          Map<String, Object> endMap = (Map<String, Object>) args.get("end");
          Expression stringExpr = parseExpression(exprMap);
          Expression startExpr = parseExpression(startMap);
          Expression endExpr = parseExpression(endMap);
          // Android uses (stringExpression, index, length). Dart uses (expression, start, end).
          Expression lengthExpr = Expression.subtract(endExpr, startExpr);
          return Expression.substring(stringExpr, startExpr, lengthExpr);
        }
      case "split":
        {
          Map<String, Object> valueMap = (Map<String, Object>) args.get("expression");
          Map<String, Object> delimiterMap = (Map<String, Object>) args.get("delimiter");
          return Expression.split(parseExpression(valueMap), parseExpression(delimiterMap));
        }
      case "join":
        {
          Map<String, Object> arrayMap = (Map<String, Object>) args.get("expression");
          Map<String, Object> delimiterMap = (Map<String, Object>) args.get("delimiter");
          return Expression.join(parseExpression(arrayMap), parseExpression(delimiterMap));
        }
        // Numeric
      case "abs":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          return Expression.abs(parseExpression(exprMap));
        }
      case "negate":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          Expression expr = parseExpression(exprMap);
          return Expression.subtract(Expression.constant(0), expr);
        }
        // Array expressions
      case "array_concat":
        {
          Map<String, Object> firstMap = (Map<String, Object>) args.get("first");
          Map<String, Object> secondMap = (Map<String, Object>) args.get("second");
          return Expression.arrayConcat(parseExpression(firstMap), parseExpression(secondMap));
        }
      case "array_concat_multiple":
        {
          List<Map<String, Object>> arrays = (List<Map<String, Object>>) args.get("arrays");
          if (arrays == null || arrays.size() < 2) {
            throw new IllegalArgumentException(
                "array_concat_multiple requires at least two arrays");
          }
          Expression result =
              Expression.arrayConcat(
                  parseExpression(arrays.get(0)), parseExpression(arrays.get(1)));
          for (int i = 2; i < arrays.size(); i++) {
            result = result.arrayConcat(parseExpression(arrays.get(i)));
          }
          return result;
        }
      case "array_length":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          return Expression.arrayLength(parseExpression(exprMap));
        }
      case "array_reverse":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          return Expression.arrayReverse(parseExpression(exprMap));
        }
      case "array_sum":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          return Expression.arraySum(parseExpression(exprMap));
        }
      case "array_slice":
        throw new UnsupportedOperationException(
            "Expression type 'array_slice' is not supported on Android Firestore pipeline API");
        // Conditional / logic value expressions
      case "if_absent":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          Map<String, Object> elseMap = (Map<String, Object>) args.get("else");
          return Expression.ifAbsent(parseExpression(exprMap), parseExpression(elseMap));
        }
      case "if_error":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          Map<String, Object> catchMap = (Map<String, Object>) args.get("catch");
          return Expression.ifError(parseExpression(exprMap), parseExpression(catchMap));
        }
      case "conditional":
        {
          Map<String, Object> conditionMap = (Map<String, Object>) args.get("condition");
          Map<String, Object> thenMap = (Map<String, Object>) args.get("then");
          Map<String, Object> elseMap = (Map<String, Object>) args.get("else");
          BooleanExpression condition = parseBooleanExpression(conditionMap);
          Expression thenExpr = parseExpression(thenMap);
          Expression elseExpr = parseExpression(elseMap);
          return Expression.conditional(condition, thenExpr, elseExpr);
        }
        // Document / path
      case "document_id":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          return Expression.documentId(parseExpression(exprMap));
        }
      case "document_id_from_ref":
        {
          String path = (String) args.get("doc_ref");
          if (path == null) {
            throw new IllegalArgumentException("document_id_from_ref requires 'doc_ref' argument");
          }
          return Expression.documentId(firestore.document(path));
        }
      case "collection_id":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          return Expression.collectionId(parseExpression(exprMap));
        }
        // Map operations
      case "map_get":
        {
          Map<String, Object> mapMap = (Map<String, Object>) args.get("map");
          Map<String, Object> keyMap = (Map<String, Object>) args.get("key");
          return Expression.mapGet(parseExpression(mapMap), parseExpression(keyMap));
        }
        // Timestamp
      case "current_timestamp":
        return Expression.currentTimestamp();
      case "timestamp_add":
        {
          Map<String, Object> timestampMap = (Map<String, Object>) args.get("timestamp");
          String unit = (String) args.get("unit");
          Map<String, Object> amountMap = (Map<String, Object>) args.get("amount");
          if (unit == null || amountMap == null) {
            throw new IllegalArgumentException("timestamp_add requires 'unit' and 'amount'");
          }
          Expression timestampExpr = parseExpression(timestampMap);
          Expression amountExpr = parseExpression(amountMap);
          return Expression.timestampAdd(timestampExpr, Expression.constant(unit), amountExpr);
        }
      case "timestamp_subtract":
        {
          Map<String, Object> timestampMap = (Map<String, Object>) args.get("timestamp");
          String unit = (String) args.get("unit");
          Map<String, Object> amountMap = (Map<String, Object>) args.get("amount");
          if (unit == null || amountMap == null) {
            throw new IllegalArgumentException("timestamp_subtract requires 'unit' and 'amount'");
          }
          Expression timestampExpr = parseExpression(timestampMap);
          Expression amountExpr = parseExpression(amountMap);
          return Expression.timestampSubtract(timestampExpr, Expression.constant(unit), amountExpr);
        }
      case "timestamp_truncate":
        {
          Map<String, Object> timestampMap = (Map<String, Object>) args.get("timestamp");
          String unit = (String) args.get("unit");
          if (unit == null) {
            throw new IllegalArgumentException("timestamp_truncate requires 'unit'");
          }
          return Expression.timestampTruncate(parseExpression(timestampMap), unit);
        }
        // Array / map literals
      case "array":
        {
          List<?> elements = (List<?>) args.get("elements");
          if (elements == null) {
            throw new IllegalArgumentException("array requires 'elements'");
          }
          Object[] parsed = new Object[elements.size()];
          for (int i = 0; i < elements.size(); i++) {
            Object el = elements.get(i);
            if (el instanceof Map) {
              parsed[i] = parseExpression((Map<String, Object>) el);
            } else {
              parsed[i] = ExpressionHelpers.parseConstantValue(el);
            }
          }
          return Expression.array(Arrays.asList(parsed));
        }
      case "map":
        {
          Map<String, Object> data = (Map<String, Object>) args.get("data");
          if (data == null) {
            throw new IllegalArgumentException("map requires 'data'");
          }
          Map<String, Object> parsed = new HashMap<>();
          for (Map.Entry<String, Object> e : data.entrySet()) {
            Object v = e.getValue();
            if (v instanceof Map) {
              @SuppressWarnings("unchecked")
              Map<String, Object> nested = (Map<String, Object>) v;
              if (nested.containsKey("name") && nested.containsKey("args")) {
                parsed.put(e.getKey(), parseExpression(nested));
              } else {
                parsed.put(e.getKey(), v);
              }
            } else {
              parsed.put(e.getKey(), ExpressionHelpers.parseConstantValue(v));
            }
          }
          return Expression.map(parsed);
        }
        // Bitwise
      case "bit_and":
        return parseBinaryOperation(args, (left, right) -> left.bitAnd(right));
      case "bit_or":
        return parseBinaryOperation(args, (left, right) -> left.bitOr(right));
      case "bit_xor":
        return parseBinaryOperation(args, (left, right) -> left.bitXor(right));
      case "bit_not":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          return parseExpression(exprMap).bitNot();
        }
      case "bit_left_shift":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          Map<String, Object> amountMap = (Map<String, Object>) args.get("amount");
          return parseExpression(exprMap).bitLeftShift(parseExpression(amountMap));
        }
      case "bit_right_shift":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          Map<String, Object> amountMap = (Map<String, Object>) args.get("amount");
          return parseExpression(exprMap).bitRightShift(parseExpression(amountMap));
        }
      default:
        Log.w(TAG, "Unsupported expression type: " + name);
        throw new UnsupportedOperationException("Expression type not yet implemented: " + name);
    }
  }

  /** Helper to parse binary comparison operations (equal, not_equal, greater_than, etc.). */
  @SuppressWarnings("unchecked")
  private BooleanExpression parseBinaryComparison(
      @NonNull Map<String, Object> args, @NonNull BinaryExpressionOp<BooleanExpression> operation) {
    Map<String, Object> leftMap = (Map<String, Object>) args.get("left");
    Map<String, Object> rightMap = (Map<String, Object>) args.get("right");
    Expression left = parseExpression(leftMap);
    Expression right = parseExpression(rightMap);
    return operation.apply(left, right);
  }

  /** Helper to parse binary arithmetic operations (add, subtract, multiply, etc.). */
  @SuppressWarnings("unchecked")
  private Expression parseBinaryOperation(
      @NonNull Map<String, Object> args, @NonNull BinaryExpressionOp<Expression> operation) {
    Map<String, Object> leftMap = (Map<String, Object>) args.get("left");
    Map<String, Object> rightMap = (Map<String, Object>) args.get("right");
    Expression left = parseExpression(leftMap);
    Expression right = parseExpression(rightMap);
    return operation.apply(left, right);
  }

  /**
   * Parses a boolean expression from a map representation. Boolean expressions are used in where
   * clauses and return BooleanExpression.
   */
  @SuppressWarnings("unchecked")
  BooleanExpression parseBooleanExpression(@NonNull Map<String, Object> expressionMap) {
    String name = (String) expressionMap.get("name");
    if (name == null) {
      throw new IllegalArgumentException("BooleanExpression must have a 'name' field");
    }

    Map<String, Object> args = (Map<String, Object>) expressionMap.get("args");
    if (args == null) {
      args = new HashMap<>();
    }

    switch (name) {
        // Comparison operations - these return BooleanExpression
      case "equal":
        return parseBinaryComparison(args, (left, right) -> left.equal(right));
      case "not_equal":
        return parseBinaryComparison(args, (left, right) -> left.notEqual(right));
      case "greater_than":
        return parseBinaryComparison(args, (left, right) -> left.greaterThan(right));
      case "greater_than_or_equal":
        return parseBinaryComparison(args, (left, right) -> left.greaterThanOrEqual(right));
      case "less_than":
        return parseBinaryComparison(args, (left, right) -> left.lessThan(right));
      case "less_than_or_equal":
        return parseBinaryComparison(args, (left, right) -> left.lessThanOrEqual(right));
        // Logical operations - these return BooleanExpression
      case "and":
        {
          List<Map<String, Object>> exprMaps = (List<Map<String, Object>>) args.get("expressions");
          return ExpressionHelpers.parseAndExpression(exprMaps, this);
        }
      case "or":
        {
          List<Map<String, Object>> exprMaps = (List<Map<String, Object>>) args.get("expressions");
          if (exprMaps == null || exprMaps.isEmpty()) {
            throw new IllegalArgumentException("'or' requires at least one expression");
          }
          if (exprMaps.size() == 1) {
            return parseBooleanExpression(exprMaps.get(0));
          }
          // BooleanExpression.or() takes exactly 2 parameters, so we chain them
          BooleanExpression result = parseBooleanExpression(exprMaps.get(0));
          for (int i = 1; i < exprMaps.size(); i++) {
            BooleanExpression next = parseBooleanExpression(exprMaps.get(i));
            result = BooleanExpression.or(result, next);
          }
          return result;
        }
      case "xor":
        {
          List<Map<String, Object>> exprMaps = (List<Map<String, Object>>) args.get("expressions");
          return ExpressionHelpers.parseXorExpression(exprMaps, this);
        }
      case "not":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          BooleanExpression expr = parseBooleanExpression(exprMap);
          return expr.not();
        }
        // Boolean-specific expressions
      case "is_absent":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          Expression expr = parseExpression(exprMap);
          return expr.isAbsent();
        }
      case "is_error":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          Expression expr = parseExpression(exprMap);
          return expr.isError();
        }
      case "exists":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          Expression expr = parseExpression(exprMap);
          return expr.exists();
        }
      case "array_contains":
        {
          Map<String, Object> arrayMap = (Map<String, Object>) args.get("array");
          Map<String, Object> elementMap = (Map<String, Object>) args.get("element");
          Expression array = parseExpression(arrayMap);
          Expression element = parseExpression(elementMap);
          return array.arrayContains(element);
        }
      case "array_contains_all":
        {
          Map<String, Object> arrayMap = (Map<String, Object>) args.get("array");
          Expression array = parseExpression(arrayMap);
          if (args.get("values") != null) {
            List<Map<String, Object>> valuesMaps = (List<Map<String, Object>>) args.get("values");
            Expression[] values = new Expression[valuesMaps.size()];
            for (int i = 0; i < valuesMaps.size(); i++) {
              values[i] = parseExpression(valuesMaps.get(i));
            }
            return array.arrayContainsAll(Arrays.asList(values));
          } else {
            Map<String, Object> arrayExprMap = (Map<String, Object>) args.get("array_expression");
            Expression arrayExpr = parseExpression(arrayExprMap);
            return array.arrayContainsAll(arrayExpr);
          }
        }
      case "array_contains_any":
        {
          Map<String, Object> arrayMap = (Map<String, Object>) args.get("array");
          List<Map<String, Object>> valuesMaps = (List<Map<String, Object>>) args.get("values");
          Expression array = parseExpression(arrayMap);
          Expression[] values = new Expression[valuesMaps.size()];
          for (int i = 0; i < valuesMaps.size(); i++) {
            values[i] = parseExpression(valuesMaps.get(i));
          }
          return array.arrayContainsAny(Arrays.asList(values));
        }
      case "equal_any":
        {
          Map<String, Object> valueMap = (Map<String, Object>) args.get("value");
          List<Map<String, Object>> valuesMaps = (List<Map<String, Object>>) args.get("values");
          Expression value = parseExpression(valueMap);
          Expression[] values = new Expression[valuesMaps.size()];
          for (int i = 0; i < valuesMaps.size(); i++) {
            values[i] = parseExpression(valuesMaps.get(i));
          }
          return value.equalAny(Arrays.asList(values));
        }
      case "not_equal_any":
        {
          Map<String, Object> valueMap = (Map<String, Object>) args.get("value");
          List<Map<String, Object>> valuesMaps = (List<Map<String, Object>>) args.get("values");
          Expression value = parseExpression(valueMap);
          Expression[] values = new Expression[valuesMaps.size()];
          for (int i = 0; i < valuesMaps.size(); i++) {
            values[i] = parseExpression(valuesMaps.get(i));
          }
          return value.notEqualAny(Arrays.asList(values));
        }
      case "as_boolean":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          Expression expr = parseExpression(exprMap);
          return expr.asBoolean();
        }
        // Handle filter expressions (PipelineFilter)
      case "filter":
        return parseFilterExpression(args);
      default:
        // Try parsing as a regular expression first, then cast to BooleanExpression if possible
        Expression expr = parseExpression(expressionMap);
        if (expr instanceof BooleanExpression) {
          return (BooleanExpression) expr;
        }
        Log.w(TAG, "Expression type '" + name + "' is not a BooleanExpression, attempting cast");
        throw new IllegalArgumentException(
            "Expression type '" + name + "' cannot be used as a BooleanExpression");
    }
  }

  /**
   * Parses a filter expression (PipelineFilter) which can have operator-based or field-based forms.
   */
  @SuppressWarnings("unchecked")
  private BooleanExpression parseFilterExpression(@NonNull Map<String, Object> args) {
    // PipelineFilter can have various forms - check for operator-based or field-based
    if (args.containsKey("operator")) {
      String operator = (String) args.get("operator");
      List<Map<String, Object>> exprMaps = (List<Map<String, Object>>) args.get("expressions");
      if ("and".equals(operator)) {
        return ExpressionHelpers.parseAndExpression(exprMaps, this);
      } else if ("or".equals(operator)) {
        if (exprMaps == null || exprMaps.isEmpty()) {
          throw new IllegalArgumentException("'or' requires at least one expression");
        }
        if (exprMaps.size() == 1) {
          return parseBooleanExpression(exprMaps.get(0));
        }
        // BooleanExpression.or() takes exactly 2 parameters, so we chain them
        BooleanExpression result = parseBooleanExpression(exprMaps.get(0));
        for (int i = 1; i < exprMaps.size(); i++) {
          BooleanExpression next = parseBooleanExpression(exprMaps.get(i));
          result = BooleanExpression.or(result, next);
        }
        return result;
      }
    }
    // Field-based filter - parse field and create appropriate comparison
    String fieldName = (String) args.get("field");
    Expression fieldExpr = Expression.field(fieldName);

    return parseFieldBasedFilter(fieldExpr, args);
  }

  /** Parses field-based filter comparisons (isEqualTo, isGreaterThan, etc.). */
  @SuppressWarnings("unchecked")
  private BooleanExpression parseFieldBasedFilter(
      @NonNull Expression fieldExpr, @NonNull Map<String, Object> args) {
    if (args.containsKey("isEqualTo")) {
      Object value = args.get("isEqualTo");
      return value instanceof Map
          ? fieldExpr.equal(parseExpression((Map<String, Object>) value))
          : fieldExpr.equal(value);
    }
    if (args.containsKey("isNotEqualTo")) {
      Object value = args.get("isNotEqualTo");
      return value instanceof Map
          ? fieldExpr.notEqual(parseExpression((Map<String, Object>) value))
          : fieldExpr.notEqual(value);
    }
    if (args.containsKey("isGreaterThan")) {
      Object value = args.get("isGreaterThan");
      return value instanceof Map
          ? fieldExpr.greaterThan(parseExpression((Map<String, Object>) value))
          : fieldExpr.greaterThan(value);
    }
    if (args.containsKey("isGreaterThanOrEqualTo")) {
      Object value = args.get("isGreaterThanOrEqualTo");
      return value instanceof Map
          ? fieldExpr.greaterThanOrEqual(parseExpression((Map<String, Object>) value))
          : fieldExpr.greaterThanOrEqual(value);
    }
    if (args.containsKey("isLessThan")) {
      Object value = args.get("isLessThan");
      return value instanceof Map
          ? fieldExpr.lessThan(parseExpression((Map<String, Object>) value))
          : fieldExpr.lessThan(value);
    }
    if (args.containsKey("isLessThanOrEqualTo")) {
      Object value = args.get("isLessThanOrEqualTo");
      return value instanceof Map
          ? fieldExpr.lessThanOrEqual(parseExpression((Map<String, Object>) value))
          : fieldExpr.lessThanOrEqual(value);
    }
    if (args.containsKey("arrayContains")) {
      Object value = args.get("arrayContains");
      return value instanceof Map
          ? fieldExpr.arrayContains(parseExpression((Map<String, Object>) value))
          : fieldExpr.arrayContains(value);
    }
    throw new IllegalArgumentException("Unsupported filter expression format");
  }

  /**
   * Parses a Selectable from a map representation. Selectables are Field or AliasedExpression
   * types.
   */
  @SuppressWarnings("unchecked")
  Selectable parseSelectable(@NonNull Map<String, Object> expressionMap) {
    Expression expr = parseExpression(expressionMap);
    if (!(expr instanceof Selectable)) {
      throw new IllegalArgumentException(
          "Expression must be a Selectable (Field or AliasedExpression). Got: "
              + expressionMap.get("name"));
    }
    return (Selectable) expr;
  }

  /** Parses an aggregate function from a map representation. */
  @SuppressWarnings("unchecked")
  AggregateFunction parseAggregateFunction(@NonNull Map<String, Object> aggregateMap) {
    String functionName = (String) aggregateMap.get("function");
    if (functionName == null) {
      // Try "name" as fallback
      functionName = (String) aggregateMap.get("name");
    }
    Map<String, Object> args = (Map<String, Object>) aggregateMap.get("args");
    Map<String, Object> exprMap;
    Expression expr = null;
    if (args != null) {
      exprMap = (Map<String, Object>) args.get("expression");
      expr = parseExpression(exprMap);
    }

    switch (functionName) {
      case "sum":
        return AggregateFunction.sum(expr);
      case "average":
        return AggregateFunction.average(expr);
      case "count":
        return AggregateFunction.count(expr);
      case "count_distinct":
        return AggregateFunction.countDistinct(expr);
      case "minimum":
        return AggregateFunction.minimum(expr);
      case "maximum":
        return AggregateFunction.maximum(expr);
      case "count_all":
        return AggregateFunction.countAll();
      default:
        throw new IllegalArgumentException("Unknown aggregate function: " + functionName);
    }
  }

  /**
   * Parses an AliasedAggregate from a Dart AliasedAggregateFunction map representation. Since Dart
   * API only accepts AliasedAggregateFunction, we can directly construct AliasedAggregate.
   */
  @SuppressWarnings("unchecked")
  AliasedAggregate parseAliasedAggregate(@NonNull Map<String, Object> aggregateMap) {
    // Check if this is an aliased aggregate function (Dart AliasedAggregateFunction format)
    String name = (String) aggregateMap.get("name");
    if ("alias".equals(name)) {
      Map<String, Object> args = (Map<String, Object>) aggregateMap.get("args");
      String alias = (String) args.get("alias");
      Map<String, Object> aggregateFunctionMap =
          (Map<String, Object>) args.get("aggregate_function");

      // Parse the underlying aggregate function
      AggregateFunction function = parseAggregateFunction(aggregateFunctionMap);

      // Apply the alias to get AliasedAggregate
      return function.alias(alias);
    }

    // If not in alias format, it might be a direct aggregate function with alias field
    // This shouldn't happen with the new Dart API, but handle for backward compatibility
    String alias = (String) aggregateMap.get("alias");
    if (alias != null) {
      AggregateFunction function = parseAggregateFunction(aggregateMap);
      return function.alias(alias);
    }

    throw new IllegalArgumentException(
        "Aggregate function must have an alias. Expected AliasedAggregateFunction format.");
  }

  /** Parses an AggregateStage from a map representation. */
  @SuppressWarnings("unchecked")
  AggregateStage parseAggregateStage(@NonNull Map<String, Object> stageMap) {
    // Parse accumulators (required)
    List<Map<String, Object>> accumulatorMaps =
        (List<Map<String, Object>>) stageMap.get("accumulators");
    if (accumulatorMaps == null || accumulatorMaps.isEmpty()) {
      throw new IllegalArgumentException("AggregateStage must have at least one accumulator");
    }

    // Parse accumulators as AliasedAggregate
    AliasedAggregate[] accumulators = new AliasedAggregate[accumulatorMaps.size()];
    for (int i = 0; i < accumulatorMaps.size(); i++) {
      accumulators[i] = parseAliasedAggregate(accumulatorMaps.get(i));
    }

    // Build AggregateStage with accumulators
    AggregateStage aggregateStage;
    if (accumulators.length == 1) {
      aggregateStage = AggregateStage.withAccumulators(accumulators[0]);
    } else {
      AliasedAggregate[] rest = new AliasedAggregate[accumulators.length - 1];
      System.arraycopy(accumulators, 1, rest, 0, rest.length);
      aggregateStage = AggregateStage.withAccumulators(accumulators[0], rest);
    }

    // Parse optional groups and add them using withGroups()
    // withGroups(group: Selectable, vararg additionalGroups: Any)
    List<Map<String, Object>> groupMaps = (List<Map<String, Object>>) stageMap.get("groups");
    if (groupMaps != null && !groupMaps.isEmpty()) {
      // Parse first group as Selectable (required)
      Selectable firstGroup = parseSelectable(groupMaps.get(0));

      if (groupMaps.size() == 1) {
        // Only one group
        aggregateStage = aggregateStage.withGroups(firstGroup);
      } else {
        // Multiple groups - parse remaining as Any[] (varargs)
        Object[] additionalGroups = new Object[groupMaps.size() - 1];
        for (int i = 1; i < groupMaps.size(); i++) {
          // Parse as Expression first, then convert to Object (can be Selectable or Any)
          Expression expr = parseExpression(groupMaps.get(i));
          additionalGroups[i - 1] = expr;
        }
        aggregateStage = aggregateStage.withGroups(firstGroup, additionalGroups);
      }
    }

    return aggregateStage;
  }

  /** Parses AggregateOptions from a map representation. */
  @SuppressWarnings("unchecked")
  AggregateOptions parseAggregateOptions(@NonNull Map<String, Object> optionsMap) {
    // For now, AggregateOptions is empty, but this method is ready for future options
    return new AggregateOptions();
  }

  /**
   * Converts a Dart DistanceMeasure enum name to Android FindNearestStage.DistanceMeasure enum.
   * Dart enum values: cosine, euclidean, dotProduct Android enum values: COSINE, EUCLIDEAN,
   * DOT_PRODUCT
   */
  FindNearestStage.DistanceMeasure parseDistanceMeasure(@NonNull String dartEnumName) {
    switch (dartEnumName) {
      case "cosine":
        return FindNearestStage.DistanceMeasure.COSINE;
      case "euclidean":
        return FindNearestStage.DistanceMeasure.EUCLIDEAN;
      case "dotProduct":
        return FindNearestStage.DistanceMeasure.DOT_PRODUCT;
      default:
        throw new IllegalArgumentException(
            "Unknown distance measure: "
                + dartEnumName
                + ". Expected: cosine, euclidean, or dotProduct");
    }
  }
}
