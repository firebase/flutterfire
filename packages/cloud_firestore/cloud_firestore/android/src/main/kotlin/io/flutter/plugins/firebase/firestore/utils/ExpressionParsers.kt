/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils

import android.util.Log
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.pipeline.AggregateFunction
import com.google.firebase.firestore.pipeline.AggregateOptions
import com.google.firebase.firestore.pipeline.AggregateStage
import com.google.firebase.firestore.pipeline.AliasedAggregate
import com.google.firebase.firestore.pipeline.BooleanExpression
import com.google.firebase.firestore.pipeline.Expression
import com.google.firebase.firestore.pipeline.FindNearestStage
import com.google.firebase.firestore.pipeline.Selectable

/**
 * Parses Dart pipeline expression maps into Android [Expression] / [BooleanExpression] types.
 * [parseBooleanExpression]'s default delegates to [parseExpression] when the name is a value
 * expression that yields a boolean (e.g. aliased comparisons).
 */
internal class ExpressionParsers(private val firestore: FirebaseFirestore) {
  private fun interface BinaryExpressionOp<R> {
    fun apply(left: Expression, right: Expression): R
  }

  @Suppress("UNCHECKED_CAST")
  private fun argsOf(expressionMap: Map<String, Any>): Map<String, Any> {
    return (expressionMap["args"] as Map<String, Any>?) ?: HashMap()
  }

  @Suppress("UNCHECKED_CAST")
  private fun parseChild(args: Map<String, Any>, key: String): Expression {
    return parseExpression(args[key] as Map<String, Any>)
  }

  private fun parseExpressionMaps(maps: List<Map<String, Any>>): List<Expression> {
    return maps.map { parseExpression(it) }
  }

  private fun parseBinaryComparisonNamed(name: String, args: Map<String, Any>): BooleanExpression {
    return when (name) {
      "equal" -> parseBinaryComparison(args) { left, right -> left.equal(right) }
      "not_equal" -> parseBinaryComparison(args) { left, right -> left.notEqual(right) }
      "greater_than" -> parseBinaryComparison(args) { left, right -> left.greaterThan(right) }
      "greater_than_or_equal" ->
          parseBinaryComparison(args) { left, right -> left.greaterThanOrEqual(right) }
      "less_than" -> parseBinaryComparison(args) { left, right -> left.lessThan(right) }
      "less_than_or_equal" ->
          parseBinaryComparison(args) { left, right -> left.lessThanOrEqual(right) }
      else -> throw IllegalArgumentException("Not a binary comparison expression: $name")
    }
  }

  @Suppress("UNCHECKED_CAST")
  private fun parseEqualAny(args: Map<String, Any>): BooleanExpression {
    val valueMap = args["value"] as Map<String, Any>
    val valuesMaps = args["values"] as List<Map<String, Any>>
    val value = parseExpression(valueMap)
    return value.equalAny(parseExpressionMaps(valuesMaps))
  }

  @Suppress("UNCHECKED_CAST")
  private fun parseNotEqualAny(args: Map<String, Any>): BooleanExpression {
    val valueMap = args["value"] as Map<String, Any>
    val valuesMaps = args["values"] as List<Map<String, Any>>
    val value = parseExpression(valueMap)
    return value.notEqualAny(parseExpressionMaps(valuesMaps))
  }

  @Suppress("UNCHECKED_CAST")
  private fun parseArrayContainsElement(args: Map<String, Any>): BooleanExpression {
    val arrayMap = args["array"] as Map<String, Any>
    val elementMap = args["element"] as Map<String, Any>
    val array = parseExpression(arrayMap)
    val element = parseExpression(elementMap)
    return array.arrayContains(element)
  }

