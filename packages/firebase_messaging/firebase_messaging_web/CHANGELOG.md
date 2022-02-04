## 2.2.7

 - **FIX**: Make Web `deleteToken()` API a Future so it resolves only when completed. (#7687). ([cf59bd38](https://github.com/FirebaseExtended/flutterfire/commit/cf59bd380a495a0390d8c14a63498ba1600f9f12))

## 2.2.6

 - Update a dependency to the latest release.

## 2.2.5

 - Update a dependency to the latest release.

## 2.2.4

 - **FIX**: messaging `isSupported()` check on web should be used lazily in `_delegate` (fixes #7511). ([9a3d1d93](https://github.com/FirebaseExtended/flutterfire/commit/9a3d1d9300c49ccdffa90b8193269badd79d2c9b))

## 2.2.3

 - Update a dependency to the latest release.

## 2.2.2

 - Update a dependency to the latest release.

## 2.2.1

 - Update a dependency to the latest release.

## 2.2.0

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

## 2.1.0

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

## 2.0.8

 - Update a dependency to the latest release.

## 2.0.7

 - Update a dependency to the latest release.

## 2.0.6

 - Update a dependency to the latest release.

## 2.0.5

 - Update a dependency to the latest release.

## 2.0.4

 - Update a dependency to the latest release.

## 2.0.3

 - Update a dependency to the latest release.

## 2.0.2

 - Update a dependency to the latest release.

## 2.0.1

 - Update a dependency to the latest release.

## 2.0.0

> Note: This release has breaking changes.

 - **FEAT**: implement isSupported for web (#6109).
 - **BREAKING** **REFACTOR**: remove support for `senderId` named argument on `getToken` & `deleteToken` methods since the native Firebase SDKs no longer support it cross-platform.

## 1.0.7

 - **DOCS**: Add missing homepage/repository links (#6054).

## 1.0.6

 - Update a dependency to the latest release.

## 1.0.5

 - **REFACTOR**: Share guard functions accross plugins (#5783).

## 1.0.4

 - Update a dependency to the latest release.

## 1.0.3

 - **FIX**: Fix broken homepage link (#4713).
 - **CHORE**: bump min Dart SDK constraint to 2.12.0 (#5430).
 - **CHORE**: publish packages (#5429).

## 1.0.2

 - **FIX**: Fix broken homepage link (#4713).

## 1.0.1

 - Update a dependency to the latest release.

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
