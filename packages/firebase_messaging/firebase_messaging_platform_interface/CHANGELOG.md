## 4.2.14

 - Update a dependency to the latest release.

## 4.2.13

 - Update a dependency to the latest release.

## 4.2.12

 - Update a dependency to the latest release.

## 4.2.11

 - Update a dependency to the latest release.

## 4.2.10

 - Update a dependency to the latest release.

## 4.2.9

 - Update a dependency to the latest release.

## 4.2.8

 - Update a dependency to the latest release.

## 4.2.7

 - Update a dependency to the latest release.

## 4.2.6

 - Update a dependency to the latest release.

## 4.2.5

 - Update a dependency to the latest release.

## 4.2.4

 - **REFACTOR**: add `verify` to `QueryPlatform` and change internal `verifyToken` API to `verify` ([#9711](https://github.com/firebase/flutterfire/issues/9711)). ([c99a842f](https://github.com/firebase/flutterfire/commit/c99a842f3e3f5f10246e73f51530cc58c42b49a3))

## 4.2.3

 - Update a dependency to the latest release.

## 4.2.2

 - Update a dependency to the latest release.

## 4.2.1

 - Update a dependency to the latest release.

## 4.2.0

 - **FEAT**: add support for exporting delivery metrics to BigQuery ([#9636](https://github.com/firebase/flutterfire/issues/9636)). ([170b99b9](https://github.com/firebase/flutterfire/commit/170b99b91573f28316172e43188d57ca14600446))

## 4.1.6

 - Update a dependency to the latest release.

## 4.1.5

 - Update a dependency to the latest release.

## 4.1.4

 - Update a dependency to the latest release.

## 4.1.3

 - Update a dependency to the latest release.

## 4.1.2

 - Update a dependency to the latest release.

## 4.1.1

 - Update a dependency to the latest release.

## 4.1.0

 - **FEAT**: Added 'criticalAlert' to notification settings. ([#9004](https://github.com/firebase/flutterfire/issues/9004)). ([4c425f27](https://github.com/firebase/flutterfire/commit/4c425f27595a6784e80d98ee0879c3fe6a5fe907))

## 4.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: upgrade messaging web to Firebase v9 JS SDK. ([#8860](https://github.com/firebase/flutterfire/issues/8860)). ([f3a6bdc5](https://github.com/firebase/flutterfire/commit/f3a6bdc5fd2441ed3c77a9d0ece0d6460afd2ec4))
 - **BREAKING**: `isSupported()` API is now asynchronous and returns `Future<bool>`. It is web only and will always resolve to `true` on other platforms.

## 3.5.4

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

## 3.5.3

 - Update a dependency to the latest release.

## 3.5.2

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

## 3.5.1

 - Update a dependency to the latest release.

## 3.5.0

 - **FEAT**: retrieve `timeSensitiveSetting` for iOS 15+. ([#8532](https://github.com/firebase/flutterfire/issues/8532)). ([14b38da3](https://github.com/firebase/flutterfire/commit/14b38da31f364ad35be20c5df9cd633c613d8067))

## 3.4.0

 - **FEAT**: retrieve `timeSensitiveSetting` for iOS 15+. (#8532). ([14b38da3](https://github.com/firebase/flutterfire/commit/14b38da31f364ad35be20c5df9cd633c613d8067))

## 3.3.1

 - **FIX**: prevent isolate callback removal during split debug symbols (#8521). ([45ca7aeb](https://github.com/firebase/flutterfire/commit/45ca7aeb50920cea0ba5784e16a5b78adac014f3))

## 3.3.0

 - **FEAT**: add `toMap()` method to `RemoteMessage` and its properties (#8453). ([047cccda](https://github.com/firebase/flutterfire/commit/047cccda6fe8e53c77e8e1f368e5f2c5d7d297e1))

## 3.2.3

 - Update a dependency to the latest release.

## 3.2.2

 - Update a dependency to the latest release.

## 3.2.1

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

## 3.2.0

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

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