  @Suppress("UNCHECKED_CAST")
  fun parseExpression(expressionMap: Map<String, Any>): Expression {
    var name = expressionMap["name"] as String?
    if (name == null) {
      if (expressionMap.containsKey("field_name")) {
        val fieldName = expressionMap["field_name"] as String
        return Expression.field(fieldName)
      }
      val argsCheck = expressionMap["args"] as Map<String, Any>?
      if (argsCheck != null && argsCheck.containsKey("field")) {
        val fieldName = argsCheck["field"] as String
        return Expression.field(fieldName)
      }
      throw IllegalArgumentException("Expression must have a 'name' field")
    }

    val args = argsOf(expressionMap)
    return when (name) {
      "null" -> Expression.nullValue()
      "field" -> {
        val fieldName =
            args["field"] as String?
                ?: throw IllegalArgumentException("Field expression must have a 'field' argument")
        Expression.field(fieldName)
      }
      "constant" -> {
        val value = args["value"]
        if (value is Map<*, *>) {
          val path = (value as Map<String, Any>)["path"] as String
          Expression.constant(firestore.document(path))
        } else {
          ExpressionHelpers.parseConstantValue(value)
        }
      }
      "alias" -> {
        val exprMap = args["expression"] as Map<String, Any>
        val alias = args["alias"] as String
        parseExpression(exprMap).alias(alias)
      }
      "equal",
      "not_equal",
      "greater_than",
      "greater_than_or_equal",
      "less_than",
      "less_than_or_equal" -> parseBinaryComparisonNamed(name, args)
      "add" -> parseBinaryOperation(args) { left, right -> left.add(right) }
      "subtract" -> parseBinaryOperation(args) { left, right -> left.subtract(right) }
      "multiply" -> parseBinaryOperation(args) { left, right -> left.multiply(right) }
      "divide" -> parseBinaryOperation(args) { left, right -> left.divide(right) }
      "modulo" -> parseBinaryOperation(args) { left, right -> left.mod(right) }
      "and" ->
          ExpressionHelpers.parseAndExpression(args["expressions"] as List<Map<String, Any>>, this)
      "or" ->
          ExpressionHelpers.parseOrExpression(args["expressions"] as List<Map<String, Any>>, this)
      "xor" ->
          ExpressionHelpers.parseXorExpression(args["expressions"] as List<Map<String, Any>>, this)
      "nor" ->
          ExpressionHelpers.parseNorExpression(args["expressions"] as List<Map<String, Any>>, this)
      "not" -> Expression.not(parseBooleanExpression(args["expression"] as Map<String, Any>))
      "concat" -> {
        val exprMaps = args["expressions"] as List<Map<String, Any>>?
        require(exprMaps != null && exprMaps.size >= 2) {
          "concat requires at least two expressions"
        }
        val first = parseExpression(exprMaps[0])
        val second = parseExpression(exprMaps[1])
        if (exprMaps.size == 2) {
          Expression.concat(first, second)
        } else {
          val others = Array<Any>(exprMaps.size - 2) { i -> parseExpression(exprMaps[i + 2]) }
          Expression.concat(first, second, *others)
        }
      }
      "length" -> Expression.length(parseChild(args, "expression"))
      "to_lower_case" -> Expression.toLower(parseChild(args, "expression"))
      "to_upper_case" -> Expression.toUpper(parseChild(args, "expression"))
      "trim" -> Expression.trim(parseChild(args, "expression"))
      "substring" -> {
        val stringExpr = parseExpression(args["expression"] as Map<String, Any>)
        val startExpr = parseExpression(args["start"] as Map<String, Any>)
        val endExpr = parseExpression(args["end"] as Map<String, Any>)
        val lengthExpr = Expression.subtract(endExpr, startExpr)
        Expression.substring(stringExpr, startExpr, lengthExpr)
      }
      "split" ->
          Expression.split(
              parseExpression(args["expression"] as Map<String, Any>),
              parseExpression(args["delimiter"] as Map<String, Any>))
      "join" ->
          Expression.join(
              parseExpression(args["expression"] as Map<String, Any>),
              parseExpression(args["delimiter"] as Map<String, Any>))
      "string_index_of" -> parseChild(args, "expression").stringIndexOf(parseChild(args, "search"))
      "string_repeat" ->
          parseChild(args, "expression").stringRepeat(parseChild(args, "repetitions"))
      "string_replace_one" ->
          parseChild(args, "expression")
              .stringReplaceOne(parseChild(args, "find"), parseChild(args, "replacement"))
      "string_replace_all" ->
          parseChild(args, "expression")
              .stringReplaceAll(parseChild(args, "find"), parseChild(args, "replacement"))
      "ltrim" -> {
        val expression = parseChild(args, "expression")
        val valueMap = args["value"] as Map<String, Any>?
        if (valueMap == null) expression.ltrim()
        else expression.ltrimValue(parseExpression(valueMap))
      }
      "rtrim" -> {
        val expression = parseChild(args, "expression")
        val valueMap = args["value"] as Map<String, Any>?
        if (valueMap == null) expression.rtrim()
        else expression.rtrimValue(parseExpression(valueMap))
      }
      "abs" -> Expression.abs(parseChild(args, "expression"))
      "negate" -> Expression.subtract(Expression.constant(0), parseChild(args, "expression"))
      "array_concat" ->
          Expression.arrayConcat(
              parseExpression(args["first"] as Map<String, Any>),
              parseExpression(args["second"] as Map<String, Any>))
      "array_concat_multiple" -> {
        val arrays = args["arrays"] as List<Map<String, Any>>?
        require(arrays != null && arrays.size >= 2) {
          "array_concat_multiple requires at least two arrays"
        }
        var result = Expression.arrayConcat(parseExpression(arrays[0]), parseExpression(arrays[1]))
        for (i in 2 until arrays.size) {
          result = result.arrayConcat(parseExpression(arrays[i]))
        }
        result
      }
      "array_length" -> Expression.arrayLength(parseChild(args, "expression"))
      "array_reverse" -> Expression.arrayReverse(parseChild(args, "expression"))
      "array_sum" -> Expression.arraySum(parseChild(args, "expression"))
      "array_slice" -> {
        val array = parseChild(args, "expression")
        val offset = parseChild(args, "offset")
        val lengthMap = args["length"] as Map<String, Any>?
        if (lengthMap == null) array.arraySliceToEnd(offset)
        else array.arraySlice(offset, parseExpression(lengthMap))
      }
      "array_filter" -> {
        val array = parseChild(args, "expression")
        val alias = args["alias"] as String?
        val filterMap = args["filter"] as Map<String, Any>?
        require(alias != null && filterMap != null) { "array_filter requires alias and filter" }
        array.arrayFilter(alias, parseBooleanExpression(filterMap))
      }
      "array_transform" -> {
        val array = parseChild(args, "expression")
        val elementAlias = args["element_alias"] as String?
        val transformMap = args["transform"] as Map<String, Any>?
        require(elementAlias != null && transformMap != null) {
          "array_transform requires element_alias and transform"
        }
        array.arrayTransform(elementAlias, parseExpression(transformMap))
      }
      "array_transform_with_index" -> {
        val array = parseChild(args, "expression")
        val elementAlias = args["element_alias"] as String?
        val indexAlias = args["index_alias"] as String?
        val transformMap = args["transform"] as Map<String, Any>?
        require(elementAlias != null && indexAlias != null && transformMap != null) {
          "array_transform_with_index requires element_alias, index_alias, and transform"
        }
        array.arrayTransformWithIndex(elementAlias, indexAlias, parseExpression(transformMap))
      }
      "if_absent" ->
          Expression.ifAbsent(
              parseExpression(args["expression"] as Map<String, Any>),
              parseExpression(args["else"] as Map<String, Any>))
      "if_error" ->
          Expression.ifError(
              parseExpression(args["expression"] as Map<String, Any>),
              parseExpression(args["catch"] as Map<String, Any>))
      "conditional" ->
          Expression.conditional(
              parseBooleanExpression(args["condition"] as Map<String, Any>),
              parseExpression(args["then"] as Map<String, Any>),
              parseExpression(args["else"] as Map<String, Any>))
      "document_id" -> Expression.documentId(parseChild(args, "expression"))
      "document_id_from_ref" -> {
        val path =
            args["doc_ref"] as String?
                ?: throw IllegalArgumentException(
                    "document_id_from_ref requires 'doc_ref' argument")
        Expression.documentId(firestore.document(path))
      }
      "collection_id" -> Expression.collectionId(parseChild(args, "expression"))
      "map_get" ->
          Expression.mapGet(
              parseExpression(args["map"] as Map<String, Any>),
              parseExpression(args["key"] as Map<String, Any>))
      "current_timestamp" -> Expression.currentTimestamp()
      "timestamp_add" -> {
        val unit = args["unit"] as String?
        val amountMap = args["amount"] as Map<String, Any>?
        require(unit != null && amountMap != null) { "timestamp_add requires 'unit' and 'amount'" }
        Expression.timestampAdd(
            parseExpression(args["timestamp"] as Map<String, Any>),
            Expression.constant(unit),
            parseExpression(amountMap))
      }
      "timestamp_subtract" -> {
        val unit = args["unit"] as String?
        val amountMap = args["amount"] as Map<String, Any>?
        require(unit != null && amountMap != null) {
          "timestamp_subtract requires 'unit' and 'amount'"
        }
        Expression.timestampSubtract(
            parseExpression(args["timestamp"] as Map<String, Any>),
            Expression.constant(unit),
            parseExpression(amountMap))
      }
      "timestamp_truncate" -> {
        val unit =
            args["unit"] as String?
                ?: throw IllegalArgumentException("timestamp_truncate requires 'unit'")
        Expression.timestampTruncate(parseExpression(args["timestamp"] as Map<String, Any>), unit)
      }
      "timestamp_diff" -> {
        val endExpr = parseExpression(args["end"] as Map<String, Any>)
        val startExpr = parseExpression(args["start"] as Map<String, Any>)
        val unitObj = args["unit"]
        if (unitObj is String) {
          Expression.timestampDiff(endExpr, startExpr, unitObj)
        } else {
          Expression.timestampDiff(endExpr, startExpr, parseExpression(unitObj as Map<String, Any>))
        }
      }
      "timestamp_extract" -> {
        val tsExpr = parseExpression(args["timestamp"] as Map<String, Any>)
        val partExpr = parseExpression(args["part"] as Map<String, Any>)
        if (!args.containsKey("timezone") || args["timezone"] == null) {
          Expression.timestampExtract(tsExpr, partExpr)
        } else {
          val tzObj = args["timezone"]
          if (tzObj is String) {
            Expression.timestampExtractWithTimezone(tsExpr, partExpr, tzObj)
          } else {
            Expression.timestampExtractWithTimezone(
                tsExpr, partExpr, parseExpression(tzObj as Map<String, Any>))
          }
        }
      }
      "parent" -> {
        if (args.containsKey("doc_ref")) {
          val path =
              args["doc_ref"] as String?
                  ?: throw IllegalArgumentException("parent requires 'doc_ref' argument")
          Expression.parent(firestore.document(path))
        } else {
          Expression.parent(parseChild(args, "expression"))
        }
      }
      "if_null" ->
          Expression.ifNull(
              parseExpression(args["expression"] as Map<String, Any>),
              parseExpression(args["replacement"] as Map<String, Any>))
      "coalesce" ->
          ExpressionHelpers.parseCoalesceExpression(
              args["expressions"] as List<Map<String, Any>>, this)
      "switch_on" ->
          ExpressionHelpers.parseSwitchOnExpression(
              args["expressions"] as List<Map<String, Any>>, this)
      "map_keys" -> Expression.mapKeys(parseChild(args, "expression"))
      "map_values" -> Expression.mapValues(parseChild(args, "expression"))
      "array" -> {
        val elements =
            args["elements"] as List<*>?
                ?: throw IllegalArgumentException("array requires 'elements'")
        val parsed =
            Array<Any>(elements.size) { i ->
              val el = elements[i]
              if (el is Map<*, *>) {
                parseExpression(el as Map<String, Any>)
              } else {
                ExpressionHelpers.parseConstantValue(el)
              }
            }
        Expression.array(parsed.toList())
      }
      "map" -> {
        val data =
            args["data"] as Map<String, Any>?
                ?: throw IllegalArgumentException("map requires 'data'")
        val parsed = HashMap<String, Any>()
        for ((key, v) in data) {
          if (v is Map<*, *>) {
            val nested = v as Map<String, Any>
            parsed[key] =
                if (nested.containsKey("name") && nested.containsKey("args")) {
                  parseExpression(nested)
                } else {
                  v
                }
          } else {
            parsed[key] = ExpressionHelpers.parseConstantValue(v)
          }
        }
        Expression.map(parsed)
      }
      "bit_and" -> parseBinaryOperation(args) { left, right -> left.bitAnd(right) }
      "bit_or" -> parseBinaryOperation(args) { left, right -> left.bitOr(right) }
      "bit_xor" -> parseBinaryOperation(args) { left, right -> left.bitXor(right) }
      "bit_not" -> parseChild(args, "expression").bitNot()
      "bit_left_shift" ->
          parseExpression(args["expression"] as Map<String, Any>)
              .bitLeftShift(parseExpression(args["amount"] as Map<String, Any>))
      "bit_right_shift" ->
          parseExpression(args["expression"] as Map<String, Any>)
              .bitRightShift(parseExpression(args["amount"] as Map<String, Any>))
      "is_absent" -> parseIsAbsent(args)
      "is_error" -> parseIsError(args)
      "exists" -> parseExists(args)
      "as_boolean" -> parseAsBoolean(args)
      "array_contains_all" -> parseArrayContainsAll(args)
      "array_contains_any" -> parseArrayContainsAny(args)
      "document_matches" -> parseDocumentMatches(args)
      else -> {
        Log.w(TAG, "Unsupported expression type: $name")
        throw UnsupportedOperationException("Expression type not yet implemented: $name")
      }
    }
  }

