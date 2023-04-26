// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class DataSnapshotPlatform extends PlatformInterface {
  DataSnapshotPlatform(this.ref, this._data) : super(token: _token);

  static final Object _token = Object();

  final Map<String, dynamic> _data;

  /// Throws an [AssertionError] if [instance] does not extend
  /// [DocumentSnapshotPlatform].
  ///
  /// This is used by the app-facing [DocumentSnapshot] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verify(DataSnapshotPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  /// The Reference for the location that generated this DataSnapshot.
  final DatabaseReferencePlatform ref;

  /// The key of the location that generated this DataSnapshot.
  String? get key {
    return _data['key'];
  }

  bool get exists {
    return _data['value'] != null;
  }

  Object? get value {
    return _data['value'];
  }

  Object? get priority {
    return _data['priority'];
  }

  /// Returns true if the specified child path has (non-null) data.
  bool hasChild(String path) {
    return child(path).exists;
  }

  DataSnapshotPlatform child(String childPath) {
    throw UnimplementedError('child has not been implemented');
  }

  Iterable<DataSnapshotPlatform> get children {
    throw UnimplementedError('get children has not been implemented');
  }
}
