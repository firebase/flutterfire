## 3.2.15

 - Update a dependency to the latest release.

## 3.2.14

 - Update a dependency to the latest release.

## 3.2.13

 - Update a dependency to the latest release.

## 3.2.12

 - Update a dependency to the latest release.

## 3.2.11

 - Update a dependency to the latest release.

## 3.2.10

 - Update a dependency to the latest release.

## 3.2.9

 - Update a dependency to the latest release.

## 3.2.8

 - **FIX**: Retrieve `messageId` from `MessagePayload` received on message event for Web platform. ([#7846](https://github.com/firebase/flutterfire/issues/7846)). ([d796d33f](https://github.com/firebase/flutterfire/commit/d796d33f722d92404217f9b153c301ab4e50b370))

## 3.2.7

 - Update a dependency to the latest release.

## 3.2.6

 - Update a dependency to the latest release.

## 3.2.5

 - Update a dependency to the latest release.

## 3.2.4

 - Update a dependency to the latest release.

## 3.2.3

 - Update a dependency to the latest release.

## 3.2.2

 - Update a dependency to the latest release.

## 3.2.1

 - Update a dependency to the latest release.

## 3.2.0

 - **FEAT**: add support for exporting delivery metrics to BigQuery ([#9636](https://github.com/firebase/flutterfire/issues/9636)). ([170b99b9](https://github.com/firebase/flutterfire/commit/170b99b91573f28316172e43188d57ca14600446))

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

 - **FEAT**: Added 'criticalAlert' to notification settings. ([#9004](https://github.com/firebase/flutterfire/issues/9004)). ([4c425f27](https://github.com/firebase/flutterfire/commit/4c425f27595a6784e80d98ee0879c3fe6a5fe907))

## 3.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: upgrade messaging web to Firebase v9 JS SDK. ([#8860](https://github.com/firebase/flutterfire/issues/8860)). ([f3a6bdc5](https://github.com/firebase/flutterfire/commit/f3a6bdc5fd2441ed3c77a9d0ece0d6460afd2ec4))
 - **BREAKING**: `isSupported()` API is now asynchronous and returns `Future<bool>`. It is web only and will always resolve to `true` on other platforms.

## 2.4.4

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

## 2.4.3

 - Update a dependency to the latest release.

## 2.4.2

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

## 2.4.1

 - Update a dependency to the latest release.

## 2.4.0

 - **FEAT**: retrieve `timeSensitiveSetting` for iOS 15+. ([#8532](https://github.com/firebase/flutterfire/issues/8532)). ([14b38da3](https://github.com/firebase/flutterfire/commit/14b38da31f364ad35be20c5df9cd633c613d8067))

## 2.3.0

 - **FEAT**: retrieve `timeSensitiveSetting` for iOS 15+. (#8532). ([14b38da3](https://github.com/firebase/flutterfire/commit/14b38da31f364ad35be20c5df9cd633c613d8067))

## 2.2.13

 - Update a dependency to the latest release.

## 2.2.12

 - Update a dependency to the latest release.

## 2.2.11

 - Update a dependency to the latest release.

## 2.2.10

 - Update a dependency to the latest release.

## 2.2.9

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

## 2.2.8

 - Update a dependency to the latest release.

## 2.2.7

 - **FIX**: Make Web `deleteToken()` API a Future so it resolves only when completed. (#7687). ([cf59bd38](https://github.com/firebase/flutterfire/commit/cf59bd380a495a0390d8c14a63498ba1600f9f12))

## 2.2.6

 - Update a dependency to the latest release.

## 2.2.5

 - Update a dependency to the latest release.

## 2.2.4

 - **FIX**: messaging `isSupported()` check on web should be used lazily in `_delegate` (fixes #7511). ([9a3d1d93](https://github.com/firebase/flutterfire/commit/9a3d1d9300c49ccdffa90b8193269badd79d2c9b))

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

 - **FIX**: null check fix that could happen when using verifyPhone notification jsObject (#4624).

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