  @Suppress("UNCHECKED_CAST")
  private fun parseBinaryComparison(
      args: Map<String, Any>,
      operation: BinaryExpressionOp<BooleanExpression>
  ): BooleanExpression {
    val left = parseExpression(args["left"] as Map<String, Any>)
    val right = parseExpression(args["right"] as Map<String, Any>)
    return operation.apply(left, right)
  }

  @Suppress("UNCHECKED_CAST")
  private fun parseBinaryOperation(
      args: Map<String, Any>,
      operation: BinaryExpressionOp<Expression>
  ): Expression {
    val left = parseExpression(args["left"] as Map<String, Any>)
    val right = parseExpression(args["right"] as Map<String, Any>)
    return operation.apply(left, right)
  }

  private fun parseIsAbsent(args: Map<String, Any>): BooleanExpression {
    return parseChild(args, "expression").isAbsent()
  }

  private fun parseIsError(args: Map<String, Any>): BooleanExpression {
    return parseChild(args, "expression").isError()
  }

  private fun parseExists(args: Map<String, Any>): BooleanExpression {
    return parseChild(args, "expression").exists()
  }

  private fun parseAsBoolean(args: Map<String, Any>): BooleanExpression {
    return parseChild(args, "expression").asBoolean()
  }

  @Suppress("UNCHECKED_CAST")
  private fun parseArrayContainsAll(args: Map<String, Any>): BooleanExpression {
    val array = parseExpression(args["array"] as Map<String, Any>)
    if (args["values"] != null) {
      val valuesMaps = args["values"] as List<Map<String, Any>>
      return array.arrayContainsAll(parseExpressionMaps(valuesMaps))
    }
    val arrayExpr = parseExpression(args["array_expression"] as Map<String, Any>)
    return array.arrayContainsAll(arrayExpr)
  }

