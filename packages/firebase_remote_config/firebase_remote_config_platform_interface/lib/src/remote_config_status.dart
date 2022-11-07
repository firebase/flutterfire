// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: require_trailing_commas
/// The outcome of the last attempt to fetch config from the
/// Firebase Remote Config server.
enum RemoteConfigFetchStatus {
  /// Indicates instance has not yet attempted a fetch.
  noFetchYet,

  /// Indicates the last fetch attempt succeeded.
  success,

  /// Indicates the last fetch attempt failed.
  failure,

  /// Indicates the last fetch attempt was rate-limited.
  throttle
}
