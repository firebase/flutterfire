## 0.4.1+3

 - Update a dependency to the latest release.

## 0.4.1+2

 - Update a dependency to the latest release.

## 0.4.1+1

 - **FIX**(app_check): Deprecate androidProvider and appleProvider parameters in activate method ([#17742](https://github.com/firebase/flutterfire/issues/17742)). ([4e7f800e](https://github.com/firebase/flutterfire/commit/4e7f800e94a895c6553bd3c1595b4f06ac69bb81))
 - **FIX**(app_check): Expose AppleAppAttestProvider without importing platform interface ([#17740](https://github.com/firebase/flutterfire/issues/17740)). ([6c2355a0](https://github.com/firebase/flutterfire/commit/6c2355a05d6bba763768ce3bc09c3cc0528fa900))

## 0.4.1

 - **FEAT**(app-check): Debug token support for the activate method ([#17723](https://github.com/firebase/flutterfire/issues/17723)). ([3c638264](https://github.com/firebase/flutterfire/commit/3c638264565d902ddbe4dff5bb027aef9e1c2140))

## 0.4.0+1

 - **FIX**(app_check,iOS): correctly parse `forceRefresh` argument using `boolValue` ([#17627](https://github.com/firebase/flutterfire/issues/17627)). ([8c0802d0](https://github.com/firebase/flutterfire/commit/8c0802d098c970740a34e83952f56dbe9eb279fd))

## 0.4.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: bump iOS SDK to version 12.0.0 ([#17549](https://github.com/firebase/flutterfire/issues/17549)). ([b2619e68](https://github.com/firebase/flutterfire/commit/b2619e685fec897513483df1d7be347b64f95606))
 - **BREAKING** **FEAT**(app-check): remove deprecated functions ([#17561](https://github.com/firebase/flutterfire/issues/17561)). ([3e4302c4](https://github.com/firebase/flutterfire/commit/3e4302c4281d1d39c140ff116643d700cd3c5ace))
 - **BREAKING** **FEAT**: bump Android SDK to version 34.0.0 ([#17554](https://github.com/firebase/flutterfire/issues/17554)). ([a5bdc051](https://github.com/firebase/flutterfire/commit/a5bdc051d40ee44e39cf0b8d2a7801bc6f618b67))

## 0.3.2+10

 - Update a dependency to the latest release.

## 0.3.2+9

 - Update a dependency to the latest release.

## 0.3.2+8

 - Update a dependency to the latest release.

## 0.3.2+7

 - Update a dependency to the latest release.

## 0.3.2+6

 - Update a dependency to the latest release.

## 0.3.2+5

 - Update a dependency to the latest release.

## 0.3.2+4

 - Update a dependency to the latest release.

## 0.3.2+3

 - Update a dependency to the latest release.

## 0.3.2+2

 - Update a dependency to the latest release.

## 0.3.2+1

 - Update a dependency to the latest release.

## 0.3.2


 - **FEAT**(app-check): Swift Package Manager support ([#16810](https://github.com/firebase/flutterfire/issues/16810)). ([f2e3f396](https://github.com/firebase/flutterfire/commit/f2e3f3965e83a6bf8c52c1cd9f80509a08907a84))

## 0.3.1+7

 - Update a dependency to the latest release.

## 0.3.1+6

 - Update a dependency to the latest release.

## 0.3.1+5

 - Update a dependency to the latest release.

## 0.3.1+4

 - Update a dependency to the latest release.

## 0.3.1+3

 - **FIX**(all,apple): use modular headers to import ([#13400](https://github.com/firebase/flutterfire/issues/13400)). ([d7d2d4b9](https://github.com/firebase/flutterfire/commit/d7d2d4b93e7c00226027fffde46699f3d5388a41))

## 0.3.1+2

 - Update a dependency to the latest release.

## 0.3.1+1

 - Update a dependency to the latest release.

## 0.3.1

 - **FEAT**(firestore,web): expose `webExperimentalForceLongPolling`, `webExperimentalAutoDetectLongPolling` and `timeoutSeconds` on web ([#13201](https://github.com/firebase/flutterfire/issues/13201)). ([6ec2a103](https://github.com/firebase/flutterfire/commit/6ec2a103a3a325a73550bdfff4c0d524ae7e4068))

## 0.3.0+5

 - **DOCS**: remove reference to flutter.io and firebase.flutter.dev ([#13152](https://github.com/firebase/flutterfire/issues/13152)). ([5f0874b9](https://github.com/firebase/flutterfire/commit/5f0874b91e28a203dd62d37d391e5760c91f5729))

## 0.3.0+4

 - Update a dependency to the latest release.

## 0.3.0+3

 - Update a dependency to the latest release.

## 0.3.0+2

 - Update a dependency to the latest release.

## 0.3.0+1

 - **FIX**(app-check,web): fixed broken `onTokenChanged` and ensured it is properly cleaned up. Streams are also cleaned up on "hot restart" ([#12933](https://github.com/firebase/flutterfire/issues/12933)). ([093b5fef](https://github.com/firebase/flutterfire/commit/093b5fef8c3b8314835dc954ce02daacd1e077f4))
 - **FIX**(firebase_app_check,ios): Replace angles with quotes in import statement ([#12929](https://github.com/firebase/flutterfire/issues/12929)). ([f2fc902b](https://github.com/firebase/flutterfire/commit/f2fc902b9e954baf9d72bd3863a85bde402d2133))
 - **FIX**(app-check,ios): update app check to stable release ([#12924](https://github.com/firebase/flutterfire/issues/12924)). ([ced11684](https://github.com/firebase/flutterfire/commit/ced1168482c3b8e8b4746abde13649d212a503fd))

## 0.3.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: android plugins require `minSdk 21`, auth requires `minSdk 23` ahead of android BOM `>=33.0.0` ([#12873](https://github.com/firebase/flutterfire/issues/12873)). ([52accfc6](https://github.com/firebase/flutterfire/commit/52accfc6c39d6360d9c0f36efe369ede990b7362))
 - **BREAKING** **REFACTOR**: bump all iOS deployment targets to iOS 13 ahead of Firebase iOS SDK `v11` breaking change ([#12872](https://github.com/firebase/flutterfire/issues/12872)). ([de0cea2c](https://github.com/firebase/flutterfire/commit/de0cea2c3c36694a76361be784255986fac84a43))

## 0.2.2+7

 - Update a dependency to the latest release.

## 0.2.2+6

 - Update a dependency to the latest release.

## 0.2.2+5

 - Update a dependency to the latest release.

## 0.2.2+4

 - Update a dependency to the latest release.

## 0.2.2+3

 - Update a dependency to the latest release.

## 0.2.2+2

 - Update a dependency to the latest release.

## 0.2.2+1

 - **FIX**(app-check,android): fix unnecessary deprecation warning ([#12578](https://github.com/firebase/flutterfire/issues/12578)). ([805ca028](https://github.com/firebase/flutterfire/commit/805ca028d20c582e93bcebbeca3105deab365edc))

## 0.2.2

 - **FEAT**(android): Bump `compileSdk` version of Android plugins to latest stable (34) ([#12566](https://github.com/firebase/flutterfire/issues/12566)). ([e891fab2](https://github.com/firebase/flutterfire/commit/e891fab291e9beebc223000b133a6097e066a7fc))

## 0.2.1+19

 - **REFACTOR**(app_check,web): small refactor around initialisation of FirebaseAppCheckWeb ([#12474](https://github.com/firebase/flutterfire/issues/12474)). ([83aab7f8](https://github.com/firebase/flutterfire/commit/83aab7f8f6a6dde6e71765826c0e1f9aabc110a0))

## 0.2.1+18

 - Update a dependency to the latest release.

## 0.2.1+17

 - Update a dependency to the latest release.

## 0.2.1+16

 - Update a dependency to the latest release.

## 0.2.1+15

 - Update a dependency to the latest release.

## 0.2.1+14

 - Update a dependency to the latest release.

## 0.2.1+13

 - Update a dependency to the latest release.

## 0.2.1+12

 - Update a dependency to the latest release.

## 0.2.1+11

 - Update a dependency to the latest release.

## 0.2.1+10

 - Update a dependency to the latest release.

## 0.2.1+9

 - Update a dependency to the latest release.

## 0.2.1+8

 - Update a dependency to the latest release.

## 0.2.1+7

 - Update a dependency to the latest release.

## 0.2.1+6

 - Update a dependency to the latest release.

## 0.2.1+5

 - Update a dependency to the latest release.

## 0.2.1+4

 - Update a dependency to the latest release.

## 0.2.1+3

 - Update a dependency to the latest release.

## 0.2.1+2

 - Update a dependency to the latest release.

## 0.2.1+1

 - Update a dependency to the latest release.

## 0.2.1

 - **REFACTOR**(app-check,android): update linting warnings ([#11666](https://github.com/firebase/flutterfire/issues/11666)). ([fa9c8181](https://github.com/firebase/flutterfire/commit/fa9c8181156697a96b2615906b24613f28346175))
 - **FIX**(firebase_app_check): Allow non-default app for Android debug provider ([#11680](https://github.com/firebase/flutterfire/issues/11680)). ([dd20c0c7](https://github.com/firebase/flutterfire/commit/dd20c0c7413dd9c9cd4c54426afc2572f9438607))
 - **FEAT**: Full support of AGP 8 ([#11699](https://github.com/firebase/flutterfire/issues/11699)). ([bdb5b270](https://github.com/firebase/flutterfire/commit/bdb5b27084d225809883bdaa6aa5954650551927))
 - **FEAT**(app_check): Use Android dependencies from Firebase BOM ([#11671](https://github.com/firebase/flutterfire/issues/11671)). ([378fcbdc](https://github.com/firebase/flutterfire/commit/378fcbdc4909e448d47cc204147a2ecd978b4fb7))
 - **DOCS**: Updated documentation link in firebase_app_check README.md ([#11712](https://github.com/firebase/flutterfire/issues/11712)). ([dd3e56c6](https://github.com/firebase/flutterfire/commit/dd3e56c67a2ddad0a11043f00e9d80544d36355a))

## 0.2.0+1

 - Update a dependency to the latest release.

## 0.2.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**(app-check,web): support for `ReCaptchaEnterpriseProvider`. User facing API updated. ([#11573](https://github.com/firebase/flutterfire/issues/11573)). ([09825edd](https://github.com/firebase/flutterfire/commit/09825edd0e1ecd609e2046fdefda439ce4099087))

## 0.1.5+2

 - Update a dependency to the latest release.

## 0.1.5+1

 - Update a dependency to the latest release.

## 0.1.5

 - **FEAT**(app-check): support for `getLimitedUseToken()` API ([#11091](https://github.com/firebase/flutterfire/issues/11091)). ([9db9326f](https://github.com/firebase/flutterfire/commit/9db9326fe503c31299c9685449150e809543974e))

## 0.1.4+3

 - Update a dependency to the latest release.

## 0.1.4+2

 - Update a dependency to the latest release.

## 0.1.4+1

 - Update a dependency to the latest release.

## 0.1.4

 - **FEAT**: update dependency constraints to `sdk: '>=2.18.0 <4.0.0'` `flutter: '>=3.3.0'` ([#10946](https://github.com/firebase/flutterfire/issues/10946)). ([2772d10f](https://github.com/firebase/flutterfire/commit/2772d10fe510dcc28ec2d37a26b266c935699fa6))
 - **FEAT**: update libraries to be compatible with Flutter 3.10.0 ([#10944](https://github.com/firebase/flutterfire/issues/10944)). ([e1f5a5ea](https://github.com/firebase/flutterfire/commit/e1f5a5ea798c54f19d1d2f7b8f2250f8819f44b7))

## 0.1.3

 - **FIX**: add support for AGP 8.0 ([#10901](https://github.com/firebase/flutterfire/issues/10901)). ([a3b96735](https://github.com/firebase/flutterfire/commit/a3b967354294c295a9be8d699a6adb7f4b1dba7f))
 - **FEAT**: upgrade to dart 3 compatible dependencies ([#10890](https://github.com/firebase/flutterfire/issues/10890)). ([4bd7e59b](https://github.com/firebase/flutterfire/commit/4bd7e59b1f2b09a2230c49830159342dd4592041))

## 0.1.2+3

 - **FIX**(app-check): use correct `getAppCheckToken()` method. Print out debug token for iOS. ([#10819](https://github.com/firebase/flutterfire/issues/10819)). ([66909a9c](https://github.com/firebase/flutterfire/commit/66909a9c5b10e85f93565cbc308fdbee4ec6f607))

## 0.1.2+2

 - Update a dependency to the latest release.

## 0.1.2+1

 - **FIX**(app-check): fix 'Semantic Issue (Xcode): `new` is unavailable' on XCode 14.3 ([#10734](https://github.com/firebase/flutterfire/issues/10734)). ([cc6d1c28](https://github.com/firebase/flutterfire/commit/cc6d1c28193d5cdaaa564729340c380b5f632982))

## 0.1.2

 - **FEAT**: bump dart sdk constraint to 2.18 ([#10618](https://github.com/firebase/flutterfire/issues/10618)). ([f80948a2](https://github.com/firebase/flutterfire/commit/f80948a28b62eead358bdb900d5a0dfb97cebb33))

## 0.1.1+14

 - Update a dependency to the latest release.

## 0.1.1+13

 - Update a dependency to the latest release.

## 0.1.1+12

 - Update a dependency to the latest release.

## 0.1.1+11

 - Update a dependency to the latest release.

## 0.1.1+10

 - Update a dependency to the latest release.

## 0.1.1+9

 - Update a dependency to the latest release.

## 0.1.1+8

 - Update a dependency to the latest release.

## 0.1.1+7

 - Update a dependency to the latest release.

## 0.1.1+6

 - Update a dependency to the latest release.

## 0.1.1+5

 - Update a dependency to the latest release.

## 0.1.1+4

 - Update a dependency to the latest release.

## 0.1.1+3

 - Update a dependency to the latest release.

## 0.1.1+2

 - **REFACTOR**: add `verify` to `QueryPlatform` and change internal `verifyToken` API to `verify` ([#9711](https://github.com/firebase/flutterfire/issues/9711)). ([c99a842f](https://github.com/firebase/flutterfire/commit/c99a842f3e3f5f10246e73f51530cc58c42b49a3))

## 0.1.1+1

 - Update a dependency to the latest release.

## 0.1.1

- Update a dependency to the latest release.

## 0.1.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: Firebase iOS SDK version: `10.0.0` ([#9708](https://github.com/firebase/flutterfire/issues/9708)). ([9627c56a](https://github.com/firebase/flutterfire/commit/9627c56a37d657d0250b6f6b87d0fec1c31d4ba3))

## 0.0.9+1

 - Update a dependency to the latest release.

## 0.0.9

 - **FEAT**: provide `androidDebugProvider` boolean for android debug provider & update app check example app ([#9412](https://github.com/firebase/flutterfire/issues/9412)). ([f1f26748](https://github.com/firebase/flutterfire/commit/f1f26748615c7c9d406e1d3d605e2987e1134ee7))

## 0.0.8

 - **FEAT**: provide `androidDebugProvider` boolean for android debug provider & update app check example app ([#9412](https://github.com/firebase/flutterfire/issues/9412)). ([f1f26748](https://github.com/firebase/flutterfire/commit/f1f26748615c7c9d406e1d3d605e2987e1134ee7))

## 0.0.7+2

 - Update a dependency to the latest release.

## 0.0.7+1

 - Update a dependency to the latest release.

## 0.0.7

 - **FEAT**: update the example app with webRecaptcha in activate button ([#9373](https://github.com/firebase/flutterfire/issues/9373)). ([1ff76c1b](https://github.com/firebase/flutterfire/commit/1ff76c1b87b623ff21c921d6a6cc2c586cf43ac3))
 - **REFACTOR**: update deprecated `Tasks.call()` to `TaskCompletionSource` API ([#9404](https://github.com/firebase/flutterfire/pull/9404)). ([837d68ea](https://github.com/firebase/flutterfire/commit/5aa9f665e70297fecb88bd0fda5445753470660f))

## 0.0.6+20

 - Update a dependency to the latest release.

## 0.0.6+19

 - Update a dependency to the latest release.

## 0.0.6+18

 - Update a dependency to the latest release.

## 0.0.6+17

 - Update a dependency to the latest release.

## 0.0.6+16

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

## 0.0.6+15

 - **DOCS**: separate the first sentence of a doc comment into its own paragraph for `getToken()` (#8968). ([4d487ef7](https://github.com/firebase/flutterfire/commit/4d487ef7abdb9a8333735ced9c40438fef9912a3))

## 0.0.6+14

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8727). ([41a963b3](https://github.com/firebase/flutterfire/commit/41a963b376ae4ec23e1394bc074f8feee6ae16b2))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

## 0.0.6+13

 - **DOCS**: use camel case style for "FlutterFire" in `README.md` (#8747). ([e2a022d7](https://github.com/firebase/flutterfire/commit/e2a022d7427817002e4114eb7434aa6e53384891))

## 0.0.6+12

 - Update a dependency to the latest release.

## 0.0.6+11

 - Update a dependency to the latest release.

## 0.0.6+10

 - Update a dependency to the latest release.

## 0.0.6+9

 - Update a dependency to the latest release.

## 0.0.6+8

 - Update a dependency to the latest release.

## 0.0.6+7

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

## 0.0.6+6

 - Update a dependency to the latest release.

## 0.0.6+5

 - **FIX**: workaround iOS build issue when targeting platforms < iOS 11. ([c78e0b79](https://github.com/firebase/flutterfire/commit/c78e0b79bde479e78c558d3df92988c130280e81))

## 0.0.6+4

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726). ([a9562bac](https://github.com/firebase/flutterfire/commit/a9562bac60ba927fb3664a47a7f7eaceb277dca6))

## 0.0.6+3

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8. ([7f0e82c9](https://github.com/firebase/flutterfire/commit/7f0e82c978a3f5a707dd95c7e9136a3e106ff75e))

## 0.0.6+2

 - Update a dependency to the latest release.

## 0.0.6+1

 - Update a dependency to the latest release.

## 0.0.6

 - **FEAT**: add token apis and documentation (#7419).

## 0.0.5

- **NEW**: Added support for multi-app via the `instanceFor()` method.
- **NEW**: Added support for getting the current App Check token via the `getToken()` method.
- **NEW**: Added support for enabling automatic token refreshing via the `setTokenAutoRefreshEnabled()` method.
- **NEW**: Added support for subscribing to token change events (as a `Stream`) via `onTokenChange`.

## 0.0.4

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

## 0.0.3

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

## 0.0.2+4

 - Update a dependency to the latest release.

## 0.0.2+3

 - Update a dependency to the latest release.

## 0.0.2+2

 - Update a dependency to the latest release.

## 0.0.2+1

 - **DOCS**: using for version `0.0.1` the same markdown headline level as the other versions have in the changelog (#6845).

## 0.0.2

 - **STYLE**: enable additional lint rules (#6832).
 - **FEAT**: lower iOS & macOS deployment targets for relevant plugins (#6757).

## 0.0.1+3

 - Update a dependency to the latest release.

## 0.0.1+2

 - Update a dependency to the latest release.

## 0.0.1+1

 - Update a dependency to the latest release.

## 0.0.1

 - Initial release.
