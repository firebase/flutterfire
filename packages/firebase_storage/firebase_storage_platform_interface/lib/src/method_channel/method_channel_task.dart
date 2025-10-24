// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_storage_platform_interface.dart';
import '../pigeon/messages.pigeon.dart';
import 'method_channel_firebase_storage.dart';
import 'method_channel_task_snapshot.dart';
import 'utils/exception.dart';

/// Implementation for a [TaskPlatform].
///
/// Other implementations for specific tasks should extend this class.
abstract class MethodChannelTask extends TaskPlatform {
  /// Creates a new [MethodChannelTask] with a given task.
  MethodChannelTask(
    this._handle,
    this.storage,
    String path,
    this._initialTask,
  ) : super() {
    Stream<TaskSnapshotPlatform> mapNativeStream() async* {
      final observerId = await _initialTask;

      final nativePlatformStream =
          MethodChannelFirebaseStorage.storageTaskChannel(observerId)
              .receiveBroadcastStream();
      try {
        await for (final events in nativePlatformStream) {
          final taskState = TaskState.values[events['taskState']];
          if (taskState == TaskState.error) {
            _didComplete = true;
            final errorMap = Map<String, dynamic>.from(events['error']);
            String code = errorMap['code'];

            // If native surfaced an unknown error but we already transitioned the
            // task snapshot to canceled (due to a local cancel), surface as canceled.
            if (code != 'canceled' && snapshot.state == TaskState.canceled) {
              code = 'canceled';
            }

            final exception = FirebaseException(
              plugin: 'firebase_storage',
              code: code,
              message: errorMap['message'],
            );
            if (code != 'canceled') {
              // If the task was canceled, we keep the previous snapshot data with canceled state.
              _snapshot = MethodChannelTaskSnapshot(
                storage,
                taskState,
                // We use previous snapshot data as errors from native do not provide snapshot data.
                {
                  'path': path,
                  'bytesTransferred': _snapshot.bytesTransferred,
                  'totalBytes': _snapshot.totalBytes,
                  'metadata': _snapshot.metadata
                },
              );
            }
            _exception = exception;
            _completer?.completeError(exception);
            if (_userListening) {
              // If the user is listening to the stream, yield the error. Otherwise, it results in an unhandled exception.
              yield* Stream.error(exception);
            }

            break;
          }
          if (taskState == TaskState.canceled) {
            _didComplete = true;
            MethodChannelTaskSnapshot snapshot = MethodChannelTaskSnapshot(
                storage,
                taskState,
                Map<String, dynamic>.from(events['snapshot']));
            _snapshot = snapshot;
            break;
          }

          if ((taskState == TaskState.success ||
                  taskState == TaskState.running ||
                  taskState == TaskState.paused)
              // Required for android which fires another event when already cancelled
              &&
              snapshot.state != TaskState.canceled) {
            MethodChannelTaskSnapshot snapshot = MethodChannelTaskSnapshot(
                storage,
                taskState,
                Map<String, dynamic>.from(events['snapshot']));
            _snapshot = snapshot;

            yield snapshot;
          }

          // If the stream event is complete, trigger the
          // completer to resolve with the snapshot.
          if (taskState == TaskState.success) {
            _didComplete = true;
            _completer?.complete(snapshot);
            break;
          }
        }
      } catch (exception, stack) {
        convertPlatformException(exception, stack);
      }
    }

    _stream = mapNativeStream().asBroadcastStream(
        onListen: (sub) => sub.resume(), onCancel: (sub) => sub.cancel());

    // Keep reference to whether the initial "start" task has completed.
    _snapshot = MethodChannelTaskSnapshot(storage, TaskState.running, {
      'path': path,
      'bytesTransferred': 0,
      'totalBytes': 1,
    });
  }

  bool _userListening = false;

