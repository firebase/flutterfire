/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.Pipeline;
import com.google.firebase.firestore.pipeline.AggregateOptions;
import com.google.firebase.firestore.pipeline.AggregateStage;
import com.google.firebase.firestore.pipeline.AliasedAggregate;
import com.google.firebase.firestore.pipeline.BooleanExpression;
import com.google.firebase.firestore.pipeline.Expression;
import com.google.firebase.firestore.pipeline.Field;
import com.google.firebase.firestore.pipeline.FindNearestOptions;
import com.google.firebase.firestore.pipeline.FindNearestStage;
import com.google.firebase.firestore.pipeline.Ordering;
import com.google.firebase.firestore.pipeline.SampleStage;
import com.google.firebase.firestore.pipeline.Selectable;
import com.google.firebase.firestore.pipeline.UnnestOptions;
import java.util.List;
import java.util.Map;

/** Handles parsing and applying pipeline stages to Pipeline instances. */
class PipelineStageHandlers {
  private final ExpressionParsers parsers;

  PipelineStageHandlers(@NonNull ExpressionParsers parsers) {
    this.parsers = parsers;
  }

  /** Applies a pipeline stage to a Pipeline instance. */
  @SuppressWarnings("unchecked")
  Pipeline applyStage(
      @NonNull Pipeline pipeline,
      @NonNull String stageName,
      @Nullable Map<String, Object> args,
      @NonNull FirebaseFirestore firestore) {
    switch (stageName) {
      case "where":
        return handleWhere(pipeline, args);
      case "limit":
        return handleLimit(pipeline, args);
      case "offset":
        return handleOffset(pipeline, args);
      case "sort":
        return handleSort(pipeline, args);
      case "select":
        return handleSelect(pipeline, args);
      case "add_fields":
        return handleAddFields(pipeline, args);
      case "remove_fields":
        return handleRemoveFields(pipeline, args);
      case "distinct":
        return handleDistinct(pipeline, args);
      case "aggregate":
        return handleAggregate(pipeline, args);
      case "unnest":
        return handleUnnest(pipeline, args);
      case "replace_with":
        return handleReplaceWith(pipeline, args);
      case "union":
        return handleUnion(pipeline, args, firestore);
      case "sample":
        return handleSample(pipeline, args);
      case "find_nearest":
        return handleFindNearest(pipeline, args);
      default:
        throw new IllegalArgumentException("Unknown pipeline stage: " + stageName);
    }
  }

  private Pipeline handleWhere(@NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    Map<String, Object> expressionMap = (Map<String, Object>) args.get("expression");
    BooleanExpression booleanExpression = parsers.parseBooleanExpression(expressionMap);
    return pipeline.where(booleanExpression);
  }

  private Pipeline handleLimit(@NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    Number limit = (Number) args.get("limit");
    return pipeline.limit(limit.intValue());
  }

  private Pipeline handleOffset(@NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    Number offset = (Number) args.get("offset");
    return pipeline.offset(offset.intValue());
  }

  private Pipeline handleSort(@NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    Map<String, Object> orderingMap = (Map<String, Object>) args.get("expression");
    Expression expression = parsers.parseExpression(orderingMap);
    String direction = (String) args.get("order_direction");
    Ordering ordering = "asc".equals(direction) ? expression.ascending() : expression.descending();
    return pipeline.sort(ordering);
  }

  private Pipeline handleSelect(@NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    List<Map<String, Object>> expressionMaps = (List<Map<String, Object>>) args.get("expressions");

    if (expressionMaps == null || expressionMaps.isEmpty()) {
      throw new IllegalArgumentException("'select' requires at least one expression");
    }

    // Parse first expression as Selectable
    Selectable firstSelection = parsers.parseSelectable(expressionMaps.get(0));

    // Parse remaining expressions as varargs
    if (expressionMaps.size() == 1) {
      return pipeline.select(firstSelection);
    }

    Object[] additionalSelections = new Object[expressionMaps.size() - 1];
    for (int i = 1; i < expressionMaps.size(); i++) {
      Expression expr = parsers.parseExpression(expressionMaps.get(i));
      // Additional selections can be Selectable or any Object
      additionalSelections[i - 1] = expr;
    }

    return pipeline.select(firstSelection, additionalSelections);
  }

