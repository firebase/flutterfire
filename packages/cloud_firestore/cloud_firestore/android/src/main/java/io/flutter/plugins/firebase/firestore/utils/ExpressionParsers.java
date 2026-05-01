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

/**
 * Parses Dart pipeline expression maps into Android {@link Expression} / {@link BooleanExpression}
 * types. {@link #parseBooleanExpression}'s default delegates to {@link #parseExpression} when the
 * name is a value expression that yields a boolean (e.g. aliased comparisons).
 */
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

  @SuppressWarnings("unchecked")
  private static Map<String, Object> argsOf(@NonNull Map<String, Object> expressionMap) {
    Map<String, Object> args = (Map<String, Object>) expressionMap.get("args");
    return args != null ? args : new HashMap<>();
  }

  @SuppressWarnings("unchecked")
  private Expression parseChild(@NonNull Map<String, Object> args, @NonNull String key) {
    return parseExpression((Map<String, Object>) args.get(key));
  }

  /** Parses a list of nested expression maps (e.g. {@code values}) to {@link Expression}s. */
  private List<Expression> parseExpressionMaps(@NonNull List<Map<String, Object>> maps) {
    Expression[] out = new Expression[maps.size()];
    for (int i = 0; i < maps.size(); i++) {
      out[i] = parseExpression(maps.get(i));
    }
    return Arrays.asList(out);
  }

  private BooleanExpression parseBinaryComparisonNamed(
      @NonNull String name, @NonNull Map<String, Object> args) {
    switch (name) {
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
      default:
        throw new IllegalArgumentException("Not a binary comparison expression: " + name);
    }
  }

  @SuppressWarnings("unchecked")
  private BooleanExpression parseEqualAny(@NonNull Map<String, Object> args) {
    Map<String, Object> valueMap = (Map<String, Object>) args.get("value");
    List<Map<String, Object>> valuesMaps = (List<Map<String, Object>>) args.get("values");
    Expression value = parseExpression(valueMap);
    return value.equalAny(parseExpressionMaps(valuesMaps));
  }

  @SuppressWarnings("unchecked")
  private BooleanExpression parseNotEqualAny(@NonNull Map<String, Object> args) {
    Map<String, Object> valueMap = (Map<String, Object>) args.get("value");
    List<Map<String, Object>> valuesMaps = (List<Map<String, Object>>) args.get("values");
    Expression value = parseExpression(valueMap);
    return value.notEqualAny(parseExpressionMaps(valuesMaps));
  }

  @SuppressWarnings("unchecked")
  private BooleanExpression parseArrayContainsElement(@NonNull Map<String, Object> args) {
    Map<String, Object> arrayMap = (Map<String, Object>) args.get("array");
    Map<String, Object> elementMap = (Map<String, Object>) args.get("element");
    Expression array = parseExpression(arrayMap);
    Expression element = parseExpression(elementMap);
    return array.arrayContains(element);
  }

  /** Parses an expression from a map representation. */
  @SuppressWarnings("unchecked")
  Expression parseExpression(@NonNull Map<String, Object> expressionMap) {
    String name = (String) expressionMap.get("name");
    if (name == null) {
      if (expressionMap.containsKey("field_name")) {
        String fieldName = (String) expressionMap.get("field_name");
        return Expression.field(fieldName);
      }
      Map<String, Object> argsCheck = (Map<String, Object>) expressionMap.get("args");
      if (argsCheck != null && argsCheck.containsKey("field")) {
        String fieldName = (String) argsCheck.get("field");
        return Expression.field(fieldName);
      }
      throw new IllegalArgumentException("Expression must have a 'name' field");
    }

    Map<String, Object> args = argsOf(expressionMap);

    switch (name) {
      case "null":
        return Expression.nullValue();
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
      case "equal":
      case "not_equal":
      case "greater_than":
      case "greater_than_or_equal":
      case "less_than":
      case "less_than_or_equal":
        return parseBinaryComparisonNamed(name, args);
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
      case "nor":
        {
          List<Map<String, Object>> exprMaps = (List<Map<String, Object>>) args.get("expressions");
          return ExpressionHelpers.parseNorExpression(exprMaps, this);
        }
      case "not":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          BooleanExpression expr = parseBooleanExpression(exprMap);
          return Expression.not(expr);
        }
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
        return Expression.length(parseChild(args, "expression"));
      case "to_lower_case":
        return Expression.toLower(parseChild(args, "expression"));
      case "to_upper_case":
        return Expression.toUpper(parseChild(args, "expression"));
      case "trim":
        return Expression.trim(parseChild(args, "expression"));
      case "substring":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          Map<String, Object> startMap = (Map<String, Object>) args.get("start");
          Map<String, Object> endMap = (Map<String, Object>) args.get("end");
          Expression stringExpr = parseExpression(exprMap);
          Expression startExpr = parseExpression(startMap);
          Expression endExpr = parseExpression(endMap);
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
      case "abs":
        return Expression.abs(parseChild(args, "expression"));
      case "negate":
        {
          Expression expr = parseChild(args, "expression");
          return Expression.subtract(Expression.constant(0), expr);
        }
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
        return Expression.arrayLength(parseChild(args, "expression"));
      case "array_reverse":
        return Expression.arrayReverse(parseChild(args, "expression"));
      case "array_sum":
        return Expression.arraySum(parseChild(args, "expression"));
      case "array_slice":
        throw new UnsupportedOperationException(
            "Expression type 'array_slice' is not supported on Android Firestore pipeline API");
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
      case "document_id":
        return Expression.documentId(parseChild(args, "expression"));
      case "document_id_from_ref":
        {
          String path = (String) args.get("doc_ref");
          if (path == null) {
            throw new IllegalArgumentException("document_id_from_ref requires 'doc_ref' argument");
          }
          return Expression.documentId(firestore.document(path));
        }
      case "collection_id":
        return Expression.collectionId(parseChild(args, "expression"));
      case "map_get":
        {
          Map<String, Object> mapMap = (Map<String, Object>) args.get("map");
          Map<String, Object> keyMap = (Map<String, Object>) args.get("key");
          return Expression.mapGet(parseExpression(mapMap), parseExpression(keyMap));
        }
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
      case "timestamp_diff":
        {
          Map<String, Object> endMap = (Map<String, Object>) args.get("end");
          Map<String, Object> startMap = (Map<String, Object>) args.get("start");
          Object unitObj = args.get("unit");
          Expression endExpr = parseExpression(endMap);
          Expression startExpr = parseExpression(startMap);
          if (unitObj instanceof String) {
            return Expression.timestampDiff(endExpr, startExpr, (String) unitObj);
          }
          @SuppressWarnings("unchecked")
          Map<String, Object> unitMap = (Map<String, Object>) unitObj;
          return Expression.timestampDiff(endExpr, startExpr, parseExpression(unitMap));
        }
      case "timestamp_extract":
        {
          Map<String, Object> timestampMap = (Map<String, Object>) args.get("timestamp");
          Map<String, Object> partMap = (Map<String, Object>) args.get("part");
          Expression tsExpr = parseExpression(timestampMap);
          Expression partExpr = parseExpression(partMap);
          if (!args.containsKey("timezone") || args.get("timezone") == null) {
            return Expression.timestampExtract(tsExpr, partExpr);
          }
          Object tzObj = args.get("timezone");
          if (tzObj instanceof String) {
            return Expression.timestampExtractWithTimezone(tsExpr, partExpr, (String) tzObj);
          }
          @SuppressWarnings("unchecked")
          Map<String, Object> tzMap = (Map<String, Object>) tzObj;
          return Expression.timestampExtractWithTimezone(tsExpr, partExpr, parseExpression(tzMap));
        }
      case "parent":
        {
          if (args.containsKey("doc_ref")) {
            String path = (String) args.get("doc_ref");
            if (path == null) {
              throw new IllegalArgumentException("parent requires 'doc_ref' argument");
            }
            return Expression.parent(firestore.document(path));
          }
          return Expression.parent(parseChild(args, "expression"));
        }
      case "if_null":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          Map<String, Object> replacementMap = (Map<String, Object>) args.get("replacement");
          return Expression.ifNull(parseExpression(exprMap), parseExpression(replacementMap));
        }
      case "coalesce":
        {
          List<Map<String, Object>> exprMaps = (List<Map<String, Object>>) args.get("expressions");
          return ExpressionHelpers.parseCoalesceExpression(exprMaps, this);
        }
      case "switch_on":
        {
          List<Map<String, Object>> exprMaps = (List<Map<String, Object>>) args.get("expressions");
          return ExpressionHelpers.parseSwitchOnExpression(exprMaps, this);
        }
      case "map_keys":
        return Expression.mapKeys(parseChild(args, "expression"));
      case "map_values":
        return Expression.mapValues(parseChild(args, "expression"));
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
      case "bit_and":
        return parseBinaryOperation(args, (left, right) -> left.bitAnd(right));
      case "bit_or":
        return parseBinaryOperation(args, (left, right) -> left.bitOr(right));
      case "bit_xor":
        return parseBinaryOperation(args, (left, right) -> left.bitXor(right));
      case "bit_not":
        return parseChild(args, "expression").bitNot();
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
      case "is_absent":
        return parseIsAbsent(args);
      case "is_error":
        return parseIsError(args);
      case "exists":
        return parseExists(args);
      case "as_boolean":
        return parseAsBoolean(args);
      case "array_contains_all":
        return parseArrayContainsAll(args);
      case "array_contains_any":
        return parseArrayContainsAny(args);
      default:
        Log.w(TAG, "Unsupported expression type: " + name);
        throw new UnsupportedOperationException("Expression type not yet implemented: " + name);
    }
  }

  @SuppressWarnings("unchecked")
  private BooleanExpression parseBinaryComparison(
      @NonNull Map<String, Object> args, @NonNull BinaryExpressionOp<BooleanExpression> operation) {
    Map<String, Object> leftMap = (Map<String, Object>) args.get("left");
    Map<String, Object> rightMap = (Map<String, Object>) args.get("right");
    Expression left = parseExpression(leftMap);
    Expression right = parseExpression(rightMap);
    return operation.apply(left, right);
  }

  @SuppressWarnings("unchecked")
  private Expression parseBinaryOperation(
      @NonNull Map<String, Object> args, @NonNull BinaryExpressionOp<Expression> operation) {
    Map<String, Object> leftMap = (Map<String, Object>) args.get("left");
    Map<String, Object> rightMap = (Map<String, Object>) args.get("right");
    Expression left = parseExpression(leftMap);
    Expression right = parseExpression(rightMap);
    return operation.apply(left, right);
  }

  private BooleanExpression parseIsAbsent(@NonNull Map<String, Object> args) {
    return parseChild(args, "expression").isAbsent();
  }

  private BooleanExpression parseIsError(@NonNull Map<String, Object> args) {
    return parseChild(args, "expression").isError();
  }

  private BooleanExpression parseExists(@NonNull Map<String, Object> args) {
    return parseChild(args, "expression").exists();
  }

  private BooleanExpression parseAsBoolean(@NonNull Map<String, Object> args) {
    return parseChild(args, "expression").asBoolean();
  }

  @SuppressWarnings("unchecked")
  private BooleanExpression parseArrayContainsAll(@NonNull Map<String, Object> args) {
    Map<String, Object> arrayMap = (Map<String, Object>) args.get("array");
    Expression array = parseExpression(arrayMap);
    if (args.get("values") != null) {
      List<Map<String, Object>> valuesMaps = (List<Map<String, Object>>) args.get("values");
      return array.arrayContainsAll(parseExpressionMaps(valuesMaps));
    }
    Map<String, Object> arrayExprMap = (Map<String, Object>) args.get("array_expression");
    Expression arrayExpr = parseExpression(arrayExprMap);
    return array.arrayContainsAll(arrayExpr);
  }

  @SuppressWarnings("unchecked")
  private BooleanExpression parseArrayContainsAny(@NonNull Map<String, Object> args) {
    Map<String, Object> arrayMap = (Map<String, Object>) args.get("array");
    List<Map<String, Object>> valuesMaps = (List<Map<String, Object>>) args.get("values");
    Expression array = parseExpression(arrayMap);
    return array.arrayContainsAny(parseExpressionMaps(valuesMaps));
  }

  @SuppressWarnings("unchecked")
  BooleanExpression parseBooleanExpression(@NonNull Map<String, Object> expressionMap) {
    String name = (String) expressionMap.get("name");
    if (name == null) {
      throw new IllegalArgumentException("BooleanExpression must have a 'name' field");
    }

    Map<String, Object> args = argsOf(expressionMap);

    switch (name) {
      case "equal":
      case "not_equal":
      case "greater_than":
      case "greater_than_or_equal":
      case "less_than":
      case "less_than_or_equal":
        return parseBinaryComparisonNamed(name, args);
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
      case "nor":
        {
          List<Map<String, Object>> exprMaps = (List<Map<String, Object>>) args.get("expressions");
          return ExpressionHelpers.parseNorExpression(exprMaps, this);
        }
      case "not":
        {
          Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
          BooleanExpression expr = parseBooleanExpression(exprMap);
          return expr.not();
        }
      case "is_absent":
        return parseIsAbsent(args);
      case "is_error":
        return parseIsError(args);
      case "exists":
        return parseExists(args);
      case "array_contains":
        return parseArrayContainsElement(args);
      case "array_contains_all":
        return parseArrayContainsAll(args);
      case "array_contains_any":
        return parseArrayContainsAny(args);
      case "equal_any":
        return parseEqualAny(args);
      case "not_equal_any":
        return parseNotEqualAny(args);
      case "as_boolean":
        return parseAsBoolean(args);
      default:
        Expression expr = parseExpression(expressionMap);
        if (expr instanceof BooleanExpression) {
          return (BooleanExpression) expr;
        }
        Log.w(TAG, "Expression type '" + name + "' is not a BooleanExpression, attempting cast");
        throw new IllegalArgumentException(
            "Expression type '" + name + "' cannot be used as a BooleanExpression");
    }
  }

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

  @SuppressWarnings("unchecked")
  AggregateFunction parseAggregateFunction(@NonNull Map<String, Object> aggregateMap) {
    String functionName = (String) aggregateMap.get("function");
    if (functionName == null) {
      functionName = (String) aggregateMap.get("name");
    }
    Map<String, Object> args = (Map<String, Object>) aggregateMap.get("args");
    Expression expr = null;
    if (args != null) {
      Map<String, Object> exprMap = (Map<String, Object>) args.get("expression");
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

  @SuppressWarnings("unchecked")
  AliasedAggregate parseAliasedAggregate(@NonNull Map<String, Object> aggregateMap) {
    String name = (String) aggregateMap.get("name");
    if ("alias".equals(name)) {
      Map<String, Object> args = (Map<String, Object>) aggregateMap.get("args");
      String alias = (String) args.get("alias");
      Map<String, Object> aggregateFunctionMap =
          (Map<String, Object>) args.get("aggregate_function");

      AggregateFunction function = parseAggregateFunction(aggregateFunctionMap);
      return function.alias(alias);
    }

    String alias = (String) aggregateMap.get("alias");
    if (alias != null) {
      AggregateFunction function = parseAggregateFunction(aggregateMap);
      return function.alias(alias);
    }

    throw new IllegalArgumentException(
        "Aggregate function must have an alias. Expected AliasedAggregateFunction format.");
  }

  @SuppressWarnings("unchecked")
  AggregateStage parseAggregateStage(@NonNull Map<String, Object> stageMap) {
    List<Map<String, Object>> accumulatorMaps =
        (List<Map<String, Object>>) stageMap.get("accumulators");
    if (accumulatorMaps == null || accumulatorMaps.isEmpty()) {
      throw new IllegalArgumentException("AggregateStage must have at least one accumulator");
    }

    AliasedAggregate[] accumulators = new AliasedAggregate[accumulatorMaps.size()];
    for (int i = 0; i < accumulatorMaps.size(); i++) {
      accumulators[i] = parseAliasedAggregate(accumulatorMaps.get(i));
    }

    AggregateStage aggregateStage;
    if (accumulators.length == 1) {
      aggregateStage = AggregateStage.withAccumulators(accumulators[0]);
    } else {
      AliasedAggregate[] rest = new AliasedAggregate[accumulators.length - 1];
      System.arraycopy(accumulators, 1, rest, 0, rest.length);
      aggregateStage = AggregateStage.withAccumulators(accumulators[0], rest);
    }

    List<Map<String, Object>> groupMaps = (List<Map<String, Object>>) stageMap.get("groups");
    if (groupMaps != null && !groupMaps.isEmpty()) {
      Selectable firstGroup = parseSelectable(groupMaps.get(0));

      if (groupMaps.size() == 1) {
        aggregateStage = aggregateStage.withGroups(firstGroup);
      } else {
        Object[] additionalGroups = new Object[groupMaps.size() - 1];
        for (int i = 1; i < groupMaps.size(); i++) {
          Expression groupExpr = parseExpression(groupMaps.get(i));
          additionalGroups[i - 1] = groupExpr;
        }
        aggregateStage = aggregateStage.withGroups(firstGroup, additionalGroups);
      }
    }

    return aggregateStage;
  }

  AggregateOptions parseAggregateOptions(@NonNull Map<String, Object> optionsMap) {
    return new AggregateOptions();
  }

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
