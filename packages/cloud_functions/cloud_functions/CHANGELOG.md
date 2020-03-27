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
