## 2.1.2

 - **FIX**: fix firebase_auth listeners assigning of currentUser (#3737).

## 2.1.1

 - Update a dependency to the latest release.

## 2.1.0

 - **FIX**: fix IdTokenResult timestamps (web, ios) (#3357).
 - **FEAT**: add support for linkWithPhoneNumber (#3436).
 - **FEAT**: use named arguments for ActionCodeSettings (#3269).
 - **FEAT**: implement signInWithPhoneNumber on web (#3205).
 - **FEAT**: expose smsCode (android only) (#3308).
 - **DOCS**: fixed signOut method documentation (#3342).

## 2.0.1

* Fixed an incorrect assert when creating a `GoogleAuthCredential` instance. [(#3216)](https://github.com/FirebaseExtended/flutterfire/pull/3216/files#diff-be71096f90f1a879f17b7c94607b0885)

## 2.0.0

* See the `firebase_auth` plugin changelog.

## 1.1.8

* Update lower bound of dart dependency to 2.0.0.

## 1.1.7

* Use package:plugin_platform_interface

## 1.1.6

* Make the pedantic dev_dependency explicit.

## 1.1.5

- Fixed typo on private method name.

## 1.1.4

- **Breaking change**: Added missing `app` parameter to `confirmPasswordReset`.
  (This is an exception to the usual policy of avoiding breaking changes since
  `confirmPasswordReset` is a new API and doesn't have clients yet.)

## 1.1.3

- Added support for `confirmPasswordReset`

## 1.1.2

- Remove the deprecated `author:` field from pubspec.yaml

## 1.1.1

- Fixed crash when platform returns an auth result where `additionalUserInfo`
  is not provided.

## 1.1.0

- Added type `PlatformOAuthCredential` for generic OAuth providers.

## 1.0.0

- Initial open-source release.
