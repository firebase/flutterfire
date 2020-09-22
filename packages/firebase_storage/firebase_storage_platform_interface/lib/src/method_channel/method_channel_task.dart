// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';

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
    // Keep reference to whether the initial "start" task has completed.
    _initialTaskCompleter = Completer<void>();
    _snapshot = MethodChannelTaskSnapshot(storage, TaskState.running, {
      'path': path,
      'bytesTransferred': 0,
      'totalBytes': 1,
    });
    _initialTask().then((_) {
      _initialTaskCompleter.complete();
    }).catchError((Object e, StackTrace stackTrace) {
      _initialTaskCompleter.completeError(e, stackTrace);
      _didComplete = true;
      _exception = e;
      _stackTrace = stackTrace;
      if (_completer != null) {
        catchFuturePlatformException(e, stackTrace)
            .catchError(_completer.completeError);
      }
    });

    // Get the task stream.
    _stream = MethodChannelFirebaseStorage.taskObservers[_handle].stream;
    StreamSubscription _subscription;

    // Listen for stream events.
    _subscription = _stream.listen((TaskSnapshotPlatform snapshot) async {
      if (_snapshot.state != TaskState.canceled) {
        _snapshot = snapshot;
      }

      // If the stream event is complete, trigger the
      // completer to resolve with the snapshot.
      if (snapshot.state == TaskState.success) {
        _didComplete = true;
        _completer?.complete(snapshot);
        await _subscription.cancel();
      }
    }, onError: (Object e, StackTrace stackTrace) {
      if (e is FirebaseException && e.code == 'canceled') {
        _snapshot = MethodChannelTaskSnapshot(storage, TaskState.canceled, {
          'path': path,
          'bytesTransferred': _snapshot.bytesTransferred,
          'totalBytes': _snapshot.totalBytes,
        });
      } else {
        _snapshot = MethodChannelTaskSnapshot(storage, TaskState.error, {
          'path': path,
          'bytesTransferred': _snapshot.bytesTransferred,
          'totalBytes': _snapshot.totalBytes,
        });
      }
      _didComplete = true;
      _exception = e;
      _stackTrace = stackTrace;
      if (_completer != null) {
        catchFuturePlatformException(e, stackTrace)
            .catchError(_completer.completeError);
      }
    }, cancelOnError: true);
  }

  Object _exception;

  StackTrace _stackTrace;

  bool _didComplete = false;

  Completer<TaskSnapshotPlatform> _completer;

  Stream<TaskSnapshotPlatform> _stream;

  Completer<void> _initialTaskCompleter;

  Future<void> Function() _initialTask;

  final int _handle;

  /// The [FirebaseStoragePlatform] used to create the task.
  final FirebaseStoragePlatform storage;

  TaskSnapshotPlatform _snapshot;

  @override
  Stream<TaskSnapshotPlatform> get snapshotEvents {
    return MethodChannelFirebaseStorage.taskObservers[_handle].stream;
  }

  @override
  TaskSnapshotPlatform get snapshot => _snapshot;

  @override
  Future<TaskSnapshotPlatform> get onComplete async {
    if (_didComplete && _exception == null) {
      return Future.value(snapshot);
    } else if (_didComplete && _exception != null) {
      return catchFuturePlatformException(_exception, _stackTrace);
    } else {
      if (_completer == null) {
        _completer = Completer<TaskSnapshotPlatform>();
      }

      return _completer.future;
    }
  }

  @override
  Future<bool> pause() async {
    try {
      if (!_initialTaskCompleter.isCompleted) {
        await _initialTaskCompleter.future;
      }

      Map<String, dynamic> data = await MethodChannelFirebaseStorage.channel
          .invokeMapMethod<String, dynamic>('Task#pause', <String, dynamic>{
        'handle': _handle,
      });

      bool success = data['status'];
      if (success) {
        _snapshot = MethodChannelTaskSnapshot(storage, TaskState.paused,
            Map<String, dynamic>.from(data['snapshot']));
      }
      return success;
    } catch (e) {
      return catchFuturePlatformException<bool>(e);
    }
  }

  @override
  Future<bool> resume() async {
    try {
      if (!_initialTaskCompleter.isCompleted) {
        await _initialTaskCompleter.future;
      }

      Map<String, dynamic> data = await MethodChannelFirebaseStorage.channel
          .invokeMapMethod<String, dynamic>('Task#resume', <String, dynamic>{
        'handle': _handle,
      });

      bool success = data['status'];
      if (success) {
        _snapshot = MethodChannelTaskSnapshot(storage, TaskState.running,
            Map<String, dynamic>.from(data['snapshot']));
      }
      return success;
    } catch (e) {
      return catchFuturePlatformException<bool>(e);
    }
  }

  @override
  Future<bool> cancel() async {
    try {
      if (!_initialTaskCompleter.isCompleted) {
        await _initialTaskCompleter.future;
      }

      Map<String, dynamic> data = await MethodChannelFirebaseStorage.channel
          .invokeMapMethod<String, dynamic>('Task#cancel', <String, dynamic>{
        'handle': _handle,
      });

      bool success = data['status'];
      if (success) {
        _snapshot = MethodChannelTaskSnapshot(storage, TaskState.canceled,
            Map<String, dynamic>.from(data['snapshot']));
      }
      return success;
    } catch (e) {
      return catchFuturePlatformException<bool>(e);
    }
  }
}

