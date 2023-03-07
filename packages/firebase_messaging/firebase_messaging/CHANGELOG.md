## 14.2.5

 - **FIX**: badge is in the `message`, not the `notification` ([#10470](https://github.com/firebase/flutterfire/issues/10470)). ([cf282675](https://github.com/firebase/flutterfire/commit/cf282675a498629887680b37a81014bb939552b4))

## 14.2.4

 - Update a dependency to the latest release.

## 14.2.3

 - Update a dependency to the latest release.

## 14.2.2

 - **REFACTOR**: upgrade project to remove warnings from Flutter 3.7 ([#10344](https://github.com/firebase/flutterfire/issues/10344)). ([e0087c84](https://github.com/firebase/flutterfire/commit/e0087c845c7526c11a4241a26d39d4673b0ad29d))

## 14.2.1

 - Update a dependency to the latest release.

## 14.2.0

 - **FEAT**: add ServerTimestampBehavior to the GetOptions class.  ([#9590](https://github.com/firebase/flutterfire/issues/9590)). ([c25bd2fe](https://github.com/firebase/flutterfire/commit/c25bd2fe4c13bc9f13d93410842c00e25aaac2b2))

## 14.1.4

 - Update a dependency to the latest release.

## 14.1.3

 - **FIX**: fix an issue where the notification wasn't restored when going into terminated state ([#9997](https://github.com/firebase/flutterfire/issues/9997)). ([d468dcb7](https://github.com/firebase/flutterfire/commit/d468dcb7519e1cb97359316f4f8f86b42b2ea9c9))

## 14.1.2

 - **FIX**: prevent getInitialMessage from being null at the start of the app ([#9969](https://github.com/firebase/flutterfire/issues/9969)). ([0b0fea8b](https://github.com/firebase/flutterfire/commit/0b0fea8b42ff61aabc0d2cdcd4d5ab1ea8192c61))

## 14.1.1

 - **FIX**: Revert "feat(messaging): use FlutterEngineGroup to improve performance of background handlers". ([8cd90b1a](https://github.com/firebase/flutterfire/commit/8cd90b1aeffc8b44383dc6a60eb8a39d0c08e3b7))

## 14.1.0

 - **FEAT**: use FlutterEngineGroup to improve performance of background handlers ([#9867](https://github.com/firebase/flutterfire/issues/9867)). ([2e9deac0](https://github.com/firebase/flutterfire/commit/2e9deac08e3c1a9a2b35f850f8519e7c5ae43b37))

## 14.0.4

 - Update a dependency to the latest release.

## 14.0.3

 - **REFACTOR**: add `verify` to `QueryPlatform` and change internal `verifyToken` API to `verify` ([#9711](https://github.com/firebase/flutterfire/issues/9711)). ([c99a842f](https://github.com/firebase/flutterfire/commit/c99a842f3e3f5f10246e73f51530cc58c42b49a3))

## 14.0.2

 - Update a dependency to the latest release.

## 14.0.1

 - Update a dependency to the latest release.

## 14.0.0

> Note: This release has breaking changes.

 - **FIX**: improve pub score ([#9722](https://github.com/firebase/flutterfire/issues/9722)). ([f27d89a1](https://github.com/firebase/flutterfire/commit/f27d89a12cbb5830eb5518854dcfbca72efedb5b))
 - **BREAKING** **FEAT**: Firebase iOS SDK version: `10.0.0` ([#9708](https://github.com/firebase/flutterfire/issues/9708)). ([9627c56a](https://github.com/firebase/flutterfire/commit/9627c56a37d657d0250b6f6b87d0fec1c31d4ba3))
 - **BREAKING** **FEAT**: Firebase android SDK BOM `31.0.0` ([#9724](https://github.com/firebase/flutterfire/issues/9724)). ([29ba1a08](https://github.com/firebase/flutterfire/commit/29ba1a082e026c4f0f0913c10183a72eadb23343))

## 13.1.0

 - **FEAT**: add support for exporting delivery metrics to BigQuery ([#9636](https://github.com/firebase/flutterfire/issues/9636)). ([170b99b9](https://github.com/firebase/flutterfire/commit/170b99b91573f28316172e43188d57ca14600446))

## 13.0.4

 - Update a dependency to the latest release.

## 13.0.3

 - Update a dependency to the latest release.

## 13.0.2

 - **DOCS**: update docs to use `@pragma('vm:entry-point')` annotation for messaging background handler ([#9494](https://github.com/firebase/flutterfire/issues/9494)). ([27a7f44e](https://github.com/firebase/flutterfire/commit/27a7f44e02f2ed533e0249622afdd0a421261385))

## 13.0.1

 - **FIX**: ensure only messaging permission request is processed ([#9486](https://github.com/firebase/flutterfire/issues/9486)). ([5b31e71b](https://github.com/firebase/flutterfire/commit/5b31e71b6cbca0e6a149482436e00598f4eaa2de))

## 13.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: android 13 notifications permission request ([#9348](https://github.com/firebase/flutterfire/issues/9348)). ([43b3b06b](https://github.com/firebase/flutterfire/commit/43b3b06b64739658f79c994110654f5a56abca05))
   `firebase_messaging` now includes this permission: `Manifest.permission.POST_NOTIFICATIONS` in its `AndroidManifest.xml` file which requires updating your `android/app/build.gradle` to target API level 33.

## 12.0.3

 - Update a dependency to the latest release.

## 12.0.2

 - **FIX**: ensure initial notification was tapped to open app. fixes `getInitialMessage()` & `onMessageOpenedApp()` . ([#9315](https://github.com/firebase/flutterfire/issues/9315)). ([e66c59ca](https://github.com/firebase/flutterfire/commit/e66c59ca4b8a13fc4ce597cb63612eaaaefaf673))

## 12.0.1

 - Update a dependency to the latest release.

## 12.0.0

> Note: This release has breaking changes.

 - **DOCS**: fix usage link to the documentation in the README.md ([#9027](https://github.com/firebase/flutterfire/issues/9027)). ([037e3a5f](https://github.com/firebase/flutterfire/commit/037e3a5f3d41a3914ed8e6fa394e42c44fe29186))
 - **BREAKING** **FEAT**: upgrade messaging web to Firebase v9 JS SDK. ([#8860](https://github.com/firebase/flutterfire/issues/8860)). ([f3a6bdc5](https://github.com/firebase/flutterfire/commit/f3a6bdc5fd2441ed3c77a9d0ece0d6460afd2ec4))
 - **BREAKING**: `isSupported()` API is now asynchronous and returns `Future<bool>`. It is web only and will always resolve to `true` on other platforms.

## 11.4.4

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

## 11.4.3

 - Update a dependency to the latest release.

## 11.4.2

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **FIX**: Swizzle check for FlutterAppLifeCycleProvider instead of UNUserNotificationCenterDelegate (#8822). ([81f6b274](https://github.com/firebase/flutterfire/commit/81f6b2743b99e47c16fc3ee13cc1e7e6e7982730))
 - **DOCS**: clarify when `vapidKey` parameter is needed when calling `getToken()` (#8905). ([5ded8652](https://github.com/firebase/flutterfire/commit/5ded86528fad07f9eac9d70e4a49db372350f50d))
 - **DOCS**: fix typo "RemoteMesage" in `messaging.dart` (#8906). ([fd016cd0](https://github.com/firebase/flutterfire/commit/fd016cd09221adde82836a777c770d604d4f99b6))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (#8814). ([78006e0d](https://github.com/firebase/flutterfire/commit/78006e0d5b9dce8038ce3606a43ddcbc8a4a71b9))

## 11.4.1

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8735). ([b2cf87a5](https://github.com/firebase/flutterfire/commit/b2cf87a5d96457bf49b9dd04d6087768bfe6ad95))
 - **FIX**: check `userInfo` for "aps.notification" property presence for firing data only messages. (#8759). ([9eb99674](https://github.com/firebase/flutterfire/commit/9eb996748f4ddae8a34a2306b51af10b4c066039))

## 11.4.0

 - **FIX**: ensure silent foreground messages for iOS are called via event channel. ([#8635](https://github.com/firebase/flutterfire/issues/8635)). ([abb91e48](https://github.com/firebase/flutterfire/commit/abb91e4861b769485878a0f165d6ba8a9604de5a))
 - **FEAT**: retrieve `timeSensitiveSetting` for iOS 15+. ([#8532](https://github.com/firebase/flutterfire/issues/8532)). ([14b38da3](https://github.com/firebase/flutterfire/commit/14b38da31f364ad35be20c5df9cd633c613d8067))

## 11.3.0

 - **FEAT**: retrieve `timeSensitiveSetting` for iOS 15+. (#8532). ([14b38da3](https://github.com/firebase/flutterfire/commit/14b38da31f364ad35be20c5df9cd633c613d8067))

## 11.2.15

 - **REFACTOR**: Remove deprecated `Tasks.call()` API from android. (#8449). ([0510d113](https://github.com/firebase/flutterfire/commit/0510d113dd279d6f55d889e522e74781d8fbb845))

## 11.2.14

 - Update a dependency to the latest release.

## 11.2.13

 - Update a dependency to the latest release.

## 11.2.12

 - Update a dependency to the latest release.

## 11.2.11

 - **FIX**: Ensure `onMessage` callback is consistently called on `iOS` platform. (#8202). ([54f5555e](https://github.com/firebase/flutterfire/commit/54f5555edbedc553df30d7e32747e3b305fbe643))

## 11.2.10

 - **FIX**: Update notification key to `NSApplicationLaunchUserNotificationKey` for macOS. (#8251). ([46b54ccd](https://github.com/firebase/flutterfire/commit/46b54ccd4aee61654e36396b86ed373939569d00))

## 11.2.9

 - **FIX**: `getInitialMessage` returns notification once & only if pressed for `iOS`. (#7634). ([85739b4c](https://github.com/firebase/flutterfire/commit/85739b4cc2f75c6f7017de0e69160fa07477eb1e))

## 11.2.8

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

## 11.2.7

 - **FIX**: Stream new token via onTokenRefresh when getToken invoked for iOS. (#8166). ([28b396b8](https://github.com/firebase/flutterfire/commit/28b396b84e019a5247e70d0abeb1ba24bdff4bcb))

## 11.2.6

 - **FIX**: Set APNS token if user initializes Firebase app from Flutter. (#7610). ([dc4c2c1d](https://github.com/firebase/flutterfire/commit/dc4c2c1d249abf214c8ec7d835af18c86d64b2f5))

## 11.2.5

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726). ([a9562bac](https://github.com/firebase/flutterfire/commit/a9562bac60ba927fb3664a47a7f7eaceb277dca6))
 - **DOCS**: Provide fallback for `messageId` field for web as JS SDK does not have. (#7234). ([4571abeb](https://github.com/firebase/flutterfire/commit/4571abeb859124b8daa520583a8f23fd8e1182d6))

## 11.2.4

 - **FIX**: Return app constants for default app only on `Android`. (#7592). ([b803c425](https://github.com/firebase/flutterfire/commit/b803c425b420acae155fea93a62ab9b3de4556a5))

## 11.2.3

 - Update a dependency to the latest release.

## 11.2.2

 - **DOCS**: Fix typos and remove unused imports (#7504).

## 11.2.1

 - Update a dependency to the latest release.

## 11.2.0

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

## 11.1.0

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

## 11.0.0

> Note: This release has breaking changes.

 - **FIX**: Add Android implementation to get notification permissions (#7168).
 - **BREAKING** **FEAT**: update Android `minSdk` version to 19 as this is required by Firebase Android SDK `29.0.0` (#7298).

## 10.0.9

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).
 - **FIX**: Fix crash. If intent.getExtras() returns `null`, do not attempt to handle `RemoteMessage` #6759 (#7094).
 - **STYLE**: macOS & iOS; explicitly include header that defines `TARGET_OS_OSX` (#7116).

## 10.0.8

 - **FIX**: Fix crash on Android in onDetachedFromEngine (#7088).
 - **CHORE**: update gradle version across packages (#7054).
 - **CHORE**: migrate example app to null-safety (#6990).

## 10.0.7

 - **FIX**: was creating a new instance each time (#6961).

## 10.0.6

 - **FIX**: revert onMessage event handler commit which causes another bug (#6878).
 - **FIX**: allow messages when device is in idle mode (#6730).
 - **FIX**: onMessage event handler for notifcations with `contentAvailable:true` (#6838).

## 10.0.5

 - Update a dependency to the latest release.

## 10.0.4

 - **DOCS**: update web example in line with flutter 2.2.0 generated `index.html` (#6398).
 - **CHORE**: update v2 embedding support (#6506).
 - **CHORE**: rm deprecated jcenter repository (#6431).

## 10.0.3

 - **DOCS**: update web example in line with flutter 2.2.0 generated `index.html` (#6398).
 - **CHORE**: rm deprecated jcenter repository (#6431).

## 10.0.2

 - Update a dependency to the latest release.

## 10.0.1

 - **FIX**: Fix FirebaseMessaging.onMessage and onMessageOpenedApp potentially throwing (#6093).
 - **DOCS**: Add Flutter Favorite badge (#6190).
 - **CHORE**: fix broken messaging example (#6176).

## 10.0.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: remove support for `senderId` named argument on `getToken` & `deleteToken` methods since the native Firebase SDKs no longer support it cross-platform.
 - **FEAT**: implement `isSupported` support for Web (#6109).
 - **FEAT**: upgrade Firebase JS SDK version to 8.6.1.
 - **FIX**: podspec osx version checking script should use a version range instead of a single fixed version.

## 9.1.4

 - Update a dependency to the latest release.

## 9.1.3

 - Update a dependency to the latest release.

## 9.1.2

 - Update a dependency to the latest release.

## 9.1.1

 - Update a dependency to the latest release.

## 9.1.0

 - **FEAT**: android.tag property on Notification (#5452).
 - **CHORE**: bump min Dart SDK constraint to 2.12.0 (#5430).
 - **CHORE**: publish packages (#5429).
 - **CHORE**: merge all analysis_options.yaml into one (#5329).
 - **CHORE**: publish packages.
 - **CHORE**: rm dev dependencies breaking CI (#5221).

## 9.0.1

 - Update a dependency to the latest release.

## 9.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 9.0.0-1.0.nullsafety.2

 - **FIX**: fix unhandled exception  (#4676).

## 9.0.0-1.0.nullsafety.1

 - **TESTS**: update mockito API usage in tests

## 9.0.0-1.0.nullsafety.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: migrate to NNBD (#4909).
 - **BREAKING**: the following deprecated APIs have been removed:
    - `iOSNotificationSettings`.
    - `requestNotificationPermissions` - use `requestPermission` instead.
    - `autoInitEnabled()` - use `setAutoInitEnabled()` instead.
    - `deleteInstanceID()` - use `deleteToken()` instead.
    - `FirebaseMessaging()` - use `FirebaseMessaging.instance` instead.


## 8.0.0-dev.14

 - **DOCS**: fix messaging regex examples (#4649).

## 8.0.0-dev.13

> Note: This release has breaking changes.

 - **FEAT**: add check on podspec to assist upgrading users deployment target.
 - **BUILD**: commit Podfiles with 10.12 deployment target.
 - **BUILD**: remove default sdk version, version should always come from firebase_core, or be user defined.
 - **BUILD**: set macOS deployment target to 10.12 (from 10.11).
 - **BREAKING** **BUILD**: set osx min supported platform version to 10.12.

## 8.0.0-dev.12

> Note: This release has breaking changes.

 - **FIX**: Add missing sdk version constraints inside pubspec.yaml (#4604).
 - **FEAT**: bump firebase-android-sdk BoM to 25.13.0.
 - **CHORE**: harmonize dependencies and version handling.
 - **BREAKING** **FEAT**: forward port to firebase-ios-sdk v7.3.0.
   - Due to this SDK upgrade, iOS 10 is now the minimum supported version by FlutterFire. Please update your build target version.

## 8.0.0-dev.11

 - **REFACTOR**: initial web release as pre-release version.
 - **FIX**: manually create a `FlutterShellArgs` instance from Android activity intent (fixes #4078) (#4341).
 - **FIX**: fixed callback handler type casting on Android (#4313).
 - **FIX**: macOS should not use `FIRAuth canHandleNotification` as it's iOS only (fixes #4136) (#4340).
 - **FIX**: some iOS methods could result in an `no implementation found` error (#4339).

## 8.0.0-dev.10

 - **FEAT**: web implementation (#4206).
 - **FEAT**: bump android `com.android.tools.build` & `'com.google.gms:google-services` versions (#4269).

## 8.0.0-dev.9

 - **TEST**: Explicitly opt-out from null safety.
 - **FIX**: various data types issues in remote message (#4150).
 - **FIX**: java String arrays should be converted to a List (fixes #4072) (#4092).
 - **CHORE**: bump gradle wrapper to 5.6.4 (#4158).

## 8.0.0-dev.8

 - **FIX**: potential crash (fixes #4032) (#4071).

## 8.0.0-dev.7

 - Update a dependency to the latest release.

## 8.0.0-dev.6

 - **REFACTOR**: use invokeMapMethod instead of invokeMethod (#4048).
 - **FIX**: don't replace `UNUserNotificationCenter` delegate when protocol conforms to `FlutterApplicationLifeCycleDelegate` (#4043).

## 8.0.0-dev.5

 - **FIX**: crash when senderId null (fixes #4024) (#4025).

## 8.0.0-dev.4

 - **FEAT**: roadmap rework (#4012).

## 8.0.0-dev.3

 - **FIX**: assert.
 - **FEAT**: notification persistence.
 - **FEAT**: add senderId (use iid on Android to support it).

## 8.0.0-dev.2

 - **FEAT**: bump firebase sdk version to 6.33.0.
 - **DOCS**: typos.

## 8.0.0-dev.1

This plugin is now federated to allow integration with other platforms, along with upgrading underlying SDK versions.

We've also added lots of features which can be seen in the changelog below, however notably the biggest changes are:

- Removed all manual native code changes that were originally required for integration - this plugin works
  out of the box once configured with Firebase & APNs.
- Support for macOS.
- iOS background handler support.
- Android background handler debugging and logging support.
- Android V2 embedding support.
- Reworked API for message handling (Streams + explicit handlers).
- Fully typed Message & Notification classes (vs raw Maps).
- New Apple notification permissions & support.
- Detailed documentation.

- **`FirebaseMessaging`**:

  - **BREAKING**: `configure()` has been removed in favor of calling specific static methods which return Streams.
    - **Why?**: The previous implementation of `configure()` caused unintended side effects if called multiple
      times (either to register a different handler, or remove handlers). This change allows developers to be more
      explicit about registering handlers and removing them without effecting others via Streams.
  - **DEPRECATED**: Calling `FirebaseMessaging()` has been deprecated in favor of `FirebaseMessaging.instance`
    & `FirebaseMessaging.instanceFor()`.
  - **DEPRECATED**: `requestNotificationPermissions()` has been deprecated in favor of `requestPermission()`.
  - **DEPRECATED**: `deleteInstanceID()` has been deprecated in favor of `deleteToken()`.
  - **DEPRECATED**: `autoInitEnabled()` has been deprecated in favor of `isAutoInitEnabled`.
  - **NEW**: Added support for `isAutoInitEnabled` as a synchronous getter.
  - **NEW**: Added support for `getInitialMessage()`. This API has been added to detect whether a messaging containing
    a notification has caused the application to be opened via users interaction.
  - **NEW**: Added support for `deleteToken()`.
  - **NEW**: Added support for `getToken()`.
  - **NEW**: [Apple] Added support for `getAPNSToken()`.
  - **NEW**: [Apple] Added support for `getNotificationSettings()`. See `NotificationSettings` below.
  - **NEW**: [Apple] Added support for `requestPermission()`. See `NotificationSettings` below. New permissions such
    as `carPlay`, `crtiticalAlert`, `announcement` are now supported.
  - **NEW**: [Android] Added support for `sendMessage()`. The `sendMessage()` API enables support for sending FCM
    payloads back to a custom server from the device.
  - **NEW**: [Android] When receiving background messages on the separate background Dart executor whilst in debug,
    you should now see flutter logs and be able to debug/add breakpoints your Dart background message handler.
  - **NEW**: [Apple] Added support for `setForegroundNotificationPresentationOptions()`. By default, iOS devices will
    not show notifications in the foreground. Use this API to override the defaults. See documentation for Android
    foreground notifications.
  - **NEW** - [Android] Firebase Cloud Messages that contain a notification are now always sent to Dart regardless of
    whether the app was in the foreground or background. Previously, if a message came through that contained a
    notification whilst your app was in the foreground then FCM would not notify the plugin messaging service of the
    message (and subsequently your handlers in Dart) until the user interacted with it.

- **Event handling**:

  - Event handling has been reworked to provide a more intuitive API for developers. Foreground based events can now
    be accessed via Streams:
    - **NEW**: `FirebaseMessaging.onMessage` Returns a Stream that is called when an incoming FCM payload is
      received whilst the Flutter instance is in the foreground, containing a [RemoteMessage].
    - **NEW**: `FirebaseMessaging.onMessageOpenedApp` Returns a [Stream] that is called when a user presses a
      notification displayed via FCM. This replaces the previous `onLaunch` and `onResume` handlers.
    - **NEW**: `FirebaseMessaging.onBackgroundMessage()` Sets a background message handler to trigger when the app
      is in the background or terminated.

- `IosNotificationSettings`:

  - **DEPRECATED**: Usage of the `IosNotificationSettings` class is now deprecated (currently used with the now
    deprecated  `requestNotificationPermissions()` method).
    - Instead of this class, use named arguments when calling `requestPermission()` and read the permissions back
      via the returned `NotificationSettings` instance.

- `NotificationSettings`:

  - **NEW**: A `NotificationSettings` class is returned from calls to `requestPermission()`
    and `getNotificationSettings()`. It contains information such as the authorization status, along with the platform
    specific settings.

- `RemoteMessage`:

  - **NEW**: Incoming FCM payloads are now represented as a `RemoteMessage` rather than a raw `Map`.

- `RemoteNotification`:
  - **NEW**:When a message includes a notification payload, the `RemoteMessage` includes a `RemoteNotification` rather
    than a raw `Map`.

- **Other**:

  - Additional types are available throughout messaging to aid with the latest changes:
    - `BackgroundMessageHandler`, `AppleNotificationSetting`, `AppleShowPreviewSetting`, `AuthorizationStatus`
      , `AndroidNotificationPriority`, `AndroidNotificationVisibility`

## 7.0.3

 - Update a dependency to the latest release.

## 7.0.2

 - **FIX**: remove `platform` package usage (#3729).

## 7.0.1

 - **FIX**: local dependencies in example apps (#3319).
 - **CHORE**: intellij cleanup (#3326).

## 7.0.0

* Depend on `firebase_core` and migrate plugin to use `firebase_core` native SDK versioning features;
	* Firebase iOS SDK versions are now locked to use the same version defined in `firebase_core`.
	* Firebase Android SDK versions are now using the Firebase Bill of Materials (BoM) to specify individual SDK versions. BoM version is also sourced from `firebase_core`.
* Allow iOS to be imported as a module.

## 6.0.16

* Fix push notifications clearing after app launch on iOS.

## 6.0.16

* Update lower bound of dart dependency to 2.0.0.

## 6.0.15

* Fix - register `pluginRegistrantCallback` on every `FcmDartService#start` call.

## 6.0.14

* Fix for missing UserAgent.h compilation failures.

## 6.0.13

* Implement `UNUserNotificationCenterDelegate` methods to allow plugin to work when method swizzling is disabled.
* Applications now only need to update their iOS project's `AppDelegate` when method swizzling is disabled.
* Applications that need to use `firebase_messaging` with other notification plugins will need to
  add the following to their iOS project's `Info.plist` file:
  ```xml
  <key>FirebaseAppDelegateProxyEnabled</key>
  <false/>
  ```

## 6.0.12

* Replace deprecated `getFlutterEngine` call on Android.

## 6.0.11

* Make the pedantic dev_dependency explicit.

## 6.0.10

* Update README to explain how to correctly implement Android background message handling with the new v2 embedding.

## 6.0.9

* Update Android Gradle plugin dependency to 3.5.3, update documentation and example.
* Update google-services Android gradle plugin to 4.3.2 in documentation and examples.

## 6.0.8

* Support for provisional notifications for iOS version >= 12.

## 6.0.7

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 6.0.6

* Updated README instructions for Android.

## 6.0.5

* Add import for UserNotifications on iOS.

## 6.0.4

* Support the v2 Android embedding.

## 6.0.3

* Fix bug where `onIosSettingsRegistered` wasn't streamed on iOS >= 10.

## 6.0.2

* Fixed a build warning caused by availability check.

## 6.0.1

* `FirebaseMessaging.configure` will throw an `ArgumentError` when `onBackgroundMessage` parameter
is not a top-level or static function.

## 6.0.0

* Use `UNUserNotificationCenter` to receive messages on iOS version >= 10.
* **Breaking Change** For iOS versions >= 10, this will cause any other plugin that specifies a
  `UNUserNotificationCenterDelegate` to `[UNUserNotificationCenter currentNotificationCenter]` to
  stop receiving notifications. To have this plugin work with plugins that specify their own
  `UNUserNotificationCenterDelegate`, you can remove the line
  ```objectivec
  [UNUserNotificationCenter currentNotificationCenter].delegate = // plugin specified delegate
  ```

  and add this line to your iOS project `AppDelegate.m`

  ```swift
  if (@available(iOS 10.0, *)) {
    [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
  }
  ```

## 5.1.9

* Fix strict compilation errors.

## 5.1.8

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 5.1.7

* Remove AndroidX warning.

## 5.1.6

* Fix warnings when compiling on Android.

## 5.1.5

* Enable background message handling on Android.

## 5.1.4

* Update documentation to reflect new repository location.
* Update unit tests to call `TestWidgetsFlutterBinding.ensureInitialized`.

## 5.1.3

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 5.1.2

* Updates to README and example with explanations of differences in data format.

## 5.1.1

* Update README with more detailed integration instructions.

## 5.1.0

* Changed the return type of `subscribeToTopic` and `unsubscribeFromTopic` to
  `Future<void>`.

## 5.0.6

* Additional integration tests.

## 5.0.5

* On Android, fix crash when calling `deleteInstanceID` with latest Flutter engine.

## 5.0.4

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 5.0.3

* Update Dart code to conform to current Dart formatter.

## 5.0.2

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 5.0.1+1

* Enable support for `onMessage` on iOS using `shouldEstablishDirectChannel`.

## 5.0.1

* Fix error in the logs on startup if unable to retrieve token on startup on Android.

## 5.0.0

* Update Android dependencies to latest.

## 4.0.0+4

* Remove obsolete `use_frameworks!` instruction.

## 4.0.0+3

* Update iOS configuration documentation.

## 4.0.0+2

* Fix example app's floating action button that stopped working due to a breaking change.

## 4.0.0+1

* Log messages about automatic configuration of the default app are now less confusing.

## 4.0.0

*  **Breaking Change** Update message structure for onMessage to match onLaunch and onResume

## 3.0.1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 3.0.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

  This was originally incorrectly pushed in the `2.2.0` update.

## 2.2.0+1

* **Revert the breaking 2.2.0 update**. 2.2.0 was known to be breaking and
  should have incremented the major version number instead of the minor. This
  revert is in and of itself breaking for anyone that has already migrated
  however. Anyone who has already migrated their app to AndroidX should
  immediately update to `3.0.0` instead. That's the correctly versioned new push
  of `2.2.0`.

## 2.2.0

* **BAD**. This was a breaking change that was incorrectly published on a minor
  version upgrade, should never have happened. Reverted by `2.2.0+1`.

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 2.1.0

* Adding support for deleteInstanceID(), autoInitEnabled() and setAutoInitEnabled().

## 2.0.3

* Removing local cache of getToken() in the dart part of the plugin. Now getToken() calls directly its counterparts in the iOS and Android implementations. This enables obtaining its value without calling configure() or having to wait for a new token refresh.

## 2.0.2

* Use boolean values when checking for notification types on iOS.

## 2.0.1

* Bump Android dependencies to latest.

## 2.0.0

* Updated Android to send Remote Message's title and body to Dart.

## 1.0.5

* Bumped test and mockito versions to pick up Dart 2 support.

## 1.0.4

* Bump Android and Firebase dependency versions.

## 1.0.3

* Updated iOS token hook from 'didRefreshRegistrationToken' to 'didReceiveRegistrationToken'

## 1.0.2

* Updated Gradle tooling to match Android Studio 3.2.2.

## 1.0.1

* Fix for Android where the onLaunch event is not triggered when the Activity is killed by the OS (or if the Don't keep activities toggle is enabled)

## 1.0.0

* Bump to released version

## 0.2.5

* Fixed Dart 2 type error.

## 0.2.4

* Updated Google Play Services dependencies to version 15.0.0.

## 0.2.3

* Updated package channel name

## 0.2.2

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 0.2.1

* Fixed Dart 2 type errors.

## 0.2.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.1.4

* Fixed Dart 2 type error in example project.

## 0.1.3

* Enabled use in Swift projects.

## 0.2.2

* Fix for APNS not being correctly registered on iOS when reinstalling application.

## 0.1.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.1.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
* Relaxed GMS dependency to [11.4.0,12.0[

## 0.0.8

* Added FLT prefix to iOS types
* Change GMS dependency to 11.4.+

## 0.0.7

In FirebaseMessagingPlugin.m:
* moved logic from 'tokenRefreshNotification' to 'didRefreshRegistrationToken'
* removed 'tokenRefreshNotification' as well as observer registration
* removed 'connectToFcm' method and related calls
* removed unnecessary FIRMessaging disconnect

## 0.0.6

* Change GMS dependency to 11.+

## 0.0.5+2

* Fixed README example for "click_action"

## 0.0.5+1

* Aligned author name with rest of repo.

## 0.0.5

* Updated to Firebase SDK to always use latest patch version for 11.0.x builds

## 0.0.4

* Updated to Firebase SDK Version 11.0.1

## 0.0.3

* Updated README.md
* Bumped buildToolsVersion to 25.0.3

## 0.0.2+2

* Updated README.md

## 0.0.2+1

* Added workaround for https://github.com/flutter/flutter/issues/9694 to README
* Moved code to https://github.com/firebase/flutterfire

## 0.0.2

* Updated to latest plugin API

## 0.0.2.2

* Downgraded gradle dependency for example app to make `flutter run` happy

## 0.0.1+1

* Updated README with installation instructions
* Added CHANGELOG

## 0.0.1

* Initial Release
