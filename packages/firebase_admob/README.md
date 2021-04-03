# Deprecation of firebase_admob Plugin

The `firebase_admob` plugin will be deprecated in April 2021 in favor of [Google Mobile Ads SDK for
Flutter](https://pub.dev/packages/google_mobile_ads).

Google Mobile Ads SDK for Flutter is a new Flutter plugin that supports more Ads formats than
`firebase_admob`. Google Mobile Ads SDK for Flutter currently supports loading and displaying
banner, interstitial (full-screen), native ads, and rewarded video ads across AdMob and AdManager.
It also supports displaying banner and native ads as Widgets as opposed to being overlayed over all
app content.

Projects currently using `firebase_admob` are encouraged to migrate to Google Mobile Ads SDK for
Flutter following the instructions outlined below.

## Migrating to Google Mobile Ads SDK for Flutter

The main change of google_mobile_ads plugin is how ads are displayed. This section provides a quick
migration guide when transitioning to the new plugin.

### Banner and Native Ads

Banner and native ads in the `firebase_admob` plugin were displayed as an overlay on top of all app
content. With `google_mobile_ads`, they can now only be displayed as a Flutter Widget. Below is an
example of displaying a BannerAd anchored to the bottom with an offset using the `firebase_admob`
plugin:

```dart
void main() {
 WidgetsFlutterBinding.ensureInitialized();
 FirebaseAdMob.instance.initialize(appId: appId);

 runApp(MyApp());
}

class MyApp extends StatefulWidget {
 @override
 MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
    );

    _bannerAd
      ..load()
      ..show(
        anchorOffset: 10.0,
        anchorType: AnchorType.bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyAppWidget();
  }
}
```

When transitioning to `google_mobile_ads`, the `show` method has been removed with `AdWidget`
replacing it. Below is an example of displaying an ad with `google_mobile_ads` that is also anchored
to the bottom with an offset:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: BannerAd.testAdUnitId,
      listener: AdListener(),
      request: AdRequest(),
    );
    _bannerAd.load();
 }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MyAppWidget(),
        Container(
          padding: EdgeInsets.only(bottom: 10.0),
          alignment: Alignment.bottomCenter,
          child: AdWidget(ad: _bannerAd),
        ),
      ],
    );
  }
}
```

### Interstitial and Rewarded Ads

The typical pattern for displaying interstitial and rewarded Ads with `firebase_admob` would be to
call `show` right after `load`. This is now discouraged and `show` should only be called when
`AdListener.onAdLoaded` has been called. Below is an example usage of an interstitial ad:

```dart
class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  InterstitialAd _interstitialAd;

  @override
  void initState() {
    super.initState();
    _interstitialAd = InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      request: AdRequest(),
      listener: AdListener(
        onAdLoaded: (Ad ad) {
          // Ad is now ready to show at any time.
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print(error);
          ad.dispose();
        },
        onAdClosed: (Ad ad) {
          ad.dispose();
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyAppWidget();
  }
}
```

# firebase_admob

A plugin for [Flutter](https://flutter.io) that supports loading and
displaying banner, interstitial (full-screen), and rewarded video ads using the
[Firebase AdMob API](https://firebase.google.com/docs/admob/).

For Flutter plugins for other Firebase products, see [README.md](https://github.com/FirebaseExtended/flutterfire/blob/master/README.md).

## AndroidManifest changes

AdMob 17 requires the App ID to be included in the `AndroidManifest.xml`. Failure
to do so will result in a crash on launch of your app.  The line should look like:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="[ADMOB_APP_ID]"/>
```

where `[ADMOB_APP_ID]` is your App ID.  You must pass the same value when you
initialize the plugin in your Dart code.

See https://goo.gl/fQ2neu for more information about configuring `AndroidManifest.xml`
and setting up your App ID.

## Info.plist changes

Admob 7.42.0 requires the App ID to be included in `Info.plist`. Failure to do so will result in a crash on launch of your app. The lines should look like:

```xml
<key>GADApplicationIdentifier</key>
<string>[ADMOB_APP_ID]</string>
```

where `[ADMOB_APP_ID]` is your App ID.  You must pass the same value when you initialize the plugin in your Dart code.

See https://developers.google.com/admob/ios/quick-start#update_your_infoplist for more information about configuring `Info.plist` and setting up your App ID.

## Initializing the plugin
The AdMob plugin must be initialized with an AdMob App ID.

```dart
FirebaseAdMob.instance.initialize(appId: appId);
```
### Android
Starting in version 17.0.0, if you are an AdMob publisher you are now required to add your AdMob app ID in your **AndroidManifest.xml** file. Once you find your AdMob app ID in the AdMob UI, add it to your manifest adding the following tag:

```xml
<manifest>
    <application>
        <!-- TODO: Replace with your real AdMob app ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-################~##########"/>
    </application>
</manifest>
```

Failure to add this tag will result in the app crashing at app launch with a message starting with *"The Google Mobile Ads SDK was initialized incorrectly."*

On Android, this value must be the same as the App ID value set in your
`AndroidManifest.xml`.

### iOS
Starting in version 7.42.0, you are required to add your AdMob app ID in your **Info.plist** file under the Runner directory. You can add it using Xcode or edit the file manually:

```xml
<dict>
	<key>GADApplicationIdentifier</key>
	<string>ca-app-pub-################~##########</string>
</dict>
```

Failure to add this tag will result in the app crashing at app launch with a message including *"GADVerifyApplicationID."*

## Firebase related changes

You are also required to ensure that you have Google Service file from Firebase inside your project.

### iOS

Create an "App" in firebase and generate a GoogleService-info.plist file. This file needs to be embedded in the projects "Runner/Runner" folder using Xcode.

https://firebase.google.com/docs/ios/setup#create-firebase-project -> Steps 1-3

### Android

Create an "App" in firebase and generate a google-service.json file. This file needs to be embedded in you projects "android/app" folder.

https://firebase.google.com/docs/android/setup#create-firebase-project -> Steps 1-3.1

## Using banners and interstitials
Banner and interstitial ads can be configured with target information.
And in the example below, the ads are given test ad unit IDs for a quick start.

```dart
MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['flutterio', 'beautiful apps'],
  contentUrl: 'https://flutter.io',
  birthday: DateTime.now(),
  childDirected: false,
  designedForFamilies: false,
  gender: MobileAdGender.male, // or MobileAdGender.female, MobileAdGender.unknown
  testDevices: <String>[], // Android emulators are considered test devices
);

BannerAd myBanner = BannerAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId: BannerAd.testAdUnitId,
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);

InterstitialAd myInterstitial = InterstitialAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId: InterstitialAd.testAdUnitId,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("InterstitialAd event is $event");
  },
);
```

Ads must be loaded before they're shown.
```dart
myBanner
  // typically this happens well before the ad is shown
  ..load()
  ..show(
    // Positions the banner ad 60 pixels from the bottom of the screen
    anchorOffset: 60.0,
    // Positions the banner ad 10 pixels from the center of the screen to the right
    horizontalCenterOffset: 10.0,
    // Banner Position
    anchorType: AnchorType.bottom,
  );
```

```dart
myInterstitial
  ..load()
  ..show(
    anchorType: AnchorType.bottom,
    anchorOffset: 0.0,
    horizontalCenterOffset: 0.0,
  );
```

`BannerAd` and `InterstitialAd` objects can be disposed to free up plugin
resources. Disposing a banner ad that's been shown removes it from the screen.
Interstitial ads, however, can't be programmatically removed from view.

Banner and interstitial ads can be created with a `MobileAdEvent` listener. The
listener can be used to detect when the ad has actually finished loading
(or failed to load at all).

## Using rewarded video ads

Unlike banners and interstitials, rewarded video ads are loaded one at a time
via a singleton object, `RewardedVideoAd.instance`. Its `load` method takes an
AdMob ad unit ID and an instance of `MobileAdTargetingInfo`:
```dart
RewardedVideoAd.instance.load(myAdMobAdUnitId, targetingInfo);
```

To listen for events in the rewarded video ad lifecycle, apps can define a
function matching the `RewardedVideoAdListener` typedef, and assign it to the
`listener` instance variable in `RewardedVideoAd`. If set, the `listener`
function will be invoked whenever one of the events in the `RewardedVideAdEvent`
enum occurs. After a rewarded video ad loads, for example, the
`RewardedVideoAdEvent.loaded` is sent. Any time after that, apps can show the ad
by calling `show`:
```dart
RewardedVideoAd.instance.show();
```

When the AdMob SDK decides it's time to grant an in-app reward, it does so via
the `RewardedVideoAdEvent.rewarded` event:
```dart
RewardedVideoAd.instance.listener =
    (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
  if (event == RewardedVideoAdEvent.rewarded) {
    setState(() {
      // Here, apps should update state to reflect the reward.
      _goldCoins += rewardAmount;
    });
  }
};
```

Because `RewardedVideoAd` is a singleton object, it does not offer a `dispose`
method.

## Using native ads

Native Ads are presented to users via UI components that
are native to the platform. (e.g. A
[View](https://developer.android.com/reference/android/view/View) on Android or a
[UIView](https://developer.apple.com/documentation/uikit/uiview?language=objc)
on iOS). Using Flutter widgets to create native ads is NOT supported by
this.

Since Native Ads require UI components native to a platform, this feature requires additional setup
for Android and iOS:

### Android
The Android Admob Plugin requires a class that implements `NativeAdFactory` which contains a method
that takes a
[UnifiedNativeAd](https://developers.google.com/android/reference/com/google/android/gms/ads/formats/UnifiedNativeAd)
and custom options and returns a
[UnifiedNativeAdView](https://developers.google.com/android/reference/com/google/android/gms/ads/formats/UnifiedNativeAdView).

You can implement this in your `MainActivity.java` or create a separate class in the same directory
as `MainActivity.java` as seen below:

```java
package my.app.path;

import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin.NativeAdFactory;
import java.util.Map;

class NativeAdFactoryExample implements NativeAdFactory {
  @Override
  public UnifiedNativeAdView createNativeAd(
      UnifiedNativeAd nativeAd, Map<String, Object> customOptions) {
    // Create UnifiedNativeAdView
  }
}
```

An instance of a `NativeAdFactory` should also be added to the `FirebaseAdMobPlugin`. This is done
slightly differently depending on whether you are using Embedding V1 or Embedding V2.

If you're using the Embedding V1, you need to register your `NativeAdFactory` with a unique `String`
identifier after calling `GeneratedPluginRegistrant.registerWith(this);`.

You're `MainActivity.java` should look similar to:

```java
package my.app.path;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    FirebaseAdMobPlugin.registerNativeAdFactory(this, "adFactoryExample", new NativeAdFactoryExample());
  }
}
```

If you're using Embedding V2, you need to register your `NativeAdFactory` with a unique `String`
identifier after adding the `FirebaseAdMobPlugin` to the `FlutterEngine`. (Adding the
`FirebaseAdMobPlugin` to `FlutterEngine` should be done in a `GeneratedPluginRegistrant` in the near
future, so you may not see it being added here). You should also unregister the factory in
`cleanUpFlutterEngine(engine)`.

You're `MainActivity.java` should look similar to:

```java
package my.app.path;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new FirebaseAdMobPlugin());

    FirebaseAdMobPlugin.registerNativeAdFactory(flutterEngine, "adFactoryExample", NativeAdFactoryExample());
  }

  @Override
  public void cleanUpFlutterEngine(FlutterEngine flutterEngine) {
    FirebaseAdMobPlugin.unregisterNativeAdFactory(flutterEngine, "adFactoryExample");
  }
}
```

When creating the `NativeAd` in Flutter, the `factoryId` parameter should match the one you used to
add the factory to `FirebaseAdMobPlugin`.

An example of displaying a `UnifiedNativeAd` with a `UnifiedNativeAdView` can be found
[here](https://developers.google.com/admob/android/native/advanced). The example app also inflates
a custom layout and displays the test Native ad.

### iOS
Native Ads for iOS require a class that implements the protocol `FLTNativeAdFactory` which has a
single method `createNativeAd:customOptions:`.

You can have your `AppDelegate` implement this protocol or create a separate class as seen below:

```objectivec
/* AppDelegate.m */

#import "FLTFirebaseAdMobPlugin.h"

@interface NativeAdFactoryExample : NSObject<FLTNativeAdFactory>
@end

@implementation NativeAdFactoryExample
- (GADUnifiedNativeAdView *)createNativeAd:(GADUnifiedNativeAd *)nativeAd
                             customOptions:(NSDictionary *)customOptions {
  // Create GADUnifiedNativeAdView
}
@end
```

Once there is an implementation of `FLTNativeAdFactory`, it must be added to the
`FLTFirebaseAdMobPlugin`. This is done by importing `FLTFirebaseAdMobPlugin.h` and calling
`registerNativeAdFactory:factoryId:nativeAdFactory:` with a `FlutterPluginRegistry`, a unique
identifier for the factory, and the factory itself. The factory also *MUST* be added after
`[GeneratedPluginRegistrant registerWithRegistry:self];` has been called.

If this is done in `AppDelegate.m`, it should look similar to:

```objectivec
#import "FLTFirebaseAdMobPlugin.h"

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];

  NativeAdFactoryExample *nativeAdFactory = [[NativeAdFactoryExample alloc] init];
  [FLTFirebaseAdMobPlugin registerNativeAdFactory:self
                                        factoryId:@"adFactoryExample"
                                  nativeAdFactory:nativeAdFactory];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
```

### Dart Example

When creating a Native Ad in Dart, setup is similar to Banners and Interstitials. You can use
`MobileAdTargetingInfo` to target ads, create a listener to respond to `MobileAdEvent`s, and test
with a test ad unit id. Your `factoryId` should match the id used to register the `NativeAdFactory`
in Java/Kotlin/Obj-C/Swift. An example of this implementation is seen below:

```dart
MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['flutterio', 'beautiful apps'],
  contentUrl: 'https://flutter.io',
  birthday: DateTime.now(),
  childDirected: false,
  designedForFamilies: false,
  gender: MobileAdGender.male, // or MobileAdGender.female, MobileAdGender.unknown
  testDevices: <String>[], // Android emulators are considered test devices
);

final NativeAd nativeAd = NativeAd(
  adUnitId: NativeAd.testAdUnitId,
  factoryId: 'adFactoryExample',
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("$NativeAd event $event");
  },
);
```

## Limitations

This plugin currently has some limitations:

- Banner ads cannot be animated into view.
- It's not possible to specify a banner ad's size.
- The existing tests are fairly rudimentary.
- There is no API doc.
- The example should demonstrate how to show gate a route push with an
  interstitial ad

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to Flutterfire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
