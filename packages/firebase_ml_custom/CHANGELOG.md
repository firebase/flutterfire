## 0.2.0+1

 - **REFACTOR**: replace usage of deprecated & removed Image Picker API.
 - **REFACTOR**: update example app to v2 embedding and fix build issues.
 - **REFACTOR**: remove unused e2e pubspec dependency.
 - **REFACTOR**: remove unused flutter_driver pubspec dependency.
 - **REFACTOR**: remove unused path/path_provider pubspec dependencies.
 - **REFACTOR**: remove unused pedantic pubspec dependencies.
 - **REFACTOR**: remove firebase_core pubspec dependencies.
 - **DOCS**: Add missing homepage/repository links (#6054).
 - **CHORE**: switch firebase configuration to default testing project.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.
 - **CHORE**: bump min Dart SDK constraint to 2.12.0 (#5430).
 - **CHORE**: publish packages (#5429).
 - **CHORE**: merge all analysis_options.yaml into one (#5329).
 - **CHORE**: publish packages.
 - **CHORE**: enable lints for firebase_ml_custom (#5254).
 - **BUILD**: remove TFLite dependency and fix/clean iOS build + e2e testing.

## 0.2.0

 - This version is not null-safe but has been created to allow compatibility with other null-safe FlutterFire packages such as `firebase_core`.

## 0.1.0

 - **FEAT**: bump firebase-android-sdk BoM to 25.13.0.
 - **CHORE**: harmonize dependencies and version handling.
 - **BREAKING** **FEAT**: forward port to firebase-ios-sdk v7.3.0.
   - Due to this SDK upgrade, iOS 10 is now the minimum supported version by FlutterFire. Please update your build target version.

## 0.0.5

 - **FEAT**: bump android `com.android.tools.build` & `'com.google.gms:google-services` versions (#4269).
 - **CHORE**: Migrate iOS example projects (#4222).
 - **CHORE**: bump gradle wrapper to 5.6.4 (#4158).

## 0.0.4

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: bump `compileSdkVersion` to 29 in preparation for upcoming Play Store requirement.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 0.0.3

 - **FEAT**: bump compileSdkVersion to 29 (#3975).

## 0.0.2+1

 - **FIX**: local dependencies in example apps (#3319).

## 0.0.2

* Fix plugin description and the changelog.

## 0.0.1

* Initial release with model manager.
* Model manager is created with default Firebase App instance.
* Model manager supports downloading, checking and getting latest model.
