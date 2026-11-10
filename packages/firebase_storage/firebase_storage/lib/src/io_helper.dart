// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show File;

/// Validates that [file] is a `dart:io` `File` and asserts that it exists.
void assertFileExists(Object file) {
  if (file is! File) {
    throw ArgumentError.value(file, 'file', 'Expected a dart:io File.');
  }
  assert(file.absolute.existsSync());
}

/// Validates that [file] is a `dart:io` `File`.
void assertIsFile(Object file) {
  if (file is! File) {
    throw ArgumentError.value(file, 'file', 'Expected a dart:io File.');
  }
}
