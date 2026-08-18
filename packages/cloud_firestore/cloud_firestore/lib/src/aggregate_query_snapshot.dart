// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// [AggregateQuerySnapshot] represents a response to an [AggregateQuery] request.
class AggregateQuerySnapshot {
  AggregateQuerySnapshot._(this._delegate, this.query) {
    AggregateQuerySnapshotPlatform.verifyExtends(_delegate);
  }
  final AggregateQuerySnapshotPlatform _delegate;

  /// [Query] represents the query over the data at a particular location used by the [AggregateQuery] to
  /// retrieve the metadata.
  final Query query;

  /// Returns the count of the documents that match the query.
  int? get count => _delegate.count;

  /// Returns the sum of the values of the documents that match the query.
  double? getSum(String field) => _delegate.getSum(field);

  /// Returns the average of the values of the documents that match the query.
  double? getAverage(String field) => _delegate.getAverage(field);
}
