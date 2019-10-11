// Copyright 2017 The Chromium Authors & Daniel Szasz. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_storage;

/// Metadata for a [ListResultItem]. ListResultItem stores name, bucket and
/// path.

class ListResultItem {
  ListResultItem({
    this.name,
    this.bucket,
    this.path,
  });

  final String name;
  final String bucket;
  final String path;
}