  private Pipeline handleAddFields(@NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    List<Map<String, Object>> expressionMaps = (List<Map<String, Object>>) args.get("expressions");

    if (expressionMaps == null || expressionMaps.isEmpty()) {
      throw new IllegalArgumentException("'add_fields' requires at least one expression");
    }

    // Parse first expression as Selectable
    Selectable firstField = parsers.parseSelectable(expressionMaps.get(0));

    // Parse remaining expressions as Selectable varargs
    if (expressionMaps.size() == 1) {
      return pipeline.addFields(firstField);
    }

    Selectable[] additionalFields = new Selectable[expressionMaps.size() - 1];
    for (int i = 1; i < expressionMaps.size(); i++) {
      additionalFields[i - 1] = parsers.parseSelectable(expressionMaps.get(i));
    }

    return pipeline.addFields(firstField, additionalFields);
  }

  private Pipeline handleRemoveFields(
      @NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    List<String> fieldPaths = (List<String>) args.get("field_paths");

    if (fieldPaths == null || fieldPaths.isEmpty()) {
      throw new IllegalArgumentException("'remove_fields' requires at least one field path");
    }

    // Convert first field path string to Field
    Field firstField = Expression.field(fieldPaths.get(0));

    // Convert remaining field paths to Field varargs
    if (fieldPaths.size() == 1) {
      return pipeline.removeFields(firstField);
    }

    Field[] additionalFields = new Field[fieldPaths.size() - 1];
    for (int i = 1; i < fieldPaths.size(); i++) {
      additionalFields[i - 1] = Expression.field(fieldPaths.get(i));
    }

    return pipeline.removeFields(firstField, additionalFields);
  }

  private Pipeline handleDistinct(@NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    List<Map<String, Object>> expressionMaps = (List<Map<String, Object>>) args.get("expressions");

    if (expressionMaps == null || expressionMaps.isEmpty()) {
      throw new IllegalArgumentException("'distinct' requires at least one expression");
    }

    // Parse first expression as Selectable
    Selectable firstGroup = parsers.parseSelectable(expressionMaps.get(0));

    // Parse remaining expressions as varargs (can be Selectable or Any)
    if (expressionMaps.size() == 1) {
      return pipeline.distinct(firstGroup);
    }

    Object[] additionalGroups = new Object[expressionMaps.size() - 1];
    for (int i = 1; i < expressionMaps.size(); i++) {
      Expression expr = parsers.parseExpression(expressionMaps.get(i));
      // Additional groups can be Selectable or any Object
      additionalGroups[i - 1] = expr;
    }

    return pipeline.distinct(firstGroup, additionalGroups);
  }

  @SuppressWarnings("unchecked")
  private Pipeline handleAggregate(@NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    // Check if this is using aggregate_stage (new API) or aggregate_functions (legacy API)
    if (args.containsKey("aggregate_stage")) {
      // New API: aggregateStage with optional options
      Map<String, Object> aggregateStageMap = (Map<String, Object>) args.get("aggregate_stage");
      AggregateStage aggregateStage = parsers.parseAggregateStage(aggregateStageMap);

      // Parse optional options
      Map<String, Object> optionsMap = (Map<String, Object>) args.get("options");
      if (optionsMap != null && !optionsMap.isEmpty()) {
        AggregateOptions options = parsers.parseAggregateOptions(optionsMap);
        return pipeline.aggregate(aggregateStage, options);
      } else {
        return pipeline.aggregate(aggregateStage);
      }
    } else {
      // Legacy API: aggregate_functions (varargs)
      List<Map<String, Object>> aggregateMaps =
          (List<Map<String, Object>>) args.get("aggregate_functions");

      if (aggregateMaps == null || aggregateMaps.isEmpty()) {
        throw new IllegalArgumentException(
            "'aggregate' requires at least one aggregate function or an aggregate_stage");
      }

      // Parse first aggregate function as AliasedAggregate
      AliasedAggregate firstAccumulator = parsers.parseAliasedAggregate(aggregateMaps.get(0));

      // Parse remaining aggregate functions as AliasedAggregate varargs
      if (aggregateMaps.size() == 1) {
        return pipeline.aggregate(firstAccumulator);
      }

      AliasedAggregate[] additionalAccumulators = new AliasedAggregate[aggregateMaps.size() - 1];
      for (int i = 1; i < aggregateMaps.size(); i++) {
        additionalAccumulators[i - 1] = parsers.parseAliasedAggregate(aggregateMaps.get(i));
      }

      return pipeline.aggregate(firstAccumulator, additionalAccumulators);
    }
  }

