/// Conditions to download remote models.
class FirebaseModelDownloadConditions {
  /// Android: Boolean that indicates if wifi is required.
  final bool androidRequireWifi;

  /// Android: Boolean that indicates if device idle is required.
  final bool androidRequireDeviceIdle;

  /// Android: Boolean that indicates if charging is required.
  final bool androidRequireCharging;

  /// IOS: Boolean that indicates if download should be over a cellular network.
  final bool iosAllowCellularAccess;

  /// IOS: Boolean that indicates if download can happen in the background.
  final bool iosAllowBackgroundDownloading;

  /// Constructor for the download conditions that takes optional parameters
  /// requireWifi, requireDeviceIdle and requireCharging and defaults them to
  /// false if none given.
  FirebaseModelDownloadConditions(
      {this.androidRequireDeviceIdle = false,
      this.androidRequireCharging = false,
      this.androidRequireWifi = false,
      this.iosAllowCellularAccess = true,
      this.iosAllowBackgroundDownloading = false});

  /// Express download conditions via map.
  ///
  /// This method is used for ease of transfer via channel and printing.
  Map<String, bool> toMap() {
    return <String, bool>{
      'requireCharging': androidRequireCharging,
      'requireDeviceIdle': androidRequireDeviceIdle,
      'requireWifi': androidRequireWifi,
      'allowCellularAccess': iosAllowCellularAccess,
      'allowBackgroundDownloading': iosAllowBackgroundDownloading,
    };
  }
}
