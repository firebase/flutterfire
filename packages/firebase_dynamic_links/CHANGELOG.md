## 0.6.1

 - **FIX**: fixed issue with overwriting correct url with null one (#3567).
 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: update Firebase iOS SDK version to 6.33.0 (from 6.26.0).

## 0.6.0+2

 - Update a dependency to the latest release.

## 0.6.0+1

 - **FIX**: local dependencies in example apps (#3319).
 - **CHORE**: intellij cleanup (#3326).

## 0.6.0

* Depend on new `firebase_core` plugin.
* Firebase iOS SDK versions are now locked to use the same version defined in
  `firebase_core`.
* Firebase Android SDK versions are now using the Firebase Bill of Materials (BoM)
  to specify individual SDK versions. BoM version is also sourced from
  `firebase_core`.

## 0.5.3

* Fix for passing null/nil link between native libraries and flutter code.

## 0.5.2

* Fix for race-condition issue on iOS during initialization process

## 0.5.1

* Update lower bound of dart dependency to 2.0.0.

## 0.5.0+12

* Fix for missing UserAgent.h compilation failures.

## 0.5.0+11

* Replace deprecated `getFlutterEngine` call on Android.

## 0.5.0+10

* Make the pedantic dev_dependency explicit.

## 0.5.0+9

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 0.5.0+8

* Support v2 embedding. This will remain compatible with the original embedding and won't require app migration.

## 0.5.0+7

* Add `getDynamicLink` to support expanding from short links.

## 0.5.0+6

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 0.5.0+5

* Remove AndroidX warning.

## 0.5.0+4

* Fix example app build by updating version of `url_launcher` that is compatible with androidx apps.

## 0.5.0+3

* Don't crash if registrar.activity() is not there.

## 0.5.0+2

* Change the OnLinkError object to be a real exception.

## 0.5.0+1

* Update documentation to reflect new repository location.
* Update unit tests to call `TestWidgetsFlutterBinding.ensureInitialized`.

## 0.5.0

* **Breaking change**. Changed architecture and method names to be able to differentiate between
the dynamic link which opened the app and links clicked during app execution (active and background).
`retrieveDynamicLink` has been replaced with two different functions:
- `getInitialLink` a future to retrieve the link that opened the app
- `onLink` a callback to listen to links opened while the app is active or in background

## 0.4.0+6

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 0.4.0+5

* Fix the bug below properly by allowing the activity to be null (but still registering the plugin). If activity is null, we don't get a latestIntent, instead we expect the intent listener to grab it.

## 0.4.0+4

* Fixed bug on Android when a headless plugin tries to register this plugin causing a crash due no activity from the registrar.

## 0.4.0+3

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 0.4.0+2

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.4.0+1

* Fixed bug where link persists after starting an app with a Dynamic Link.
* Fixed bug where retrieving a link would fail when app was already running.

## 0.4.0

* Update dependency on firebase_core to 0.4.0.

## 0.3.0.

* Update Android dependencies to 16.1.7.
* **Breaking change**. Dynamic link parameter `domain` replaced with `uriPrefix`.

## 0.2.1

* Throw `PlatformException` if there is an error retrieving dynamic link.

## 0.2.0+4

* Fix crash when receiving `ShortDynamicLink` warnings.

## 0.2.0+3

* Log messages about automatic configuration of the default app are now less confusing.

## 0.2.0+2

* Remove categories.

## 0.2.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.2.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.1.1

* Update example to create a clickable and copyable link.

## 0.1.0+2

* Change android `invites` dependency to `dynamic links` dependency.

## 0.1.0+1

* Bump Android dependencies to latest.

## 0.1.0

* **Breaking Change** Calls to retrieve dynamic links on iOS always returns null after first call.

## 0.0.6

* Bump Android and Firebase dependency versions.

## 0.0.5

* Added capability to receive dynamic links.

## 0.0.4

* Fixed dynamic link dartdoc generation.

## 0.0.3

* Fixed incorrect homepage link in pubspec.

## 0.0.2

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.0.1

* Initial release with api to create long or short dynamic links.
