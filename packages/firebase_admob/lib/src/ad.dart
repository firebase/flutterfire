import 'dart:async';
import 'dart:io';

import 'package:firebase_admob/src/ad_instance_manager.dart';
import 'package:meta/meta.dart';

// ignore_for_file: public_member_api_docs

abstract class FirebaseAdMob {
  static Future<void> initialize() {
    return AdInstanceManager.instance.initialize();
  }
}

abstract class Ad {
  const Ad({@required this.adUnitId, AdRequest request, this.listener})
      : request = request ?? const AdRequest(),
        assert(adUnitId != null);

  final String adUnitId;
  final AdRequest request;
  final AdListener listener;

  void load() {
    AdInstanceManager.instance.load(this);
  }

  void dispose() {
    AdInstanceManager.instance.dispose(this);
  }
}

class AdRequest {
  const AdRequest();
}

mixin AdListener {
  void onAdLoaded(Ad ad);
  //void onNativeAdClicked(NativeAd ad);

}

enum AnchorType { bottom, top }

mixin PlatformViewAd {
  Future<void> show({
    double anchorOffset = 0.0,
    double horizontalCenterOffset = 0.0,
    AnchorType anchorType = AnchorType.bottom,
  }) {
    return AdInstanceManager.instance.showPlatformViewAd(
      this,
      anchorOffset: anchorOffset,
      horizontalCenterOffset: horizontalCenterOffset,
      anchorType: anchorType,
    );
  }
}

mixin FullscreenAd {
  Future<void> show() {
    return AdInstanceManager.instance.showFullscreenAd(this);
  }
}

class AdSize {
  const AdSize(this.width, this.height);

  final int width;
  final int height;

  static final AdSize banner = AdSize(320, 50);
}

class BannerAd extends Ad with PlatformViewAd {
  const BannerAd({
    @required String adUnitId,
    @required this.size,
    AdRequest request,
    AdListener listener,
  })  : assert(size != null),
        super(adUnitId: adUnitId, request: request, listener: listener);

  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  final AdSize size;
}

class InterstitialAd extends Ad with FullscreenAd {
  const InterstitialAd({
    @required String adUnitId,
    AdRequest request,
    AdListener listener,
  }) : super(adUnitId: adUnitId, request: request, listener: listener);

  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';
}

class NativeAd extends Ad with PlatformViewAd {
  const NativeAd({
    @required String adUnitId,
    @required this.factoryId,
    AdRequest request,
    AdListener listener,
    this.customOptions,
  }) : super(adUnitId: adUnitId, request: request, listener: listener);

  /// Optional options used to create the [NativeAd].
  ///
  /// These options are passed to the platform's `NativeAdFactory`.
  final Map<String, dynamic> customOptions;

  /// An identifier for the factory that creates the Platform view.
  final String factoryId;

  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';
}

class RewardedAd extends Ad with FullscreenAd {
  const RewardedAd({
    @required String adUnitId,
    AdRequest request,
    AdListener listener,
  }) : super(adUnitId: adUnitId, request: request, listener: listener);

  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';
}
