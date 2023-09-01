// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Defines the options for the corresponding Remote Config instance.
class RemoteConfigSettings {
  /// Constructs an instance of [RemoteConfigSettings] with given [fetchTimeout]
  /// and [minimumFetchInterval].
  RemoteConfigSettings({
    required this.fetchTimeout,
    required this.minimumFetchInterval,
  });

  /// Maximum Duration to wait for a response when fetching configuration from
  /// the Remote Config server.
  Duration fetchTimeout;

  /// Maximum age of a cached config before it is considered stale.
  Duration minimumFetchInterval;
}
