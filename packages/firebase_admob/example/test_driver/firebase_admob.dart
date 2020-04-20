import 'dart:async';

import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_admob/firebase_admob.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$FirebaseAdMob', () {
    test('Initialize Firebase Admob', () async {
      expect(
        FirebaseAdMob.initialize(),
        completes,
      );
    });

    test('$BannerAd', () async {
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

    test('$InterstitialAd', () async {
      final Completer<Ad> adCompleter = Completer<Ad>();

      final InterstitialAd interstitialAd = InterstitialAd(
        adUnitId: InterstitialAd.testAdUnitId,
        listener: AdListener(onAdLoaded: (Ad ad) {
          adCompleter.complete(ad);
        }),
      );

      await interstitialAd.load();
      expect(adCompleter.future, completion(interstitialAd));
    });

    test('$RewardedAd', () async {
      final Completer<Ad> adCompleter = Completer<Ad>();

      final RewardedAd rewardedAd = RewardedAd(
        adUnitId: RewardedAd.testAdUnitId,
        listener: AdListener(onAdLoaded: (Ad ad) {
          adCompleter.complete(ad);
        }),
      );

      await rewardedAd.load();
      expect(adCompleter.future, completion(rewardedAd));
    });

    test('$NativeAd', () async {
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
  });
}
