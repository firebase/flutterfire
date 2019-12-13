// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class PlatformDocumentSnapshot {
  PlatformDocumentSnapshot({this.path, this.data, this.metadata});
  String path;
  Map<String, dynamic> data;
  PlatformSnapshotMetadata metadata;

  Map<String, dynamic> asMap() {
    return <String, dynamic> {
      'data': data,
      'metadata': metadata.asMap(),
    };
  }
}

class PlatformSnapshotMetadata {
  PlatformSnapshotMetadata({this.hasPendingWrites, this.isFromCache});
  bool hasPendingWrites;
  bool isFromCache;

  Map<String, dynamic> asMap() {
    return <String, dynamic> {
      'hasPendingWrites': hasPendingWrites,
      'isFromCache': isFromCache,
    };
  }
}
