// ignore_for_file: require_trailing_commas
// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:cloud_firestore_web/src/interop/firestore_interop.dart'
    as interop;
import 'package:cloud_firestore_web/src/pipeline_expression_parser_web.dart';
import 'package:firebase_core/firebase_core.dart';

/// Builds a JS Pipeline from serialized [stages] and returns it ready to execute.
/// Keeps [executePipeline] thin: build → execute → convert.
interop.PipelineJsImpl buildPipelineFromStages(
  interop.FirestoreJsImpl jsFirestore,
  List<Map<String, dynamic>> stages,
) {
  final source = jsFirestore.pipeline();
  final first = stages.first;
  final stageName = first['stage'] as String?;

  // Build source stage
  interop.PipelineJsImpl pipeline = _applySourceStage(
      source as interop.PipelineSourceJsImpl, jsFirestore, stageName, first);

  final converter = PipelineExpressionParserWeb(interop.pipelines, jsFirestore);

  // Apply remaining stages
  for (var i = 1; i < stages.length; i++) {
    pipeline = _applyStage(pipeline, stages[i], converter, jsFirestore);
  }
  return pipeline;
}

interop.PipelineJsImpl _applySourceStage(
  interop.PipelineSourceJsImpl source,
  interop.FirestoreJsImpl jsFirestore,
  String? stageName,
  Map<String, dynamic> first,
) {
  final args = first['args'];
  return switch (stageName) {
    'collection' => source
        .collection(((args as Map<String, dynamic>)['path']! as String).toJS),
    'collection_group' => source.collectionGroup(
        ((args as Map<String, dynamic>)['path']! as String).toJS),
    'database' => source.database(),
    'documents' => source.documents(
        (args as List<dynamic>)
            .map((e) => (e as Map<String, dynamic>)['path']! as String)
            .map((p) => interop.doc(jsFirestore as JSAny, p.toJS))
            .toList()
            .toJS,
      ),
    _ => throw UnsupportedError(
        'Pipeline source stage "$stageName" is not supported on web.'),
  };
}

interop.PipelineJsImpl _applyStage(
  interop.PipelineJsImpl pipeline,
  Map<String, dynamic> stage,
  PipelineExpressionParserWeb converter,
  interop.FirestoreJsImpl jsFirestore,
) {
  final name = stage['stage'] as String?;
  final args = stage['args'];
  final map = args is Map<String, dynamic> ? args : <String, dynamic>{};

  switch (name) {
    case 'limit':
      final limit = map['limit'] as int;
      return pipeline.limit(limit.toJS);
    case 'offset':
      final offset = map['offset'] as int;
      return pipeline.offset(offset.toJS);
    case 'where':
      final expression = map['expression'];
      if (expression == null) return pipeline;
      final condition =
          converter.toBooleanExpression(expression as Map<String, dynamic>);
      if (condition == null) {
        throw UnsupportedError(
          'Pipeline where() on web: could not parse the condition expression.',
        );
      }
      return pipeline.where(condition);
    case 'sort':
      final orderings = map['orderings'] as List<dynamic>?;
      if (orderings == null || orderings.isEmpty) return pipeline;
      return pipeline.sort(converter.toSortOptions(orderings));
    case 'add_fields':
      final expressions = map['expressions'] as List<dynamic>?;
      if (expressions == null || expressions.isEmpty) return pipeline;
      return pipeline.addFields(converter.toAddFieldsOptions(expressions));
    case 'select':
      final expressions = map['expressions'] as List<dynamic>?;
      if (expressions == null || expressions.isEmpty) return pipeline;
      return pipeline.select(converter.toSelectOptions(expressions));
    case 'distinct':
      final expressions = map['expressions'] as List<dynamic>?;
      if (expressions == null || expressions.isEmpty) return pipeline;
      return pipeline.distinct(converter.toDistinctOptions(expressions));
    case 'aggregate':
      return pipeline.aggregate(converter.toAggregateOptionsFromFunctions(map));
    case 'aggregate_with_options':
      return pipeline
          .aggregate(converter.toAggregateOptionsFromStageAndOptions(map));
    case 'sample':
      return pipeline.sample(converter.toSampleOptions(args));
    case 'unnest':
      return pipeline.unnest(converter.toUnnestOptions(map));
    case 'remove_fields':
      final fieldPaths = map['field_paths'] as List<dynamic>?;
      if (fieldPaths == null || fieldPaths.isEmpty) return pipeline;
      return pipeline.removeFields(converter.toRemoveFieldsOptions(fieldPaths));
    case 'replace_with':
      final expression = map['expression'];
      if (expression == null) return pipeline;
      return pipeline.replaceWith(
          converter.toReplaceWithOptions(expression as Map<String, dynamic>));
    case 'find_nearest':
      return pipeline.findNearest(converter.toFindNearestOptions(map));
    case 'union':
      final pipelineStages = map['pipeline'] as List<Map<String, dynamic>>;
      final otherPipeline =
          buildPipelineFromStages(jsFirestore, pipelineStages);
      return pipeline.union(otherPipeline);
    default:
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unknown-pipeline-stage',
        message: 'Unknown pipeline stage: $name',
      );
  }
}
