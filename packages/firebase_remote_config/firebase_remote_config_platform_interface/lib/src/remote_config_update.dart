// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Used by Remote Config real-time config update service, this class represents changes between the newly fetched config and the current one.
///
/// An instance of this class is returned from [FirebaseRemoteConfig.onConfigUpdated].
class RemoteConfigUpdate {
  /// Parameter keys whose values have been updated from the currently activated values.
  /// Includes keys that are added, deleted, and whose value, value source, or metadata has changed.
  final Set<String> updatedKeys;

  RemoteConfigUpdate(this.updatedKeys);
}
