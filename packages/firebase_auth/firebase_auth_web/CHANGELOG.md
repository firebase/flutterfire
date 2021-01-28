## 0.4.0-1.0.nullsafety.0

 - **REFACTOR**: Migrate firebase auth to nnbd (#4633).
 - **FIX**: send userPlatform on changes (#3313).
 - **FIX**: bubble exceptions (#3700).
 - **FIX**: Revert #4312: Double event fire on initialization (#4620).
 - **FIX**: bump firebase_core_* package versions to updated NNBD versioning format (#4832).
 - **FIX**: web now fires once on authStateListener initialisation (#4312).
 - **FIX**: fix IdTokenResult timestamps (web, ios) (#3357).
 - **FIX**: force locale timestamp conversion (#3320).
 - **FIX**: implement missing web confirmPasswordReset (#3344).
 - **FEAT**: migrate firebase interop files to local repository (#3973).
 - **FEAT**: implement signInWithPhoneNumber on web (#3205).
 - **FEAT**: add support for linkWithPhoneNumber (#3436).
 - **FEAT**: use named arguments for ActionCodeSettings (#3269).
 - **FEAT**: bump firebase_core to v0.8.0-nullsafety.1 (#4760).
 - **FEAT**: v1 rework (#3140).
 - **FEAT**: v1 rework (#7) (#2890).
 - **FEAT**: add support for `confirmPasswordReset` (#2559).
 - **CHORE**: null safety hints (#4370).
 - **CHORE**: remove quiver + remove dependency_overrides + use latest firebase (#4689).
 - **CHORE**: publish packages.
 - **CHORE**: Migrate firebase_core/firebase_core_platform_interface/firebase_core_web to non-nullable types (#4656).
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.
 - **CHORE**: update lower bound dart dependency to 2.0.0.
 - **CHORE**: Add changelogs for firebase_auth (#4757).
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.
 - **CHORE**: firebase_auth_web v0.3.0+1.
 - **CHORE**: promote to stable version.
 - **CHORE**: remove android directory from web plugins (#3199).
 - **CHORE**: migrate to depend on new `firebase_core` plugin.
 - **CHORE**: publish packages.

## 0.4.0-nullsafety.1

Bump firebase_auth_platform_interface to v4.0.0-nullsafety.1

## 0.4.0-nullsafety.0

Migrated to null safety (#4633)

## 0.3.2+6

 - Update a dependency to the latest release.

## 0.3.2+5

 - **FIX**: Revert #4312: Double event fire on initialization (#4620).

## 0.3.2+4

 - **FIX**: bubble exceptions (#3700).

## 0.3.2+3

 - **FIX**: web now fires once on authStateListener initialisation (#4312).

## 0.3.2+2

 - Update a dependency to the latest release.

## 0.3.2+1

 - Update a dependency to the latest release.

## 0.3.2

 - **FEAT**: migrate firebase interop files to local repository (#3973).
 - **FEAT** [WEB] adds support for `EmailAuthProvider.credentialWithLink`
 - **FEAT** [WEB] adds support for `FirebaseAuth.setSettings`
 - **FEAT** [WEB] adds support for `User.tenantId`
 - **FEAT** [WEB] `FirebaseAuthException` now supports `email` & `credential` properties
 - **FEAT** [WEB] `ActionCodeInfo` now supports `previousEmail` field

## 0.3.1+2

 - Update a dependency to the latest release.

## 0.3.1+1

 - Update a dependency to the latest release.

## 0.3.1

 - **FIX**: fix IdTokenResult timestamps (web, ios) (#3357).
 - **FIX**: force locale timestamp conversion (#3320).
 - **FIX**: implement missing web confirmPasswordReset (#3344).
 - **FIX**: send userPlatform on changes (#3313).
 - **FEAT**: add support for linkWithPhoneNumber (#3436).
 - **FEAT**: use named arguments for ActionCodeSettings (#3269).
 - **FEAT**: implement signInWithPhoneNumber on web (#3205).

## 0.3.0+1

* Bump `firebase_auth_platform_interface` dependency to fix an assertion issue when creating Google sign-in credentials.

## 0.3.0

* See the `firebase_auth` plugin changelog.
* Depend on `firebase_core`.

## 0.1.3+1

* Implement `confirmPasswordReset`.

## 0.1.3

* Update lower bound of dart dependency to 2.0.0.

## 0.1.2+2

* Make the pedantic dev_dependency explicit.

## 0.1.2+1

* Require `firebase_core_web` from hosted

## 0.1.2

* Implement `fetchSignInMethodsForEmail`, `isSignInWithEmailLink`, `signInWithEmailAndLink`, and `sendLinkToEmail`.

## 0.1.1+4

* Prevent `null` users (unauthenticated) from breaking the `onAuthStateChanged` Stream.
* Migrate tests from jsify to package:js.

## 0.1.1+3

* Fix the tests on dart2js.

## 0.1.1+2

* Update setup instructions in the README.

## 0.1.1+1

* Add an android/ folder with no-op implementation to workaround https://github.com/flutter/flutter/issues/46898

## 0.1.1

* Require Flutter SDK version 1.12.13+hotfix.4 or later.
* Add fake podspec so we don't break compilation on iOS.
* Fix homepage.

## 0.1.0+2

* Remove the deprecated `author:` field from pubspec.yaml.
* Bump the minimum Flutter version to 1.10.0.

## 0.1.0+1

* Fixed serialization error for creationTime and lastSignInTime being RFC 1123.

## 0.1.0

* Initial open-source release.
