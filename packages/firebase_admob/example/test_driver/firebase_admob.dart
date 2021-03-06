// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

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
        FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId),
        completes,
      );
    });

    test('$BannerAd', () async {
      final Completer<void> adCompleter = Completer<void>();

      final BannerAd bannerAd = BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.banner,
        targetingInfo: const MobileAdTargetingInfo(
          keywords: <String>['foo', 'bar'],
          contentUrl: 'http://foo.com/bar.html',
          childDirected: true,
          nonPersonalizedAds: true,
        ),
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) adCompleter.complete();
        },
      );

      await bannerAd.load();
      expect(adCompleter.future, completes);
    });

    test('$InterstitialAd', () async {
      final Completer<void> adCompleter = Completer<void>();

      final InterstitialAd interstitialAd = InterstitialAd(
        adUnitId: InterstitialAd.testAdUnitId,
        targetingInfo: const MobileAdTargetingInfo(
          keywords: <String>['foo', 'bar'],
          contentUrl: 'http://foo.com/bar.html',
          childDirected: true,
          nonPersonalizedAds: true,
        ),
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) adCompleter.complete();
        },
      );

      await interstitialAd.load();
      expect(adCompleter.future, completes);
    });

    test('$RewardedVideoAd', () async {
      // Request without a targeting info
      bool hasStartedLoading = await RewardedVideoAd.instance.load(
        adUnitId: RewardedVideoAd.testAdUnitId,
      );
      expect(hasStartedLoading, isTrue);

      // Request with a targeting info
      hasStartedLoading = await RewardedVideoAd.instance.load(
        adUnitId: RewardedVideoAd.testAdUnitId,
        targetingInfo: const MobileAdTargetingInfo(
          keywords: <String>['foo', 'bar'],
          contentUrl: 'http://foo.com/bar.html',
          childDirected: true,
          nonPersonalizedAds: true,
        ),
      );
      expect(hasStartedLoading, isTrue);
    });

    test('$NativeAd', () async {
      final Completer<void> adCompleter = Completer<void>();

      final NativeAd nativeAd = NativeAd(
        adUnitId: NativeAd.testAdUnitId,
        factoryId: 'adFactoryExample',
        targetingInfo: const MobileAdTargetingInfo(
          keywords: <String>['foo', 'bar'],
          contentUrl: 'http://foo.com/bar.html',
          childDirected: true,
          nonPersonalizedAds: true,
        ),
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) adCompleter.complete();
        },
      );

      await nativeAd.load();
      expect(adCompleter.future, completes);
    });
  });
}
