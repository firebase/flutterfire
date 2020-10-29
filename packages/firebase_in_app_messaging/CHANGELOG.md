## 0.2.1

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: update Firebase iOS SDK version to 6.33.0 (from 6.26.0).

## 0.2.0+3

 - Update a dependency to the latest release.

## 0.2.0+2

 - **FIX**: local dependencies in example apps (#3319).
 - **CHORE**: fix pod install error on example FIAM app (#3116).

## 0.2.0+1

* Fixed issue #3227 (Invalid podspec). 

## 0.2.0

* Depend on `firebase_core` pre-release.
* Firebase iOS SDK versions are now locked to use the same version defined in
  `firebase_core`.
* Firebase Android SDK versions are now using the Firebase Bill of Materials (BoM)
  to specify individual SDK versions. BoM version is also sourced from
  `firebase_core`.
* Allow iOS to be imported as a module.
* Updated package of Android from `com.example.firebase_in_app_messaging` to
  `io.flutter.plugins.firebase.inappmessaging`.

## 0.1.2

* Update lower bound of dart dependency to 2.0.0.

## 0.1.1+3

* Replace deprecated `getFlutterEngine` call on Android.

## 0.1.1+2

* Make the pedantic dev_dependency explicit.

## 0.1.1+1

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 0.1.1

* Updated the plugin API to v2.

## 0.1.0

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 0.0.1+4

* Update example app with correct const constructors.

## 0.0.1+3

* Update AGP, gradle and inappmessaging-display versions on Android.

## 0.0.1+2

* Remove dependency `androidx.annotation:annotation:1.0.0`.

## 0.0.1+1

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 0.0.1

* Initial release.
