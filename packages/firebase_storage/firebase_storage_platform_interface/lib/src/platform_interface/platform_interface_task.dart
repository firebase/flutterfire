// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../firebase_storage_platform_interface.dart';

/// The interface a task must implement.
abstract class TaskPlatform extends PlatformInterface {
  // ignore: public_member_api_docs
  TaskPlatform() : super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [TaskPlatform].
  ///
  /// This is used by the app-facing [Task] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verify(TaskPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  /// Returns a [Stream] of [TaskSnapshot] events.
  ///
  /// If the task is canceled or fails, the stream will send an error event.
  /// See [TaskState] for more information of the different event types.
  ///
  /// If you do not need to know about on-going stream events, you can instead
  /// wait for the stream to complete via [onComplete].
  Stream<TaskSnapshotPlatform> get snapshotEvents {
    throw UnimplementedError('snapshotEvents is not implemented');
  }

  /// The latest [TaskSnapshot] for this task.
  TaskSnapshotPlatform get snapshot {
    throw UnimplementedError('snapshot is not implemented');
  }

  /// Returns a [Future] once the task has completed.
  ///
  /// Waiting for the future is not required, instead you can wait for a
  /// completion event via [snapshotEvents].
  Future<TaskSnapshotPlatform> get onComplete {
    throw UnimplementedError('onComplete is not implemented');
  }

  /// Pauses the current task.
  ///
  /// Calling this method will trigger a snapshot event with a [TaskState.paused]
  /// state.
  Future<bool> pause() {
    throw UnimplementedError('pause() is not implemented');
  }

  /// Resumes the current task.
  ///
  /// Calling this method will trigger a snapshot event with a [TaskState.running]
  /// state.
  Future<bool> resume() {
    throw UnimplementedError('resume() is not implemented');
  }

  /// Cancels the current task.
  ///
  /// Calling this method will cause the task to fail. Both the Future ([onComplete])
  /// and stream ([streamEvents]) will trigger an error with a [FirebaseException].
  Future<bool> cancel() {
    throw UnimplementedError('cancel() is not implemented');
  }
}
