part of firebase_ml;

/// Conditions to download remote models.
class FirebaseModelDownloadConditions {
  final bool _requiredWifi;
  final bool _requiredDeviceIdle;
  final bool _requiredCharging;

  FirebaseModelDownloadConditions._builder(
      FirebaseModelDownloadConditionsBuilder builder)
      : _requiredWifi = builder._requiredWifi,
        _requiredDeviceIdle = builder._requiredDeviceIdle,
        _requiredCharging = builder._requiredCharging;

  /// Returns true if charging is required for download.
  bool isChargingRequired() => _requiredWifi;

  /// Returns true if device idle is required for download.
  bool isDeviceIdleRequired() => _requiredDeviceIdle;

  /// Returns true if wifi is required for download.
  bool isWifiRequired() => _requiredCharging;
}

/// Builder of [FirebaseModelDownloadConditions].
class FirebaseModelDownloadConditionsBuilder {
  bool _requiredWifi = false;
  bool _requiredDeviceIdle = false;
  bool _requiredCharging = false;

  /// Sets whether wifi is required.
  void requireWifi() {
    this._requiredWifi = true;
  }

  /// Sets whether device idle is required.
  void requireDeviceIdle() {
    this._requiredDeviceIdle = true;
  }

  /// Sets whether charging is required.
  void requireCharging() {
    this._requiredCharging = true;
  }

  /// Builds [FirebaseModelDownloadConditions].
  FirebaseModelDownloadConditions build() {
    return FirebaseModelDownloadConditions._builder(this);
  }
}

