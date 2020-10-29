## 0.5.1

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: update Firebase Android SDK BoM version to 25.12.0 (from 25.3.1).
 - **FEAT**: update Firebase iOS SDK version to 6.33.0 (from 6.26.0).

## 0.5.0+1

 - **FIX**: remove unused dart:async import (#3611).

## 0.5.0

* Allow iOS and macOS to be imported as a module.
* DEPRECATED: `FirebaseApp.configure` method is now deprecated in favor of the `Firebase.initializeApp` method.
* DEPRECATED: `FirebaseApp.allApps` method is now deprecated in favor of the `Firebase.apps` property.
  * Previously, `allApps` was async & `apps` is now synchronous.
* DEPRECATED: `FirebaseApp.appNamed` method is now deprecated in favor of the `Firebase.app` method.
* BREAKING: `FirebaseApp.options` getter is now synchronous.

* `FirebaseOptions` has been reworked to better match web property names:
  * DEPRECATED: `googleAppID` is now deprecated in favor of `appId`.
  * DEPRECATED: `projectID` is now deprecated in favor of `projectId`.
  * DEPRECATED: `bundleID` is now deprecated in favor of `bundleId`.
  * DEPRECATED: `clientID` is now deprecated in favor of `androidClientId`.
  * DEPRECATED: `trackingID` is now deprecated in favor of `trackingId`.
  * DEPRECATED: `gcmSenderID` is now deprecated in favor of `messagingSenderId`.
  * Added support for `authDomain`.
  * Added support for `trackingId`.
  * Required properties are now `apiKey`, `appId`, `messagingSenderId` & `projectId`.

* Added support for deleting Firebase app instances via the `delete` method on `FirebaseApp`.
* Added support for returning consistent error messages from `firebase-dart` plugin.
  * Any FlutterFire related errors now throw a `FirebaseException`.
* Added a `FirebaseException` class to handle all FlutterFire related errors.
  * Matching the web sdk, the exception returns a formatted "[plugin/code] message" message when thrown.
* Added support for `setAutomaticDataCollectionEnabled` & `isAutomaticDataCollectionEnabled` on a `FirebaseApp` instance.
* Added support for `setAutomaticResourceManagementEnabled` on a `FirebaseApp` instance.

* Android: Gradle build tools updated to 3.6.3 from 3.3.0.
* Android: Removed Gradle ‘hacks’ and upgrade Flutter SDK requirement from `>=1.12.13+hotfix.4` to `>=1.12.13+hotfix.5` - based on PR https://github.com/flutter/plugins/pull/2651
* Android: Switched to using Firebase BoM to manage SDK versions

## 0.4.5

* Update lower bound of dart dependency to 2.0.0.

## 0.4.4+3

* Fix for missing UserAgent.h compilation failures.

## 0.4.4+2

* Update dependency on firebase_core_platform_interface to 1.0.4.

## 0.4.4+1

* Make the pedantic dev_dependency explicit.

## 0.4.4

* Add macOS support

## 0.4.3+3

* Fix overrides a deprecated API.

## 0.4.3+2

* Add integration instructions for the `web` platform.

## 0.4.3+1

* Move `Platform.isIOS` check behind a configurable import so that pub.dev registers
  this as a Web plugin.

## 0.4.3

* Enable the `web` implementation by default.
* Raise minimum required Flutter SDK version to 1.12.13+hotfix.4

## 0.4.2+2

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 0.4.2+1

* Check `kIsWeb` before checking `Platform.isIos` for the default app name.

## 0.4.2

* Migrate to `firebase_core_platform_interface`.

## 0.4.1+6

* Update the homepage now that the package structure has changed.

## 0.4.1+5

* Remove deprecated [firebase-core](https://firebase.google.com/support/release-notes/android) dependency.

## 0.4.1+4

* Remove visibleForTesting annotation from FirebaseApp constructor. 

## 0.4.1+3

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 0.4.1+2

* Remove AndroidX warning.

## 0.4.1+1

* Include lifecycle dependency as a compileOnly one on Android to resolve
  potential version conflicts with other transitive libraries.

## 0.4.1

* Support the v2 Android embedding.

## 0.4.0+9

* Update documentation to reflect new repository location.
* Update unit tests to call `TestWidgetsFlutterBinding.ensureInitialized`.

## 0.4.0+8

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 0.4.0+7

* Fix Android compilation warning.

## 0.4.0+6

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 0.4.0+5

* Rollback of automatic plugin version retrieval.

## 0.4.0+4

* Automate the retrieval of the plugin's version when reporting usage to Firebase.

## 0.4.0+3

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.4.0+2

* Update user agent name. Set to `flutter-fire-core` for consistency with other
  libraries.

## 0.4.0+1

* Send user agent to Firebase.

## 0.4.0

* Update Android dependencies to latest.

## 0.3.4

* Updates Android firebase-core dependency to a version that is compatible with other Flutterfire plugins.

## 0.3.3

* Remove Gradle BoM to avoid Gradle version issues.

## 0.3.2

* Move Android dependency to Gradle BoM to help maintain compatability
  with other FlutterFire plugins.

## 0.3.1+1

* Add nil check on static functions to prevent crashes or unwanted behaviors.

## 0.3.1

* Remove an assertion that can interfere with hot-restart.

## 0.3.0+2

* Remove categories.

## 0.3.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.3.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.2.5+1

* Bump Android dependencies to latest.

## 0.2.5

* Bump Android and Firebase dependency versions.

## 0.2.4

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.2.3

* Updated Google Play Services dependencies to version 15.0.0.

## 0.2.2

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 0.2.1

* Fix setting project ID on Android.

## 0.2.0

* **Breaking change**. Options API is now async to interoperate with native code that configures Firebase apps.
* Provide a getter for the default app
* Fix setting of GCM sender ID on iOS

## 0.1.2

* Fix projectID on iOS

## 0.1.1

* Fix behavior of constructor for named Firebase apps.

## 0.1.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.0.7

* Fixed Dart 2 type errors.

## 0.0.6

* Enabled use in Swift projects.

## 0.0.5

* Moved to the io.flutter.plugins org.

## 0.0.4

* Fixed warnings from the Dart 2.0 analyzer.
* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

# 0.0.3

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).

## 0.0.2

* Fixes for database URL on Android
* Make GCM sender id optional on Android
* Relax GMS dependency to 11.+

## 0.0.1

* Initial Release
