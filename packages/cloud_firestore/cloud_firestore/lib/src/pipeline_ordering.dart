// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// Direction for ordering results
enum OrderDirection {
  /// Ascending order
  asc,

  /// Descending order
  desc,
}

/// Represents an ordering specification for pipeline sorting
class Ordering implements PipelineSerializable {
  final Expression expression;
  final OrderDirection direction;

  Ordering(this.expression, this.direction);

  @override
  Map<String, dynamic> toMap() {
    return {
      'expression': expression.toMap(),
      'order_direction': direction == OrderDirection.asc ? 'asc' : 'desc',
    };
  }
}
