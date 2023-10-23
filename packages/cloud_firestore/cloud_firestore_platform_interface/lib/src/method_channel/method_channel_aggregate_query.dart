// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../cloud_firestore_platform_interface.dart';
import 'method_channel_firestore.dart';

/// An implementation of [AggregateQueryPlatform] for the [MethodChannel]
class MethodChannelAggregateQuery extends AggregateQueryPlatform {
  MethodChannelAggregateQuery(
    query,
    this._pigeonParameters,
    this._path,
    this._pigeonApp,
    this._aggregateQueries,
  ) : super(query);

  final FirestorePigeonFirebaseApp _pigeonApp;
  final String _path;
  final PigeonQueryParameters _pigeonParameters;

  final List<AggregateQuery> _aggregateQueries;

  @override
  Future<AggregateQuerySnapshotPlatform> get({
    required AggregateSource source,
  }) async {
    final data =
        await MethodChannelFirebaseFirestore.pigeonChannel.aggregateQuery(
      _pigeonApp,
      _path,
      _pigeonParameters,
      source,
      _aggregateQueries,
    );

    int? count;
    List<AggregateQueryResponse> sum = [];
    List<AggregateQueryResponse> average = [];
    for (final query in data) {
      if (query == null) continue;
      switch (query.type) {
        case AggregateType.count:
          count = query.value.toInt();
          break;
        case AggregateType.sum:
          sum.add(query);
          break;
        case AggregateType.average:
          average.add(query);
          break;
      }
    }

    return AggregateQuerySnapshotPlatform(
      count: count,
      sum: sum,
      average: average,
    );
  }

  @override
  AggregateQueryPlatform count() {
    return MethodChannelAggregateQuery(
      query,
      _pigeonParameters,
      _path,
      _pigeonApp,
      [
        ..._aggregateQueries,
        AggregateQuery(type: AggregateType.count),
      ],
    );
  }

  @override
  AggregateQueryPlatform sum(String field) {
    return MethodChannelAggregateQuery(
      query,
      _pigeonParameters,
      _path,
      _pigeonApp,
      [
        ..._aggregateQueries,
        AggregateQuery(type: AggregateType.sum, field: field),
      ],
    );
  }

  @override
  AggregateQueryPlatform average(String field) {
    return MethodChannelAggregateQuery(
      query,
      _pigeonParameters,
      _path,
      _pigeonApp,
      [
        ..._aggregateQueries,
        AggregateQuery(type: AggregateType.average, field: field),
      ],
    );
  }
}
