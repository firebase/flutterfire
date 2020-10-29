## 0.18.2

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: update Firebase iOS SDK version to 6.33.0 (from 6.26.0).

## 0.18.1+2

 - **FIX**: on iOS use sendEmailVerificationWithActionCodeSettings instead of sendEmailVerificationWithCompletion (#3686).
 - **DOCS**: README updates (#3768).

## 0.18.1+1

 - **FIX**: Optional params for "signInWithCredential" method are converted to "nil" if "null" for iOS (#3731).

## 0.18.1

 - **FIX**: local dependencies in example apps (#3319).
 - **FIX**: fix IdTokenResult timestamps (web, ios) (#3357).
 - **FIX**: pub.dev score fixes (#3318).
 - **FIX**: use unknown APNS token type (#3345).
 - **FIX**: update FLTFirebaseAuthPlugin.m (#3360).
 - **FIX**: use correct FIRAuth instance on listeners (#3316).
 - **FEAT**: add support for linkWithPhoneNumber (#3436).
 - **FEAT**: use named arguments for ActionCodeSettings (#3269).
 - **FEAT**: implement signInWithPhoneNumber on web (#3205).
 - **FEAT**: expose smsCode (android only) (#3308).
 - **DOCS**: fixed signOut method documentation (#3342).

## 0.18.0+1

* Fixed an Android issue where certain network related Firebase Auth error codes would come through as `unknown`. [(#3217)](https://github.com/FirebaseExtended/flutterfire/pull/3217)
* Added missing deprecations: `FirebaseUser` class and `photoUrl` getter.
* Bump `firebase_auth_platform_interface` dependency to fix an assertion issue when creating Google sign-in credentials.
* Bump `firebase_auth_web` dependency to `^0.3.0+1`.

## 0.18.0

Overall, Firebase Auth has been heavily reworked to bring it inline with the federated plugin setup along with adding new features, documentation and many more unit and end-to-end tests. The API has mainly been kept the same, however there are some breaking changes.

### General

- **BREAKING**: The `FirebaseUser` class has been renamed to `User`.
- **BREAKING**: The `AuthResult` class has been renamed to `UserCredential`.
- **NEW**: The `ActionCodeSettings` class is now consumable on all supporting methods.
  - **NEW**: Added support for the `dynamicLinkDomain` property.
- **NEW**: Added a new `FirebaseAuthException` class (extends `FirebaseException`).
  - All errors are now returned as a `FirebaseAuthException`, allowing you to access the code & message associated with the error.
  - In addition, it is now possible to access the `email` and `credential` properties on exceptions if they exist.

### `FirebaseAuth`

- **BREAKING**: Accessing the current user via `currentUser()` is now synchronous via the `currentUser` getter.
- **BREAKING**: `isSignInWithEmailLink()` is now synchronous.
- **DEPRECATED**: `FirebaseAuth.fromApp()` is now deprecated in favor of `FirebaseAuth.instanceFor()`.
- **DEPRECATED**: `onAuthStateChanged` has been deprecated in favor of `authStateChanges()`.
- **NEW**: Added support for `idTokenChanges()` stream listener.
- **NEW**: Added support for `userChanges()` stream listener.
  - The purpose of this API is to allow users to subscribe to all user events without having to manually hydrate app state in cases where a manual reload was required (e.g. `updateProfile()`).
- **NEW**: Added support for `applyActionCode()`.
- **NEW**: Added support for `checkActionCode()`.
- **NEW**: Added support for `verifyPasswordResetCode()`.
- **NEW**: Added support for accessing the current language code via the `languageCode` getter.
- **NEW**: `setLanguageCode()` now supports providing a `null` value.
  - On web platforms, if `null` is provided the Firebase projects default language will be set.
  - On native platforms, if `null` is provided the device language will be used.
- **NEW**: `verifyPhoneNumber()` exposes a `autoRetrievedSmsCodeForTesting` property.
  - This allows developers to test automatic SMS code resolution on Android devices during development.
- **NEW** (iOS): `appVerificationDisabledForTesting`  setting can now be set for iOS.
  - This allows developers to skip ReCaptcha verification when testing phone authentication.
- **NEW** (iOS): `userAccessGroup` setting can now be set for iOS & MacOS.
  - This allows developers to share authentication states across multiple apps or extensions on iOS & MacOS. For more information see the [Firebase iOS SDK documentation](https://firebase.google.com/docs/auth/ios/single-sign-on).

### `User`

- **BREAKING**: Removed the `UpdateUserInfo` class when using `updateProfile` in favor of named arguments.
- **NEW**: Added support for `getIdTokenResult()`.
- **NEW**: Added support for `verifyBeforeUpdateEmail()`.
- **FIX**: Fixed several iOS crashes when the Firebase SDK returned `nil` property values.
- **FIX**: Fixed an issue on Web & iOS where a users email address would still show after unlinking the email/password provider.

### `UserCredential`

- **NEW**: Added support for accessing the users `AuthCredential` via the `credential` property.

### `AuthProvider` & `AuthCredential`

- **DEPRECATED**: All sub-class (e.g. `GoogleAuthProvider`) `getCredential()` methods have been deprecated in favor of `credential()`.
  - **DEPRECATED**:  `EmailAuthProvider.getCredentialWithLink()` has been deprecated in favor of `EmailAuthProvider.credentialWithLink()`.
- **NEW**: Supporting providers can now assign scope and custom request parameters.
  - The scope and parameters will be used on web platforms when triggering a redirect or popup via `signInWithPopup()` or `signInWithRedirect()`.

## 0.17.0-dev.2

* Update plugin and example to use the same core.

## 0.17.0-dev.1

* Depend on `firebase_core` pre-release versions.

## 0.16.1+2

* Update README to make it clear which authentication options are possible.

## 0.16.1+1

* Fix bug #2656 (verifyPhoneNumber always use the default FirebaseApp, not the configured one)

## 0.16.1

* Update lower bound of dart dependency to 2.0.0.

## 0.16.0

* Migrate to Android v2 embedding.

## 0.15.5+3

* Fix for missing UserAgent.h compilation failures.

## 0.15.5+2

* Update the platform interface dependency to 1.1.7 and update tests.

## 0.15.5+1

* Make the pedantic dev_dependency explicit.

## 0.15.5

* Add macOS support

## 0.15.4+1

* Fix fallthrough bug in Android code.

## 0.15.4

* Add support for `confirmPasswordReset` on Android and iOS.

## 0.15.3+1

* Add integration instructions for the `web` platform.

## 0.15.3

* Add support for OAuth Authentication for iOS and Android to solve generic providers authentication.

## 0.15.2

* Add web support by default.
* Require Flutter SDK 1.12.13+hotfix.4 or later.

## 0.15.1+1

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 0.15.1

* Migrate to use `firebase_auth_platform_interface`.

## 0.15.0+2

*  Update homepage since this package was moved.

## 0.15.0+1

*  Added missing ERROR_WRONG_PASSWORD Exception to the `reauthenticateWithCredential` docs.

## 0.15.0

* Fixed `NoSuchMethodError` in `reauthenticateWithCredential`.
* Fixed `IdTokenResult` analyzer warnings.
* Reduced visibility of `IdTokenResult` constructor.

## 0.14.0+10

* Formatted lists in member documentations for better readability.

## 0.14.0+9

* Fix the behavior of `getIdToken` to use the `refresh` parameter instead of always refreshing.

## 0.14.0+8

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 0.14.0+7

* Remove AndroidX warning.

## 0.14.0+6

* Update example app with correct const constructors.

## 0.14.0+5

* On iOS, `fetchSignInMethodsForEmail` now returns an empty list when the email
  cannot be found, matching the Android behavior.

## 0.14.0+4

* Fixed "Register a user" example code snippet in README.md.

## 0.14.0+3

* Update documentation to reflect new repository location.
* Update unit tests to call `TestWidgetsFlutterBinding.ensureInitialized`.
* Remove executable bit on LICENSE file.

## 0.14.0+2

* Reduce compiler warnings on iOS port by replacing `int` with `long` backing in returned timestamps.

## 0.14.0+1

* Add dependency on `androidx.annotation:annotation:1.0.0`.

## 0.14.0

* Added new `IdTokenResult` class.
* **Breaking Change**. `getIdToken()` method now returns `IdTokenResult` instead of a token `String`.
  Use the `token` property of `IdTokenResult` to retrieve the token `String`.
* Added integration testing for `getIdToken()`.

## 0.13.1+1

* Update authentication example in README.

## 0.13.1

* Fixed a crash on iOS when sign-in fails.
* Additional integration testing.
* Updated documentation for `FirebaseUser.delete()` to include error codes.
* Updated Firebase project to match other Flutterfire apps.

## 0.13.0

* **Breaking change**: Replace `FirebaseUserMetadata.creationTimestamp` and
  `FirebaseUserMetadata.lastSignInTimestamp` with `creationTime` and `lastSignInTime`.
  Previously on iOS `creationTimestamp` and `lastSignInTimestamp` returned in
  seconds and on Android in milliseconds. Now, both platforms provide values as a
  `DateTime`.

## 0.12.0+1

* Fixes iOS sign-in exceptions when `additionalUserInfo` is `nil` or has `nil` fields.
* Additional integration testing.

## 0.12.0

* Added new `AuthResult` and `AdditionalUserInfo` classes.
* **Breaking Change**. Sign-in methods now return `AuthResult` instead of `FirebaseUser`.
  Retrieve the `FirebaseUser` using the `user` property of `AuthResult`.

## 0.11.1+12

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 0.11.1+11

* On iOS, `getIdToken()` now uses the `refresh` parameter instead of always using `true`.

## 0.11.1+10

* On Android, `providerData` now includes `UserInfo` for the phone authentication provider.

## 0.11.1+9

* Update README to clarify importance of filling out all fields for OAuth consent screen.

## 0.11.1+8

* Automatically register for iOS notifications, ensuring that phone authentication
  will work even if Firebase method swizzling is disabled.

## 0.11.1+7

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 0.11.1+6

* Add documentation of support email requirement to README.

## 0.11.1+5

* Fix `updatePhoneNumberCredential` on Android.

## 0.11.1+4

* Fix `updatePhoneNumberCredential` on iOS.

## 0.11.1+3

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.
* FirebaseUser private constructor takes `Map<String, dynamic>` instead of `Map<dynamic, dynamic>`.

## 0.11.1+2

* Suppress deprecation warning for BinaryMessages. See: https://github.com/flutter/flutter/issues/33446

## 0.11.1+1

* Updated the error code documentation for `linkWithCredential`.

## 0.11.1

* Support for `updatePhoneNumberCredential`.

## 0.11.0

* **Breaking change**: `linkWithCredential` is now a function of `FirebaseUser`instead of
  `FirebaseAuth`.
* Added test for newer `linkWithCredential` function.

## 0.10.0+1

* Increase Firebase/Auth CocoaPod dependency to '~> 6.0'.

## 0.10.0

* Update firebase_dynamic_links dependency.
* Update Android dependencies to latest.

## 0.9.0

* **Breaking change**: `PhoneVerificationCompleted` now provides an `AuthCredential` that can
  be used with `signInWithCredential` or `linkWithCredential` instead of signing in automatically.
* **Breaking change**: Remove internal counter `nextHandle` from public API.

## 0.8.4+5

* Increase Firebase/Auth CocoaPod dependency to '~> 5.19'.

## 0.8.4+4

* Update FirebaseAuth CocoaPod dependency to ensure availability of `FIRAuthErrorUserInfoNameKey`.

## 0.8.4+3

* Updated deprecated API usage on iOS to use non-deprecated versions.
* Updated FirebaseAuth CocoaPod dependency to ensure a minimum version of 5.0.

## 0.8.4+2

* Fixes an error in the documentation of createUserWithEmailAndPassword.

## 0.8.4+1

* Adds credential for email authentication with link.

## 0.8.4

* Adds support for email link authentication.

## 0.8.3

* Make providerId 'const String' to use in 'case' statement.

## 0.8.2+1

* Fixed bug where `PhoneCodeAutoRetrievalTimeout` callback was never called.

## 0.8.2

* Fixed `linkWithCredential` on Android.

## 0.8.1+5

* Added a driver test.

## 0.8.1+4

* Update README.
* Update the example app with separate pages for registration and sign-in.

## 0.8.1+3

* Reduce compiler warnings in Android plugin
* Raise errors early when accessing methods that require a Firebase User

## 0.8.1+2

* Log messages about automatic configuration of the default app are now less confusing.

## 0.8.1+1

* Remove categories.

## 0.8.1

* Fixes Firebase auth phone sign-in for Android.

## 0.8.0+3

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.8.0+2

* Update Google sign-in example in the README.

## 0.8.0+1

* Update a broken dependency.

## 0.8.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.7.0

* Introduce third-party auth provider classes that generate `AuthCredential`s
* **Breaking Change** Signing in, linking, and reauthenticating now require an `AuthCredential`
* **Breaking Change** Unlinking now uses providerId
* **Breaking Change** Moved reauthentication to FirebaseUser

## 0.6.7

* `FirebaseAuth` and `FirebaseUser` are now fully documented.
* `PlatformExceptions` now report error codes as stated in docs.
* Credentials can now be unlinked from Accounts with new methods on `FirebaseUser`.

## 0.6.6

* Users can now reauthenticate in response to operations that require a recent sign-in.

## 0.6.5

* Fixing async method `verifyPhoneNumber`, that would never return even in a successful call.

## 0.6.4

* Added support for Github signin and linking Github accounts to existing users.

## 0.6.3

* Add multi app support.

## 0.6.2+1

* Bump Android dependencies to latest.

## 0.6.2

* Add access to user metadata.

## 0.6.1

* Adding support for linkWithTwitterCredential in FirebaseAuth.

## 0.6.0

* Added support for `updatePassword` in `FirebaseUser`.
* **Breaking Change** Moved `updateEmail` and `updateProfile` to `FirebaseUser`.
  This brings the `firebase_auth` package inline with other implementations and documentation.

## 0.5.20

* Replaced usages of guava's: ImmutableList and ImmutableMap with platform
Collections.unmodifiableList() and Collections.unmodifiableMap().

## 0.5.19

* Update test package dependency to pick up Dart 2 support.
* Modified dependency on google_sign_in to point to a published
  version instead of a relative path.

## 0.5.18

* Adding support for updateEmail in FirebaseAuth.

## 0.5.17

* Adding support for FirebaseUser.delete.

## 0.5.16

* Adding support for setLanguageCode in FirebaseAuth.

## 0.5.15

* Bump Android and Firebase dependency versions.

## 0.5.14

* Fixed handling of auto phone number verification.

## 0.5.13

* Add support for phone number authentication.

## 0.5.12

* Fixed ArrayIndexOutOfBoundsException in handleStopListeningAuthState

## 0.5.11

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.5.10

* Updated iOS implementation to reflect Firebase API changes.

## 0.5.9

* Added support for signing in with a Twitter account.

## 0.5.8

* Added support to reload firebase user

## 0.5.7

* Added support to sendEmailVerification

## 0.5.6

* Added support for linkWithFacebookCredential

## 0.5.5

* Updated Google Play Services dependencies to version 15.0.0.

## 0.5.4

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 0.5.3

* Secure fetchProvidersForEmail (no providers)

## 0.5.2

* Fixed Dart 2 type error in fetchProvidersForEmail.

## 0.5.1

* Added support to fetchProvidersForEmail

## 0.5.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.4.7

* Fixed Dart 2 type errors.

## 0.4.6

* Fixed Dart 2 type errors.

## 0.4.5

* Enabled use in Swift projects.

## 0.4.4

* Added support for sendPasswordResetEmail

## 0.4.3

* Moved to the io.flutter.plugins organization.

## 0.4.2

* Added support for changing user data

## 0.4.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.4.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
* Relaxed GMS dependency to [11.4.0,12.0[

## 0.3.2

* Added FLT prefix to iOS types
* Change GMS dependency to 11.4.+

## 0.3.1

* Change GMS dependency to 11.+

## 0.3.0

* **Breaking Change**: Method FirebaseUser getToken was renamed to getIdToken.

## 0.2.5

* Added support for linkWithCredential with Google credential

## 0.2.4

* Added support for `signInWithCustomToken`
* Added `Stream<FirebaseUser> onAuthStateChanged` event to listen when the user change

## 0.2.3+1

* Aligned author name with rest of repo.

## 0.2.3

* Remove dependency on Google/SignIn

## 0.2.2

* Remove dependency on FirebaseUI

## 0.2.1

* Added support for linkWithEmailAndPassword

## 0.2.0

* **Breaking Change**: Method currentUser is async now.

## 0.1.2

* Added support for signInWithFacebook

## 0.1.1

* Updated to Firebase SDK to always use latest patch version for 11.0.x builds

## 0.1.0

* Updated to Firebase SDK Version 11.0.1
* **Breaking Change**: You need to add a maven section with the "https://maven.google.com" endpoint to the repository section of your `android/build.gradle`. For example:
```gradle
allprojects {
    repositories {
        jcenter()
        maven {                              // NEW
            url "https://maven.google.com"   // NEW
        }                                    // NEW
    }
}
```

## 0.0.4

* Add method getToken() to FirebaseUser

## 0.0.3+1

* Updated README.md

## 0.0.3

* Added support for createUserWithEmailAndPassword, signInWithEmailAndPassword, and signOut Firebase methods

## 0.0.2+1

* Updated README.md

## 0.0.2

* Bump buildToolsVersion to 25.0.3

## 0.0.1

* Initial Release
