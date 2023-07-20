// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


import 'method_channel_firestore.dart';
import '../../cloud_firestore_platform_interface.dart';

/// An implementation of [AggregateQueryPlatform] for the [MethodChannel]
class MethodChannelAggregateQuery extends AggregateQueryPlatform {
  MethodChannelAggregateQuery(QueryPlatform query, this.pigeonApp,) : super(query);

  final PigeonFirebaseApp pigeonApp;

  @override
  Future<AggregateQuerySnapshotPlatform> get({
    required AggregateSource source,
  }) async {
    await MethodChannelFirebaseFirestore
        .pigeonChannel
        .aggregateQueryCount(pigeonApp, query., arg_parameters, arg_options, arg_source);
    

    return AggregateQuerySnapshotPlatform(
      count: data!['count'] as int,
    );
  }
}
