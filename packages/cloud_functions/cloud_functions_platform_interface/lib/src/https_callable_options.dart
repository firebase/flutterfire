// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Interface representing an HttpsCallable instance's options,
class HttpsCallableOptions {
  /// Constructs a new [HttpsCallableOptions] instance with given `timeout` & `limitedUseAppCheckToken`
  /// Defaults [timeout] to 60 seconds.
  /// Defaults [limitedUseAppCheckToken] to `false`
  HttpsCallableOptions(
      {this.timeout = const Duration(seconds: 60),
      this.limitedUseAppCheckToken = false});

  /// Returns the timeout for this instance
  Duration timeout;

  /// Sets whether or not to use limited-use App Check tokens when invoking the associated function.
  bool limitedUseAppCheckToken;
}
