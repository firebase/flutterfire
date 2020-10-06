## 7.3.0

- added additional options to interop 'Settings' to Fix Timestamp Error.

## 7.2.2-dev

- Enabled sending of user properties in analytics with `setUserProperties`.
- Removed unused (and unusable) `CustomParams` class.

## 7.2.1

- Mark intereop types `AuthProvider` and `OAuthCredential` anonymous. 

## 7.2.0

- Added [Remote Config](https://firebase.google.com/docs/remote-config) support.
  - See the top-level `remoteConfig` function and the related `RemoteConfig`
    class.
- Added back `AuthProvider` and made `OAuthProvider` a subtype.

## 7.1.0

- Added `Auth.fetchSignInMethodsForEmail` and `Auth.isSignInWithEmailLink`.

## 7.0.0

- **BREAKING** renamed `AuthCredential` into `OAuthCredential` to align with JS API
- **BREAKING** removed deprecated Firestore `Settings.timestampsInSnapshots`. 
- Added support for functions.
- Added `idToken`, `accessToken` and `secret` to `OAuthCredential`
- Added support for Email Link authentication.
- Firestore `Settings` added `cacheSizeBytes`, `host`, and `ssl` properties.
- Added `measurementId` and `appId` to `FirebaseOptions` (both required for analytics)
- Added analytics and performance interop
- Added `User.getIdTokenResult`.
- Removed long-deprecated `Auth.fetchProvidersForEmail` function.
- Updated documented JS library from `6.6.1` of the JS API to `7.4.0`.

## 6.0.0

- **BREAKING** Removed and renamed members across `auth` and `firestore` to
  align with v6 changes to
  [JS API](https://firebase.google.com/support/release-notes/js#version_600_-_may_7_2019).
- **BREAKING** The `Promise` polyfil has been removed from the JS SDK. Users
  will have to include their own polyfil for `Promise`. 
- **BREAKING** All of the setters on `FirebaseError` have been removed.

- Added `serverResponse` getter to `FirebaseError`.
- Added `FieldValue.increment` static function.
- Added support for storage List API.
- Added support for firestore `collectionGroup`.
- Added `OAuthProvider`.

## 5.0.4

- Require at least Dart 2.1.0.
- Updated documented JS library from `5.5.2` of the JS API to `5.10.1`.

## 5.0.3

- Add support for firestore `FieldValue.arrayUnion()` and `FieldValue.arrayRemove()`
- Fix a number of issues in interop.
- Support the latest `pkg:http`.

## 5.0.2

* Updated documented JS library from `5.1.0` of the JS API to `5.5.2`.

* Fixed issues with canceled subscriptions in Database `Query`.

## 5.0.1

* README updates.

## 5.0.0

* Updated from `4.13.0` of the JS API to `5.1.0`.

* Auth
  * `getToken` has been removed.
  * `linkWithCredential`, `fetchProvidersForEmail`, `signinWithCredential`, and 
    `reauthenticateWithCredential` have been deprecated.
  * `createUserWithEmailAndPassword`, `signInAnonymously`, 
    `signinWithCustomToken`, and `signInWithEmailAndPassword` all return 
    `UserCredential` instead of `User`.

* Firestore
  * `QuerySnapshot.docChanges` is now a function.
  * `timestampInSnapshots` is set to `true` by default.

* Storage
  * `downloadURLs` and `downloadURL` have been removed.

## 4.5.1

* Require at least Dart SDK `2.0.0-dev.61`.

* Simplify promise-Future interop using new `dart:html` API.

* Fixed remaining issues with Dart2 runtime semantics.

## 4.5.0

* Updated tested JS API version to `4.13.0`.
  * Deprecated `downloadURL` and `downloadURLs`. 

* Require at least Dart SDK `2.0.0-dev.36`.

### Firestore

* Moved `setLogLevel` to a top-level method from `Firestore`.
  *Not considering this a breaking change since the method never worked as
  previously exposed.*

* Added `isEqual` to `CollectionReference`, `DocumentSnapshot`,
  `SnapshotMetadata`and `QuerySnapshot`.

* Added `disableNetwork` and `enableNetwork` to `Firestore`

## 4.4.0

* Added support for
  [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging/).

* Updated tested/documented Firebase JS API `4.10.1`.

* **BREAKING** Firestore `Blob` is no longer wrapped. It is now just the raw
  interop object.
  
  * The only practical change is the `fromUint8List` static function is now
    `fromUint8Array` – since it maps to the source JS function.
  * Usage of `Blob` for value storage was broken until this change, so a we're
    not doing a major version update.

* Added `isEqual` API to `Blob`, `GeoPoint`, `FieldValue`, and `FieldPath`. 

## 4.3.1

* Support `DocumentReference` and `GeoPoint` as a field values in a document.

## 4.3.0

* Upgraded to Firebase JS API `4.8.1`.
* Added `metadata` property to `User`.
* Added `isNewUser` property to `AdditionalUserInfo`.
* Updated auth examples and tests with the latest features.
* Added new Firestore library - see [README](README.md) and [example/firestore](example/firestore) on how to use it.
* Added new APIs for the `Auth` library which function the same as their counterparts but return a `Future` that 
resolves with a `UserCredential` instead of a `User`. These methods will be eventually renamed to replace the older 
methods.
    * `createUserAndRetrieveDataWithEmailAndPassword`
    * `signInAndRetrieveDataWithCustomToken`
    * `signInAndRetrieveDataWithEmailAndPassword`
    * `signInAnonymouslyAndRetrieveData`
    
## 4.2.0+1

* Updates to `lib/src/` files that are not meant for consumptions outside this
  package.

## 4.2.0

* Improve the generic types in the interop library.
* Upgraded to Firebase JS API `4.4.0`.
* Added client side localization for email actions, phone authentication SMS 
  messages, OAuth flows and reCAPTCHA verification:
    * Added readable/writable `languageCode` property to `Auth`.
    * Added `useDeviceLanguage` method.
* Added the ability to pass a continue URL/state when triggering a password 
  reset/email verification which gives a user the ability to go back to the app
  after completion.
* Added support for the ability to open these links directly from a mobile app
  instead of a web flow using Firebase Dynamic Links:
    * `sendEmailVerification` and `sendPasswordResetEmail` have 
      optional `ActionCodeSettings` parameter.
* Added `Persistence` state via `setPersistence` method on `Auth` class.
* Updated auth example with the latest features.

## 4.1.0

* Upgraded to Firebase JS API `4.2.0`.
* Added `toJson` to `DataSnapshot` and `Query`. 
* `Auth`:
    * Implemented `PhoneAuthProvider` and `RecaptchaVerifier`.
* `User`:
    * Added `phoneNumber` property to the `UserInfo`.
    * Added `linkWithPhoneNumber`, `updatePhoneNumber` and 
      `reauthenticateWithPhoneNumber` methods.
* New example demonstrating `PhoneAuthProvider` functionality in 
  `example/auth_phone`.
* Added more tests for V4 API.

## 4.0.0

* Upgraded to Firebase JS API `4.1.3`.

* Breaking changes
  * The value in `Auth.onAuthStateChanged` is now `User`. `AuthEvent` has been 
    removed.

* Removed deprecated APIs: 
    * `User`
        * `link` method in favor of `linkWithCredential`.
        * `reauthenticate` method in favor of `reauthenticateWithCredential`.
    * `AuthCredential`
        * `provider` property in favor of `providerId`.

* `User`: added `getIdToken`, `reauthenticateAndRetrieveDataWithCredential`,
  `linkAndRetrieveDataWithCredential`, and `toJson()`.

* `Auth`: added `signInAndRetrieveDataWithCredential` and `onIdTokenChanged`.

## 3.2.1

* Update minimum Dart SDK to `1.21.0` – required to use generic method syntax. 

## 3.2.0

* The `FirebaseJsNotLoadedException` is thrown when the firebase.js script is 
  not included in the html file.
  
* Fix to support `dartdevc`.

## 3.1.0

* Updates from the Firebase `3.8.0` and `3.9.0` in `auth` library:
    * `User`
        * Deprecated `link` method in favor of `linkWithCredential`.
        * Deprecated `reauthenticate` method in favor of
          `reauthenticateWithCredential`.
        * Added new `reauthenticateWithPopup` and `reauthenticateWithRedirect`
          methods.
    * `UserCredential`
        * Added new `operationType` property.
    * `AuthCredential`
        * Deprecated `provider` property in favor of `providerId`.
* The `app.storage()` has now an optional storage bucket parameter.

## 3.0.2

* Throw `FirebaseClientException` if there are request failures in
  `firebase_io.dart`.
* Fix provider's `addScope` and `setCustomParameters` methods return types.
* Support the latest release of `pkg/func`.

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

