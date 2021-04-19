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
