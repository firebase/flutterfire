// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// Base sealed class for all pipeline stages
sealed class PipelineStage implements PipelineSerializable {
  String get name;
}

/// Stage representing a collection source
final class _CollectionPipelineStage extends PipelineStage {
  final String collectionPath;

  _CollectionPipelineStage(this.collectionPath);

  @override
  String get name => 'collection';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {'path': collectionPath},
    };
  }
}

/// Stage representing a documents source
final class _DocumentsPipelineStage extends PipelineStage {
  final List<DocumentReference<Map<String, dynamic>>> documents;

  _DocumentsPipelineStage(this.documents);

  @override
  String get name => 'documents';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': documents.map((doc) => {'path': doc.path}).toList(),
    };
  }
}

/// Stage representing a database source
final class _DatabasePipelineStage extends PipelineStage {
  _DatabasePipelineStage();

  @override
  String get name => 'database';

  @override
  Map<String, dynamic> toMap() {
    return {'stage': name};
  }
}

/// Stage representing a collection group source
final class _CollectionGroupPipelineStage extends PipelineStage {
  final String collectionPath;

  _CollectionGroupPipelineStage(this.collectionPath);

  @override
  String get name => 'collection_group';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {'path': collectionPath},
    };
  }
}

/// Stage for adding fields to documents
final class _AddFieldsStage extends PipelineStage {
  final List<Expression> expressions;

  _AddFieldsStage(this.expressions);

  @override
  String get name => 'add_fields';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {'expressions': expressions.map((expr) => expr.toMap()).toList()},
    };
  }
}

/// Stage for aggregating data
final class _AggregateStage extends PipelineStage {
  final List<AliasedAggregateFunction> aggregateFunctions;

  _AggregateStage(this.aggregateFunctions);

  @override
  String get name => 'aggregate';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {
        'aggregate_functions': aggregateFunctions
            .map((func) => func.toMap())
            .toList(),
      },
    };
  }
}

/// Stage for aggregating data with options and grouping
final class _AggregateStageWithOptions extends PipelineStage {
  final AggregateStageOptions aggregateStage;
  final AggregateOptions? options;

  _AggregateStageWithOptions(this.aggregateStage, this.options);

  @override
  String get name => 'aggregate_with_options';

  @override
  Map<String, dynamic> toMap() {
    final map = aggregateStage.toMap();
    final optionsMap = options?.toMap();
    return {
      'stage': name,
      'args': {'aggregate_stage': map, 'options': optionsMap},
    };
  }
}

/// Stage for getting distinct values
final class _DistinctStage extends PipelineStage {
  final List<Selectable> expressions;

  _DistinctStage(this.expressions);

  @override
  String get name => 'distinct';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {'expressions': expressions.map((expr) => expr.toMap()).toList()},
    };
  }
}

/// Stage for finding nearest vectors
final class _FindNearestStage extends PipelineStage {
  final Field vectorField;
  final List<double> vectorValue;
  final DistanceMeasure distanceMeasure;
  final int? limit;
  final String? distanceField;

  _FindNearestStage(
    this.vectorField,
    this.vectorValue,
    this.distanceMeasure, {
    this.limit,
    this.distanceField,
  });

  @override
  String get name => 'find_nearest';

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'stage': name,
      'args': {
        'vector_field': vectorField.fieldName,
        'vector_value': vectorValue,
        'distance_measure': distanceMeasure.name,
      },
    };
    if (limit != null) {
      map['args']['limit'] = limit;
    }
    final outputField = distanceField;
    if (outputField != null && outputField.isNotEmpty) {
      map['args']['distance_field'] = outputField;
    }
    return map;
  }
}

/// Stage for full-text or geo search.
final class _SearchStage extends PipelineStage {
  final SearchStage searchStage;

  _SearchStage(this.searchStage);

  @override
  String get name => 'search';

  @override
  Map<String, dynamic> toMap() {
    return {'stage': name, 'args': searchStage.toMap()};
  }
}

/// Stage for limiting results
final class _LimitStage extends PipelineStage {
  final int limit;

  _LimitStage(this.limit);

  @override
  String get name => 'limit';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {'limit': limit},
    };
  }
}

/// Stage for offsetting results
final class _OffsetStage extends PipelineStage {
  final int offset;

  _OffsetStage(this.offset);

  @override
  String get name => 'offset';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {'offset': offset},
    };
  }
}

/// Stage for removing fields
final class _RemoveFieldsStage extends PipelineStage {
  final List<String> fieldPaths;

  _RemoveFieldsStage(this.fieldPaths);

  @override
  String get name => 'remove_fields';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {'field_paths': fieldPaths},
    };
  }
}

/// Stage for replacing documents
final class _ReplaceWithStage extends PipelineStage {
  final Expression expression;

  _ReplaceWithStage(this.expression);

  @override
  String get name => 'replace_with';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {'expression': expression.toMap()},
    };
  }
}

/// Stage for sampling documents
final class _SampleStage extends PipelineStage {
  final PipelineSample sample;

  _SampleStage(this.sample);

  @override
  String get name => 'sample';

  @override
  Map<String, dynamic> toMap() {
    return {'stage': name, 'args': sample.toMap()};
  }
}

/// Stage for selecting specific fields
final class _SelectStage extends PipelineStage {
  final List<Selectable> expressions;

