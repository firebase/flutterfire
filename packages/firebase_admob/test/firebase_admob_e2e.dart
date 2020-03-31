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

  testWidgets('Rewarded Video Ads', (WidgetTester tester) async {
    bool adLoaded = false;

    RewardedVideoAd.instance.listener = 
      (RewardedVideoAdEvent event, {int rewardAmount, String rewardType}) {
        if (event == RewardedVideoAdEvent.loaded) adLoaded = true;
    };

    // Request without a targeting info
    await RewardedVideoAd.instance.load(adUnitId: RewardedVideoAd.testAdUnitId);
    await Future<void>.delayed(Duration(seconds: 10));
    expect(adLoaded, isTrue);

    adLoaded = false;

    // Request with a targeting info
    await RewardedVideoAd.instance.load(
      adUnitId: RewardedVideoAd.testAdUnitId, 
      targetingInfo: MobileAdTargetingInfo(
        keywords: <String>['foo', 'bar'],
        contentUrl: 'http://foo.com/bar.html',
        childDirected: true,
        nonPersonalizedAds: true,
      ),
    );
    await Future<void>.delayed(Duration(seconds: 10));
    expect(adLoaded, isTrue);
  });

  testWidgets('Native Ads', (WidgetTester tester) async {
    bool adLoaded = false;

    final NativeAd nativeAd = NativeAd(
      adUnitId: NativeAd.testAdUnitId,
      factoryId: 'adFactoryExample',
      targetingInfo: MobileAdTargetingInfo(
        keywords: <String>['foo', 'bar'],
        contentUrl: 'http://foo.com/bar.html',
        childDirected: true,
        nonPersonalizedAds: true,
      ),
      listener: (MobileAdEvent event) {
        print('NativeAd event: $event');
        if (event == MobileAdEvent.loaded) adLoaded = true;
      },
    );

    await nativeAd.load();
    await Future<void>.delayed(Duration(seconds: 10));
    expect(adLoaded, isTrue);
  });
}
