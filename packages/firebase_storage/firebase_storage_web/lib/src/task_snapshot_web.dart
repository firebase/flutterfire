// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';

import 'interop/storage.dart' as storage_interop;
import 'utils/metadata.dart';
import 'utils/task.dart';

/// Implementation for a [TaskSnapshotPlatform].
class TaskSnapshotWeb extends TaskSnapshotPlatform {
  /// Create a TaskSnapshotWeb from its [ReferencePlatform] and a native [fb.UploadTaskSnapshot]
  TaskSnapshotWeb(
      ReferencePlatform ref, storage_interop.UploadTaskSnapshot snapshot)
      : _reference = ref,
        _snapshot = snapshot,
        super(fbTaskStateToTaskState(snapshot.state), {});

  /// The [FirebaseStoragePlatform] used to create the task.
  final ReferencePlatform _reference;

  final storage_interop.UploadTaskSnapshot _snapshot;

  /// The current transferred bytes of this task.
  @override
  int get bytesTransferred => _snapshot.bytesTransferred;

  /// The [FullMetadata] associated with this task.
  ///
  /// May be `null` if no metadata exists.
  @override
  FullMetadata get metadata => fbFullMetadataToFullMetadata(_snapshot.metadata);

  /// The [Reference] for this snapshot.
  @override
  ReferencePlatform get ref {
    return _reference;
  }

  /// The current task snapshot state.
  ///
  /// The state indicates the current progress of the task, such as whether it
  /// is running, paused or completed.
  @override
  TaskState get state {
    return fbTaskStateToTaskState(_snapshot.state);
  }

  /// The total bytes of the task.
  @override
  int get totalBytes => _snapshot.totalBytes;
}
