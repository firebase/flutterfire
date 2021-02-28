## 1.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.0.0-1.0.nullsafety.0

 - Bump "firebase_messaging_web" to `1.0.0-1.0.nullsafety.0`.

## 0.2.0-1.0.nullsafety.1

 - Update a dependency to the latest release.

## 0.2.0-1.0.nullsafety.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: migrate to NNBD (#4909).
 - **BREAKING**: the following deprecated APIs have been removed:
   - `iOSNotificationSettings`.
   - `requestNotificationPermissions` - use `requestPermission` instead.
   - `autoInitEnabled()` - use `setAutoInitEnabled()` instead.
   - `deleteInstanceID()` - use `deleteToken()` instead.
   - `FirebaseMessaging()` - use `FirebaseMessaging.instance` instead.

## 0.1.0-dev.5

 - **FIX**: check is supported before init web (#4644).

## 0.1.0-dev.4

 - **FIX**: null check notification jsObject (#4624).

## 0.1.0-dev.3

 - Update a dependency to the latest release.

## 0.1.0-dev.2

 - **REFACTOR**: initial web release as pre-release version (changelog).
 - **REFACTOR**: initial web release as pre-release version.
 - **FEAT**: web implementation (#4206).
 - **CHORE**: add no-op ios podspec for web plugin.
 - **CHORE**: publish packages.

## 0.1.0-dev.1

- Initial release of `firebase_messaging_web`.
