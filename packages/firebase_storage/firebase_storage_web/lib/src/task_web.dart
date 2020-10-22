// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:async/async.dart';

import 'package:firebase/firebase.dart' as fb;
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_storage_web/src/utils/errors.dart';

import '../firebase_storage_web.dart';
import 'utils/task.dart';

/// Doc
class TaskWeb extends TaskPlatform {
  final FirebaseStorageWeb _storage;

  final fb.UploadTask _task;

  Future<TaskSnapshotPlatform> _onComplete;
  Stream<TaskSnapshotPlatform> _snapshotEvents;

  /// Doc
  TaskWeb(FirebaseStorageWeb storage, fb.UploadTask task)
      : _storage = storage,
        _task = task,
        super() {
    // This future represents the internal state of the Task.
    // It not only signals when the Task is done, but also when it fails.
    // The frontend Task uses _delegate.onComplete when implementing the
    // Future interface, so we must ensure we reject with the correct
    // type of Exception.
    _onComplete = _task.future
        .then<TaskSnapshotPlatform>(
      (snapshot) => fbUploadTaskSnapshotToTaskSnapshot(storage, snapshot),
    )
        .catchError((e) {
      fbFirebaseErrorToFirebaseException(e);
    });

    // The mobile version of the plugin pushes a "success" snapshot to the
    // onStateChanged stream, but the Firebase JS SDK does *not*.
    // We use a StreamGroup + Future.asStream to simulate that feature:
    final group = StreamGroup<TaskSnapshotPlatform>.broadcast();

    // This stream converts the UploadTask Snapshots from JS to the plugins'
    // It can also throw a FirebaseError internally, so we handle it.
    final onStateChangedStream = _task.onStateChanged
        .map<TaskSnapshotPlatform>(
            (snapshot) => fbUploadTaskSnapshotToTaskSnapshot(storage, snapshot))
        .handleError((e) {
      fbFirebaseErrorToFirebaseException(e);
    });

    group.add(onStateChangedStream);
    group.add(_onComplete.asStream());

    _snapshotEvents = group.stream;
  }

  /// Returns a [Stream] of [TaskSnapshot] events.
  ///
  /// If the task is canceled or fails, the stream will send an error event.
  /// See [TaskState] for more information of the different event types.
  ///
  /// If you do not need to know about on-going stream events, you can instead
  /// wait for the stream to complete via [onComplete].
  @override
  Stream<TaskSnapshotPlatform> get snapshotEvents => _snapshotEvents;

  /// The latest [TaskSnapshot] for this task.
  @override
  TaskSnapshotPlatform get snapshot {
    return fbUploadTaskSnapshotToTaskSnapshot(_storage, _task.snapshot);
  }

  /// Returns a [Future] once the task has completed.
  ///
  /// Waiting for the future is not required, instead you can wait for a
  /// completion event via [snapshotEvents].
  @override
  Future<TaskSnapshotPlatform> get onComplete => _onComplete;

  /// Pauses the current task.
  ///
  /// Calling this method will trigger a snapshot event with a [TaskState.paused]
  /// state.
  @override
  Future<bool> pause() async {
    return _task.pause();
  }

  /// Resumes the current task.
  ///
  /// Calling this method will trigger a snapshot event with a [TaskState.running]
  /// state.
  @override
  Future<bool> resume() async {
    return _task.resume();
  }

  /// Cancels the current task.
  ///
  /// Calling this method will cause the task to fail. Both the Future ([onComplete])
  /// and stream ([streamEvents]) will trigger an error with a [FirebaseException].
  @override
  Future<bool> cancel() async {
    return _task.cancel();
  }
}
