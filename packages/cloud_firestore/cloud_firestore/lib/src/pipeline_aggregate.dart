// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// Base class for aggregate functions used in pipelines
abstract class PipelineAggregateFunction implements PipelineSerializable {
  /// Assigns an alias to this aggregate function
  AliasedAggregateFunction as(String alias) {
    return AliasedAggregateFunction(
      alias: alias,
      aggregateFunction: this,
    );
  }

  String get name;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
    };
  }
}

/// Represents an aggregate function with an alias
class AliasedAggregateFunction implements PipelineSerializable {
  final String _alias;
  final PipelineAggregateFunction aggregateFunction;

  AliasedAggregateFunction({
    required String alias,
    required this.aggregateFunction,
  }) : _alias = alias;

  String get alias => _alias;

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': 'alias',
      'args': {
        'alias': _alias,
        'aggregate_function': aggregateFunction.toMap(),
      },
    };
  }
}

/// Counts all documents in the pipeline result
class CountAll extends PipelineAggregateFunction {
  CountAll();

  @override
  String get name => 'count_all';
}

/// Counts non-null values of the specified expression
class Count extends PipelineAggregateFunction {
  final Expression expression;

  Count(this.expression);

  @override
  String get name => 'count';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['args'] = {
      'expression': expression.toMap(),
    };
    return map;
  }
}

/// Sums numeric values of the specified expression
class Sum extends PipelineAggregateFunction {
  final Expression expression;

  Sum(this.expression);

  @override
  String get name => 'sum';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['args'] = {
      'expression': expression.toMap(),
    };
    return map;
  }
}

/// Calculates average of numeric values of the specified expression
class Average extends PipelineAggregateFunction {
  final Expression expression;

  Average(this.expression);

  @override
  String get name => 'average';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['args'] = {
      'expression': expression.toMap(),
    };
    return map;
  }
}

/// Counts distinct values of the specified expression
class CountDistinct extends PipelineAggregateFunction {
  final Expression expression;

  CountDistinct(this.expression);

  @override
  String get name => 'count_distinct';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['args'] = {
      'expression': expression.toMap(),
    };
    return map;
  }
}

/// Finds minimum value of the specified expression
class Minimum extends PipelineAggregateFunction {
  final Expression expression;

  Minimum(this.expression);

  @override
  String get name => 'minimum';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['args'] = {
      'expression': expression.toMap(),
    };
    return map;
  }
}

/// Finds maximum value of the specified expression
class Maximum extends PipelineAggregateFunction {
  final Expression expression;

  Maximum(this.expression);

  @override
  String get name => 'maximum';

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['args'] = {
      'expression': expression.toMap(),
    };
    return map;
  }
}

/// Represents an aggregate stage with functions and optional grouping
class AggregateStage implements PipelineSerializable {
  final List<AliasedAggregateFunction> accumulators;
  final List<Selectable>? groups;

  AggregateStage({
    required this.accumulators,
    this.groups,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'accumulators': accumulators.map((acc) => acc.toMap()).toList(),
    };
    if (groups != null && groups!.isNotEmpty) {
      map['groups'] = groups!.map((group) => group.toMap()).toList();
    }
    return map;
  }
}

/// Options for aggregate operations
class AggregateOptions implements PipelineSerializable {
  // Add any aggregate-specific options here as needed
  // For now, this is a placeholder for future options

  AggregateOptions();

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{};
  }
}
