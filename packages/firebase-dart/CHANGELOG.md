## 3.0.1

* Updated documentation and tests to reference the latest JS release: `3.7.2`

* Improvements to `README.md`

## 3.0.0

* Completely rewritten for Firebase v3.

## 0.6.6+3

* Support `crypto` 2.0.0.

## 0.6.6+2

* Strong-mode clean.

* Doc fixes.

## 0.6.6+1

* Support non-integer values for `priority` in set operations.

## 0.6.6

* Support latest version of `pkg/crypto`

* Support latest version of `firebase.js` - 2.4.2

## 0.6.5+1

* Fixed `FirebaseClient.post` to use `POST`.

## 0.6.5

* Added `FirebaseClient.post` to `firebase_io.dart`.

## 0.6.4

* Added `Firebase.ServerValue.TIMESTAMP` constant

## 0.6.3

* Added `onComplete` argument to `Firebase.push`.

## 0.6.2

* Fix an issue calling `push` with a `Map`.

* Fixed the return type of `Firebase.onAuth`. Also made the returned `Stream`
  asynchronous.

## 0.6.1

* Added `anonymous` constructor to `FirebaseClient`.

* Added `firebase_io.dart` library.
  * `createFirebaseJwtToken` can be used for authentication.
  * The `FirebaseClient` class is a simple wrapper for the Firebase `REST` API.

* Added `encodeKey` and `decodeKey` methods to `firebase.dart`
  and `firebas_io.dart`. Convenience methods for dealing with key values with
  disallowed characters.

## 0.6.0

* Removed deprecated `name` property on `Firebase` and `Snapshot`.
  Use `key` instead`.

* Removed deprecated `limit` method on `Firebase`.
  Use `limitToFirst` and `limitToLast` instead.

## 0.5.1

* Updated startAt() and endAt() methods. They don't take a
  priority anymore and are meant to be used in conjunction with orderBy*

## 0.5.0

* Added authWithOAuthToken()

* Changed return value of auth methods to return a native dart Map
  object containing all authData. This is a breaking change.

## 0.4.0

* Updated for Firebase api v2.2.2

* Deprecated `name` getter on Firebase and DataSnapshot

* Added `key` getter on Firebase and DataSnapshot, replacing `name`

* Added changeEmail()

* Added authAnonymously(), authWithOAuthPopup(), authWithOAuthRedirect()

* Added getAuth() and onAuth() listener

* Added orderByChild(), orderByKey(), orderByValue(), orderByPriority()

* Added equalTo(), limitToFirst(), limitToLast()

* Deprecated `limit` on Query object

* Added `exists` getter to DataSnapshot

* Added several tests

## 0.3.0

* Add createUser(), removeUser() and authWithPassword()
  (thanks to wilsynet)
* AuthResponse.auth was changed to type JsObject

## 0.2.1

* Added new `authWithCustomToken` method (thanks to rayk)
* Deprecate `auth`

## 0.2.0+1

* Updated README to include latest `firebase.js` link.

## 0.2.0

* A number of breaking changes and updates.

* A number of methods are now properties.

## 0.1.1+3

* Fixed up tests.

* Cleaned up library structure.

