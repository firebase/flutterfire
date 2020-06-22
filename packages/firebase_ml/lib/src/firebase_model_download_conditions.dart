/// Conditions to download remote models.
class FirebaseModelDownloadConditions {
  /// Boolean value that indicates if wifi is required.
  final bool requireWifi;

  /// Boolean value that indicates if device idle is required.
  final bool requireDeviceIdle;

  /// Boolean value that indicates if charging is required.
  final bool requireCharging;

  /// Constructor for the download conditions that takes optional parameters
  /// requireWifi, requireDeviceIdle and requireCharging and defaults them to
  /// false if none given.
  FirebaseModelDownloadConditions({
    this.requireWifi = false,
    this.requireDeviceIdle = false,
    this.requireCharging = false,
  });
}
