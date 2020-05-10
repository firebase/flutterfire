// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_admob/src/ad_instance_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseAdMob', () {
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/firebase_admob',
    );

    final List<MethodCall> log = <MethodCall>[];
    final FirebaseAdMob admob = FirebaseAdMob.private(channel);

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'initialize':
          case 'loadBannerAd':
          case 'loadInterstitialAd':
          case 'loadRewardedVideoAd':
          case 'showAd':
          case 'showRewardedVideoAd':
          case 'setRewardedVideoAdUserId':
          case 'setRewardedVideoAdCustomData':
          case 'disposeAd':
            return Future<bool>.value(true);
          default:
            assert(false);
            return null;
        }
      });
    });

    test('initialize', () async {
      log.clear();

      expect(await admob.initialize(appId: FirebaseAdMob.testAppId), true);
      expect(log, <Matcher>[
        isMethodCall('initialize', arguments: <String, dynamic>{
          'appId': FirebaseAdMob.testAppId,
          'trackingId': null,
          'analyticsEnabled': false,
        }),
      ]);
    });

    test('banner', () async {
      log.clear();

      final BannerAd banner = BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.banner,
      );
      final int id = banner.id;

      expect(await banner.load(), true);
      expect(await banner.show(), true);
      expect(await banner.dispose(), true);

      expect(log, <Matcher>[
        isMethodCall('loadBannerAd', arguments: <String, dynamic>{
          'id': id,
          'adUnitId': BannerAd.testAdUnitId,
          'targetingInfo': <String, String>{'requestAgent': 'flutter-alpha'},
          'width': 320,
          'height': 50,
          'adSizeType': 'AdSizeType.WidthAndHeight',
        }),
        isMethodCall('showAd', arguments: <String, dynamic>{
          'id': id,
          'anchorOffset': '0.0',
          'horizontalCenterOffset': '0.0',
          'anchorType': 'bottom',
        }),
        isMethodCall('disposeAd', arguments: <String, dynamic>{
          'id': id,
        }),
      ]);
    });

    test('interstitial', () async {
      log.clear();

      final InterstitialAd interstitial = InterstitialAd(
        adUnitId: InterstitialAd.testAdUnitId,
      );
      final int id = interstitial.id;

      expect(await interstitial.load(), true);
      expect(
          await interstitial.show(
              anchorOffset: 60.0,
              horizontalCenterOffset: 10.0,
              anchorType: AnchorType.top),
          true);
      expect(await interstitial.dispose(), true);

      expect(log, <Matcher>[
        isMethodCall('loadInterstitialAd', arguments: <String, dynamic>{
          'id': id,
          'adUnitId': InterstitialAd.testAdUnitId,
          'targetingInfo': <String, String>{'requestAgent': 'flutter-alpha'},
        }),
        isMethodCall('showAd', arguments: <String, dynamic>{
          'id': id,
          'anchorOffset': '60.0',
          'horizontalCenterOffset': '10.0',
          'anchorType': 'top',
        }),
        isMethodCall('disposeAd', arguments: <String, dynamic>{
          'id': id,
        }),
      ]);
    });

    test('rewarded', () async {
      log.clear();

      expect(
          await RewardedVideoAd.instance.load(
              adUnitId: RewardedVideoAd.testAdUnitId,
              targetingInfo: const MobileAdTargetingInfo()),
          true);

      RewardedVideoAd.instance.userId = "user-id";
      RewardedVideoAd.instance.customData = "custom-data";

      expect(await RewardedVideoAd.instance.show(), true);

      expect(log, <Matcher>[
        isMethodCall('loadRewardedVideoAd', arguments: <String, dynamic>{
          'adUnitId': RewardedVideoAd.testAdUnitId,
          'targetingInfo': <String, String>{'requestAgent': 'flutter-alpha'},
        }),
        isMethodCall('setRewardedVideoAdUserId', arguments: <String, dynamic>{
          'userId': "user-id",
        }),
        isMethodCall('setRewardedVideoAdCustomData',
            arguments: <String, dynamic>{
              'customData': "custom-data",
            }),
        isMethodCall('showRewardedVideoAd', arguments: null),
      ]);
    });
  });

  group('$AdInstanceManager', () {
    final List<MethodCall> methodCallLog = <MethodCall>[];

    setUp(() {
      adInstanceManager = AdInstanceManager(MethodChannel('test_channel'));
      adInstanceManager.channel.setMockMethodCallHandler(
        (MethodCall methodCall) async {
          methodCallLog.add(methodCall);
          return null;
        },
      );
    });

    tearDown(() {
      methodCallLog.clear();
    });

    test('initialize', () {
      FirebaseAdMob.instance.initialize(appId: 'testAppId');
      expect(methodCallLog, <Matcher>[
        isMethodCall(
          'initialize',
          arguments: null,
        ),
      ]);
    });

    test('loadBannerAd', () {
      final BannerAd ad = BannerAd(adUnitId: 'testId', size: AdSize.banner);

      ad.load();
      ad.load();
      expect(adInstanceManager.adFor(0), equals(ad));
      expect(methodCallLog, <Matcher>[
        isMethodCall(
          'loadBannerAd',
          arguments: <dynamic, dynamic>{
            'adId': 0,
            'adUnitId': 'testId',
          },
        )
      ]);

      final BannerAd ad2 = BannerAd(adUnitId: 'testId2', size: AdSize.banner);
      ad2.load();
      expect(adInstanceManager.adFor(1), equals(ad2));
    });
  });
}
