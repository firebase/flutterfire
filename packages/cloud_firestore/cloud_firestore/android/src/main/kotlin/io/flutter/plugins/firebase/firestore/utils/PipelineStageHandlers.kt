/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils

import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Pipeline
import com.google.firebase.firestore.pipeline.AggregateOptions
import com.google.firebase.firestore.pipeline.Expression
import com.google.firebase.firestore.pipeline.FindNearestOptions
import com.google.firebase.firestore.pipeline.Ordering
import com.google.firebase.firestore.pipeline.SampleStage
import com.google.firebase.firestore.pipeline.SearchStage
import com.google.firebase.firestore.pipeline.UnnestOptions

/** Handles parsing and applying pipeline stages to Pipeline instances. */
internal class PipelineStageHandlers(private val parsers: ExpressionParsers) {
  @Suppress("UNCHECKED_CAST")
  fun applyStage(
      pipeline: Pipeline,
      stageName: String,
      args: Map<String, Any>?,
      firestore: FirebaseFirestore
  ): Pipeline {
    return when (stageName) {
      "where" -> handleWhere(pipeline, args)
      "limit" -> handleLimit(pipeline, args)
      "offset" -> handleOffset(pipeline, args)
      "sort" -> handleSort(pipeline, args)
      "select" -> handleSelect(pipeline, args)
      "add_fields" -> handleAddFields(pipeline, args)
      "remove_fields" -> handleRemoveFields(pipeline, args)
      "distinct" -> handleDistinct(pipeline, args)
      "aggregate" -> handleAggregate(pipeline, args)
      "aggregate_with_options" -> handleAggregateWithOptions(pipeline, args)
      "unnest" -> handleUnnest(pipeline, args)
      "replace_with" -> handleReplaceWith(pipeline, args)
      "union" -> handleUnion(pipeline, args, firestore)
      "sample" -> handleSample(pipeline, args)
      "find_nearest" -> handleFindNearest(pipeline, args)
      "search" -> handleSearch(pipeline, args)
      else -> throw IllegalArgumentException("Unknown pipeline stage: $stageName")
    }
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleWhere(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val expressionMap = args!!["expression"] as Map<String, Any>
    val booleanExpression = parsers.parseBooleanExpression(expressionMap)
    return pipeline.where(booleanExpression)
  }

  private fun handleLimit(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val limit = args!!["limit"] as Number
    return pipeline.limit(limit.toInt())
  }

  private fun handleOffset(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val offset = args!!["offset"] as Number
    return pipeline.offset(offset.toInt())
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleSort(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val orderingMaps = args!!["orderings"] as List<Map<String, Any>>?
    require(!orderingMaps.isNullOrEmpty()) { "'sort' requires at least one ordering" }

    val firstMap = orderingMaps[0]
    var expression = parsers.parseExpression(firstMap["expression"] as Map<String, Any>)
    var direction = firstMap["order_direction"] as String?
    val firstOrdering = if (direction == "asc") expression.ascending() else expression.descending()

    if (orderingMaps.size == 1) {
      return pipeline.sort(firstOrdering)
    }

    val additionalOrderings =
        Array(orderingMaps.size - 1) { i ->
          val map = orderingMaps[i + 1]
          expression = parsers.parseExpression(map["expression"] as Map<String, Any>)
          direction = map["order_direction"] as String?
          if (direction == "asc") expression.ascending() else expression.descending()
        }
    return pipeline.sort(firstOrdering, *additionalOrderings)
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleSelect(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val expressionMaps = args!!["expressions"] as List<Map<String, Any>>?
    require(!expressionMaps.isNullOrEmpty()) { "'select' requires at least one expression" }

    val firstSelection = parsers.parseSelectable(expressionMaps[0])
    if (expressionMaps.size == 1) {
      return pipeline.select(firstSelection)
    }
    val additionalSelections =
        Array<Any>(expressionMaps.size - 1) { i -> parsers.parseExpression(expressionMaps[i + 1]) }
    return pipeline.select(firstSelection, *additionalSelections)
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleAddFields(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val expressionMaps = args!!["expressions"] as List<Map<String, Any>>?
    require(!expressionMaps.isNullOrEmpty()) { "'add_fields' requires at least one expression" }

    val firstField = parsers.parseSelectable(expressionMaps[0])
    if (expressionMaps.size == 1) {
      return pipeline.addFields(firstField)
    }
    val additionalFields =
        Array(expressionMaps.size - 1) { i -> parsers.parseSelectable(expressionMaps[i + 1]) }
    return pipeline.addFields(firstField, *additionalFields)
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleRemoveFields(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val fieldPaths = args!!["field_paths"] as List<String>?
    require(!fieldPaths.isNullOrEmpty()) { "'remove_fields' requires at least one field path" }

    val firstField = Expression.field(fieldPaths[0])
    if (fieldPaths.size == 1) {
      return pipeline.removeFields(firstField)
    }
    val additionalFields = Array(fieldPaths.size - 1) { i -> Expression.field(fieldPaths[i + 1]) }
    return pipeline.removeFields(firstField, *additionalFields)
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleDistinct(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val expressionMaps = args!!["expressions"] as List<Map<String, Any>>?
    require(!expressionMaps.isNullOrEmpty()) { "'distinct' requires at least one expression" }

    val firstGroup = parsers.parseSelectable(expressionMaps[0])
    if (expressionMaps.size == 1) {
      return pipeline.distinct(firstGroup)
    }
    val additionalGroups =
        Array<Any>(expressionMaps.size - 1) { i -> parsers.parseExpression(expressionMaps[i + 1]) }
    return pipeline.distinct(firstGroup, *additionalGroups)
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleAggregate(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val aggregateMaps = args!!["aggregate_functions"] as List<Map<String, Any>>?
    require(!aggregateMaps.isNullOrEmpty()) {
      "'aggregate' requires at least one aggregate function"
    }

    val firstAccumulator = parsers.parseAliasedAggregate(aggregateMaps[0])
    if (aggregateMaps.size == 1) {
      return pipeline.aggregate(firstAccumulator)
    }
    val additionalAccumulators =
        Array(aggregateMaps.size - 1) { i -> parsers.parseAliasedAggregate(aggregateMaps[i + 1]) }
    return pipeline.aggregate(firstAccumulator, *additionalAccumulators)
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleAggregateWithOptions(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val aggregateStageMap = args!!["aggregate_stage"] as Map<String, Any>
    val aggregateStage = parsers.parseAggregateStage(aggregateStageMap)
    val optionsMap = args["options"] as Map<String, Any>?
    if (optionsMap != null && optionsMap.isNotEmpty()) {
      val options: AggregateOptions = parsers.parseAggregateOptions(optionsMap)
      return pipeline.aggregate(aggregateStage, options)
    }
    return pipeline.aggregate(aggregateStage)
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleUnnest(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val expressionMap = args!!["expression"] as Map<String, Any>
    val expression = parsers.parseSelectable(expressionMap)
    val indexField = args["index_field"] as String?
    return if (indexField != null) {
      pipeline.unnest(expression, UnnestOptions().withIndexField(indexField))
    } else {
      pipeline.unnest(expression)
    }
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleReplaceWith(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val expressionMap = args!!["expression"] as Map<String, Any>
    val expression = parsers.parseExpression(expressionMap)
    return pipeline.replaceWith(expression)
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleUnion(
      pipeline: Pipeline,
      args: Map<String, Any>?,
      firestore: FirebaseFirestore
  ): Pipeline {
    val nestedStages = args!!["pipeline"] as List<Map<String, Any>>?
    require(!nestedStages.isNullOrEmpty()) { "'union' requires a non-empty 'pipeline' argument" }
    val otherPipeline = PipelineParser.buildPipeline(firestore, nestedStages)
    return pipeline.union(otherPipeline)
  }

  private fun handleSample(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val sampleMap = args!!
    val type = sampleMap["type"] as String?
    return if (type == "percentage") {
      val value = (sampleMap["value"] as Number).toDouble()
      pipeline.sample(SampleStage.withPercentage(value))
    } else {
      val value = (sampleMap["value"] as Number).toInt()
      pipeline.sample(SampleStage.withDocLimit(value))
    }
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleFindNearest(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    val vectorField = args!!["vector_field"] as String
    val vectorValue = args["vector_value"] as List<Number>
    val distanceMeasureStr = args["distance_measure"] as String?
    val limitObj = args["limit"] as Number?
    require(distanceMeasureStr != null) { "'find_nearest' requires a 'distance_measure' argument" }

    val distanceMeasure = parsers.parseDistanceMeasure(distanceMeasureStr)
    val vectorArray = DoubleArray(vectorValue.size) { i -> vectorValue[i].toDouble() }
    val fieldExpr = Expression.field(vectorField)
    return if (limitObj != null) {
      pipeline.findNearest(
          vectorField,
          Expression.vector(vectorArray),
          distanceMeasure,
          FindNearestOptions().withLimit(limitObj.toLong()))
    } else {
      pipeline.findNearest(fieldExpr, vectorArray, distanceMeasure)
    }
  }

  @Suppress("UNCHECKED_CAST")
  private fun handleSearch(pipeline: Pipeline, args: Map<String, Any>?): Pipeline {
    require(args != null) { "'search' requires arguments" }
    val queryType = args["query_type"] as String?
    val query = args["query"]
    var searchStage: SearchStage =
        when (queryType) {
          "string" -> SearchStage.withQuery(query as String)
          "expression" ->
              SearchStage.withQuery(parsers.parseBooleanExpression(query as Map<String, Any>))
          else ->
              throw IllegalArgumentException(
                  "'search' requires query_type to be either 'string' or 'expression'")
        }

    val sortMaps = args["sort"] as List<Map<String, Any>>?
    if (!sortMaps.isNullOrEmpty()) {
      val firstOrdering = parseOrdering(sortMaps[0])
      searchStage =
          if (sortMaps.size == 1) {
            searchStage.withSort(firstOrdering)
          } else {
            val additionalOrderings =
                Array(sortMaps.size - 1) { i -> parseOrdering(sortMaps[i + 1]) }
            searchStage.withSort(firstOrdering, *additionalOrderings)
          }
    }

    val addFieldMaps = args["add_fields"] as List<Map<String, Any>>?
    if (!addFieldMaps.isNullOrEmpty()) {
      val firstField = parsers.parseSelectable(addFieldMaps[0])
      searchStage =
          if (addFieldMaps.size == 1) {
            searchStage.withAddFields(firstField)
          } else {
            val additionalFields =
                Array(addFieldMaps.size - 1) { i -> parsers.parseSelectable(addFieldMaps[i + 1]) }
            searchStage.withAddFields(firstField, *additionalFields)
          }
    }

    val languageCode = args["language_code"] as String?
    if (languageCode != null) {
      searchStage = searchStage.withLanguageCode(languageCode)
    }
    val limit = args["limit"] as Number?
    if (limit != null) {
      searchStage = searchStage.withLimit(limit.toLong())
    }
    val offset = args["offset"] as Number?
    if (offset != null) {
      searchStage = searchStage.withOffset(offset.toLong())
    }
    val retrievalDepth = args["retrieval_depth"] as Number?
    if (retrievalDepth != null) {
      searchStage = searchStage.withRetrievalDepth(retrievalDepth.toLong())
    }
    return pipeline.search(searchStage)
  }

  @Suppress("UNCHECKED_CAST")
  private fun parseOrdering(orderingMap: Map<String, Any>): Ordering {
    val expression = parsers.parseExpression(orderingMap["expression"] as Map<String, Any>)
    val direction = orderingMap["order_direction"] as String?
    return if (direction == "asc") expression.ascending() else expression.descending()
  }
}
