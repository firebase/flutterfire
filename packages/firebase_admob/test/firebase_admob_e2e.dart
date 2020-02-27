import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

import 'package:firebase_admob/firebase_admob.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Initialize Firebase Admob', (WidgetTester tester) async {
    expect(
      FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId),
      completion(isTrue),
    );
  });

  testWidgets('Native Ads', (WidgetTester tester) async {
    print('TEST START');
    final randInt = Random().nextDouble();
    print('Random: ${randInt}');
    bool adLoaded = false;
    bool adImpression = false;

    final NativeAd nativeAd = NativeAd(
      adUnitId: NativeAd.testAdUnitId,
      factoryId: 'adFactoryExample',
      targetingInfo: MobileAdTargetingInfo(
        keywords: <String>['foo', 'bar'],
        contentUrl: 'http://foo.com/bar.html',
        childDirected: true,
        nonPersonalizedAds: true,
      ),
      listener: (MobileAdEvent event) {
        print('NativeAd event: $event');
        if (event == MobileAdEvent.loaded) {
          adLoaded = true;
        }
        if (event == MobileAdEvent.impression) {
          print('Setting adImpression to true');
          adImpression = true;
          print('adimpression: $adImpression');
        }
      },
    );

    await nativeAd.load();
    await Future<void>.delayed(Duration(seconds: 10));
    print('Finished load wait');
    expect(adLoaded, isTrue);

    await nativeAd.show();
    await Future<void>.delayed(Duration(seconds: 10));
    print('Finished show await');
    print('2adImpression: $adImpression');
    print('End Random: ${randInt}');
    expect(adImpression, isTrue);
    print('TEST END');
  });
}
