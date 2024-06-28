// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';

import 'interop/storage.dart' as storage_interop;
import 'utils/errors.dart';
import 'utils/task.dart';

/// The web platform implementation of an (Upload)Task.
/// This class wraps a proper [storage_interop.UploadTask] and exposes bindings
/// to its functionality: Stream of changes, a Future notifying of
/// success/errors, and pause/resume/cancel methods.
class TaskWeb extends TaskPlatform {
  /// Creates a Task for web from a [ReferencePlatform] object and a native [storage_interop.UploadTask].
  /// The `reference` is used when creating [TaskSnapshotWeb] of this task.
  TaskWeb(ReferencePlatform reference, storage_interop.UploadTask task)
      : _reference = reference,
        _task = task,
        super();

  final ReferencePlatform _reference;

  final storage_interop.UploadTask _task;

  Stream<TaskSnapshotPlatform>? _stream;

  /// Returns a [Stream] of [TaskSnapshot] events.
  ///
  /// If the task is canceled or fails, the stream will send an error event.
  /// See [TaskState] for more information of the different event types.
  ///
  /// If you do not need to know about on-going stream events, you can instead
  /// wait for the stream to complete via [onComplete].
  @override
  Stream<TaskSnapshotPlatform> get snapshotEvents {
    _stream ??= guard(() {
      // The mobile version of the plugin pushes a "success" snapshot to the
      // onStateChanged stream, but the Firebase JS SDK does *not*.
      // We use a StreamGroup + Future.asStream to simulate that feature:
      // ignore: close_sinks
      final group = StreamGroup<TaskSnapshotPlatform>.broadcast();

      // This stream converts the UploadTask Snapshots from JS to the plugins'
      // It can also throw a FirebaseError internally, so we handle it.
      final onStateChangedStream = _task
          .onStateChanged(
        _reference.storage.app.name,
        _reference.bucket,
        _reference.fullPath,
      )
          .map<TaskSnapshotPlatform>((snapshot) {
        return fbUploadTaskSnapshotToTaskSnapshot(_reference, snapshot);
      });

      group.add(onStateChangedStream);

      onComplete.asStream().last.then((value) async {
        // If successful, we add a final snapshot with the state "success"
        await group.add(onComplete.asStream());
        await group.close();
      }).catchError((e) async {
        // We don't care about the error here as it has already propagated via `guard()`
        // We need to remove the onStateChangedStream from the group and close group for onDone callback to be called
        await group.remove(onStateChangedStream);
        await group.close();
      });

      return group.stream;
    });

    return _stream!;
  }

  /// Returns a [Future] once the task has completed.
  ///
  /// Waiting for the future is not required, instead you can wait for a
  /// completion event via [snapshotEvents].
  @override
  Future<TaskSnapshotPlatform> get onComplete {
    return guard(() async {
      return fbUploadTaskSnapshotToTaskSnapshot(
        _reference,
        await _task.future,
      );
    });
  }

  /// The latest [TaskSnapshot] for this task.
  @override
  TaskSnapshotPlatform get snapshot {
    return fbUploadTaskSnapshotToTaskSnapshot(_reference, _task.snapshot);
  }

  /// Pauses the current task.
  ///
  /// Calling this method will trigger a snapshot event with a [TaskState.paused]
  /// state.
  @override
  Future<bool> pause() async {
    if (snapshot.state == TaskState.paused) {
      return true;
    }

    final paused = _task.pause();
    // Wait until the snapshot is paused, then return the value of paused...
    return snapshotEvents
        .firstWhere((snapshot) => snapshot.state == TaskState.paused)
        .then<bool>((_) => paused);
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
    if (snapshot.state == TaskState.canceled) {
      return true;
    }

    final canceled = _task.cancel();
    // The snapshotEvents will eventually throw an exception when the user cancels.
    // Wait for that signal, and then return the value of "canceled" (or true).
    return snapshotEvents
        .drain()
        .then<bool>((_) => canceled, onError: (_) => canceled);
  }
}