  _SelectStage(this.expressions);

  @override
  String get name => 'select';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {'expressions': expressions.map((expr) => expr.toMap()).toList()},
    };
  }
}

/// Stage for sorting results
final class _SortStage extends PipelineStage {
  final List<Ordering> orderings;

  _SortStage(this.orderings);

  @override
  String get name => 'sort';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {
        'orderings': orderings
            .map(
              (o) => {
                'expression': o.expression.toMap(),
                'order_direction': o.direction == OrderDirection.asc
                    ? 'asc'
                    : 'desc',
              },
            )
            .toList(),
      },
    };
  }
}

/// Stage for unnesting arrays
final class _UnnestStage extends PipelineStage {
  final Selectable expression;
  final String? indexField;

  _UnnestStage(this.expression, this.indexField);

  @override
  String get name => 'unnest';

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'stage': name,
      'args': <String, dynamic>{'expression': expression.toMap()},
    };
    if (indexField != null) {
      map['args']['index_field'] = indexField;
    }
    return map;
  }
}

/// Stage for union with another pipeline
final class _UnionStage extends PipelineStage {
  final Pipeline pipeline;

  _UnionStage(this.pipeline);

  @override
  String get name => 'union';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {'pipeline': pipeline.stages},
    };
  }
}

/// Stage that deletes each input document.
final class _DeleteStage extends PipelineStage {
  @override
  String get name => 'delete';

  @override
  Map<String, dynamic> toMap() {
    return {'stage': name, 'args': <String, dynamic>{}};
  }
}

/// Stage that updates each input document.
final class _UpdateStage extends PipelineStage {
  final List<Selectable> transformedFields;

  _UpdateStage(this.transformedFields);

  @override
  String get name => 'update';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {
        'expressions': transformedFields.map((field) => field.toMap()).toList(),
      },
    };
  }
}

/// Stage that inserts each input document.
final class _InsertStage extends PipelineStage {
  final String? collectionPath;
  final Expression? documentId;

  _InsertStage(this.collectionPath, this.documentId);

  @override
  String get name => 'insert';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': _writeTargetArgs(collectionPath, documentId),
    };
  }
}

/// Stage that inserts or replaces each input document.
final class _UpsertStage extends PipelineStage {
  final String? collectionPath;
  final Expression? documentId;
  final List<Selectable> additionalFields;

  _UpsertStage(this.collectionPath, this.documentId, this.additionalFields);

  @override
  String get name => 'upsert';

  @override
  Map<String, dynamic> toMap() {
    final args = _writeTargetArgs(collectionPath, documentId);
    if (additionalFields.isNotEmpty) {
      args['additional_fields'] = additionalFields
          .map((field) => field.toMap())
          .toList();
    }
    return {'stage': name, 'args': args};
  }
}

Map<String, dynamic> _writeTargetArgs(
  String? collectionPath,
  Expression? documentId,
) {
  final args = <String, dynamic>{};
  if (collectionPath != null) {
    args['collection'] = collectionPath;
  }
  if (documentId != null) {
    args['document_id'] = documentId.toMap();
  }
  return args;
}

/// Stage representing literal documents as a pipeline source.
final class _LiteralsPipelineStage extends PipelineStage {
  final List<Map<String, Object?>> documents;

  _LiteralsPipelineStage(this.documents);

  @override
  String get name => 'literals';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {'documents': documents.map(_encodeLiteralDocument).toList()},
    };
  }
}

Map<String, dynamic> _encodeLiteralDocument(Map<String, Object?> document) {
  return document.map(
    (key, value) => MapEntry(key, _encodeLiteralField(value)),
  );
}

Map<String, dynamic> _encodeLiteralField(Object? value) {
  if (value is Expression) {
    return {'kind': 'expression', 'expression': value.toMap()};
  }
  if (value is DocumentReference) {
    return {'kind': 'expression', 'expression': Constant(value).toMap()};
  }
  return {'kind': 'value', 'value': _encodeLiteralValue(value)};
}

Object? _encodeLiteralValue(Object? value) {
  if (value is Expression) {
    throw ArgumentError(
      'literals() only supports Expression values as top-level document fields.',
    );
  }
  if (value is DocumentReference) {
    throw ArgumentError(
      'literals() only supports DocumentReference values as top-level '
      'document fields.',
    );
  }
  if (value == null ||
      value is String ||
      value is num ||
      value is bool ||
      value is DateTime ||
      value is Timestamp ||
      value is GeoPoint ||
      value is Blob ||
      value is VectorValue) {
    return value;
  }
  if (value is Map) {
    return value.map(
      (key, nested) => MapEntry(key.toString(), _encodeLiteralValue(nested)),
    );
  }
  if (value is List) {
    return value.map(_encodeLiteralValue).toList();
  }
  throw ArgumentError(
    'literals() value must be null, String, num, bool, DateTime, Timestamp, '
    'GeoPoint, Blob, VectorValue, List, Map, or a top-level Expression. '
    'Got: ${value.runtimeType}',
  );
}

/// Stage for filtering documents
final class _WhereStage extends PipelineStage {
  final BooleanExpression expression;

  _WhereStage(this.expression);

  @override
  String get name => 'where';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {'expression': expression.toMap()},
    };
  }
}
