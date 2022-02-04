## 11.2.6

 - **FIX**: Set APNS token if user initializes Firebase app from Flutter. (#7610). ([dc4c2c1d](https://github.com/FirebaseExtended/flutterfire/commit/dc4c2c1d249abf214c8ec7d835af18c86d64b2f5))

## 11.2.5

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726). ([a9562bac](https://github.com/FirebaseExtended/flutterfire/commit/a9562bac60ba927fb3664a47a7f7eaceb277dca6))
 - **DOCS**: Provide fallback for `messageId` field for web as JS SDK does not have. (#7234). ([4571abeb](https://github.com/FirebaseExtended/flutterfire/commit/4571abeb859124b8daa520583a8f23fd8e1182d6))

## 11.2.4

 - **FIX**: Return app constants for default app only on `Android`. (#7592). ([b803c425](https://github.com/FirebaseExtended/flutterfire/commit/b803c425b420acae155fea93a62ab9b3de4556a5))

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
* Moved code to https://github.com/FirebaseExtended/flutterfire

## 0.0.2

* Updated to latest plugin API

## 0.0.2.2

* Downgraded gradle dependency for example app to make `flutter run` happy

## 0.0.1+1

* Updated README with installation instructions
* Added CHANGELOG

## 0.0.1

* Initial Release
