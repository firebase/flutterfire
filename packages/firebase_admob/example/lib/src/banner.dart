import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Article URL
final String article =
    'https://medium.com/flutter/announcing-flutter-1-17-4182d8af7f8e';

void main() => runApp(AdBanner());

/// Top-level banner ad class
class AdBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BannerAdPage(),
    );
  }
}

/// Display banner ad
class BannerAdPage extends StatefulWidget {
  @override
  _BannerAdPageState createState() => _BannerAdPageState();
}

class _BannerAdPageState extends State<BannerAdPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  BannerAd myBanner;

  BannerAd buildBannerAd() {
    return BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.banner,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) {
            myBanner..show();
          }
        });
  }

  BannerAd buildLargeBannerAd() {
    return BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.largeBanner,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) {
            myBanner
              ..show(
                  anchorType: AnchorType.top,
                  anchorOffset: MediaQuery.of(context).size.height * 0.50);
          }
        });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
    myBanner = buildLargeBannerAd()..load();
  }

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: WebView(initialUrl: article),
      ),
    );
  }
}