  private Pipeline handleUnnest(@NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    Map<String, Object> expressionMap = (Map<String, Object>) args.get("expression");
    Selectable expression = parsers.parseSelectable(expressionMap);
    String indexField = (String) args.get("index_field");
    if (indexField != null) {
      return pipeline.unnest(expression, new UnnestOptions().withIndexField(indexField));
    } else {
      return pipeline.unnest(expression);
    }
  }

  private Pipeline handleReplaceWith(
      @NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    Map<String, Object> expressionMap = (Map<String, Object>) args.get("expression");
    Expression expression = parsers.parseExpression(expressionMap);
    return pipeline.replaceWith(expression);
  }

  @SuppressWarnings("unchecked")
  private Pipeline handleUnion(
      @NonNull Pipeline pipeline,
      @Nullable Map<String, Object> args,
      @NonNull FirebaseFirestore firestore) {
    List<Map<String, Object>> nestedStages = (List<Map<String, Object>>) args.get("pipeline");
    if (nestedStages == null || nestedStages.isEmpty()) {
      throw new IllegalArgumentException("'union' requires a non-empty 'pipeline' argument");
    }
    Pipeline otherPipeline = PipelineParser.buildPipeline(firestore, nestedStages);
    return pipeline.union(otherPipeline);
  }

  private Pipeline handleSample(@NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    // Sample stage parsing
    Map<String, Object> sampleMap = (Map<String, Object>) args;
    // Parse sample configuration
    String type = (String) sampleMap.get("type");
    if (type == "percentage") {
      double value = (double) sampleMap.get("value");
      return pipeline.sample(SampleStage.withPercentage(value));
    } else {
      int value = (int) sampleMap.get("value");
      return pipeline.sample(SampleStage.withDocLimit(value));
    }
  }

  @SuppressWarnings("unchecked")
  private Pipeline handleFindNearest(
      @NonNull Pipeline pipeline, @Nullable Map<String, Object> args) {
    String vectorField = (String) args.get("vector_field");
    List<Number> vectorValue = (List<Number>) args.get("vector_value");
    String distanceMeasureStr = (String) args.get("distance_measure");
    Number limitObj = (Number) args.get("limit");

    if (distanceMeasureStr == null) {
      throw new IllegalArgumentException("'find_nearest' requires a 'distance_measure' argument");
    }

    // Convert Dart enum name to Android enum value
    FindNearestStage.DistanceMeasure distanceMeasure =
        parsers.parseDistanceMeasure(distanceMeasureStr);

    // Convert vector value to double array
    double[] vectorArray = new double[vectorValue.size()];
    for (int i = 0; i < vectorValue.size(); i++) {
      vectorArray[i] = vectorValue.get(i).doubleValue();
    }

    Field fieldExpr = Expression.field(vectorField);

    if (limitObj != null) {
      return pipeline.findNearest(
          vectorField,
          Expression.vector(vectorArray),
          distanceMeasure,
          new FindNearestOptions().withLimit(limitObj.intValue()));
    } else {
      return pipeline.findNearest(fieldExpr, vectorArray, distanceMeasure);
    }
  }
}
