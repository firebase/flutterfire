// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The result instance returned from a App Check token request.
class AppCheckTokenResult {
  AppCheckTokenResult(this.token);

  /// The current App Check token.
  ///
  /// Returns null if no token is present and no token requests are in-flight.
  final String? token;
}
