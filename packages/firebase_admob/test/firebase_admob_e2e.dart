// @dart=2.9

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:pedantic/pedantic.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Initialize Firebase Admob', (WidgetTester tester) async {
    expect(
      FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId),
      completion(isTrue),
    );
  });

  testWidgets('Native Ads', (WidgetTester tester) async {
    bool adLoaded = false;

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
        // ignore: avoid_print
        print('NativeAd event: $event');
        if (event == MobileAdEvent.loaded) adLoaded = true;
      },
    );

    await nativeAd.load();
    await Future<void>.delayed(const Duration(seconds: 10));
    expect(adLoaded, isTrue);
  });

  // TODO(bparrishMines): Unskip on Android once tests work on Firebase TestLab.
  // See https://github.com/FirebaseExtended/flutterfire/issues/2384
  testWidgets('Load two Ads Simultaneously', (WidgetTester tester) async {
    final Completer<void> adCompleter1 = Completer<void>();
    final Completer<void> adCompleter2 = Completer<void>();

    final BannerAd bannerAd1 = BannerAd(
      adUnitId: NativeAd.testAdUnitId,
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) adCompleter1.complete();
      },
    );

    final BannerAd bannerAd2 = BannerAd(
      adUnitId: NativeAd.testAdUnitId,
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) adCompleter1.complete();
      },
    );

    unawaited(bannerAd1.load());
    unawaited(bannerAd2.load());

    await expectLater(adCompleter1.future, completes);
    await expectLater(adCompleter2.future, completes);
  }, skip: Platform.isAndroid);
}
