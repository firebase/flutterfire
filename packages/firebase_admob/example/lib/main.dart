// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';

// You can also test with your own ad unit IDs by registering your device as a
// test device. Check the logs for your device's ID value.
const String testDevice = 'YOUR_DEVICE_ID';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AdListener {
  BannerAd _bannerAd;
  BannerAd _offsetBannerAd;
  InterstitialAd _interstitialAd;
//  NativeAd _nativeAd;
  int _coins = 0;

  BannerAd _createBannerAd() {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      listener: this,
    );
  }

  InterstitialAd _createInterstitialAd() {
    return InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      listener: this,
    );
  }
//
//  NativeAd createNativeAd() {
//    return NativeAd(
//      adUnitId: NativeAd.testAdUnitId,
//      factoryId: 'adFactoryExample',
//      targetingInfo: targetingInfo,
//      listener: (MobileAdEvent event) {
//        print("$NativeAd event $event");
//      },
//    );
//  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.initialize();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
//    _nativeAd?.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton(
                    child: const Text('SHOW BANNER'),
                    onPressed: () {
                      _bannerAd ??= _createBannerAd()..load();
                      //..show();
                    }),
                RaisedButton(
                    child: const Text('REMOVE BANNER'),
                    onPressed: () {
                      _bannerAd?.dispose();
                      _bannerAd = null;
                    }),
                RaisedButton(
                    child: const Text('SHOW BANNER WITH OFFSET'),
                    onPressed: () {
                      _offsetBannerAd ??= _createBannerAd()..load();
                      //..show(horizontalCenterOffset: -50, anchorOffset: 100);
                    }),
                RaisedButton(
                    child: const Text('REMOVE OFFSET BANNER'),
                    onPressed: () {
                      _offsetBannerAd?.dispose();
                      _offsetBannerAd = null;
                    }),
                RaisedButton(
                  child: const Text('SHOW INTERSTITIAL'),
                  onPressed: () {
                    _interstitialAd?.dispose();
                    _interstitialAd = _createInterstitialAd()..load();
                  },
                ),
//                RaisedButton(
//                  child: const Text('SHOW NATIVE'),
//                  onPressed: () {
//                    _nativeAd ??= createNativeAd();
//                    _nativeAd
//                      ..load()
//                      ..show(
//                        anchorType: Platform.isAndroid
//                            ? AnchorType.bottom
//                            : AnchorType.top,
//                      );
//                  },
//                ),
//                RaisedButton(
//                  child: const Text('REMOVE NATIVE'),
//                  onPressed: () {
//                    _nativeAd?.dispose();
//                    _nativeAd = null;
//                  },
//                ),
//                RaisedButton(
//                  child: const Text('LOAD REWARDED VIDEO'),
//                  onPressed: () {
//                    RewardedVideoAd.instance.load(
//                        adUnitId: RewardedVideoAd.testAdUnitId,
//                        targetingInfo: targetingInfo);
//                  },
//                ),
//                RaisedButton(
//                  child: const Text('SHOW REWARDED VIDEO'),
//                  onPressed: () {
//                    RewardedVideoAd.instance.show();
//                  },
//                ),
                Text("You have $_coins coins."),
              ].map((Widget button) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: button,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onAdLoaded(Ad ad) {
    print('Ad loaded');
    if (ad == _bannerAd) {
      _bannerAd.show();
    } else if (ad == _offsetBannerAd) {
      _offsetBannerAd?.show(
        anchorOffset: 20,
        horizontalCenterOffset: 20,
        anchorType: AnchorType.top,
      );
    } else if (ad == _interstitialAd) {
      _interstitialAd.show();
    }
  }
}

void main() {
  runApp(MyApp());
}