/// Implementation for [putFile] tasks.
class MethodChannelPutFileTask extends MethodChannelTask {
  // ignore: public_member_api_docs
  MethodChannelPutFileTask(int handle, FirebaseStoragePlatform storage,
      String path, File file, SettableMetadata metadata)
      : super(handle, storage, path,
            _getTask(handle, storage, path, file, metadata));

  static Future<void> Function() _getTask(
      int handle,
      FirebaseStoragePlatform storage,
      String path,
      File file,
      SettableMetadata metadata) {
    return () => MethodChannelFirebaseStorage.channel
            .invokeMethod<void>('Task#startPutFile', <String, dynamic>{
          'appName': storage.app.name,
          'maxOperationRetryTime': storage.maxOperationRetryTime,
          'maxUploadRetryTime': storage.maxUploadRetryTime,
          'maxDownloadRetryTime': storage.maxDownloadRetryTime,
          'bucket': storage.bucket,
          'handle': handle,
          'path': path,
          'filePath': file.absolute.path,
          'metadata': metadata?.asMap(),
        });
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
      SettableMetadata metadata)
      : super(handle, storage, path,
            _getTask(handle, storage, path, data, format, metadata));

  static Future<void> Function() _getTask(
      int handle,
      FirebaseStoragePlatform storage,
      String path,
      String data,
      PutStringFormat format,
      SettableMetadata metadata) {
    return () => MethodChannelFirebaseStorage.channel
            .invokeMethod<void>('Task#startPutString', <String, dynamic>{
          'appName': storage.app.name,
          'bucket': storage.bucket,
          'maxOperationRetryTime': storage.maxOperationRetryTime,
          'maxUploadRetryTime': storage.maxUploadRetryTime,
          'maxDownloadRetryTime': storage.maxDownloadRetryTime,
          'handle': handle,
          'path': path,
          'data': data,
          'format': format.index,
          'metadata': metadata?.asMap(),
        });
  }
}

/// Implementation for [put] tasks.
class MethodChannelPutTask extends MethodChannelTask {
  // ignore: public_member_api_docs
  MethodChannelPutTask(int handle, FirebaseStoragePlatform storage, String path,
      Uint8List data, SettableMetadata metadata)
      : super(handle, storage, path,
            _getTask(handle, storage, path, data, metadata));

  static Future<void> Function() _getTask(
      int handle,
      FirebaseStoragePlatform storage,
      String path,
      Uint8List data,
      SettableMetadata metadata) {
    return () => MethodChannelFirebaseStorage.channel
            .invokeMethod<void>('Task#startPutData', <String, dynamic>{
          'appName': storage.app.name,
          'bucket': storage.bucket,
          'maxOperationRetryTime': storage.maxOperationRetryTime,
          'maxUploadRetryTime': storage.maxUploadRetryTime,
          'maxDownloadRetryTime': storage.maxDownloadRetryTime,
          'handle': handle,
          'path': path,
          'data': data,
          'metadata': metadata?.asMap(),
        });
  }
}

/// Implementation for [writeToFile] tasks.
class MethodChannelDownloadTask extends MethodChannelTask {
  // ignore: public_member_api_docs
  MethodChannelDownloadTask(
      int handle, FirebaseStoragePlatform storage, String path, File file)
      : super(handle, storage, path, _getTask(handle, storage, path, file));

  static Future<void> Function() _getTask(
      int handle, FirebaseStoragePlatform storage, String path, File file) {
    return () => MethodChannelFirebaseStorage.channel
            .invokeMethod<void>('Task#writeToFile', <String, dynamic>{
          'appName': storage.app.name,
          'maxOperationRetryTime': storage.maxOperationRetryTime,
          'maxUploadRetryTime': storage.maxUploadRetryTime,
          'maxDownloadRetryTime': storage.maxDownloadRetryTime,
          'bucket': storage.bucket,
          'handle': handle,
          'path': path,
          'filePath': file.path,
        });
  }
}
