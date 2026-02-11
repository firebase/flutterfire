// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// Base class for aggregate functions used in pipelines
abstract class PipelineAggregateFunction implements PipelineSerializable {
  String? _alias;

  /// Assigns an alias to this aggregate function
  PipelineAggregateFunction as(String alias) {
    _alias = alias;
    return this;
  }

  String? get alias => _alias;

  String get name;

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
    };
    if (_alias != null) {
      map['alias'] = _alias;
    }
    return map;
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
