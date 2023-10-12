// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Effectively a dummy class, Filters has been moved to the user facing code
/// so it can have access to encoding utilities. This class is required to
/// use as an argument for methods for all the platforms
abstract class FilterPlatformInterface {
  Map<String, Object?> toJson() {
    throw UnimplementedError('toJson() is not implemented');
  }
}
