// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:meta/meta.dart' show required;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../types.dart';

/// The Query platform interface.
abstract class QueryPlatform extends PlatformInterface {
  /// Constructor
  QueryPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The default instance of [QueryPlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [QueryPlatform] when they register themselves.
  static QueryPlatform get instance => _instance;

  static QueryPlatform _instance;

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(QueryPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Actual interface

  /// A Stream of QuerySnapshots.
  /// The snapshot stream is never-ending.
  // TODO(ditman): Type the return of this Stream (PlatformQuerySnapshot?)
  Stream<PlatformQuerySnapshot> snapshots(
    String app, {
    @required String path,
    bool isCollectionGroup,
    Map<String, dynamic> parameters,
    bool includeMetadataChanges,
  }) {
    throw UnimplementedError('QueryPlatform::snapshots() is not implemented');
  }

  /// What does this method correspond to in the Firebase API?
  // TODO(ditman): Type this return (PlatformQueryDocument?)
  Future<PlatformQuerySnapshot> getDocuments(
    String app, {
    @required String path,
    bool isCollectionGroup,
    Map<String, dynamic> parameters,
    Source source,
  }) async {
    throw UnimplementedError(
        'QueryPlatform::getDocuments() is not implemented');
  }
}
