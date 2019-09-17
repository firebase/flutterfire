part of firebase_admob;

/// [BannerAdSize] represents the size of a banner ad. There are six sizes available,
/// which are the same for both iOS and Android. See the guides for banners on
/// [Android](https://developers.google.com/admob/android/banner#banner_sizes)
/// and [iOS](https://developers.google.com/admob/ios/banner#banner_sizes) for
/// additional details.
class BannerAdSize {
  // Private constructor. Apps should use the static constants rather than
  // create their own instances of [BannerAdSize].
  const BannerAdSize({
    @required this.width,
    @required this.height,
    this.name,
  });

  final int width, height;
  final String name;

  /// The standard banner (320x50) size.
  static const BannerAdSize BANNER =
      BannerAdSize(width: 320, height: 50, name: 'BANNER');

  /// The large banner (320x100) size.
  static const BannerAdSize LARGE_BANNER =
      BannerAdSize(width: 320, height: 100, name: 'LARGE_BANNER');

  /// The medium rectangle (300x250) size.
  static const BannerAdSize MEDIUM_RECTANGLE =
      BannerAdSize(width: 300, height: 250, name: 'MEDIUM_RECTANGLE');

  /// The full banner (468x60) size.
  static const BannerAdSize FULL_BANNER =
      BannerAdSize(width: 468, height: 60, name: 'FULL_BANNER');

  /// The leaderboard (728x90) size.
  static const BannerAdSize LEADERBOARD =
      BannerAdSize(width: 728, height: 90, name: 'LEADERBOARD');

  /// The smart banner size. Smart banners are unique in that the width and
  /// height values declared here aren't used. At runtime, the Mobile Ads SDK
  /// will automatically adjust the banner's width to match the width of the
  /// displaying device's screen. It will also set the banner's height using a
  /// calculation based on the displaying device's height. For more info see the
  /// [Android](https://developers.google.com/admob/android/banner) and
  /// [iOS](https://developers.google.com/admob/ios/banner) banner ad guides.
  static const BannerAdSize SMART_BANNER =
      BannerAdSize(width: -1, height: -2, name: 'SMART_BANNER');

  Map<String, dynamic> get toMap => <String, dynamic>{
        'width': width,
        'height': height,
        'name': name,
      };
}