  ///  FirebaseApp pigeon instance
  static PigeonStorageFirebaseApp pigeonFirebaseApp(
      FirebaseStoragePlatform storage) {
    return PigeonStorageFirebaseApp(
      appName: storage.app.name,
      bucket: storage.bucket,
    );
  }

  /// Convert [TaskState] to [PigeonStorageTaskState]
  PigeonStorageTaskState convertToPigeonTaskState(TaskState state) {
    switch (state) {
      case TaskState.canceled:
        return PigeonStorageTaskState.canceled;
      case TaskState.error:
        return PigeonStorageTaskState.error;
      case TaskState.paused:
        return PigeonStorageTaskState.paused;
      case TaskState.running:
        return PigeonStorageTaskState.running;
      case TaskState.success:
        return PigeonStorageTaskState.success;
    }
  }

  Object? _exception;

  bool _didComplete = false;

  Completer<TaskSnapshotPlatform>? _completer;

  late Stream<TaskSnapshotPlatform> _stream;

  Future<String> _initialTask;

  final int _handle;

  /// The [FirebaseStoragePlatform] used to create the task.
  final FirebaseStoragePlatform storage;

  late TaskSnapshotPlatform _snapshot;

  @override
  Stream<TaskSnapshotPlatform> get snapshotEvents {
    _userListening = true;
    return _stream;
  }

  @override
  TaskSnapshotPlatform get snapshot => _snapshot;

  @override
  Future<TaskSnapshotPlatform> get onComplete async {
    if (_didComplete && _exception == null) {
      return Future.value(snapshot);
    } else if (_didComplete && _exception != null) {
      return catchFuturePlatformException(_exception!, StackTrace.current);
    } else {
      // Call _stream.last to trigger the stream initialization, in case it hasn't been.
      // ignore: unawaited_futures
      _stream.last.catchError((_) {
        // We ignore the exception here, stream exceptions are propagated in the stream handler above
        // This causes unhandled exceptions when task.listen & onComplete are used together.
        return Future.value(snapshot);
      });
      _completer ??= Completer<TaskSnapshotPlatform>();
      return _completer!.future;
    }
  }

  @override
  Future<bool> pause() async {
    try {
      Map<String, dynamic>? data = (await MethodChannelFirebaseStorage
              .pigeonChannel
              .taskPause(MethodChannelTask.pigeonFirebaseApp(storage), _handle))
          .cast<String, dynamic>();

      final success = data['status'] ?? false;
      if (success) {
        _snapshot = MethodChannelTaskSnapshot(storage, TaskState.paused,
            Map<String, dynamic>.from(data['snapshot']));
      }
      return success;
    } catch (e, stack) {
      return catchFuturePlatformException<bool>(e, stack);
    }
  }

  @override
  Future<bool> resume() async {
    try {
      Map<String, dynamic>? data =
          (await MethodChannelFirebaseStorage.pigeonChannel.taskResume(
                  MethodChannelTask.pigeonFirebaseApp(storage), _handle))
              .cast<String, dynamic>();

      final success = data['status'] ?? false;
      if (success) {
        _snapshot = MethodChannelTaskSnapshot(storage, TaskState.running,
            Map<String, dynamic>.from(data['snapshot']));
      }
      return success;
    } catch (e, stack) {
      return catchFuturePlatformException<bool>(e, stack);
    }
  }

  @override
  Future<bool> cancel() async {
    try {
      Map<String, dynamic>? data =
          (await MethodChannelFirebaseStorage.pigeonChannel.taskCancel(
                  MethodChannelTask.pigeonFirebaseApp(storage), _handle))
              .cast<String, dynamic>();

      final success = data['status'] ?? false;
      if (success) {
        _snapshot = MethodChannelTaskSnapshot(storage, TaskState.canceled,
            Map<String, dynamic>.from(data['snapshot']));
      }
      return success;
    } catch (e, stack) {
      return catchFuturePlatformException<bool>(e, stack);
    }
  }
}

