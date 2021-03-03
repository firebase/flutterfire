## 2.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 2.0.0-1.0.nullsafety.1

 - Update a dependency to the latest release.

## 2.0.0-1.0.nullsafety.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: migrate to NNBD (#4909).
 - **BREAKING**: the following deprecated APIs have been removed:
   - `iOSNotificationSettings`.
   - `requestNotificationPermissions` - use `requestPermission` instead.
   - `autoInitEnabled()` - use `setAutoInitEnabled()` instead.
   - `deleteInstanceID()` - use `deleteToken()` instead.
   - `FirebaseMessaging()` - use `FirebaseMessaging.instance` instead.


## 1.0.0-dev.10

 - **DOCS**: fix messaging regex examples (#4649).

## 1.0.0-dev.9

 - Update a dependency to the latest release.

## 1.0.0-dev.8

 - **FIX**: cast args lists to string values (#4382).

## 1.0.0-dev.7

 - Update a dependency to the latest release.

## 1.0.0-dev.6

 - **FIX**: various data types issues in remote message (#4150).

## 1.0.0-dev.5

 - Update a dependency to the latest release.

## 1.0.0-dev.4

 - **REFACTOR**: use invokeMapMethod instead of invokeMethod (#4048).

## 1.0.0-dev.3

 - **FEAT**: roadmap rework (#4012).

## 1.0.0-dev.2

 - **FEAT**: add senderId (use iid on Android to support it).

## 1.0.0-dev.1

- Initial release.
