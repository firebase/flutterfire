## 0.2.0

* DEPRECATED: `FirebaseApp.configure` method is now deprecated in favor of the `Firebase.initializeApp` method.
* DEPRECATED: `FirebaseApp.allApps` method is now deprecated in favor of the `Firebase.apps` property.
  * Previously, `allApps` was asynchronous where it is now synchronous.
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

## 0.1.2

* Update lower bound of dart dependency to 2.0.0.

## 0.1.1+3

* Make the pedantic dev_dependency explicit.

## 0.1.1+2

* Update setup instructions in the README.

## 0.1.1+1

* Add an android/ folder with no-op implementation to workaround https://github.com/flutter/flutter/issues/46898

## 0.1.1

* Require Flutter SDK 1.12.13+hotfix.4 or greater.
* Fix homepage.

## 0.1.0+3

* Remove the deprecated `author:` field from pubspec.yaml
* Bump the minimum Flutter version to 1.10.0.

## 0.1.0+2

* Add documentation for initializing the default app.

## 0.1.0+1

* Use `package:firebase` for firebase functionality.

## 0.1.0

* Initial open-source release.
