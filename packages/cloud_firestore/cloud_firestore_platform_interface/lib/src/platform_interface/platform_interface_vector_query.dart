// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../cloud_firestore_platform_interface.dart';

/// [VectorQueryPlatform] represents the data at a particular location for retrieving metadata
/// without retrieving the actual documents.
abstract class VectorQueryPlatform extends PlatformInterface {
  VectorQueryPlatform(this.query) : super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [VectorQueryPlatform].
  ///
  /// This is used by the app-facing [VectorQuery] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verify(VectorQueryPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  /// The [QueryPlatform] instance to which this [VectorQueryPlatform] queries against to retrieve the metadata.
  final QueryPlatform query;

  /// Returns an [VectorQuerySnapshotPlatform] .
  Future<QuerySnapshotPlatform> get({
    required VectorSource source,
  }) async {
    throw UnimplementedError('get() is not implemented');
  }
}

class VectorValue {
  final List<double> value;
  VectorValue(this.value);

  List<double> toList() {
    return value;
  }
}
