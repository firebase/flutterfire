// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_query_snapshot.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/utils/exception.dart';

import '../../cloud_firestore_platform_interface.dart';
import 'method_channel_firestore.dart';

/// An implementation of [VectorQueryPlatform] for the [MethodChannel]
class MethodChannelVectorQuery extends VectorQueryPlatform {
  MethodChannelVectorQuery(
    this.firestore,
    query,
    this._pigeonParameters,
    this._path,
    this._pigeonApp,
    this._queryVector,
    this._limit,
    this._distanceMeasure,
    this._options,
    this._isCollectionGroupQuery,
  ) : super(query);

  final FirebaseFirestorePlatform firestore;
  final FirestorePigeonFirebaseApp _pigeonApp;
  final String _path;
  final PigeonQueryParameters _pigeonParameters;
  final bool _isCollectionGroupQuery;

  final int _limit;
  final DistanceMeasure _distanceMeasure;
  final List<double> _queryVector;
  final VectorQueryOptions _options;

  @override
  Future<QuerySnapshotPlatform> get({
    required VectorSource source,
  }) async {
    try {
      final PigeonQuerySnapshot result =
          await MethodChannelFirebaseFirestore.pigeonChannel.findNearest(
        _pigeonApp,
        _path,
        _isCollectionGroupQuery,
        _pigeonParameters,
        _queryVector,
        source,
        _limit,
        _options,
        _distanceMeasure,
      );

      return MethodChannelQuerySnapshot(firestore, result);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }
}
