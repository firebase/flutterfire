// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show File;

/// Extracts the filesystem path from [file], verifying it is a `dart:io` `File`.
String filePath(Object file) {
  if (file is! File) {
    throw ArgumentError.value(file, 'file', 'Expected a dart:io File.');
  }
  return file.path;
}
