// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'interop/firestore.dart' as firestore_interop;

/// Web implementation for Firestore [AggregateQueryPlatform].
class AggregateQueryWeb extends AggregateQueryPlatform {
  /// instance of [AggregateQuery] from the web plugin
  final firestore_interop.AggregateQuery _delegate;

  /// [AggregateQueryWeb] represents the data at a particular location for retrieving metadata
  /// without retrieving the actual documents.
  AggregateQueryWeb(
    QueryPlatform query,
    _webQuery,
    this._aggregateQueries,
  )   : _delegate = firestore_interop.AggregateQuery(_webQuery),
        _webQuery = _webQuery,
        super(query);

  final List<AggregateQuery> _aggregateQueries;
  final firestore_interop.Query _webQuery;

  /// Returns an [AggregateQuerySnapshotPlatform] with the count of the documents that match the query.
  @override
  Future<AggregateQuerySnapshotPlatform> get({
    required AggregateSource source,
  }) async {
    // Note: There isn't a source option on the web platform
    firestore_interop.AggregateQuerySnapshot snapshot =
        await _delegate.get(_aggregateQueries);

    List<AggregateQueryResponse> sum = [];
    List<AggregateQueryResponse> average = [];

    for (final query in _aggregateQueries) {
      switch (query.type) {
        case AggregateType.sum:
          sum.add(
            AggregateQueryResponse(
              type: AggregateType.sum,
              value: snapshot.getDataValue(query),
              field: query.field,
            ),
          );
          break;
        case AggregateType.average:
          average.add(
            AggregateQueryResponse(
              type: AggregateType.average,
              value: snapshot.getDataValue(query),
              field: query.field,
            ),
          );
          break;
        default:
          break;
      }
    }

    return AggregateQuerySnapshotPlatform(
      count: snapshot.count,
      sum: sum,
      average: average,
    );
  }

  @override
  AggregateQueryPlatform count() {
    return AggregateQueryWeb(
      query,
      _webQuery,
      [
        ..._aggregateQueries,
        AggregateQuery(
          type: AggregateType.count,
        ),
      ],
    );
  }

  @override
  AggregateQueryPlatform sum(String field) {
    return AggregateQueryWeb(
      query,
      _webQuery,
      [
        ..._aggregateQueries,
        AggregateQuery(type: AggregateType.sum, field: field),
      ],
    );
  }

  @override
  AggregateQueryPlatform average(String field) {
    return AggregateQueryWeb(
      query,
      _webQuery,
      [
        ..._aggregateQueries,
        AggregateQuery(type: AggregateType.average, field: field),
      ],
    );
  }
}
