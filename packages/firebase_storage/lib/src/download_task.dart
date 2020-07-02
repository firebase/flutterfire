// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_storage;

/// TODO: Move into own file and build out progress functionality
class StorageFileDownloadTask {
  StorageFileDownloadTask._(this._firebaseStorage, this._path, this._file);

  final FirebaseStorage _firebaseStorage;
  final String _path;
  final File _file;

  Future<void> _start() async {
    try {
      final int totalByteCount =
          await FirebaseStorage.channel.invokeMethod<int>(
        "StorageReference#writeToFile",
        <String, dynamic>{
          'app': _firebaseStorage.app?.name,
          'bucket': _firebaseStorage.storageBucket,
          'filePath': _file.absolute.path,
          'path': _path,
        },
      );
      _completer
          .complete(FileDownloadTaskSnapshot(totalByteCount: totalByteCount));
    } catch (e) {
      _completer.completeError(e);
    }
  }

  Completer<FileDownloadTaskSnapshot> _completer =
      Completer<FileDownloadTaskSnapshot>();
  Future<FileDownloadTaskSnapshot> get future => _completer.future;
}

class FileDownloadTaskSnapshot {
  FileDownloadTaskSnapshot({this.totalByteCount});
  final int totalByteCount;
}
