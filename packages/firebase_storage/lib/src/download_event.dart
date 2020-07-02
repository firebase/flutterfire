// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_storage;

/// `Event` encapsulates a FileDownloadTaskSnapshot
class FileDownloadTaskEvent {
  FileDownloadTaskEvent._(
      int type, StorageReference ref, Map<dynamic, dynamic> data)
      : type = StorageTaskEventType.values[type],
        snapshot =
            FileDownloadTaskSnapshot._(ref, data.cast<String, dynamic>());

  final StorageTaskEventType type;
  final FileDownloadTaskSnapshot snapshot;
}

class FileDownloadTaskSnapshot {
  FileDownloadTaskSnapshot._(this.ref, Map<String, dynamic> m)
      : error = m['error'],
        bytesTransferred = m['bytesTransferred'],
        totalByteCount = m['totalByteCount'];

  final StorageReference ref;
  final int error;
  final int bytesTransferred;
  final int totalByteCount;
}
