import 'dart:async';

import 'package:flutter/services.dart';
import 'package:quiver/collection.dart';

import '../firebase_admob.dart';

// ignore_for_file: public_member_api_docs

class AdInstanceManager {
  AdInstanceManager(this.channel);

  static int _nextAdId = 0;
  final BiMap<MobileAd, int> _adToAdIdMap = BiMap<MobileAd, int>();

  final MethodChannel channel;

  int adIdFor(MobileAd ad) => _adToAdIdMap[ad];

  MobileAd adFor(int adId) => _adToAdIdMap.inverse[adId];

  Future<void> initialize() {
    return channel.invokeMethod<void>('initialize');
  }

  void loadBannerAd(BannerAd ad) {
    if (adIdFor(ad) != null) return;

    final int adId = _nextAdId++;
    _adToAdIdMap[ad] = adId;
    channel.invokeMethod<void>(
      'loadBannerAd',
      <dynamic, dynamic>{
        'adId': adId,
        'adUnitId': ad.adUnitId,
      },
    );
  }

  void disposeAd(MobileAd ad) {
    final int adId = _adToAdIdMap.remove(ad);
    if (adId == null) return;
    channel.invokeMethod<void>('disposeAd', adId);
  }
}
