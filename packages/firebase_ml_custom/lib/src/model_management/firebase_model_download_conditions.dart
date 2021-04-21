// @dart=2.9

/// Conditions to download remote models.
class FirebaseModelDownloadConditions {
  /// Constructor for the download conditions that takes optional platform-specific parameters and defaults them if none given.
  FirebaseModelDownloadConditions({
    this.androidRequireDeviceIdle = false,
    this.androidRequireCharging = false,
    this.androidRequireWifi = false,
    this.iosAllowCellularAccess = true,
    this.iosAllowBackgroundDownloading = false,
  })  : assert(androidRequireDeviceIdle != null),
        assert(androidRequireCharging != null),
        assert(androidRequireWifi != null),
        assert(iosAllowCellularAccess != null),
        assert(iosAllowBackgroundDownloading != null);

  /// Android only: indicates if wifi is required.
  ///
  /// The default is false.
  final bool androidRequireWifi;

  /// Android only: indicates if device idle is required.
  ///
  /// The default is false.
  final bool androidRequireDeviceIdle;

  /// Android only: indicates if charging is required.
  ///
  /// The default is false.
  final bool androidRequireCharging;

  /// IOS only: indicates if download should be over a cellular network.
  ///
  /// The default is true.
  final bool iosAllowCellularAccess;

  /// IOS only: indicates if download can happen in the background.
  ///
  /// The default is false.
  final bool iosAllowBackgroundDownloading;

  /// Express download conditions via map.
  ///
  /// This method is used for ease of transfer via channel and printing.
  Map<String, bool> toMap() {
    return <String, bool>{
      'androidRequireCharging': androidRequireCharging,
      'androidRequireDeviceIdle': androidRequireDeviceIdle,
      'androidRequireWifi': androidRequireWifi,
      'iosAllowCellularAccess': iosAllowCellularAccess,
      'iosAllowBackgroundDownloading': iosAllowBackgroundDownloading,
    };
  }
}
