part of firebase_admob;

class BannerAdSize {
  const BannerAdSize({
    @required this.width,
    @required this.height,
    this.name,
  });

  final int width, height;
  final String name;

  static const BannerAdSize BANNER =
      BannerAdSize(width: 320, height: 50, name: 'BANNER');
  static const BannerAdSize LARGE_BANNER =
      BannerAdSize(width: 320, height: 100, name: 'LARGE_BANNER');
  static const BannerAdSize MEDIUM_RECTANGLE =
      BannerAdSize(width: 300, height: 250, name: 'MEDIUM_RECTANGLE');
  static const BannerAdSize FULL_BANNER =
      BannerAdSize(width: 468, height: 60, name: 'FULL_BANNER');
  static const BannerAdSize LEADERBOARD =
      BannerAdSize(width: 728, height: 90, name: 'LEADERBOARD');
  static const BannerAdSize SMART_BANNER =
      BannerAdSize(width: -1, height: -2, name: 'SMART_BANNER');

  Map<String, dynamic> get toMap => <String, dynamic>{
        'width': width,
        'height': height,
        'name': name,
      };
}