  @Suppress("UNCHECKED_CAST")
  private fun parseArrayContainsAny(args: Map<String, Any>): BooleanExpression {
    val array = parseExpression(args["array"] as Map<String, Any>)
    val valuesMaps = args["values"] as List<Map<String, Any>>
    return array.arrayContainsAny(parseExpressionMaps(valuesMaps))
  }

  @Suppress("UNCHECKED_CAST")
  fun parseBooleanExpression(expressionMap: Map<String, Any>): BooleanExpression {
    val name =
        expressionMap["name"] as String?
            ?: throw IllegalArgumentException("BooleanExpression must have a 'name' field")
    val args = argsOf(expressionMap)
    return when (name) {
      "equal",
      "not_equal",
      "greater_than",
      "greater_than_or_equal",
      "less_than",
      "less_than_or_equal" -> parseBinaryComparisonNamed(name, args)
      "and" ->
          ExpressionHelpers.parseAndExpression(args["expressions"] as List<Map<String, Any>>, this)
      "or" ->
          ExpressionHelpers.parseOrExpression(args["expressions"] as List<Map<String, Any>>, this)
      "xor" ->
          ExpressionHelpers.parseXorExpression(args["expressions"] as List<Map<String, Any>>, this)
      "nor" ->
          ExpressionHelpers.parseNorExpression(args["expressions"] as List<Map<String, Any>>, this)
      "not" -> parseBooleanExpression(args["expression"] as Map<String, Any>).not()
      "is_absent" -> parseIsAbsent(args)
      "is_error" -> parseIsError(args)
      "exists" -> parseExists(args)
      "array_contains" -> parseArrayContainsElement(args)
      "array_contains_all" -> parseArrayContainsAll(args)
      "array_contains_any" -> parseArrayContainsAny(args)
      "equal_any" -> parseEqualAny(args)
      "not_equal_any" -> parseNotEqualAny(args)
      "as_boolean" -> parseAsBoolean(args)
      "document_matches" -> parseDocumentMatches(args)
      else -> {
        val expr = parseExpression(expressionMap)
        if (expr is BooleanExpression) {
          expr
        } else {
          Log.w(TAG, "Expression type '$name' is not a BooleanExpression, attempting cast")
          throw IllegalArgumentException(
              "Expression type '$name' cannot be used as a BooleanExpression")
        }
      }
    }
  }

