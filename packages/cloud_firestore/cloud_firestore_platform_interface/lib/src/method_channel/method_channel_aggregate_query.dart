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
  ) : super(query);

  final FirestorePigeonFirebaseApp _pigeonApp;
  final String _path;
  final PigeonQueryParameters _pigeonParameters;

  @override
  Future<AggregateQuerySnapshotPlatform> get({
    required AggregateSource source,
  }) async {
    switch (aggregateType) {
      case AggregateType.count:
        return _getCount(source);
      case AggregateType.sum:
        return _getSum(source);
      case AggregateType.average:
        return _getAverage(source);
    }
  }

  Future<AggregateQuerySnapshotPlatform> _getCount(
    AggregateSource source,
  ) async {
    final data = await MethodChannelFirebaseFirestore.pigeonChannel
        .aggregateQueryCount(_pigeonApp, _path, _pigeonParameters, source);

    return AggregateQuerySnapshotPlatform(
      count: data.toInt(),
      sum,
    );
  }

  Future<AggregateQuerySnapshotPlatform> _getSum(
    AggregateSource source,
  ) async {
    final data = await MethodChannelFirebaseFirestore.pigeonChannel
        .aggregateQuerySum(_pigeonApp, _path, _pigeonParameters, source);

    return AggregateQuerySnapshotPlatform(
      sum: data,
    );
  }

  Future<AggregateQuerySnapshotPlatform> _getAverage(
    AggregateSource source,
  ) async {
    final data = await MethodChannelFirebaseFirestore.pigeonChannel
        .aggregateQueryAverage(_pigeonApp, _path, _pigeonParameters, source);

    return AggregateQuerySnapshotPlatform(
      average: data,
    );
  }
}
