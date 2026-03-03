// ignore_for_file: require_trailing_commas
// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:cloud_firestore_web/src/interop/firestore_interop.dart'
    as interop;
import 'package:cloud_firestore_web/src/pipeline_expression_converter_web.dart';

/// Builds a JS Pipeline from serialized [stages] and returns it ready to execute.
/// Keeps [executePipeline] thin: build → execute → convert.
interop.PipelineJsImpl buildPipelineFromStages(
  interop.FirestoreJsImpl jsFirestore,
  List<Map<String, dynamic>> stages,
) {
  if (stages.isEmpty) {
    throw ArgumentError('Pipeline must have at least one stage (source).');
  }
  print(jsFirestore);
  final source = jsFirestore.pipeline();
  print('source: $source');
  final first = stages.first;
  final stageName = first['stage'] as String?;

  // Build source stage
  interop.PipelineJsImpl pipeline = _applySourceStage(
      source as interop.PipelineSourceJsImpl, jsFirestore, stageName, first);

  final converter = PipelineExpressionConverterWeb(jsFirestore);

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
  switch (stageName) {
    case 'collection':
      final path = (args is Map ? args['path'] as String? : null) ?? '';
      return source.collection(path.toJS);
    case 'collection_group':
      final path = (args is Map ? args['path'] as String? : null) ?? '';
      return source.collectionGroup(path.toJS);
    case 'database':
      return source.database();
    case 'documents':
      final docsRaw = first['args'];
      final docs = docsRaw is List
          ? docsRaw
          : (args is Map
                  ? args['documents'] as List<dynamic>? ??
                      args['paths'] as List<dynamic>?
                  : null) ??
              [];
      final paths = docs
          .map((e) => (e is Map ? e['path'] as String? : e?.toString()) ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      final refs =
          paths.map((p) => interop.doc(jsFirestore as JSAny, p.toJS)).toList();
      return source.documents(refs.toJS);
    default:
      throw UnsupportedError(
        'Pipeline source stage "$stageName" is not supported on web.',
      );
  }
}

interop.PipelineJsImpl _applyStage(
  interop.PipelineJsImpl pipeline,
  Map<String, dynamic> stage,
  PipelineExpressionConverterWeb converter,
  interop.FirestoreJsImpl jsFirestore,
) {
  final name = stage['stage'] as String?;
  final args = stage['args'];
  final map = args is Map<String, dynamic> ? args : <String, dynamic>{};

  switch (name) {
    case 'limit':
      final limit = map['limit'] as int? ?? 0;
      return pipeline.limit(limit.toJS);
    case 'offset':
      final offset = map['offset'] as int? ?? 0;
      return pipeline.offset(offset.toJS);
    case 'where':
      final expression = map['expression'];
      if (expression == null) return pipeline;
      return pipeline.where(
          converter.toBooleanExpression(expression as Map<String, dynamic>));
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
      return pipeline.aggregate(converter.toAggregateOptions(map));
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
      // Union requires another Pipeline; not yet supported from serialized stages.
      return pipeline;
    default:
      // Ignore unknown stages
      return pipeline;
  }
}