  fun parseSelectable(expressionMap: Map<String, Any>): Selectable {
    val expr = parseExpression(expressionMap)
    if (expr !is Selectable) {
      throw IllegalArgumentException(
          "Expression must be a Selectable (Field or AliasedExpression). Got: " +
              expressionMap["name"])
    }
    return expr
  }

  private fun parseDocumentMatches(args: Map<String, Any>): BooleanExpression {
    val query =
        args["query"] as String?
            ?: throw IllegalArgumentException("document_matches requires a 'query' argument")
    return Expression.documentMatches(query)
  }

  @Suppress("UNCHECKED_CAST")
  fun parseAggregateFunction(aggregateMap: Map<String, Any>): AggregateFunction {
    var functionName = aggregateMap["function"] as String?
    if (functionName == null) {
      functionName = aggregateMap["name"] as String?
    }
    val args = aggregateMap["args"] as Map<String, Any>?
    var expr: Expression? = null
    if (args != null) {
      expr = parseExpression(args["expression"] as Map<String, Any>)
    }
    return when (functionName) {
      "sum" -> AggregateFunction.sum(expr!!)
      "average" -> AggregateFunction.average(expr!!)
      "count" -> AggregateFunction.count(expr!!)
      "count_distinct" -> AggregateFunction.countDistinct(expr!!)
      "minimum" -> AggregateFunction.minimum(expr!!)
      "maximum" -> AggregateFunction.maximum(expr!!)
      "count_all" -> AggregateFunction.countAll()
      else -> throw IllegalArgumentException("Unknown aggregate function: $functionName")
    }
  }

