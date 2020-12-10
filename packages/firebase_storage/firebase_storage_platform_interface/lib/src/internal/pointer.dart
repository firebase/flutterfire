// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Internal helper class used to manage storage reference paths.
class Pointer {
  /// Constructs a new [Pointer] with a given path.
  Pointer(String path) {
    if (path == null || path.isEmpty) {
      _path = '/';
    } else {
      String _parsedPath = path;

      // Remove trailing slashes
      if (path.length > 1 && path.endsWith('/')) {
        _parsedPath = _parsedPath.substring(0, _parsedPath.length - 1);
      }

      // Remove starting slashes
      if (path.startsWith('/') && path.length > 1) {
        _parsedPath = _parsedPath.substring(1, _parsedPath.length);
      }

      _path = _parsedPath;
    }
  }

  String _path;

  /// Returns whether the path points to the root of a bucket.
  bool get isRoot {
    return path == '/';
  }

  /// Returns the serialized path.
  String get path {
    return _path;
  }

  /// Returns the name of the path.
  ///
  /// For example, a paths "foo/bar.jpg" name is "bar.jpg".
  String get name {
    return path.split('/').last;
  }

  /// Returns the parent path.
  ///
  /// If the current path is root, `null` wil be returned.
  String get parent {
    if (isRoot) {
      return null;
    }

    List<String> chunks = path.split('/');
    chunks.removeLast();
    return chunks.join('/');
  }

  /// Returns a child path relative to the current path.
  String child(String childPath) {
    assert(childPath != null);
    Pointer childPointer = Pointer(childPath);

    // If already at
    if (isRoot) {
      return childPointer.path;
    }

    return '$path/${childPointer.path}';
  }
}
