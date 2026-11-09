// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A web stub for [File] from `dart:io`.
class File {
  /// Create a [File] stub.
  File(this.path);

  /// The path of the file.
  final String path;

  /// Returns the absolute path of the file.
  File get absolute =>
      throw UnsupportedError('File is not available on the web.');

  /// Returns whether the file exists.
  bool existsSync() => false;
}
