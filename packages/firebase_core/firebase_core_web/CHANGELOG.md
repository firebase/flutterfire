## 1.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.0.0-1.0.nullsafety.0

 - Bump "firebase_core_web" to `1.0.0-1.0.nullsafety.0`.

## 0.3.0-1.0.nullsafety.1

 - **REFACTOR**: pubspec & dependency updates (#4932).
 - **FIX**: Analysis error with firebase_core/web (#4836).
 - **CHORE**: update PromiseJsImpl resolve/reject to match expected types.

## 0.3.0-1.0.nullsafety.0

 - Bump "firebase_core_web" to `0.3.0-1.0.nullsafety.0`.

## 0.3.0-nullsafety.0

Major bump for the null-safety version to respect the versioning convention.

## 0.2.2-nullsafety.1

 - Bump `firebase_core` dependency version.

## 0.2.2-nullsafety.0

 - **REFACTOR**: Migrate to non-nullable types (#4656).

## 0.2.1+3

 - Update a dependency to the latest release.

## 0.2.1+2

 - Update a dependency to the latest release.

## 0.2.1+1

 - **REFACTOR**: ignore typedefs.
 - **FIX**: ensure list items are converted (#4076).

## 0.2.1

 - **FEAT**: migrate firebase interop files to local repository (#3973).
 - **CHORE**: promote to stable version.
 - **CHORE**: remove android directory from web plugins (#3199).

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
