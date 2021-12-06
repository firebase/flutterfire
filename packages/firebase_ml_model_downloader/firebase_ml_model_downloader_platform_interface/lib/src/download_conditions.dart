// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Download conditions for downloading a model via the [getModel] API.
class DownloadConditions {
  /// Creates a new [DownloadConditions] instance.
  DownloadConditions({
    this.iOSAllowsCellularAccess = true,
    this.iOSAllowsBackgroundDownloading = false,
    this.androidChargingRequired = false,
    this.androidWifiRequired = false,
    this.androidDeviceIdleRequired = false,
  });

  /// Indicates whether download requests should be made over a cellular network.
  ///
  /// Default is `true`. iOS only.
  bool iOSAllowsCellularAccess;

  /// Indicates whether the model can be downloaded while the app is in the
  /// background.
  ///
  /// Default is `false`. iOS only.
  bool iOSAllowsBackgroundDownloading;

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
      'iOSAllowsCellularAccess': iOSAllowsCellularAccess,
      'iOSAllowsBackgroundDownloading': iOSAllowsBackgroundDownloading,
      'androidChargingRequired': androidChargingRequired,
      'androidWifiRequired': androidWifiRequired,
      'androidDeviceIdleRequired': androidDeviceIdleRequired,
    };
  }
}
