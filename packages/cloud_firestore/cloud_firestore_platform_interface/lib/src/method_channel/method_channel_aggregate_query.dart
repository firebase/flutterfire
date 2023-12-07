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
    this._isCollectionGroupQuery,
  ) : super(query);

  final FirestorePigeonFirebaseApp _pigeonApp;
  final String _path;
  final PigeonQueryParameters _pigeonParameters;
  final bool _isCollectionGroupQuery;

  @override
  Future<AggregateQuerySnapshotPlatform> get({
    required AggregateSource source,
  }) async {
    final data =
        await MethodChannelFirebaseFirestore.pigeonChannel.aggregateQueryCount(
      _pigeonApp,
      _path,
      _pigeonParameters,
      source,
      _isCollectionGroupQuery,
    );

    return AggregateQuerySnapshotPlatform(
      count: data.toInt(),
    );
  }
}
