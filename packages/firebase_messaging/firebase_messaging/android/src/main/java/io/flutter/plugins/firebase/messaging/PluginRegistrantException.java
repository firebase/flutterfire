// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

// Only applicable to v1 embedding applications.
class PluginRegistrantException extends RuntimeException {
  public PluginRegistrantException() {
    super(
        "PluginRegistrantCallback is not set. Did you forget to call "
            + "FlutterFirebaseMessagingBackgroundService.setPluginRegistrant? See the documentation for instructions.");
  }
}
