// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Extracts the filesystem path from [file].
///
/// Always throws [UnsupportedError] on web platforms where `dart:io` is
/// unavailable.
String filePath(Object file) {
  throw UnsupportedError(
    'dart:io File operations are not supported on the web.',
  );
}
