// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Download conditions for downloading a model via the [getModel] API.
class FirebaseModelDownloadConditions {
  /// Creates a new [DownloadConditions] instance.
  FirebaseModelDownloadConditions({
    this.iosAllowsCellularAccess = true,
    this.iosAllowsBackgroundDownloading = false,
    this.androidChargingRequired = false,
    this.androidWifiRequired = false,
    this.androidDeviceIdleRequired = false,
  });

  /// Indicates whether download requests should be made over a cellular network.
  ///
  /// Default is `true`. iOS only.
  bool iosAllowsCellularAccess;

  /// Indicates whether the model can be downloaded while the app is in the
  /// background.
  ///
  /// Default is `false`. iOS only.
  bool iosAllowsBackgroundDownloading;

  /// Indicates whether the model can only be downloaded whilst the device is
  /// charging.
  ///
  /// Defaults to `false`. Android only.
  bool androidChargingRequired;

  /// Indicates whether the model can only be downloaded whilst the device is
  /// connected to Wifi.
  ///
  /// Defaults to `false`. Android only.
  bool androidWifiRequired;

  /// Indicates whether the model can only be downloaded whilst the device is
  /// idle.
  ///
  /// Defaults to `false`. Android only.
  bool androidDeviceIdleRequired;

  /// Converts the instance to a [Map].
  Map<String, bool> toMap() {
    return <String, bool>{
      'iosAllowsCellularAccess': iosAllowsCellularAccess,
      'iosAllowsBackgroundDownloading': iosAllowsBackgroundDownloading,
      'androidChargingRequired': androidChargingRequired,
      'androidWifiRequired': androidWifiRequired,
      'androidDeviceIdleRequired': androidDeviceIdleRequired,
    };
  }
}
