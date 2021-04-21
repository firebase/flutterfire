// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_admob/firebase_admob.dart';

// You can also test with your own ad unit IDs by registering your device as a
// test device. Check the logs for your device's ID value.
const String testDevice = 'YOUR_DEVICE_ID';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;
  NativeAd _nativeAd;
  InterstitialAd _interstitialAd;
  int _coins = 0;

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print('BannerAd event $event');
      },
    );
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print('InterstitialAd event $event');
      },
    );
  }

  NativeAd createNativeAd() {
    return NativeAd(
      adUnitId: NativeAd.testAdUnitId,
      factoryId: 'adFactoryExample',
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print('$NativeAd event $event');
      },
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
    _bannerAd = createBannerAd()..load();
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print('RewardedVideoAd event $event');
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          _coins += rewardAmount;
        });
      }
    };
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _nativeAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AdMob Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    _bannerAd ??= createBannerAd();
                    _bannerAd
                      ..load()
                      ..show();
                  },
                  child: const Text('SHOW BANNER'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _bannerAd ??= createBannerAd();
                    _bannerAd
                      ..load()
                      ..show(horizontalCenterOffset: -50, anchorOffset: 100);
                  },
                  child: const Text('SHOW BANNER WITH OFFSET'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _bannerAd?.dispose();
                    _bannerAd = null;
                  },
                  child: const Text('REMOVE BANNER'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _interstitialAd?.dispose();
                    _interstitialAd = createInterstitialAd()..load();
                  },
                  child: const Text('LOAD INTERSTITIAL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _interstitialAd?.show();
                  },
                  child: const Text('SHOW INTERSTITIAL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _nativeAd ??= createNativeAd();
                    _nativeAd
                      ..load()
                      ..show(
                        anchorType: Platform.isAndroid
                            ? AnchorType.bottom
                            : AnchorType.top,
                      );
                  },
                  child: const Text('SHOW NATIVE'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _nativeAd?.dispose();
                    _nativeAd = null;
                  },
                  child: const Text('REMOVE NATIVE'),
                ),
                ElevatedButton(
                  onPressed: () {
                    RewardedVideoAd.instance.load(
                        adUnitId: RewardedVideoAd.testAdUnitId,
                        targetingInfo: targetingInfo);
                  },
                  child: const Text('LOAD REWARDED VIDEO'),
                ),
                ElevatedButton(
                  onPressed: () {
                    RewardedVideoAd.instance.show();
                  },
                  child: const Text('SHOW REWARDED VIDEO'),
                ),
                Text('You have $_coins coins.'),
              ].map((Widget button) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: button,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
