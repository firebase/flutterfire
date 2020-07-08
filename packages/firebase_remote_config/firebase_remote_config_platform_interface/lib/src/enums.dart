// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_remote_config_platform_interface;

/// ValueSource defines the possible sources of a config parameter value.
enum ValueSource {
  /// Value is a static default value, returned because no value is present for,
  /// and no default value has been set for, the parameter
  valueStatic,

  /// Value is the default value set for the parameter
  valueDefault,

  /// Value is from the Firebase Remote Config server
  valueRemote
}
