// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:collection/collection.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// [AggregateQuerySnapshotPlatform] represents a response to an [AggregateQueryPlatform] request.
class AggregateQuerySnapshotPlatform extends PlatformInterface {
  AggregateQuerySnapshotPlatform({
    required int? count,
    required List<AggregateQueryResponse> sum,
    required List<AggregateQueryResponse> average,
  })  : _count = count,
        _sum = sum,
        _average = average,
        super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [AggregateQuerySnapshotPlatform].
  ///
  /// This is used by the app-facing [AggregateQuerySnapshot] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verifyExtends(AggregateQuerySnapshotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  final int? _count;

  final List<AggregateQueryResponse> _average;

  final List<AggregateQueryResponse> _sum;

  /// Returns the count of the documents that match the query.
  int? get count => _count;

  /// Returns the average of the documents that match the query.
  /// The key is the field name and the value is the average.
  double? getAverage(String field) {
    return _average
        .firstWhereOrNull((element) => element.field == field)
        ?.value;
  }

  /// Returns the sum of the documents that match the query.
  /// The key is the field name and the value is the sum.
  double? getSum(String field) {
    return _sum.firstWhereOrNull((element) => element.field == field)?.value;
  }
}
