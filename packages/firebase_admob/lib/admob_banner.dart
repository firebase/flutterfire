part of firebase_admob;

class BannerAd extends StatefulWidget {
  BannerAd({
    Key key,
    @required this.adUnitId,
    @required this.adSize,
    this.listener,
    this.onBannerCreated,
  }) : super(key: key);

  final String adUnitId;
  final BannerAdSize adSize;
  final void Function(AdmobAdEvent, Map<String, dynamic>) listener;
  final void Function(BannerAdController) onBannerCreated;

  /// These are AdMob's test ad unit IDs, which always return test ads. You're
  /// encouraged to use them for testing in your own apps.
  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  @override
  _BannerAdState createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd> {
  BannerAdController _controller;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        width: widget.adSize.width >= 0
            ? widget.adSize.width.toDouble()
            : double.infinity,
        height: widget.adSize.height >= 0
            ? widget.adSize.height.toDouble()
            : double.infinity,
        child: AndroidView(
          key: UniqueKey(),
          viewType: 'plugins.flutter.io/firebase_admob/banner',
          creationParams: <String, dynamic>{
            "adUnitId": widget.adUnitId,
            "adSize": widget.adSize.toMap,
          },
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        key: UniqueKey(),
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        child: UiKitView(
          viewType: 'plugins.flutter.io/firebase_admob/banner',
          creationParams: <String, dynamic>{
            "adUnitId": widget.adUnitId,
            "adSize": widget.adSize.toMap,
          },
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      );
    } else {
      return Text('$defaultTargetPlatform is not yet supported by the plugin');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    _controller = BannerAdController(id, widget.listener);

    if (widget.onBannerCreated != null) {
      widget.onBannerCreated(_controller);
    }
  }
}
