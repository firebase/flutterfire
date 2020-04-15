import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quiver/collection.dart';

import 'ads.dart';

// ignore_for_file: public_member_api_docs

class AdInstanceManager {
  @visibleForTesting
  AdInstanceManager() {
    channel.setMethodCallHandler(_handleMethodCall);
  }

  static final AdInstanceManager instance = AdInstanceManager();

  static final MethodChannel channel = MethodChannel(
      'plugins.flutter.io/firebase_admob',
      StandardMethodCodec(const FirebaseAdMobMessageCodec()));

  final BiMap<Ad, int> _adToReferenceId = BiMap<Ad, int>();

  int referenceIdFor(Ad ad) => _adToReferenceId[ad];

  Ad adFor(int referenceId) => _adToReferenceId.inverse[referenceId];

  List<dynamic> getAdParameters(Ad ad) {
    if (ad is BannerAd) {
      return <dynamic>[ad.adUnitId, ad.request, ad.size];
    } else if (ad is InterstitialAd) {
      return <dynamic>[ad.adUnitId, ad.request];
    }
    throw ArgumentError();
  }

  Future<void> initialize() {
    return channel.invokeMethod<void>('INITIALIZE');
  }

  void load(Ad ad) {
    if (referenceIdFor(ad) != null) return;

    final int referenceId = ad.hashCode;
    _adToReferenceId[ad] = referenceId;
    channel.invokeMethod<void>(
      'LOAD',
      <dynamic>[referenceId, ad.runtimeType.toString(), getAdParameters(ad)],
    );
  }

  Future<void> showPlatformViewAd(
    PlatformViewAd ad, {
    double anchorOffset,
    double horizontalCenterOffset,
    AnchorType anchorType,
  }) {
    assert(referenceIdFor(ad as Ad) != null);
    return channel.invokeMethod<void>(
      'SHOW',
      <dynamic>[
        referenceIdFor(ad as Ad),
        <dynamic>[anchorOffset, horizontalCenterOffset, anchorType],
      ],
    );
  }

  Future<void> showFullscreenAd(FullscreenAd ad) {
    assert(referenceIdFor(ad as Ad) != null);
    return channel.invokeMethod<void>(
      'SHOW',
      <dynamic>[referenceIdFor(ad as Ad), <dynamic>[]],
    );
  }

  void receiveMethodCall(
    int referenceId,
    String methodName,
    List<dynamic> arguments,
  ) {
    final Ad ad = adFor(referenceId);
    switch (methodName) {
      case 'AdListener#onAdLoaded':
        ad?.listener?.onAdLoaded(ad);
        return;
    }
  }

  void dispose(Ad ad) {
    assert(ad is Ad);
    final int referenceId = referenceIdFor(ad);
    if (referenceId == null) return;
    channel.invokeMethod<void>('DISPOSE', referenceId);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    receiveMethodCall(
      call.arguments[0],
      call.method,
      call.arguments[1],
    );
  }
}

class FirebaseAdMobMessageCodec extends StandardMessageCodec {
  const FirebaseAdMobMessageCodec();

  static const int _valueAdRequest = 128;
  static const int _valueAdSize = 129;
  static const int _valueAnchorType = 130;

  @override
  void writeValue(WriteBuffer buffer, dynamic value) {
    if (value is AdRequest) {
      buffer.putUint8(_valueAdRequest);
    } else if (value is AdSize) {
      buffer.putUint8(_valueAdSize);
      writeValue(buffer, value.width);
      writeValue(buffer, value.height);
    } else if (value is AnchorType) {
      buffer.putUint8(_valueAnchorType);
      writeValue(buffer, value.toString());
    } else {
      super.writeValue(buffer, value);
    }
  }
}
