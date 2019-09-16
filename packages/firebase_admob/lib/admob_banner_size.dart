part of firebase_admob;


class AdmobBannerSize {
  final int width, height;
  final String name;

  static const AdmobBannerSize BANNER =
      AdmobBannerSize(width: 320, height: 50, name: 'BANNER');
  static const AdmobBannerSize LARGE_BANNER =
      AdmobBannerSize(width: 320, height: 100, name: 'LARGE_BANNER');
  static const AdmobBannerSize MEDIUM_RECTANGLE =
      AdmobBannerSize(width: 300, height: 250, name: 'MEDIUM_RECTANGLE');
  static const AdmobBannerSize FULL_BANNER =
      AdmobBannerSize(width: 468, height: 60, name: 'FULL_BANNER');
  static const AdmobBannerSize LEADERBOARD =
      AdmobBannerSize(width: 728, height: 90, name: 'LEADERBOARD');
  static const AdmobBannerSize SMART_BANNER =
      AdmobBannerSize(width: -1, height: -2, name: 'SMART_BANNER');

  const AdmobBannerSize({
    @required this.width,
    @required this.height,
    this.name,
  });

  Map<String, dynamic> get toMap => <String, dynamic>{
        'width': width,
        'height': height,
        'name': name,
      };
}
