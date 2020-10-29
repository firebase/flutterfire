## 0.7.0-dev.3

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: update Firebase iOS SDK version to 6.33.0 (from 6.26.0).

## 0.7.0-dev.2

 - **DOCS**: update package readme.
 - **DOCS**: update pubspec description to meet minumum length requirement.

## 0.7.0-dev.1

Along with the below changes, the plugin has been reworked to bring it inline with the federated plugin setup along with documentation and additional unit and end-to-end tests. The API has mainly been kept the same, however there are some breaking changes.

 - **`FirebaseFunctions`**:
   - **DEPRECATED**: Class `CloudFunctions` is now deprecated. Use `FirebaseFunctions` instead.
   - **DEPRECATED**: Calling `CloudFunctions.instance` or `CloudFunctions(app: app, region: region)` is now deprecated. Use `FirebaseFunctions.instance` or `FirebaseFunctions.instanceFor(app: app, region: region)` instead.
   - **DEPRECATED**: Calling `getHttpsCallable(functionName: functionName)` is deprecated in favor of `httpsCallable(functionName)`
   - **DEPRECATED**: `CloudFunctionsException` is deprecated in favor of `FirebaseFunctionsException`.
   - **NEW**: `FirebaseFunctionsException` now exposes a `details` property to retrieve any additional data provided with the exception returned by a HTTPS callable function.
   - **NEW**: Internally, instances of `FirebaseFunctions` are now cached and lazily loaded.
   - **NEW**: `httpsCallable` accepts an instance of `HttpsCallableOptions` (see below).


 - **`HttpsCallable`**:
   - **DEPRECATED**: Setting `timeout` is deprecated in favor of using `HttpsCallableOptions` (see below).


 - **`HttpsCallableResult`**:
   - **BREAKING**: `data` is now read-only, only its getter is exposed.
   - **FIX**: `HttpsCallableResult`'s `data` property can now return a Map, List or a primitive value. Previously the Web implementation incorrectly assumed that a Map was always returned by the HTTPS callable function.


 - **`HttpsCallableOptions`**: 
   - **NEW**: This new class has been created to support setting options for `httpsCallable` instances.

## 0.6.0+1

 - **FIX**: local dependencies in example apps (#3319).

## 0.6.0

* Fix HttpsCallable#call not working with parameters of non-Map type.
* Firebase iOS SDK versions are now locked to use the same version defined in
  `firebase_core`.
* Firebase Android SDK versions are now using the Firebase Bill of Materials (BoM)
  to specify individual SDK versions. BoM version is also sourced from
  `firebase_core`.
* Allow iOS & MacOS plugins to be imported as modules.
* Update to depend on `firebase_core` plugin.

## 0.5.0

* Fix example app build failure on CI (missing AndroidX Gradle properties).
* Change environment SDK requirement from `>=2.0.0-dev.28.0` to `>=2.0.0` to fix 'publishable' CI stage.

## 0.4.2+3

* Fix for missing UserAgent.h compilation failures.

## 0.4.2+2

* Fix method channel on darwin

## 0.4.2+1

* Make the pedantic dev_dependency explicit.

## 0.4.2

* Add macOS support

## 0.4.1+9

* Depends on `cloud_functions_web` so that projects importing this plugin will get web support.
* Added web implementation to the example application.

## 0.4.1+8

* Fixes the `No implementation found for method CloudFunctions#call`

## 0.4.1+7

* Update to use the platform interface to execute calls.
* Fix timeout for Android (which had been ignoring explicit timeouts due to unit mismatch).
* Update repository location based on platform interface refactoring.

## 0.4.1+6

* Fix analysis failures

## 0.4.1+5

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 0.4.1+4

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 0.4.1+3

* Remove AndroidX warning.

## 0.4.1+2

* Update Android package name.

## 0.4.1+1

* Update documentation to reflect new repository location.
* Update unit tests to call `TestWidgetsFlutterBinding.ensureInitialized`.

## 0.4.1

* Support for cloud functions emulators.

## 0.4.0+3

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 0.4.0+2

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 0.4.0+1

* Remove reference to unused header file.

## 0.4.0

* Removed unused `parameters` param from `getHttpsCallable`.

## 0.3.0+1

* Update iOS dependencies to latest.

## 0.3.0

* Update Android dependencies to latest.

## 0.2.0+1

* Removed flaky timeout test.

## 0.2.0

* **Breaking change**. Updated Dart API to replace `call` with `getHttpsCallable`.
* Added support for timeouts.
* Additional integration testing.

## 0.1.2+1

* Added a driver test.

## 0.1.2

* Specifying a version for Cloud Functions CocoaPod dependency to prevent build errors on iOS.
* Fix on iOS when using a null region.
* Upgrade the firebase_core dependency of the example app.

## 0.1.1+1

* Log messages about automatic configuration of the default app are now less confusing.

## 0.1.1

* Support for regions and multiple apps

## 0.1.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.1.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.0.5

* Set iOS deployment target to 8.0 (minimum supported by both Firebase SDKs and Flutter), fixes compilation errors.
* Fixes null pointer error when callable function fails with exception (iOS).

## 0.0.4+1

* Bump Android dependencies to latest.

## 0.0.4

* Fixed podspec to use static_framework

## 0.0.3

* Added missing dependency on meta package.

## 0.0.2

* Bump Android and Firebase dependency versions.

## 0.0.1

* The Cloud Functions for Firebase client SDKs let you call functions
  directly from a Firebase app. This plugin exposes this ability to
  Flutter apps.

  [Callable functions](https://firebase.google.com/docs/functions/callable)
  are similar to other HTTP functions, with these additional features:

  - With callables, Firebase Authentication and FCM tokens are
    automatically included in requests.
  - The functions.https.onCall trigger automatically deserializes
    the request body and validates auth tokens.
