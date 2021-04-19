## 4.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 4.0.0-1.0.nullsafety.1

 - **REFACTOR**: pubspec & dependency updates (#4932).

## 4.0.0-1.0.nullsafety.0

 - Bump "firebase_core_platform_interface" to `4.0.0-1.0.nullsafety.0`.

## 4.0.0-nullsafety.0

Major bump for the null-safety version to respect the versioning convention.

## 3.0.2-nullsafety.0

 - **REFACTOR**: Migrate to non-nullable types (#4656).

## 3.0.1

 - **DOCS**: installation links updated (#4479).

## 3.0.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: remove all currently deprecated APIs.

## 2.1.0

 - **FEAT**: add FirebaseException.stackTrace support (#4095).
 - **CHORE**: promote to stable version.

## 2.0.0

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
* Added support for `setAutomaticDataCollectionEnabled` & `isAutomaticDataCollectionEnabled` on a `FirebaseApp` instance.
* Added support for `setAutomaticResourceManagementEnabled` on a `FirebaseApp` instance.

## 1.0.5

* Update lower bound of dart dependency to 2.0.0.

## 1.0.4

* Migrate to package:plugin_platform_interface.

## 1.0.3

* Make the pedantic dev_dependency explicit.

## 1.0.2

- Remove the deprecated `author:` field from pubspec.yaml

## 1.0.1

- Switch away from quiver_hashcode.

## 1.0.0

- Initial open-source release.
