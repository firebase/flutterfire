## 0.4.1

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: update Firebase iOS SDK version to 6.33.0 (from 6.26.0).
 - **CHORE**: bump perf example min android sdk for multidex purposes.

## 0.4.0+2

 - Update a dependency to the latest release.

## 0.4.0+1

 - **FIX**: local dependencies in example apps (#3319).
 - **CHORE**: intellij cleanup (#3326).

## 0.4.0

* Depend on `firebase_core`.
* Firebase iOS SDK versions are now locked to use the same version defined in
  `firebase_core`.
* Firebase Android SDK versions are now using the Firebase Bill of Materials (BoM)
  to specify individual SDK versions. BoM version is also sourced from
  `firebase_core`.
* Allow iOS to be imported as a module.

## 0.3.2

* Update lower bound of dart dependency to 2.0.0.

## 0.3.1+8

* Fix for missing UserAgent.h compilation failures.

## 0.3.1+7

* Replace deprecated `getFlutterEngine` call on Android.

## 0.3.1+6

* Make the pedantic dev_dependency explicit.

## 0.3.1+5

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 0.3.1+4

* Skip flaky driver tests.

## 0.3.1+3

* Fixed analyzer warnings about unused fields.

## 0.3.1+2

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 0.3.1+1

* Remove AndroidX warning.

## 0.3.1

* Support v2 embedding. This will remain compatible with the original embedding and won't require
app migration.

## 0.3.0+5

* Update documentation to reflect new repository location.
* Update unit tests to call `TestWidgetsFlutterBinding.ensureInitialized`.

## 0.3.0+4

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 0.3.0+3

* Fix bug that caused `invokeMethod` to fail with Dart code obfuscation

## 0.3.0+2

* Fix bug preventing this plugin from working with hot restart.

## 0.3.0+1

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 0.3.0

* **Breaking Change** Removed `Trace.incrementCounter`. Please use `Trace.incrementMetric`.
* Assertion errors are no longer thrown for incorrect input for `Trace`s and `HttpMetric`s.
* You can now get entire list of attributes from `Trace` and `HttpMetric` with `getAttributes()`.
* Added access to `Trace` value `name`.
* Added access to `HttpMetric` values `url` and `HttpMethod`.

## 0.2.0

* Update Android dependencies to latest.

## 0.1.1

* Deprecate `Trace.incrementCounter` and add `Trace.incrementMetric`.
* Additional integration testing.

## 0.1.0+4

* Remove deprecated methods for iOS.
* Fix bug where `Trace` attributes were not set correctly.

## 0.1.0+3

* Log messages about automatic configuration of the default app are now less confusing.

## 0.1.0+2

* Fixed bug where `Traces` and `HttpMetrics` weren't being passed to Firebase on iOS.

## 0.1.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.1.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.0.8+1

* Bump Android dependencies to latest.

## 0.0.8

* Set http version to be compatible with flutter_test.

## 0.0.7

* Added missing http package dependency.

## 0.0.6

* Bump Android and Firebase dependency versions.

## 0.0.5

Added comments explaining the time it takes to see performance results.

## 0.0.4

* Formatted code, updated comments, and removed unnecessary files.

## 0.0.3

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.0.2

* Added HttpMetric for monitoring for specific network requests.

## 0.0.1

* Initial Release.
