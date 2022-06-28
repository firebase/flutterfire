## 3.3.17

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

## 3.3.16

 - Update a dependency to the latest release.

## 3.3.15

 - Update a dependency to the latest release.

## 3.3.14

 - Update a dependency to the latest release.

## 3.3.13

 - Update a dependency to the latest release.

## 3.3.12

 - Update a dependency to the latest release.

## 3.3.11

 - **FIX**: Allow `rawNonce` to be passed through on web via the `OAuthCredential`. (#8410). ([0df32f61](https://github.com/firebase/flutterfire/commit/0df32f6106ca41cdb95c36c7816e6487124937d4))

## 3.3.10

 - **FIX**: Check if `UserMetadata` properties are `null` before parsing. (#8313). ([cac41fb9](https://github.com/firebase/flutterfire/commit/cac41fb9ddd5462b57f9d17615f387478f10d3dc))

## 3.3.9

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

## 3.3.8

 - Update a dependency to the latest release.

## 3.3.7

 - **FIX**: Add support for`dynamicLinkDomain` property to `ActionCodeSetting` for web. (#7683). ([3b0bf76e](https://github.com/firebase/flutterfire/commit/3b0bf76e015c95840b2d38eec7f12c001d3bd47c))

## 3.3.6

 - Update a dependency to the latest release.

## 3.3.5

 - Update a dependency to the latest release.

## 3.3.4

 - Update a dependency to the latest release.

## 3.3.3

 - Update a dependency to the latest release.

## 3.3.2

 - Update a dependency to the latest release.

## 3.3.1

 - Update a dependency to the latest release.

## 3.3.0

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

## 3.2.0

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

## 3.1.4

 - Update a dependency to the latest release.

## 3.1.3

 - Update a dependency to the latest release.

## 3.1.2

 - **FIX**: null-safety migration issue for web types (#7137).

## 3.1.1

 - **FIX**: allow setLanguage to accept null (#7050).

## 3.1.0

 - **FEAT**: Add support for `secret` on `OAuthCredential` on web (#6830).
 - **FEAT**: expose linkWithPopup() & correctly parse credentials in exceptions (#6562).

## 3.0.1

 - Update a dependency to the latest release.

## 3.0.0

> Note: This release has breaking changes.

 - **FEAT**: setSettings now possible for android (#6367).
 - **CHORE**: catch native error verifyBeforeUpdateEmail() (#6473).
 - **BREAKING** **FEAT**: use<product>Emulator(host, port) API update (#6439).

## 2.0.0

> Note: This release has breaking changes.

 - **FEAT**: setSettings now possible for android (#6367).
 - **CHORE**: catch native error verifyBeforeUpdateEmail() (#6473).
 - **BREAKING** **FEAT**: useAuthEmulator(host, port) API update.

## 1.3.1

 - Update a dependency to the latest release.

## 1.3.0

 - **FEAT**: add tenantId support  (#5736).

## 1.2.0

 - **FEAT**: add User.updateDisplayName and User.updatePhotoURL (#6213).

## 1.1.3

 - Update a dependency to the latest release.

## 1.1.2

 - **DOCS**: Add missing homepage/repository links (#6054).
 - **CHORE**: publish packages (#6022).
 - **CHORE**: publish packages.

## 1.1.1

 - Update a dependency to the latest release.

## 1.1.0

 - **FEAT**: OAuthProvider.parameters is now non-nullable (#5656).

## 1.0.7

 - **FIX**: ensure web is initialized before sending stream events (#5766).
 - **CHORE**: update Web plugins to use Firebase JS SDK version 8.4.1 (#4464).

## 1.0.6

 - Update a dependency to the latest release.

## 1.0.5

 - Update a dependency to the latest release.

## 1.0.4

 - Update a dependency to the latest release.

## 1.0.3

 - Update a dependency to the latest release.

## 1.0.2

 - Update a dependency to the latest release.

## 1.0.1

 - **FIX**: correct use of underlying useEmulator API, sync not async (#5171).

## 1.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.0.0-1.0.nullsafety.0

 - Bump "firebase_auth_web" to `1.0.0-1.0.nullsafety.0`.

## 0.4.0-1.1.nullsafety.3

 - Update a dependency to the latest release.

## 0.4.0-1.1.nullsafety.2

 - Update a dependency to the latest release.

## 0.4.0-1.1.nullsafety.1

 - **REFACTOR**: pubspec & dependency updates (#4932).

## 0.4.0-1.1.nullsafety.0

 - **FEAT**: implement support for `useEmulator` (#4263).

## 0.4.0-1.0.nullsafety.0

 - **FIX**: bump firebase_core_* package versions to updated NNBD versioning format (#4832).

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
