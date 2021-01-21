// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../../firebase_storage_platform_interface.dart';

/// The interface a task snapshot must extend.
abstract class TaskSnapshotPlatform extends PlatformInterface {
  // ignore: public_member_api_docs
  TaskSnapshotPlatform(this._state, this._data) : super(token: _token);

  static final Object _token = Object();

  final TaskState _state;

  final Map<String, dynamic> _data;

  /// Throws an [AssertionError] if [instance] does not extend
  /// [TaskSnapshotPlatform].
  ///
  /// This is used by the app-facing [TaskSnapshot] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verifyExtends(TaskSnapshotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// The current transferred bytes of this task.
  int get bytesTransferred => _data['bytesTransferred'];

  /// The [FullMetadata] associated with this task.
  ///
  /// May be `null` if no metadata exists.
  FullMetadata? get metadata => _data['metadata'] == null
      ? null
      : FullMetadata(Map<String, dynamic>.from(_data['metadata']));

  /// The [Reference] for this snapshot.
  ReferencePlatform get ref {
    throw UnimplementedError('ref is not implemented');
  }

  /// The current task snapshot state.
  ///
  /// The state indicates the current progress of the task, such as whether it
  /// is running, paused or completed.
  TaskState get state {
    return _state;
  }

  /// The total bytes of the task.
  int get totalBytes => _data['totalBytes'];
}
