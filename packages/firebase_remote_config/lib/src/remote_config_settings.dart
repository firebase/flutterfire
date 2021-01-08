// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_remote_config;

/// RemoteConfigSettings can be used to configure how Remote Config operates.
class RemoteConfigSettings {
  RemoteConfigSettings(
      {this.minimumFetchIntervalMillis = 43200000,
      this.fetchTimeoutMillis = 60000});

  /// Set the minimum fetch interval for Remote Config, in milliseconds
  ///
  /// Indicates the default value in milliseconds to set for the minimum
  /// interval that needs to elapse before a fetch request can again be made
  /// to the Remote Config server. Defaults to 43200000 (Twelve hours).
  final int minimumFetchIntervalMillis;

  /// Set the fetch timeout for Remote Config, in milliseconds
  ///
  /// Indicates the default value in milliseconds to abandon a pending fetch
  /// request made to the Remote Config server. Defaults to 60000 (One minute).
  final int fetchTimeoutMillis;
}
