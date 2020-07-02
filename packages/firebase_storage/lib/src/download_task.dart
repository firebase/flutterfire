// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_storage;

abstract class StorageFileDownloadTask {
  StorageFileDownloadTask._(this._firebaseStorage, this._ref);

  final FirebaseStorage _firebaseStorage;
  final StorageReference _ref;

  Future<dynamic> _platformStart();

  int _handle;

  bool isCanceled = false;
  bool isComplete = false;
  bool isInProgress = true;
  bool isPaused = false;
  bool isSuccessful = false;

  FileDownloadTaskSnapshot lastSnapshot;

  /// Returns a last snapshot when completed
  Completer<FileDownloadTaskSnapshot> _completer =
      Completer<FileDownloadTaskSnapshot>();

  Future<FileDownloadTaskSnapshot> get onComplete => _completer.future;

  /// `future` has been deprecated. Please use `onComplete` instead
  @deprecated
  Future<FileDownloadTaskSnapshot> get future => _completer.future;

  StreamController<FileDownloadTaskEvent> _controller =
      StreamController<FileDownloadTaskEvent>.broadcast();
  Stream<FileDownloadTaskEvent> get events => _controller.stream;

  Future<FileDownloadTaskSnapshot> _start() async {
    _handle = await _platformStart();
    final FileDownloadTaskEvent event = await _firebaseStorage._methodStream
        .where((MethodCall m) {
      return m.method == 'StorageDownloadTaskEvent' &&
          m.arguments['handle'] == _handle;
    }).map<FileDownloadTaskEvent>((MethodCall m) {
      final Map<dynamic, dynamic> args = m.arguments;
      final FileDownloadTaskEvent e =
          FileDownloadTaskEvent._(args['type'], _ref, args['snapshot']);
      _changeState(e);
      lastSnapshot = e.snapshot;
      _controller.add(e);
      if (e.type == StorageTaskEventType.success ||
          e.type == StorageTaskEventType.failure) {
        _completer.complete(e.snapshot);
      }
      return e;
    }).firstWhere((FileDownloadTaskEvent e) =>
            e.type == StorageTaskEventType.success ||
            e.type == StorageTaskEventType.failure);
    return event.snapshot;
  }

  void _changeState(FileDownloadTaskEvent event) {
    _resetState();
    switch (event.type) {
      case StorageTaskEventType.progress:
        isInProgress = true;
        break;
      case StorageTaskEventType.resume:
        isInProgress = true;
        break;
      case StorageTaskEventType.pause:
        isPaused = true;
        break;
      case StorageTaskEventType.success:
        isSuccessful = true;
        isComplete = true;
        break;
      case StorageTaskEventType.failure:
        isComplete = true;
        if (event.snapshot.error == StorageError.canceled) {
          isCanceled = true;
        }
        break;
    }
  }

  void _resetState() {
    isCanceled = false;
    isComplete = false;
    isInProgress = false;
    isPaused = false;
    isSuccessful = false;
  }

  /// Pause the upload
  void pause() => FirebaseStorage.channel.invokeMethod<void>(
        'DownloadTask#pause',
        <String, dynamic>{
          'app': _firebaseStorage.app?.name,
          'bucket': _firebaseStorage.storageBucket,
          'handle': _handle,
        },
      );

  /// Resume the upload
  void resume() => FirebaseStorage.channel.invokeMethod<void>(
        'DownloadTask#resume',
        <String, dynamic>{
          'app': _firebaseStorage.app?.name,
          'bucket': _firebaseStorage.storageBucket,
          'handle': _handle,
        },
      );

  /// Cancel the upload
  void cancel() => FirebaseStorage.channel.invokeMethod<void>(
        'DownloadTask#cancel',
        <String, dynamic>{
          'app': _firebaseStorage.app?.name,
          'bucket': _firebaseStorage.storageBucket,
          'handle': _handle,
        },
      );
}

class _StorageFileDownloadTask extends StorageFileDownloadTask {
  _StorageFileDownloadTask._(
      this._file, FirebaseStorage firebaseStorage, StorageReference ref)
      : super._(firebaseStorage, ref);

  final File _file;

  @override
  Future<dynamic> _platformStart() {
    return FirebaseStorage.channel.invokeMethod<dynamic>(
      "StorageReference#writeToFile",
      <String, dynamic>{
        'app': _firebaseStorage.app?.name,
        'bucket': _firebaseStorage.storageBucket,
        'filePath': _file.absolute.path,
        'path': _ref.path,
      },
    );
  }
}
