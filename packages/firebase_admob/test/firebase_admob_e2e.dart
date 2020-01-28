import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

import 'package:firebase_admob/firebase_admob.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Initialize Firebase Admob', (WidgetTester tester) async {
    expect(
      FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId),
      completion(isTrue),
    );
  });

  testWidgets('Native Ads', (WidgetTester tester) async {
    bool adLoaded = false;
    bool adImpression = false;

    final NativeAd nativeAd = NativeAd(
      adUnitId: NativeAd.testAdUnitId,
      targetingInfo: MobileAdTargetingInfo(
        keywords: <String>['foo', 'bar'],
        contentUrl: 'http://foo.com/bar.html',
        childDirected: true,
        nonPersonalizedAds: true,
      ),
      listener: (MobileAdEvent event) {
        print('NativeAd event: $event');
        if (event == MobileAdEvent.loaded) adLoaded = true;
        if (event == MobileAdEvent.impression) adImpression = true;
      },
    );

    await nativeAd.load();
    await Future<void>.delayed(Duration(seconds: 10));
    expect(adLoaded, isTrue);

    await nativeAd.show();
    await Future<void>.delayed(Duration(seconds: 10));
    expect(adImpression, isTrue);
  });
}
