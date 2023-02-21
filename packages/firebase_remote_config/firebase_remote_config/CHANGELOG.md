## 3.0.13

 - Update a dependency to the latest release.

## 3.0.12

 - Update a dependency to the latest release.

## 3.0.11

 - Update a dependency to the latest release.

## 3.0.10

 - **REFACTOR**: upgrade project to remove warnings from Flutter 3.7 ([#10344](https://github.com/firebase/flutterfire/issues/10344)). ([e0087c84](https://github.com/firebase/flutterfire/commit/e0087c845c7526c11a4241a26d39d4673b0ad29d))
 - **FIX**: update exception handling to show actual exception ([#9629](https://github.com/firebase/flutterfire/issues/9629)). ([3bb4d1b1](https://github.com/firebase/flutterfire/commit/3bb4d1b19480afff6f94c27a214925380850304b))

## 3.0.9

 - Update a dependency to the latest release.

## 3.0.8

 - Update a dependency to the latest release.

## 3.0.7

 - Update a dependency to the latest release.

## 3.0.6

 - Update a dependency to the latest release.

## 3.0.5

 - Update a dependency to the latest release.

## 3.0.4

 - Update a dependency to the latest release.

## 3.0.3

 - **REFACTOR**: add `verify` to `QueryPlatform` and change internal `verifyToken` API to `verify` ([#9711](https://github.com/firebase/flutterfire/issues/9711)). ([c99a842f](https://github.com/firebase/flutterfire/commit/c99a842f3e3f5f10246e73f51530cc58c42b49a3))

## 3.0.2

 - Update a dependency to the latest release.

## 3.0.1

 - Update a dependency to the latest release.

## 3.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: Firebase iOS SDK version: `10.0.0` ([#9708](https://github.com/firebase/flutterfire/issues/9708)). ([9627c56a](https://github.com/firebase/flutterfire/commit/9627c56a37d657d0250b6f6b87d0fec1c31d4ba3))

## 2.0.20

 - Update a dependency to the latest release.

## 2.0.19

 - Update a dependency to the latest release.

## 2.0.18

 - Update a dependency to the latest release.

## 2.0.17

 - Update a dependency to the latest release.

## 2.0.16

 - **REFACTOR**: update deprecated `Tasks.call()` to `TaskCompletionSource` API ([#9405](https://github.com/firebase/flutterfire/issues/9405)). ([837d68ea](https://github.com/firebase/flutterfire/commit/837d68ea60649fa1fb1c7f8254e4ae67874e9bf2))

## 2.0.15

 - Update a dependency to the latest release.

## 2.0.14

 - Update a dependency to the latest release.

## 2.0.13

 - Update a dependency to the latest release.

## 2.0.12

 - Update a dependency to the latest release.

## 2.0.11

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

## 2.0.10

 - Update a dependency to the latest release.

## 2.0.9

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **FIX**: Provide firebase_remote_config as error code for android (#8717). ([2854cbcb](https://github.com/firebase/flutterfire/commit/2854cbcb5a2e604ace8dc55993893e5ffdbff5a8))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

## 2.0.8

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8738). ([f5ca08b2](https://github.com/firebase/flutterfire/commit/f5ca08b2ca68e674f6c59c458ec26126c9e1b002))

## 2.0.7

 - Update a dependency to the latest release.

## 2.0.6

 - Update a dependency to the latest release.

## 2.0.5

 - Update a dependency to the latest release.

## 2.0.4

 - Update a dependency to the latest release.

## 2.0.3

 - Update a dependency to the latest release.

## 2.0.2

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

## 2.0.1

 - **FIX**: add missing `default_package` entry for web in `pubspec.yaml` (#8139). ([5e6b570f](https://github.com/firebase/flutterfire/commit/5e6b570f8445b0bd2eac8b112a2a6b35ff69b7b6))

## 2.0.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: deprecated `RemoteConfig` in favour of `FirebaseRemoteConfig` to align Firebase services naming with other plugins. ([99b932be](https://github.com/firebase/flutterfire/commit/99b932bea6d604d500bb29841ad59177165dee60))

## 1.0.4

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726). ([a9562bac](https://github.com/firebase/flutterfire/commit/a9562bac60ba927fb3664a47a7f7eaceb277dca6))

## 1.0.3

 - Update a dependency to the latest release.

## 1.0.2

 - Update a dependency to the latest release.

## 1.0.1

 - **DOCS**: Fix typos and remove unused imports (#7504).

## 1.0.0

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).
 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).
 - **FEAT**: Add initial platform support for Web.
 - Bump "firebase_remote_config" to stable versioning `0.x.x` -> `x.x.x`.

## 0.11.0+2

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).
 - **STYLE**: macOS & iOS; explicitly include header that defines `TARGET_OS_OSX` (#7116).

## 0.11.0+1

 - Update a dependency to the latest release.

## 0.11.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: check value types before passing them to native (#6817).

## 0.10.0+5

 - Update a dependency to the latest release.

## 0.10.0+4

 - **STYLE**: enable additional lint rules (#6832).
 - **FIX**: propagate error message (#6834).

## 0.10.0+3

 - Update a dependency to the latest release.

## 0.10.0+2

 - Update a dependency to the latest release.

## 0.10.0+1

 - Update a dependency to the latest release.

## 0.10.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 0.10.0-dev.4

 - **FIX**: podspec osx version checking script should use a version range instead of a single fixed version.

## 0.10.0-dev.3

 - Update a dependency to the latest release.

## 0.10.0-dev.2

 - **REFACTOR**: upgrade example to v2 Android embedding.
 - **REFACTOR**: switch e2e tests to use `drive` package + fix analyzer issues.
 - **REFACTOR**: fix analyzer config and issues.

## 0.10.0-dev.1

 - Update a dependency to the latest release.

## 0.10.0-dev.0

 - Migrate to null safety.

## 0.9.0-dev.2

 - Update a dependency to the latest release.

## 0.9.0-dev.1

 - **FIX**: ensureInitialized() task should ignore return value (fixes #5222) (#5467).
 - **DOCS**: remove incorrect ARCHS in ios examples (#5450).
 - **CHORE**: bump min Dart SDK constraint to 2.12.0 (#5430).
 - **CHORE**: publish packages (#5429).
 - **CHORE**: publish packages.
 - **CHORE**: enable lints for firebase_remote_config (#5232).
 - **CHORE**: rm dev dependencies breaking CI (#5221).

## 0.9.0-dev.0

 - This version is not null-safe but has been created to allow compatibility with other null-safe FlutterFire packages such as `firebase_core`.

## 0.8.0-dev.1

 - Update a dependency to the latest release.

## 0.8.0-dev.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: rework remote config plugin (#4186).

## 0.7.0

The plugin has been updated and reworked to better mirror the features
currently offered by the native (iOS and Android) clients.

`RemoteConfig`:
- **CHORE**: migrate to platform interface.
- **FEAT**: support multiple firebase apps. `RemoteConfig.instanceFor()` can
  be used to retrieve an instance of RemoteConfig for a particular
  Firebase App.
- **BREAKING**: `fetch()` now takes no arguments. `RemoteConfigSettings` should
  be used to specify the freshness of the cached config via the `minimumFetchInterval`
  property.
- **BREAKING**: `activateFetched()` is now `activate()`.
- **FEAT**: Added `fetchAndActivate()` support.
- **FEAT**: Added `ensureInitialized()` support.

`RemoteConfigSettings`
- **BREAKING**: `fetchTimeoutMillis` is now `fetchTimeout`.
- **BREAKING**: `minimumFetchIntervalMillis` is now `minimumFetchInterval`
- **BREAKING**: `fetchTimeout` and `minimumFetchInterval` are refactored
  from `int` to `Duration`.

`FetchThrottledException`
- **BREAKING**: removed `FetchThrottledException`. The general
  FirebaseException is used to handle all RemoteConfig specific exceptions.

## 0.6.0

> Note: This release has breaking changes.

 - **FEAT**: add check on podspec to assist upgrading users deployment target.
 - **BUILD**: commit Podfiles with 10.12 deployment target.
 - **BUILD**: remove default sdk version, version should always come from firebase_core, or be user defined.
 - **BUILD**: set macOS deployment target to 10.12 (from 10.11).
 - **BREAKING** **BUILD**: set osx min supported platform version to 10.12.

## 0.5.0

> Note: This release has breaking changes.

 - **FEAT**: bump firebase-android-sdk to v26.2.0.
 - **CHORE**: harmonize dependencies and version handling.
 - **BREAKING** **FEAT**: forward port to firebase-ios-sdk v7.3.0.
   - Due to this SDK upgrade, iOS 10 is now the minimum supported version by FlutterFire. Please update your build target version.

## 0.4.3

 - **FEAT**: bump android `com.android.tools.build` & `'com.google.gms:google-services` versions (#4269).
 - **CHORE**: publish packages.
 - **CHORE**: bump gradle wrapper to 5.6.4 (#4158).

## 0.4.2

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: bump `compileSdkVersion` to 29 in preparation for upcoming Play Store requirement.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 0.4.1

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: update Firebase iOS SDK version to 6.33.0 (from 6.26.0).

## 0.4.0+2

 - Update a dependency to the latest release.

## 0.4.0+1

 - **FIX**: local dependencies in example apps (#3319).
 - **CHORE**: intellij cleanup (#3326).

## 0.4.0

* Depend on new `firebase_core`.
* Firebase iOS SDK versions are now locked to use the same version defined in
  `firebase_core`.
* Firebase Android SDK versions are now using the Firebase Bill of Materials (BoM)
  to specify individual SDK versions. BoM version is also sourced from
  `firebase_core`.
* Added support for MacOS.
* Allow iOS & MacOS plugins to be imported as modules.


## 0.3.1+1

* Propagate native error message on fetch method.

## 0.3.1

* Update lower bound of dart dependency to 2.0.0.

## 0.3.0+4

* Fix for missing UserAgent.h compilation failures.

## 0.3.0+3

* Replace deprecated `getFlutterEngine` call on Android.

## 0.3.0+2

* Make the pedantic dev_dependency explicit.

## 0.3.0+1

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 0.3.0

* Update Android Firebase Remote Config dependency to 19.0.3.
* Resolve an Android compiler warning due to deprecated API usage.
* Bump Gradle, AGP & Google Services plugin versions.

## 0.2.1

* Support Android V2 embedding.
* Migrate to using the new e2e test binding.

## 0.2.0+9

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 0.2.0+8

* Remove AndroidX warning.

## 0.2.0+7

* Fix `Bad state: Future already completed` error when initially
  calling `RemoteConfig.instance` multiple times in parallel.

## 0.2.0+6

* Update documentation to reflect new repository location.
* Update unit tests to call `TestWidgetsFlutterBinding.ensureInitialized`.

## 0.2.0+5

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 0.2.0+4

* Fixed a bug where `RemoteConfigValue` could incorrectly report a remote `source` for default values.
* Added an integration test for the fixed behavior of `source`.
* Removed a test that made integration test flaky.

## 0.2.0+3

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 0.2.0+2

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.2.0+1

* Minor internal code cleanup in Java implementation.

## 0.2.0

* Update Android dependencies to latest.

## 0.1.0+3

* Initial integration tests.

## 0.1.0+2

* Log messages about automatic configuration of the default app are now less confusing.

## 0.1.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.1.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.0.6+1

* Bump Android dependencies to latest.

## 0.0.6

* Allowed extending the RemoteConfig class.

## 0.0.5

* Bump Android and Firebase dependency versions.

## 0.0.4

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.0.3

* Added missing await in setDefaults.
* Fixed example code in README.

## 0.0.2

* Update iOS plugin so that it returns fetch status
  as a String instead of an int.
* Bump Android library version to 15.+. The Android plugins for
  FlutterFire need to all be on the same version. Updating
  Remote Config to match other FlutterFire plugins.

## 0.0.1

* Implement Firebase Remote Config.
