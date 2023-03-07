## 3.0.15

 - Update a dependency to the latest release.

## 3.0.14

 - Update a dependency to the latest release.

## 3.0.13

 - Update a dependency to the latest release.

## 3.0.12

 - **REFACTOR**: upgrade project to remove warnings from Flutter 3.7 ([#10344](https://github.com/firebase/flutterfire/issues/10344)). ([e0087c84](https://github.com/firebase/flutterfire/commit/e0087c845c7526c11a4241a26d39d4673b0ad29d))

## 3.0.11

 - **FIX**: improve reason field handling in recordError ([#10264](https://github.com/firebase/flutterfire/issues/10264)). ([8f670e4f](https://github.com/firebase/flutterfire/commit/8f670e4fe67869aaff83362a7df1afdf9bb41315))

## 3.0.10

 - **FIX**: improve reason field handling in recordError ([#10256](https://github.com/firebase/flutterfire/issues/10256)). ([48af8110](https://github.com/firebase/flutterfire/commit/48af8110b34d6c2e635ef5d1023086ab5eadcbf4))

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
 - **DOCS**: Use `PlatformDispatcher.instance.onError` for async errors. Update Crashlytics example app to use "flutterfire-e2e-tests" project. ([#9669](https://github.com/firebase/flutterfire/issues/9669)). ([8a0caa05](https://github.com/firebase/flutterfire/commit/8a0caa05d5abf6fef5bf0e654654dcd0b6ec874a))

## 3.0.2

 - Update a dependency to the latest release.

## 3.0.1

 - Update a dependency to the latest release.

## 3.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: Firebase iOS SDK version: `10.0.0` ([#9708](https://github.com/firebase/flutterfire/issues/9708)). ([9627c56a](https://github.com/firebase/flutterfire/commit/9627c56a37d657d0250b6f6b87d0fec1c31d4ba3))

## 2.9.0

 - **FEAT**: Send Flutter Build Id to Crashlytics to get --split-debug-info working ([#9409](https://github.com/firebase/flutterfire/issues/9409)). ([17931f30](https://github.com/firebase/flutterfire/commit/17931f307434c88e87318c97e2d81c7eb3219ed9))

## 2.8.13

 - **FIX**: parameter `information` accepts `Iterable<Object>` for further diagnostic logging information ([#9678](https://github.com/firebase/flutterfire/issues/9678)). ([2d2b5b03](https://github.com/firebase/flutterfire/commit/2d2b5b03901b68976047e5f2888beb0296f4af45))
 - **DOCS**: add note for `crash()` that the app needs to be restarted to send a crash report ([#9586](https://github.com/firebase/flutterfire/issues/9586)). ([3a3e5212](https://github.com/firebase/flutterfire/commit/3a3e52123f04eac6d73c21474155e6e67cb357c1))

## 2.8.12

 - Update a dependency to the latest release.

## 2.8.11

 - Update a dependency to the latest release.

## 2.8.10

 - **FIX**: Replace null or empty stack traces with the current stack trace ([#9490](https://github.com/firebase/flutterfire/issues/9490)). ([c54a95f3](https://github.com/firebase/flutterfire/commit/c54a95f365c5a61d2df52fb89467ab6103aa0146))

## 2.8.9

 - Update a dependency to the latest release.

## 2.8.8

 - Update a dependency to the latest release.

## 2.8.7

 - Update a dependency to the latest release.

## 2.8.6

 - Update a dependency to the latest release.

## 2.8.5

 - **FIX**: `[core/duplicate-app]` exception when running the example ([#8991](https://github.com/firebase/flutterfire/issues/8991)). ([c70e66a5](https://github.com/firebase/flutterfire/commit/c70e66a546cf9236e728796c5b59a3d4e39caeb2))

## 2.8.4

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

## 2.8.3

 - Update a dependency to the latest release.

## 2.8.2

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8731). ([c534eb04](https://github.com/firebase/flutterfire/commit/c534eb045a2ced454fdc803d438c3cd0f0b8097a))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **FIX**: fix deprecation warning in Android (#8903). ([f2e03484](https://github.com/firebase/flutterfire/commit/f2e03484f99bd2efcb065d31721b9a2b6e801bf5))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

## 2.8.1

 - **DOCS**: use camel case style for "FlutterFire" in `README.md` (#8750). ([e9e1c1bf](https://github.com/firebase/flutterfire/commit/e9e1c1bf19d32e5b8967da162b03d0254843a836))

## 2.8.0

 - **REFACTOR**: remove deprecated `Tasks.call` for android and replace with `TaskCompletionSource`. ([#8582](https://github.com/firebase/flutterfire/issues/8582)). ([9539c92a](https://github.com/firebase/flutterfire/commit/9539c92a53f73bf57b9c61ae9e0ce5042b4b8ca4))
 - **FIX**: symlink `ExceptionModel_Platform.h` to macOS. ([#8570](https://github.com/firebase/flutterfire/issues/8570)). ([9991b7a5](https://github.com/firebase/flutterfire/commit/9991b7a5389738a7bbba8f2210f8379b887d90e7))
 - **FEAT**: bump Firebase Android SDK to 30.0.0 ([#8617](https://github.com/firebase/flutterfire/issues/8617)). ([72158aaf](https://github.com/firebase/flutterfire/commit/72158aaf9721dbf5f20c362f0c99853273507538))

## 2.7.2

 - Update a dependency to the latest release.

## 2.7.1

 - **FIX**: re-add support for `recordFlutterFatalError` method from previous EAP API (#8550). ([8ef8b55c](https://github.com/firebase/flutterfire/commit/8ef8b55c113f24abac783170723c7f784f5d1fe5))

## 2.7.0

 - **FEAT**: add support for on-demand exception reporting (#8540). ([dfec7d60](https://github.com/firebase/flutterfire/commit/dfec7d60592abe0a5c6523e13feabffb8b03020b))

## 2.6.3

 - Update a dependency to the latest release.

## 2.6.2

 - Update a dependency to the latest release.

## 2.6.1

 - **FIX**: Exit the add crashlytics upload-symbols script if the required json isn't present. ([94077929](https://github.com/firebase/flutterfire/commit/940779290a3039181a92567fe8492a720af899e1))

## 2.6.0

 - **FEAT**: add automatic Crashlytics symbol uploads for iOS & macOS apps (#8157). ([c4a3eaa7](https://github.com/firebase/flutterfire/commit/c4a3eaa7200d924f9ec71370dd3c875813804935))

## 2.5.3

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

## 2.5.2

 - Update a dependency to the latest release.

## 2.5.1

 - Fixed macOS project not compiling by symlinking missing header file: `Crashlytics_Platform.h`

## 2.5.0

 - **FEAT**: Set the dSYM file format through the Crashlytic's podspec to allow symbolicating crash reports. (#7872). ([d5d7e26a](https://github.com/firebase/flutterfire/commit/d5d7e26a4828963f375b656c6e1a397d26aac980))

## 2.4.5

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726). ([a9562bac](https://github.com/firebase/flutterfire/commit/a9562bac60ba927fb3664a47a7f7eaceb277dca6))

## 2.4.4

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8. ([7f0e82c9](https://github.com/firebase/flutterfire/commit/7f0e82c978a3f5a707dd95c7e9136a3e106ff75e))
 - **FIX**: set build id as not required, to allow Dart default app initialization (#7594). ([c15fdda3](https://github.com/firebase/flutterfire/commit/c15fdda33b447ddd0c8e066e9c9ec7cabf9cd6fd))
 - **FIX**: Return app constants for default app only on `Android`. (#7592). ([b803c425](https://github.com/firebase/flutterfire/commit/b803c425b420acae155fea93a62ab9b3de4556a5))

## 2.4.3

 - Update a dependency to the latest release.

## 2.4.2

 - Update a dependency to the latest release.

## 2.4.1

 - Update a dependency to the latest release.

## 2.4.0

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FEAT**: log development platform to Crashlytics in Crashlytics iOS plugin (#7322).

## 2.3.0

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

## 2.2.5

 - Update a dependency to the latest release.

## 2.2.4

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).

## 2.2.3

 - **FIX**: switch usage of `dumpErrorToConsole` to `presentError` to remove duplicate logging (#7046).
 - **CHORE**: remove unused deprecated V1 embedding for android (#7127).

## 2.2.2

 - Update a dependency to the latest release.

## 2.2.1

 - Update a dependency to the latest release.

## 2.2.0

 - **STYLE**: enable additional lint rules (#6832).
 - **FEAT**: lower iOS & macOS deployment targets for relevant plugins (#6757).

## 2.1.1

 - **FIX**: issue where build would fail with missing header (#6628).

## 2.1.0

 - **FIX**: improve stack trace symbol. "class.method" signature. (#6442).
 - **FEAT**: submit analytics crash event on fatal - enables support for crash free users reporting (#5900).
 - **CHORE**: rm deprecated jcenter repository (#6431).

## 2.0.7

 - **FIX**: improve stack trace symbol. "class.method" signature. (#6442).
 - **CHORE**: rm deprecated jcenter repository (#6431).

## 2.0.6

 - Update a dependency to the latest release.

## 2.0.5

 - **DOCS**: Add Flutter Favorite badge (#6190).

## 2.0.4

 - **FIX**: podspec osx version checking script should use a version range instead of a single fixed version.

## 2.0.3

 - Update a dependency to the latest release.

## 2.0.2

 - Update a dependency to the latest release.

## 2.0.1

 - **FIX**: Avoid duplicate prints (#5718).
 - **FIX**: Include obfuscated stack traces (#4407).
 - **CHORE**: update drive dependency (#5740).

## 2.0.0

> Note: This release has breaking changes.

 - **FIX**: Add Flutter dependency to podspec (#5455).
 - **FEAT**: fatal error crash report (#5427).
 - **CHORE**: add repository urls to pubspecs (#5542).
 - **CHORE**: bump min Dart SDK constraint to 2.12.0 (#5430).
 - **CHORE**: merge all analysis_options.yaml into one (#5329).
 - **CHORE**: publish packages.
 - **BREAKING** **FIX**: `checkForUnsentReports` should error if `isCrashlyticsCollectionEnabled` is false (#5187).

## 1.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.0.0-1.0.nullsafety.0

 - Bump "firebase_crashlytics" to `1.0.0-1.0.nullsafety.0`.

## 0.5.0-1.0.nullsafety.3

 - Update a dependency to the latest release.

## 0.5.0-1.0.nullsafety.2

 - **REFACTOR**: pubspec & dependency updates (#4932).
 - **REFACTOR**: replace deprecated `RaisedButton` widget with `ElevatedButton`.

## 0.5.0-1.0.nullsafety.1

 - **FIX**: bump firebase_core_* package versions to updated NNBD versioning format (#4832).

## 0.5.0-1.0.nullsafety.0

- **REFACTOR**: migrate to NNBD.

## 0.4.0+1

 - **REFACTOR**: updated crashlytics e2e test library.
 - **FIX**: updated didCrashOnPreviousExecution call.

## 0.4.0

> Note: This release has breaking changes.

 - **FEAT**: add check on podspec to assist upgrading users deployment target.
 - **BUILD**: commit Podfiles with 10.12 deployment target.
 - **BUILD**: remove default sdk version, version should always come from firebase_core, or be user defined.
 - **BUILD**: set macOS deployment target to 10.12 (from 10.11).
 - **BREAKING** **BUILD**: set osx min supported platform version to 10.12.

## 0.3.0

> Note: This release has breaking changes.

 - **FIX**: bubble exceptions (#4419).
 - **BREAKING** **REFACTOR**: remove all currently deprecated APIs.
 - **BREAKING** **FEAT**: forward port to firebase-ios-sdk v7.3.0.
   - Due to this SDK upgrade, iOS 10 is now the minimum supported version by FlutterFire. Please update your build target version.
 - **CHORE**: harmonize dependencies and version handling.

## 0.2.4

 - **FEAT**: bump android `com.android.tools.build` & `'com.google.gms:google-services` versions (#4269).

## 0.2.3+1

 - Update a dependency to the latest release.

## 0.2.3

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: bump `compileSdkVersion` to 29 in preparation for upcoming Play Store requirement.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 0.2.2

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: update Firebase iOS SDK version to 6.33.0 (from 6.26.0).

## 0.2.1+1

 - **FIX**: Change minimum version of stack_trace package (#3639).
 - **DOCS**: README updates (#3768).

## 0.2.1

 - **REFACTOR**: changes context to reason (#1542) (#3334).
 - **FEAT**: rework (#3420).
 - **CHORE**: firebase_crashlytics v0.2.0 release.

## 0.2.0

For help migrating to this release please see the [migration guide](https://firebase.flutter.dev/docs/migration).

* **BREAKING**: Removal of Fabric SDKs and migration to the new Firebase Crashlytics SDK.
* **BREAKING**: The following methods have been removed as they are no longer available on the Firebase Crashlytics SDK:
  * `setUserEmail`
  * `setUserName`
  * `getVersion`
  * `isDebuggable`
* **BREAKING**: `log` now returns a Future. Calling `log` now sends logs immediately to the underlying Crashlytics SDK instead of pooling them in Dart.
* **BREAKING**: the methods `setInt`, `setDouble`, `setString` and `setBool` have been replaced by `setCustomKey`.
  * `setCustomKey` returns a Future. Calling `setCustomKey` now sends custom keys immediately to the underlying Crashlytics SDK instead of pooling them in Dart.
* **DEPRECATED**: `enableInDevMode` has been deprecated, use `isCrashlyticsCollectionEnabled` and `setCrashlyticsCollectionEnabled` instead.
* **DEPRECATED**: `Crashlytics` has been deprecated, use `FirebaseCrashlytics` instead.
* **NEW**: Custom keys that are automatically added by FlutterFire when calling `reportError` are now prefixed with `flutter_error_`.
* **NEW**: Calling `.crash()` on Android  & iOS/macOS now reports a custom named exception to the Firebase Console. This allows you to easily locate test crashes.
  * Name: `FirebaseCrashlyticsTestCrash`.
  * Message: `This is a test crash caused by calling .crash() in Dart.`.
* **NEW**: `recordError` now uses a named native exception when reporting to the Firebase Console. This allows you to easily locate errors originating from Flutter.
  * Name: `FlutterError`.
* **NEW**: Added support for `checkForUnsentReports`.
  * Checks a device for any fatal or non-fatal crash reports that haven't yet been sent to Crashlytics.
  * See reference API docs for more information.
* **NEW**: Added support for `deleteUnsentReports`.
  * If automatic data collection is disabled, this method queues up all the reports on a device for deletion.
  * See reference API docs for more information.
* **NEW**: Added support for `didCrashOnPreviousExecution`.
  * Checks whether the app crashed on its previous run.
  * See reference API docs for more information.
* **NEW**: Added support for `sendUnsentReports`.
  * If automatic data collection is disabled, this method queues up all the reports on a device to send to Crashlytics.
  * See reference API docs for more information.
* **NEW**: Added support for `setCrashlyticsCollectionEnabled`.
  * Enables/disables automatic data collection by Crashlytics.
  * See reference API docs for more information.
* **NEW**: Added support for `isCrashlyticsCollectionEnabled`.
  * Whether the current Crashlytics instance is collecting reports. If false, then no crash reporting data is sent to Firebase.
  * See reference API docs for more information.
* **FIX**: Fixed a bug that prevented keys from being set on iOS devices.

## 0.1.4+1

* Put current stack trace into report if no other stack trace is supplied.

## 0.1.4

* Update lower bound of dart dependency to 2.0.0.

## 0.1.3+3

* Fix for missing UserAgent.h compilation failures.

## 0.1.3+2

* Fix Cirrus build by removing WorkspaceSettings.xcsettings file in the iOS example app.

## 0.1.3+1

* Make the pedantic dev_dependency explicit.

## 0.1.3

* Add macOS support

## 0.1.2+5

* Fix overrides a deprecated API.
* Raise minimum required Flutter SDK version to 1.12.13+hotfix.4

## 0.1.2+4

* Updated the example with the missing `recordError()` method.
* Added a `recordError()` integration test.

## 0.1.2+3

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 0.1.2+2

* Removed the `async` from the `runZoned()` in the example, as there's no `await` to be executed.

## 0.1.2+1

* Updated a confusing comment.

## 0.1.2

* Updated to use the v2 plugin API.

## 0.1.1+2

* When reporting to Crashlytics on iOS, and printing supplied logs, do not
  prepend each line with "FirebaseCrashlyticsPlugin.m line 44".
* Prepend `firebase_crashlytics: ` to the final answer from Crashlytics
  plugin in the log to realize where it's coming from.

## 0.1.1+1

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 0.1.1

* Log FlutterErrorDetails using Flutter's standard `FlutterError.dumpErrorToConsole`.
* In debug mode, always log errors.

## 0.1.0+5

* Fix example app `support-compat` crash by setting `compileSdkVersion` to 28.

## 0.1.0+4

* Fix linter finding in examples.

## 0.1.0+3

* Update documentation to reflect new repository location.
* Update unit tests to call `TestWidgetsFlutterBinding.ensureInitialized`.

## 0.1.0+2

* [iOS] Fixes crash when trying to report a crash without any context

## 0.1.0+1

* Added additional exception information from the Flutter framework to the reports.
* Refactored debug printing of exceptions to be human-readable.
* Passing `null` stack traces is now supported.
* Added the "Error reported to Crashlytics." print statement that was previously missing.
* Updated `README.md` to include both the breaking change from `0.1.0` and the newly added
  `recordError` function in the setup section.
* Adjusted `README.md` formatting.
* Fixed `recordFlutterError` method name in the `0.1.0` changelog entry.

## 0.1.0

* **Breaking Change** Renamed `onError` to `recordFlutterError`.
* Added `recordError` method for errors caught using `runZoned`'s `onError`.

## 0.0.4+12

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 0.0.4+11

* Fixed an issue where `Crashlytics#getStackTraceElements` didn't handle functions without classes.

## 0.0.4+10

* Update README.

## 0.0.4+9

* Fixed custom keys implementation.
* Added tests for custom keys implementation.
* Removed a print statement.

## 0.0.4+8

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 0.0.4+7

* Fixed an issue where `Crashlytics#setUserIdentifier` incorrectly called `setUserEmail` on iOS.

## 0.0.4+6

* On Android, use actual the Dart exception name instead of "Dart error."

## 0.0.4+5

* Fix parsing stacktrace.

## 0.0.4+4

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.

## 0.0.4+3

* Migrate our handling of `FlutterErrorDetails` to work on both Flutter stable
  and master.

## 0.0.4+2

* Keep debug log formatting.

## 0.0.4+1

* Added an integration test.

## 0.0.4

* Initialize Fabric automatically, preventing crashes that could occur when setting user data.

## 0.0.3

* Rely on firebase_core to add the Android dependency on Firebase instead of hardcoding the version ourselves.

## 0.0.2+1

* Update variable name `enableInDevMode` in README.

## 0.0.2

* Updated the iOS podspec to a static framework to support compatibility with Swift plugins.
* Updated the Android gradle dependencies to prevent build errors.

## 0.0.1

* Initial release of Firebase Crashlytics plugin.
This version reports uncaught errors as non-fatal exceptions in the
Firebase console.
