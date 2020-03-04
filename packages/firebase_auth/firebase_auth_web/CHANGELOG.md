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
