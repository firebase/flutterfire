## 3.1.6

 - Update a dependency to the latest release.

## 3.1.5

 - Update a dependency to the latest release.

## 3.1.4

 - Update a dependency to the latest release.

## 3.1.3

 - Update a dependency to the latest release.

## 3.1.2

 - Update a dependency to the latest release.

## 3.1.1

 - Update a dependency to the latest release.

## 3.1.0

 - **FEAT**: add support for `RemoteMessage` on web (#7430).

## 3.0.9

 - Update a dependency to the latest release.

## 3.0.8

 - **FIX**: Add Android implementation to get notification permissions (#7168).

## 3.0.7

 - Update a dependency to the latest release.

## 3.0.6

 - Update a dependency to the latest release.

## 3.0.5

 - Update a dependency to the latest release.

## 3.0.4

 - **STYLE**: enable additional lint rules (#6832).
 - **FIX**: critical of sound causing a hidden error (#6505).

## 3.0.3

 - Update a dependency to the latest release.

## 3.0.2

 - Update a dependency to the latest release.

## 3.0.1

 - **FIX**: Fix FirebaseMessaging.onMessage and onMessageOpenedApp potentially throwing (#6093).

## 3.0.0

> Note: This release has breaking changes.

 - **FEAT**: implement isSupported for web (#6109).
 - **BREAKING** **REFACTOR**: remove support for `senderId` named argument on `getToken` & `deleteToken` methods since the native Firebase SDKs no longer support it cross-platform.

## 2.1.4

 - **DOCS**: Add missing homepage/repository links (#6054).

## 2.1.3

 - Update a dependency to the latest release.

## 2.1.2

 - Update a dependency to the latest release.

## 2.1.1

 - **FIX**: APN message with critical sound causing a hidden error (#5653).
 - **FIX**: fix getNotificationSettings for null safety (#5518).

## 2.1.0

 - **FIX**: regression in `RemoteMessage.fromMap()` causing silent failure (#5336).
 - **FEAT**: android.tag property on Notification (#5452).
 - **CHORE**: bump min Dart SDK constraint to 2.12.0 (#5430).
 - **CHORE**: publish packages (#5429).
 - **CHORE**: publish packages.

## 2.0.1

 - **FIX**: regression in `RemoteMessage.fromMap()` causing silent failure (#5336).
 - **CHORE**: publish packages.

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