/// Implementation for [putFile] tasks.
class MethodChannelPutFileTask extends MethodChannelTask {
  // ignore: public_member_api_docs
  MethodChannelPutFileTask(int handle, FirebaseStoragePlatform storage,
      String path, File file, SettableMetadata? metadata)
      : super(handle, storage, path,
            _getTask(handle, storage, path, file, metadata));

  static Future<String> _getTask(int handle, FirebaseStoragePlatform storage,
      String path, File file, SettableMetadata? metadata) {
    PigeonSettableMetadata? pigeonSettableMetadata;
    if (defaultTargetPlatform == TargetPlatform.windows) {
      // TODO(russellwheatley): sending null to windows throws exception so we pass empty metadata
      pigeonSettableMetadata =
          MethodChannelFirebaseStorage.getPigeonSettableMetaData(metadata);
    } else {
      pigeonSettableMetadata = metadata == null
          ? null
          : MethodChannelFirebaseStorage.getPigeonSettableMetaData(metadata);
    }
    return MethodChannelFirebaseStorage.pigeonChannel.referencePutFile(
      MethodChannelTask.pigeonFirebaseApp(storage),
      MethodChannelFirebaseStorage.getPigeonReference(
          storage.bucket, path, 'putFile'),
      file.path,
      pigeonSettableMetadata,
      handle,
    );
  }
}

/// Implementation for [putString] tasks.
class MethodChannelPutStringTask extends MethodChannelTask {
  // ignore: public_member_api_docs
  MethodChannelPutStringTask(
      int handle,
      FirebaseStoragePlatform storage,
      String path,
      String data,
      PutStringFormat format,
      SettableMetadata? metadata)
      : super(handle, storage, path,
            _getTask(handle, storage, path, data, format, metadata));

  static Future<String> _getTask(
      int handle,
      FirebaseStoragePlatform storage,
      String path,
      String data,
      PutStringFormat format,
      SettableMetadata? metadata) {
    return MethodChannelFirebaseStorage.pigeonChannel.referencePutString(
      MethodChannelTask.pigeonFirebaseApp(storage),
      MethodChannelFirebaseStorage.getPigeonReference(
          storage.bucket, path, 'putString'),
      data,
      format.index,
      MethodChannelFirebaseStorage.getPigeonSettableMetaData(metadata),
      handle,
    );
  }
}

/// Implementation for [put] tasks.
class MethodChannelPutTask extends MethodChannelTask {
  // ignore: public_member_api_docs
  MethodChannelPutTask(int handle, FirebaseStoragePlatform storage, String path,
      Uint8List data, SettableMetadata? metadata)
      : super(handle, storage, path,
            _getTask(handle, storage, path, data, metadata));

  static Future<String> _getTask(int handle, FirebaseStoragePlatform storage,
      String path, Uint8List data, SettableMetadata? metadata) {
    return MethodChannelFirebaseStorage.pigeonChannel.referencePutData(
      MethodChannelTask.pigeonFirebaseApp(storage),
      MethodChannelFirebaseStorage.getPigeonReference(
          storage.bucket, path, 'putData'),
      data,
      MethodChannelFirebaseStorage.getPigeonSettableMetaData(metadata),
      handle,
    );
  }
}

/// Implementation for [writeToFile] tasks.
class MethodChannelDownloadTask extends MethodChannelTask {
  // ignore: public_member_api_docs
  MethodChannelDownloadTask(
      int handle, FirebaseStoragePlatform storage, String path, File file)
      : super(handle, storage, path, _getTask(handle, storage, path, file));

  static Future<String> _getTask(
      int handle, FirebaseStoragePlatform storage, String path, File file) {
    return MethodChannelFirebaseStorage.pigeonChannel.referenceDownloadFile(
      MethodChannelTask.pigeonFirebaseApp(storage),
      MethodChannelFirebaseStorage.getPigeonReference(
          storage.bucket, path, 'writeToFile'),
      file.path,
      handle,
    );
  }
}
