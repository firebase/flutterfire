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
