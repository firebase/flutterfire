// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'interop/firestore.dart' as firestore_interop;

/// Web implementation for Firestore [AggregateQueryPlatform].
class AggregateQueryWeb extends AggregateQueryPlatform {
  /// instance of Firestore from the web plugin
  // final firestore_interop.Firestore firestoreWeb;

  /// instance of DocumentReference from the web plugin
  final firestore_interop.AggregateQuery _delegate;
  final firestore_interop.Query _webQuery;

  /// Creates an instance of [DocumentReferenceWeb] which represents path
  /// at [pathComponents] and uses implementation of [firestoreWeb]
  AggregateQueryWeb(
  QueryPlatform query, this._webQuery): _delegate = firestore_interop.AggregateQuery(_webQuery), super(query);

  @override
  Future<AggregateQuerySnapshotPlatform> get({required AggregateSource source}) async {
    // There isn't a source option on web
    firestore_interop.AggregateQuerySnapshot snapshot = await _delegate.get();

    return AggregateQuerySnapshotPlatform(count: snapshot.count);
  }
}
