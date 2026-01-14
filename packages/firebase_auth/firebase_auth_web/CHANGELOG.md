## 6.1.1

 - Update a dependency to the latest release.

## 6.1.0

 - **FIX**(auth): fix JS interop lints ([#17802](https://github.com/firebase/flutterfire/issues/17802)). ([0956646a](https://github.com/firebase/flutterfire/commit/0956646a0e1f88cbb416b748b4738a8bd83ad616))
 - **FEAT**(web): add `registerVersion` support for packages ([#17780](https://github.com/firebase/flutterfire/issues/17780)). ([3c8c83d4](https://github.com/firebase/flutterfire/commit/3c8c83d4251f2965ae6fb1fe7b64c21dcb94e9ec))

## 6.0.4

 - Update a dependency to the latest release.

## 6.0.3

 - Update a dependency to the latest release.

## 6.0.2

 - Update a dependency to the latest release.

## 6.0.1

 - Update a dependency to the latest release.

## 6.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**(auth): remove deprecated functions ([#17562](https://github.com/firebase/flutterfire/issues/17562)). ([d50aad95](https://github.com/firebase/flutterfire/commit/d50aad954443904d64d4ebd4442ebc63ed702986))

## 5.15.3

 - Update a dependency to the latest release.

## 5.15.2

 - Update a dependency to the latest release.

## 5.15.1

 - Update a dependency to the latest release.

## 5.15.0

 - **FEAT**(auth): add support for initializeRecaptchaConfig ([#17365](https://github.com/firebase/flutterfire/issues/17365)). ([73f9028e](https://github.com/firebase/flutterfire/commit/73f9028e114874fddc8a4f76f22b247504a95a02))

## 5.14.3

 - Update a dependency to the latest release.

## 5.14.2

 - **FIX**(auth,web): fix an issue that could occur when deleting FirebaseApp ([#17145](https://github.com/firebase/flutterfire/issues/17145)). ([a2246cd0](https://github.com/firebase/flutterfire/commit/a2246cd0ae8a7a53abc2537d7cd66ee079d3b096))

## 5.14.1

 - Update a dependency to the latest release.

## 5.14.0

 - **FEAT**(auth): support for `linkDomain` in `ActionCodeSettings` ([#17099](https://github.com/firebase/flutterfire/issues/17099)). ([090cdb20](https://github.com/firebase/flutterfire/commit/090cdb2078dc66e58aa4b1a3ef9a48101467b6ac))

## 5.13.8

 - Update a dependency to the latest release.

## 5.13.7

 - Update a dependency to the latest release.

## 5.13.6

 - Update a dependency to the latest release.

## 5.13.5

 - Update a dependency to the latest release.

## 5.13.4

 - Update a dependency to the latest release.

## 5.13.3

 - Update a dependency to the latest release.

## 5.13.2

 - Update a dependency to the latest release.

## 5.13.1

 - Update a dependency to the latest release.

## 5.13.0

 - **FIX**: (auth) TypeError when converting ActionCodeSettings to JS ([#13260](https://github.com/firebase/flutterfire/issues/13260)). ([6969e48a](https://github.com/firebase/flutterfire/commit/6969e48a632a69bb071b80102d3cc2cfc53736a6))
 - **FEAT**(web): update to `web: ^1.0.0` ([#13200](https://github.com/firebase/flutterfire/issues/13200)). ([8fab04ae](https://github.com/firebase/flutterfire/commit/8fab04aec3b95789856d95639131bf09db29175b))

## 5.12.6

 - **DOCS**: remove reference to flutter.io and firebase.flutter.dev ([#13152](https://github.com/firebase/flutterfire/issues/13152)). ([5f0874b9](https://github.com/firebase/flutterfire/commit/5f0874b91e28a203dd62d37d391e5760c91f5729))

## 5.12.5

 - Update a dependency to the latest release.

## 5.12.4

 - **FIX**(auth,web): ensure exact same streams are not unsubscribed ([#13033](https://github.com/firebase/flutterfire/issues/13033)). ([111f5f64](https://github.com/firebase/flutterfire/commit/111f5f647b0b3d9b6c932a6e491a22602d71197c))

## 5.12.3

 - Update a dependency to the latest release.

## 5.12.2

 - **FIX**(auth,web): unsubscribe from stream handlers after "hot restart" ([#12908](https://github.com/firebase/flutterfire/issues/12908)). ([a76c8866](https://github.com/firebase/flutterfire/commit/a76c8866c7f62dd62764f147f114f42f4137b66d))
 - **FIX**(auth,web): stream handlers are properly cleaned up and recreated ([#12903](https://github.com/firebase/flutterfire/issues/12903)). ([daaef12c](https://github.com/firebase/flutterfire/commit/daaef12c7cf0f403bbe2b4bc2210f3db2c33125b))

## 5.12.1

 - **FIX**(web): fix some casting issue on Web JS Interop ([#12852](https://github.com/firebase/flutterfire/issues/12852)). ([4b56df1c](https://github.com/firebase/flutterfire/commit/4b56df1cc187d77ef22a82688a37f1c7aba4ed40))

## 5.12.0

 - **FEAT**(auth): update Pigeon version to 19 ([#12828](https://github.com/firebase/flutterfire/issues/12828)). ([5e76153f](https://github.com/firebase/flutterfire/commit/5e76153fbcd337a26e83abc2b43b651ab6c501bc))

## 5.11.6

 - **FIX**(auth,web): get auth credential from exception and pass to user if one is available ([#12780](https://github.com/firebase/flutterfire/issues/12780)). ([39f6e7bd](https://github.com/firebase/flutterfire/commit/39f6e7bd7843178f72052ad5e08e66a5c6ba7908))

## 5.11.5

 - Update a dependency to the latest release.

## 5.11.4

 - **FIX**(web): fixing some incorrect type casting for Web ([#12696](https://github.com/firebase/flutterfire/issues/12696)). ([471b5072](https://github.com/firebase/flutterfire/commit/471b507265a08bbc68277d3a2fdb7ef608c9efcc))

## 5.11.3

 - **FIX**(auth,web): fix verifyPhoneNumber by using jsify() to convert phone options to javascript ([#12681](https://github.com/firebase/flutterfire/issues/12681)). ([967aa5d2](https://github.com/firebase/flutterfire/commit/967aa5d2a86b238314ab58857999110b17bd34bc))
 - **FIX**(auth,web): invocation of unsubscribe callback for dart2wasm compatibility. ([#12669](https://github.com/firebase/flutterfire/issues/12669)). ([2b84feb1](https://github.com/firebase/flutterfire/commit/2b84feb1b6ec32b1a3605824ed1370b08912184c))

## 5.11.2

 - Update a dependency to the latest release.

## 5.11.1

 - **FIX**(web): fix typing conversion for Maps ([#12615](https://github.com/firebase/flutterfire/issues/12615)). ([2cc16189](https://github.com/firebase/flutterfire/commit/2cc161898573736216dbf6cba25c4951e571fa13))
 - **FIX**(auth,web): fix an issue that could prevent Recaptcha from being properly initialized ([#12589](https://github.com/firebase/flutterfire/issues/12589)). ([8ce9162c](https://github.com/firebase/flutterfire/commit/8ce9162c78d4634b9b3f9ea839f9500e1be5947f))

## 5.11.0

 - **FEAT**(web): remove the dependency on `package:js` in favor of `dart:js_interop` ([#12534](https://github.com/firebase/flutterfire/issues/12534)). ([d83f6327](https://github.com/firebase/flutterfire/commit/d83f632753707c974fef2ac8a7f9bf6cb8ba8758))

## 5.10.1

 - Update a dependency to the latest release.

## 5.10.0

 - **FEAT**: update `web` package to 0.5.1 ([#12469](https://github.com/firebase/flutterfire/issues/12469)). ([f5c4354a](https://github.com/firebase/flutterfire/commit/f5c4354a66377da9d231c5e3fc7e955ddb7ef8cf))

## 5.9.8

 - Update a dependency to the latest release.

## 5.9.7

 - Update a dependency to the latest release.

## 5.9.6

 - **REFACTOR**(auth,web): update error handling to ensure stack traces are preserved. ([#12392](https://github.com/firebase/flutterfire/issues/12392)). ([280dcb3d](https://github.com/firebase/flutterfire/commit/280dcb3d77ab5688258fe9d75fa69dd2424fda98))
 - **FIX**(auth,web): lower SDK minimum version constraint to "3.2.0" ([#12369](https://github.com/firebase/flutterfire/issues/12369)). ([fa412b44](https://github.com/firebase/flutterfire/commit/fa412b448247224adedf2b770faeeea462f3c5d4))

## 5.9.5

 - **FIX**(auth,web): flutter `3.19.0` interop broke auth persistence setting. Updated the way we initialise JS Map inline with latest interop. ([#12338](https://github.com/firebase/flutterfire/issues/12338)). ([9d5480f8](https://github.com/firebase/flutterfire/commit/9d5480f8f943d095dd3ca94d4868ec75bed84b22))
 - **FIX**(auth,web): `signInWithEmailAndPassword()` throwing with incorrect exception code ([#12310](https://github.com/firebase/flutterfire/issues/12310)). ([004f6d41](https://github.com/firebase/flutterfire/commit/004f6d4195801359583f047c1909f55205125840))

## 5.9.4

 - Update a dependency to the latest release.

## 5.9.3

 - **FIX**(auth,web): fix null safety issue in typing JS Interop for OAuthCredential ([#12270](https://github.com/firebase/flutterfire/issues/12270)). ([7de58e43](https://github.com/firebase/flutterfire/commit/7de58e438337355f51a144868a0843bdc2e73f6e))
 - **FIX**(core,web): fix Recaptcha instantiation error ([#12268](https://github.com/firebase/flutterfire/issues/12268)). ([de2fe990](https://github.com/firebase/flutterfire/commit/de2fe99063d2919e2c109f355f3cf41afdf1f626))

## 5.9.2

 - **FIX**(auth,web): fix null safety issue in typing JS Interop ([#12250](https://github.com/firebase/flutterfire/issues/12250)). ([d0d30405](https://github.com/firebase/flutterfire/commit/d0d30405a895ae221603ddd158b1cb1636312fb4))

## 5.9.1

 - Update a dependency to the latest release.

## 5.9.0

 - **FEAT**(firestore,web): migrate web to js_interop to be compatible with WASM ([#12169](https://github.com/firebase/flutterfire/issues/12169)). ([57ebd529](https://github.com/firebase/flutterfire/commit/57ebd529de5def2bab1557a1bd9967ee4267c08a))
 - **FEAT**(auth,web): migrate web to js_interop to be compatible with WASM ([#12145](https://github.com/firebase/flutterfire/issues/12145)). ([8d2df7a1](https://github.com/firebase/flutterfire/commit/8d2df7a1b2198797e9c95c45efaf21b4e5bfe766))

## 5.8.13

 - **FIX**(auth,web): fix typing of `getRedirectResult` on Web, preventing a crash ([#12036](https://github.com/firebase/flutterfire/issues/12036)). ([52c53f5c](https://github.com/firebase/flutterfire/commit/52c53f5c470aeca32e652cb0d477c5fc2bba7812))

## 5.8.12

 - Update a dependency to the latest release.

## 5.8.11

 - Update a dependency to the latest release.

## 5.8.10

 - Update a dependency to the latest release.

## 5.8.9

 - Update a dependency to the latest release.

## 5.8.8

 - **FIX**(auth,web): use the device language when using `setLanguageCode` with null ([#11905](https://github.com/firebase/flutterfire/issues/11905)). ([f9322b6f](https://github.com/firebase/flutterfire/commit/f9322b6f25cd9520c5e033361e63a4db3f375a15))

## 5.8.7

 - Update a dependency to the latest release.

## 5.8.6

 - Update a dependency to the latest release.

## 5.8.5

 - Update a dependency to the latest release.

## 5.8.4

 - Update a dependency to the latest release.

## 5.8.3

 - Update a dependency to the latest release.

## 5.8.2

 - Update a dependency to the latest release.

## 5.8.1

 - **FIX**(auth): deprecate `FirebaseAuth.instanceFor`'s `persistence` parameter ([#11259](https://github.com/firebase/flutterfire/issues/11259)). ([a1966e82](https://github.com/firebase/flutterfire/commit/a1966e82c15f13119cb28a262a57c67b4f2b8d3b))

## 5.8.0

 - **FIX**(firebase_auth): Update the position of the auth parameter for `RecaptchaVerifier` in the interop code to reflect changes in `firebase-js-sdk` ([#11514](https://github.com/firebase/flutterfire/issues/11514)). ([a836dba1](https://github.com/firebase/flutterfire/commit/a836dba186b0765745a8e81a04229fe8fd8f96b2))
 - **FEAT**(auth): TOTP (time-based one-time password) support for multi-factor authentication ([#11420](https://github.com/firebase/flutterfire/issues/11420)). ([3cc1243c](https://github.com/firebase/flutterfire/commit/3cc1243c94368de44d3a5c4be96b905a0a37b963))

## 5.7.0

 - **FEAT**(auth): `revokeTokenWithAuthorizationCode()` implementation for revoking Apple sign-in token ([#11454](https://github.com/firebase/flutterfire/issues/11454)). ([92de98c9](https://github.com/firebase/flutterfire/commit/92de98c9e62f2bf20712dbfed22dd39f6883eb58))

## 5.6.3

 - Update a dependency to the latest release.

## 5.6.2

 - **FIX**(auth,web): convert `NativeError` to `FirebaseAuthError` ([#11258](https://github.com/firebase/flutterfire/issues/11258)). ([b95c3807](https://github.com/firebase/flutterfire/commit/b95c38075cd3b48395d56f3fea38e5be32b21a06))

## 5.6.1

 - **FIX**(auth,web): fix an issue preventing Web to properly parse providerData ([#11301](https://github.com/firebase/flutterfire/issues/11301)). ([08299050](https://github.com/firebase/flutterfire/commit/08299050db0fc3a849e35fb4a1a600d643ce5ffe))

## 5.6.0

 - **FIX**(auth,web): add guarding to error casting in useEmulator ([#11247](https://github.com/firebase/flutterfire/issues/11247)). ([aca20481](https://github.com/firebase/flutterfire/commit/aca204814bc2463818fe5114bce8ff23876ec7e1))
 - **FEAT**(auth): move to Pigeon for Platform channels ([#10802](https://github.com/firebase/flutterfire/issues/10802)). ([43e5b20b](https://github.com/firebase/flutterfire/commit/43e5b20b14799102a6544a4763476eaba44b9cfb))

## 5.5.3

 - **FIX**(core): Omit unnecessary libraries for web ([#10068](https://github.com/firebase/flutterfire/issues/10068)). ([8659d4ed](https://github.com/firebase/flutterfire/commit/8659d4ed805ac92964c2c92d55192f6ef40d721a))

## 5.5.2

 - Update a dependency to the latest release.

## 5.5.1

 - Update a dependency to the latest release.

## 5.5.0

 - **FEAT**: update dependency constraints to `sdk: '>=2.18.0 <4.0.0'` `flutter: '>=3.3.0'` ([#10946](https://github.com/firebase/flutterfire/issues/10946)). ([2772d10f](https://github.com/firebase/flutterfire/commit/2772d10fe510dcc28ec2d37a26b266c935699fa6))
 - **FEAT**: update libraries to be compatible with Flutter 3.10.0 ([#10944](https://github.com/firebase/flutterfire/issues/10944)). ([e1f5a5ea](https://github.com/firebase/flutterfire/commit/e1f5a5ea798c54f19d1d2f7b8f2250f8819f44b7))

## 5.4.0

 - **FEAT**: upgrade to dart 3 compatible dependencies ([#10890](https://github.com/firebase/flutterfire/issues/10890)). ([4bd7e59b](https://github.com/firebase/flutterfire/commit/4bd7e59b1f2b09a2230c49830159342dd4592041))

## 5.3.2

 - Update a dependency to the latest release.

## 5.3.1

 - **FIX**(auth,web): fix support for hot reload with multiple named instances when using an emulator on Web ([#10766](https://github.com/firebase/flutterfire/issues/10766)). ([b5de275d](https://github.com/firebase/flutterfire/commit/b5de275d9278e4be04d25c6f5f512fbcd53a103b))

## 5.3.0

 - **FEAT**: bump dart sdk constraint to 2.18 ([#10618](https://github.com/firebase/flutterfire/issues/10618)). ([f80948a2](https://github.com/firebase/flutterfire/commit/f80948a28b62eead358bdb900d5a0dfb97cebb33))

## 5.2.10

 - **FIX**(auth): fix an issue where unenroll would not throw a FirebaseException ([#10572](https://github.com/firebase/flutterfire/issues/10572)). ([8dba33e1](https://github.com/firebase/flutterfire/commit/8dba33e1a95f03d70d527885aa58ce23622e359f))

## 5.2.9

 - **FIX**(auth,web): fix currentUser being null when using emulator or named instance ([#10565](https://github.com/firebase/flutterfire/issues/10565)). ([11e8644d](https://github.com/firebase/flutterfire/commit/11e8644df402a5abbb0d0c37714879272dec024c))

## 5.2.8

 - Update a dependency to the latest release.

## 5.2.7

 - Update a dependency to the latest release.

## 5.2.6

 - Update a dependency to the latest release.

## 5.2.5

 - Update a dependency to the latest release.

## 5.2.4

 - Update a dependency to the latest release.

## 5.2.3

 - revert dependency `Intl` to 0.17.0

## 5.2.2

 - Update a dependency to the latest release.

## 5.2.1

 - Update a dependency to the latest release.

## 5.2.0

 - **FIX**: properly cast the PlatformException to FirebaseAuthException ([#10058](https://github.com/firebase/flutterfire/issues/10058)). ([6c8f9515](https://github.com/firebase/flutterfire/commit/6c8f951552ba7f767ce1b7b7ea5328454ba28cce))
 - **FIX**: `currentUser` is now populated right at the start of the application without needing to wait for `authStateChange` ([#10028](https://github.com/firebase/flutterfire/issues/10028)). ([2bd0dbff](https://github.com/firebase/flutterfire/commit/2bd0dbffb081370da051ec52859b924e1cf06fca))
 - **FEAT**: add SAMLProvider support to Web ([#10075](https://github.com/firebase/flutterfire/issues/10075)). ([d4c27da1](https://github.com/firebase/flutterfire/commit/d4c27da1589c07f890e67fa11f10e277f19e1570))

## 5.1.3

 - **FIX**: catch hot reload & hot restart exception for web emulator ([#9601](https://github.com/firebase/flutterfire/issues/9601)). ([3467483b](https://github.com/firebase/flutterfire/commit/3467483be993a65f76203400721dc07e0729cac3))

## 5.1.2

 - Update a dependency to the latest release.

## 5.1.1

 - **FIX**: use correct UTC time from server for _webUser.metadata.creationTime & _webUser.metadata.lastSignInTime ([#9789](https://github.com/firebase/flutterfire/issues/9789)). ([44ac2a36](https://github.com/firebase/flutterfire/commit/44ac2a3665a1006d444b4725c131ad4f084fe3d1))

## 5.1.0

 - **FIX**: properly propagate the `FirebaseAuthMultiFactorException` for all reauthenticate and link methods ([#9700](https://github.com/firebase/flutterfire/issues/9700)). ([9ad97c82](https://github.com/firebase/flutterfire/commit/9ad97c82ead0f5c6f1307625374c34e0dcde730b))
 - **FEAT**: expose reauthenticateWithRedirect and reauthenticateWithPopup ([#9696](https://github.com/firebase/flutterfire/issues/9696)). ([2a1f910f](https://github.com/firebase/flutterfire/commit/2a1f910ff6cab21a126c62fd4322a14ec263b629))

## 5.0.2

 - Update a dependency to the latest release.

## 5.0.1

- Update a dependency to the latest release.

## 5.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: Firebase iOS SDK version: `10.0.0` ([#9708](https://github.com/firebase/flutterfire/issues/9708)). ([9627c56a](https://github.com/firebase/flutterfire/commit/9627c56a37d657d0250b6f6b87d0fec1c31d4ba3))

## 4.6.1

 - Update a dependency to the latest release.

## 4.6.0

 - **FEAT**: add OAuth Access Token support to sign in with providers ([#9593](https://github.com/firebase/flutterfire/issues/9593)). ([cb6661bb](https://github.com/firebase/flutterfire/commit/cb6661bbc701031d6f920ace3a6efc8e8d56aa4c))
 - **FEAT**: add `linkWithRedirect` to the web ([#9580](https://github.com/firebase/flutterfire/issues/9580)). ([d834b90f](https://github.com/firebase/flutterfire/commit/d834b90f29fc1929a195d7d546170e4ea03c6ab1))

## 4.5.0

 - **FEAT**: add `reauthenticateWithProvider` ([#9570](https://github.com/firebase/flutterfire/issues/9570)). ([dad6b481](https://github.com/firebase/flutterfire/commit/dad6b4813c682e35315dda3965ea8aaf5ba030e8))

## 4.4.1

 - Update a dependency to the latest release.

## 4.4.0

 - **FIX**: fix enrollementTimestamp parsing on Web ([#9440](https://github.com/firebase/flutterfire/issues/9440)). ([639cab7b](https://github.com/firebase/flutterfire/commit/639cab7b84aa33cc1dda144fc89db2236a1945b2))
 - **FEAT**: add Yahoo as provider for iOS, Android and Web ([#9443](https://github.com/firebase/flutterfire/issues/9443)). ([6c3108a7](https://github.com/firebase/flutterfire/commit/6c3108a767aca3b1a844b2b5da04b2da45bc9fbd))

## 4.3.0

 - **FEAT**: add Microsoft login for Android, iOS and Web ([#9415](https://github.com/firebase/flutterfire/issues/9415)). ([1610ce8a](https://github.com/firebase/flutterfire/commit/1610ce8ac96d6da202ef014e9a3dfeb4acfacec9))
 - **FEAT**: add Sign in with Apple directly in Firebase Auth for Android, iOS 13+ and Web ([#9408](https://github.com/firebase/flutterfire/issues/9408)). ([da36b986](https://github.com/firebase/flutterfire/commit/da36b9861b7d635382705b4893eed85fd672125c))

## 4.2.4

 - Update a dependency to the latest release.

## 4.2.3

 - Update a dependency to the latest release.

## 4.2.2

 - Update a dependency to the latest release.

## 4.2.1

 - **FIX**: restore default persistence to IndexedDB that was incorrectly set to localStorage ([#9247](https://github.com/firebase/flutterfire/issues/9247)). ([785c4869](https://github.com/firebase/flutterfire/commit/785c4869a45be039d3f1b1473380a1d08609c28e))

## 4.2.0

 - **FIX**: pass `Persistence` value to `FirebaseAuth.instanceFor(app: app, persistence: persistence)` for setting persistence on Web platform ([#9138](https://github.com/firebase/flutterfire/issues/9138)). ([ae7ebaf8](https://github.com/firebase/flutterfire/commit/ae7ebaf8e304a2676b2acfa68aadf0538468b4a0))
 - **FEAT**: expose the missing MultiFactor classes through the universal package ([#9194](https://github.com/firebase/flutterfire/issues/9194)). ([d8bf8185](https://github.com/firebase/flutterfire/commit/d8bf818528c3705350cdb1b4675d600ba1d29d14))

## 4.1.1

 - **FIX**: provide `browserPopupRedirectResolver` on init ([#9146](https://github.com/firebase/flutterfire/issues/9146)). ([bf1d9be1](https://github.com/firebase/flutterfire/commit/bf1d9be11a59475be173b01184efb53d92d152fe))

## 4.1.0

 - **FEAT**: add all providers available to MFA ([#9159](https://github.com/firebase/flutterfire/issues/9159)). ([5a03a859](https://github.com/firebase/flutterfire/commit/5a03a859385f0b06ad9afe8e8c706c046976b8d8))
 - **FEAT**: add phone MFA ([#9044](https://github.com/firebase/flutterfire/issues/9044)). ([1b85c8b7](https://github.com/firebase/flutterfire/commit/1b85c8b7fbcc3f21767f23981cb35061772d483f))

## 4.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: upgrade auth web to Firebase v9 JS SDK ([#8236](https://github.com/firebase/flutterfire/issues/8236)). ([8e95a51d](https://github.com/firebase/flutterfire/commit/8e95a51d99ffc5fec106d933e46c9f331c1e2d50))
 - **BREAKING**: Cannot set `updateDisplayName()` or `updatePhotoURL()` to `null` on web anymore.

## 3.3.19

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

## 3.3.18

 - **FIX**: Web recaptcha hover removed after use. (#8812). ([790e450e](https://github.com/firebase/flutterfire/commit/790e450e8d6acd2fc50e0232c77a152430c7b3ea))

## 3.3.17

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

## 3.3.16

 - Update a dependency to the latest release.

## 3.3.15

 - Update a dependency to the latest release.

## 3.3.14

 - Update a dependency to the latest release.

## 3.3.13

 - Update a dependency to the latest release.

## 3.3.12

 - Update a dependency to the latest release.

## 3.3.11

 - **FIX**: Allow `rawNonce` to be passed through on web via the `OAuthCredential`. (#8410). ([0df32f61](https://github.com/firebase/flutterfire/commit/0df32f6106ca41cdb95c36c7816e6487124937d4))

## 3.3.10

 - **FIX**: Check if `UserMetadata` properties are `null` before parsing. (#8313). ([cac41fb9](https://github.com/firebase/flutterfire/commit/cac41fb9ddd5462b57f9d17615f387478f10d3dc))

## 3.3.9

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

## 3.3.8

 - Update a dependency to the latest release.

## 3.3.7

 - **FIX**: Add support for`dynamicLinkDomain` property to `ActionCodeSetting` for web. (#7683). ([3b0bf76e](https://github.com/firebase/flutterfire/commit/3b0bf76e015c95840b2d38eec7f12c001d3bd47c))

## 3.3.6

 - Update a dependency to the latest release.

## 3.3.5

 - Update a dependency to the latest release.

## 3.3.4

 - Update a dependency to the latest release.

## 3.3.3

 - Update a dependency to the latest release.

## 3.3.2

 - Update a dependency to the latest release.

## 3.3.1

 - Update a dependency to the latest release.

## 3.3.0

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

## 3.2.0

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

## 3.1.4

 - Update a dependency to the latest release.

## 3.1.3

 - Update a dependency to the latest release.

## 3.1.2

 - **FIX**: null-safety migration issue for web types (#7137).

## 3.1.1

 - **FIX**: allow setLanguage to accept null (#7050).

## 3.1.0

 - **FEAT**: Add support for `secret` on `OAuthCredential` on web (#6830).
 - **FEAT**: expose linkWithPopup() & correctly parse credentials in exceptions (#6562).

## 3.0.1

 - Update a dependency to the latest release.

## 3.0.0

> Note: This release has breaking changes.

 - **FEAT**: setSettings now possible for android (#6367).
 - **CHORE**: catch native error verifyBeforeUpdateEmail() (#6473).
 - **BREAKING** **FEAT**: use<product>Emulator(host, port) API update (#6439).

## 2.0.0

> Note: This release has breaking changes.

 - **FEAT**: setSettings now possible for android (#6367).
 - **CHORE**: catch native error verifyBeforeUpdateEmail() (#6473).
 - **BREAKING** **FEAT**: useAuthEmulator(host, port) API update.

## 1.3.1

 - Update a dependency to the latest release.

## 1.3.0

 - **FEAT**: add tenantId support  (#5736).

## 1.2.0

 - **FEAT**: add User.updateDisplayName and User.updatePhotoURL (#6213).

## 1.1.3

 - Update a dependency to the latest release.

## 1.1.2

 - **DOCS**: Add missing homepage/repository links (#6054).
 - **CHORE**: publish packages (#6022).
 - **CHORE**: publish packages.

## 1.1.1

 - Update a dependency to the latest release.

## 1.1.0

 - **FEAT**: OAuthProvider.parameters is now non-nullable (#5656).

## 1.0.7

 - **FIX**: ensure web is initialized before sending stream events (#5766).
 - **CHORE**: update Web plugins to use Firebase JS SDK version 8.4.1 (#4464).

## 1.0.6

 - Update a dependency to the latest release.

## 1.0.5

 - Update a dependency to the latest release.

## 1.0.4

 - Update a dependency to the latest release.

## 1.0.3

 - Update a dependency to the latest release.

## 1.0.2

 - Update a dependency to the latest release.

## 1.0.1

 - **FIX**: correct use of underlying useEmulator API, sync not async (#5171).

## 1.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.0.0-1.0.nullsafety.0

 - Bump "firebase_auth_web" to `1.0.0-1.0.nullsafety.0`.

## 0.4.0-1.1.nullsafety.3

 - Update a dependency to the latest release.

## 0.4.0-1.1.nullsafety.2

 - Update a dependency to the latest release.

## 0.4.0-1.1.nullsafety.1

 - **REFACTOR**: pubspec & dependency updates (#4932).

## 0.4.0-1.1.nullsafety.0

 - **FEAT**: implement support for `useEmulator` (#4263).

## 0.4.0-1.0.nullsafety.0

 - **FIX**: bump firebase_core_* package versions to updated NNBD versioning format (#4832).

## 0.4.0-nullsafety.1

Bump firebase_auth_platform_interface to v4.0.0-nullsafety.1

## 0.4.0-nullsafety.0

Migrated to null safety (#4633)

## 0.3.2+6

 - Update a dependency to the latest release.

## 0.3.2+5

 - **FIX**: Revert #4312: Double event fire on initialization (#4620).

## 0.3.2+4

 - **FIX**: bubble exceptions (#3700).

## 0.3.2+3

 - **FIX**: web now fires once on authStateListener initialisation (#4312).

## 0.3.2+2

 - Update a dependency to the latest release.

## 0.3.2+1

 - Update a dependency to the latest release.

## 0.3.2

 - **FEAT**: migrate firebase interop files to local repository (#3973).
 - **FEAT** [WEB] adds support for `EmailAuthProvider.credentialWithLink`
 - **FEAT** [WEB] adds support for `FirebaseAuth.setSettings`
 - **FEAT** [WEB] adds support for `User.tenantId`
 - **FEAT** [WEB] `FirebaseAuthException` now supports `email` & `credential` properties
 - **FEAT** [WEB] `ActionCodeInfo` now supports `previousEmail` field

## 0.3.1+2

 - Update a dependency to the latest release.

## 0.3.1+1

 - Update a dependency to the latest release.

## 0.3.1

 - **FIX**: fix IdTokenResult timestamps (web, ios) (#3357).
 - **FIX**: force locale timestamp conversion (#3320).
 - **FIX**: implement missing web confirmPasswordReset (#3344).
 - **FIX**: send userPlatform on changes (#3313).
 - **FEAT**: add support for linkWithPhoneNumber (#3436).
 - **FEAT**: use named arguments for ActionCodeSettings (#3269).
 - **FEAT**: implement signInWithPhoneNumber on web (#3205).

## 0.3.0+1

* Bump `firebase_auth_platform_interface` dependency to fix an assertion issue when creating Google sign-in credentials.

## 0.3.0

* See the `firebase_auth` plugin changelog.
* Depend on `firebase_core`.

## 0.1.3+1

* Implement `confirmPasswordReset`.

## 0.1.3

* Update lower bound of dart dependency to 2.0.0.

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
