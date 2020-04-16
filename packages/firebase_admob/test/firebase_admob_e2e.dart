import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

import 'package:firebase_admob/firebase_admob.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Initialize Firebase Admob', (WidgetTester tester) async {
    expect(
      FirebaseAdMob.initialize(),
      completion(isTrue),
    );
  });

  testWidgets('$BannerAd', (WidgetTester tester) async {
    final Completer<Ad> adCompleter = Completer<Ad>();

    final BannerAd bannerAd = BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      listener: AdListener(onAdLoaded: (Ad ad) {
        adCompleter.complete(ad);
      }),
    );

    await bannerAd.load();
    expect(adCompleter.future, completion(bannerAd));
  });

  testWidgets('$InterstitialAd', (WidgetTester tester) async {
    final Completer<Ad> adCompleter = Completer<Ad>();

    final InterstitialAd interstitialAd = InterstitialAd(
      adUnitId: NativeAd.testAdUnitId,
      listener: AdListener(onAdLoaded: (Ad ad) {
        adCompleter.complete(ad);
      }),
    );

    await interstitialAd.load();
    expect(adCompleter.future, completion(interstitialAd));
  });

  testWidgets('$RewardedAd', (WidgetTester tester) async {
    final Completer<Ad> adCompleter = Completer<Ad>();

    final RewardedAd rewardedAd = RewardedAd(
      adUnitId: NativeAd.testAdUnitId,
      listener: AdListener(onAdLoaded: (Ad ad) {
        adCompleter.complete(ad);
      }),
    );

    await rewardedAd.load();
    expect(adCompleter.future, completion(rewardedAd));
  });

  testWidgets('$NativeAd', (WidgetTester tester) async {
    final Completer<Ad> adCompleter = Completer<Ad>();

    final NativeAd nativeAd = NativeAd(
      adUnitId: NativeAd.testAdUnitId,
      factoryId: 'adFactoryExample',
      listener: AdListener(onAdLoaded: (Ad ad) {
        adCompleter.complete(ad);
      }),
    );

    await nativeAd.load();
    expect(adCompleter.future, completion(nativeAd));
  });
}
