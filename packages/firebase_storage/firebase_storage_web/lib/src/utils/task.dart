// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';

import '../interop/storage.dart' as storage_interop;
import '../task_snapshot_web.dart';

Map<storage_interop.TaskState, TaskState> _fbTaskStateToTaskState = {
  storage_interop.TaskState.CANCELED: TaskState.canceled,
  storage_interop.TaskState.ERROR: TaskState.error,
  storage_interop.TaskState.PAUSED: TaskState.paused,
  storage_interop.TaskState.RUNNING: TaskState.running,
  storage_interop.TaskState.SUCCESS: TaskState.success,
};

/// Converts TaskStates from the JS interop layer to TaskStates for the plugin
TaskState fbTaskStateToTaskState(storage_interop.TaskState state) {
  return _fbTaskStateToTaskState[state]!;
}

/// Converts UploadTaskSnapshot from the JS interop layer to TaskSnapshotWeb for the plugin.
TaskSnapshotWeb fbUploadTaskSnapshotToTaskSnapshot(
    ReferencePlatform reference, storage_interop.UploadTaskSnapshot snapshot) {
  return TaskSnapshotWeb(reference, snapshot);
}
