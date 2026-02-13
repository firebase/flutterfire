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
      'args': {
        'path': collectionPath,
      },
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
      'args': documents
          .map((doc) => {
                'path': doc.path,
              })
          .toList(),
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
    return {
      'stage': name,
    };
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
      'args': {
        'path': collectionPath,
      },
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
      'args': {
        'expressions': expressions.map((expr) => expr.toMap()).toList(),
      },
    };
  }
}

/// Stage for aggregating data
final class _AggregateStage extends PipelineStage {
  final List<PipelineAggregateFunction> aggregateFunctions;

  _AggregateStage(this.aggregateFunctions);

  @override
  String get name => 'aggregate';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {
        'aggregate_functions':
            aggregateFunctions.map((func) => func.toMap()).toList(),
      },
    };
  }
}

/// Stage for getting distinct values
final class _DistinctStage extends PipelineStage {
  final List<Expression> expressions;

  _DistinctStage(this.expressions);

  @override
  String get name => 'distinct';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {
        'expressions': expressions.map((expr) => expr.toMap()).toList(),
      },
    };
  }
}

/// Stage for finding nearest vectors
final class _FindNearestStage extends PipelineStage {
  final Field vectorField;
  final List<double> vectorValue;
  final DistanceMeasure distanceMeasure;
  final int? limit;

  _FindNearestStage(
    this.vectorField,
    this.vectorValue,
    this.distanceMeasure, {
    this.limit,
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
    return map;
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
      'args': {
        'limit': limit,
      },
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
      'args': {
        'offset': offset,
      },
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
      'args': {
        'field_paths': fieldPaths,
      },
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
      'args': {
        'expression': expression.toMap(),
      },
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
    return {
      'stage': name,
      'args': sample.toMap(),
    };
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
      'args': {
        'expressions': expressions.map((expr) => expr.toMap()).toList(),
      },
    };
  }
}

/// Stage for sorting results
final class _SortStage extends PipelineStage {
  final Ordering ordering;

  _SortStage(this.ordering);

  @override
  String get name => 'sort';

  @override
  Map<String, dynamic> toMap() {
    return {
      'stage': name,
      'args': {
        'expression': ordering.expression.toMap(),
        'order_direction':
            ordering.direction == OrderDirection.asc ? 'asc' : 'desc',
      },
    };
  }
}

/// Stage for unnesting arrays
final class _UnnestStage extends PipelineStage {
  final Expression expression;
  final String? indexField;

  _UnnestStage(this.expression, this.indexField);

  @override
  String get name => 'unnest';

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'stage': name,
      'args': {
        'expression': expression.toMap(),
      },
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
      'args': {
        'pipeline': pipeline.stages,
      },
    };
  }
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
      'args': {
        'expression': expression.toMap(),
      },
    };
  }
}
