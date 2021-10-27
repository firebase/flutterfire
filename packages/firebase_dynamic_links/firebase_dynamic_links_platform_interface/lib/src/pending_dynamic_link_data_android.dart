/// Provides android specific data from received dynamic link.
class PendingDynamicLinkDataAndroid {
  const PendingDynamicLinkDataAndroid(
      this.clickTimestamp,
      this.minimumVersion,
      );

  /// The time the user clicked on the dynamic link.
  ///
  /// Equals the number of milliseconds that have elapsed since January 1, 1970.
  final int? clickTimestamp;

  /// The minimum version of your app that can open the link.
  ///
  /// The minimum Android app version requested to process the dynamic link that
  /// can be compared directly with versionCode.
  ///
  /// If the installed app is an older version, the user is taken to the Play
  /// Store to upgrade the app.
  final int? minimumVersion;
}