  @Suppress("UNCHECKED_CAST")
  fun parseAliasedAggregate(aggregateMap: Map<String, Any>): AliasedAggregate {
    val name = aggregateMap["name"] as String?
    if (name == "alias") {
      val args = aggregateMap["args"] as Map<String, Any>
      val alias = args["alias"] as String
      val aggregateFunctionMap = args["aggregate_function"] as Map<String, Any>
      return parseAggregateFunction(aggregateFunctionMap).alias(alias)
    }
    val alias = aggregateMap["alias"] as String?
    if (alias != null) {
      return parseAggregateFunction(aggregateMap).alias(alias)
    }
    throw IllegalArgumentException(
        "Aggregate function must have an alias. Expected AliasedAggregateFunction format.")
  }

  @Suppress("UNCHECKED_CAST")
  fun parseAggregateStage(stageMap: Map<String, Any>): AggregateStage {
    val accumulatorMaps = stageMap["accumulators"] as List<Map<String, Any>>?
    require(!accumulatorMaps.isNullOrEmpty()) {
      "AggregateStage must have at least one accumulator"
    }

    val accumulators =
        Array(accumulatorMaps.size) { i -> parseAliasedAggregate(accumulatorMaps[i]) }
    var aggregateStage =
        if (accumulators.size == 1) {
          AggregateStage.withAccumulators(accumulators[0])
        } else {
          AggregateStage.withAccumulators(
              accumulators[0], *accumulators.copyOfRange(1, accumulators.size))
        }

    val groupMaps = stageMap["groups"] as List<Map<String, Any>>?
    if (!groupMaps.isNullOrEmpty()) {
      val firstGroup = parseSelectable(groupMaps[0])
      aggregateStage =
          if (groupMaps.size == 1) {
            aggregateStage.withGroups(firstGroup)
          } else {
            val additionalGroups =
                Array<Any>(groupMaps.size - 1) { i -> parseExpression(groupMaps[i + 1]) }
            aggregateStage.withGroups(firstGroup, *additionalGroups)
          }
    }
    return aggregateStage
  }

  fun parseAggregateOptions(optionsMap: Map<String, Any>): AggregateOptions {
    return AggregateOptions()
  }

  fun parseDistanceMeasure(dartEnumName: String): FindNearestStage.DistanceMeasure {
    return when (dartEnumName) {
      "cosine" -> FindNearestStage.DistanceMeasure.COSINE
      "euclidean" -> FindNearestStage.DistanceMeasure.EUCLIDEAN
      "dotProduct" -> FindNearestStage.DistanceMeasure.DOT_PRODUCT
      else ->
          throw IllegalArgumentException(
              "Unknown distance measure: $dartEnumName. Expected: cosine, euclidean, or dotProduct")
    }
  }

  companion object {
    private const val TAG = "ExpressionParsers"
  }
}
