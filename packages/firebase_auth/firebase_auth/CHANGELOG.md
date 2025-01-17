## 5.4.0


 - **FIX**: Remove dart:io imports for analytics, auth and app check ([#16827](https://github.com/firebase/flutterfire/issues/16827)). ([8c7f57c4](https://github.com/firebase/flutterfire/commit/8c7f57c4a181b8cae3b0d2ba564682ad7d68f484))
 - **FIX**(firebase_auth): Fix `std::variant` compiler errors with VS 2022 17.12 ([#16840](https://github.com/firebase/flutterfire/issues/16840)). ([b88b71f4](https://github.com/firebase/flutterfire/commit/b88b71f45c856eb0ff2d2caefb8b6aa367e91418))
 - **FEAT**(auth): Swift Package Manager support ([#16773](https://github.com/firebase/flutterfire/issues/16773)). ([69abbe19](https://github.com/firebase/flutterfire/commit/69abbe19bb37e6eb450b0b5123a74c2d68a761c7))

## 5.3.4

 - **FIX**(auth,android): `signInWithProvider()` for non-default instances ([#13522](https://github.com/firebase/flutterfire/issues/13522)). ([fe016a44](https://github.com/firebase/flutterfire/commit/fe016a4487993c8aa444e15c9881fe355b5f6624))

## 5.3.3

 - Update a dependency to the latest release.

## 5.3.2

 - **FIX**(auth,apple): set nullability on pigeon parser method ([#13571](https://github.com/firebase/flutterfire/issues/13571)). ([7e8a1b2e](https://github.com/firebase/flutterfire/commit/7e8a1b2e5be454b168d942056c4abb7f8e92a9a8))

## 5.3.1

 - **FIX**(all,apple): use modular headers to import ([#13400](https://github.com/firebase/flutterfire/issues/13400)). ([d7d2d4b9](https://github.com/firebase/flutterfire/commit/d7d2d4b93e7c00226027fffde46699f3d5388a41))

## 5.3.0

 - **FEAT**(fdc): Initial Release of Data Connect ([#13313](https://github.com/firebase/flutterfire/issues/13313)). ([603a6726](https://github.com/firebase/flutterfire/commit/603a67261a2f7cbdd6ef594bfaef480aeb820683))

## 5.2.1

 - Update a dependency to the latest release.

## 5.2.0

 - **FEAT**: bump iOS SDK to version 11.0.0 ([#13158](https://github.com/firebase/flutterfire/issues/13158)). ([c0e0c997](https://github.com/firebase/flutterfire/commit/c0e0c99703ea394d1bb873ac225c5fe3539b002d))
 - **DOCS**: remove reference to flutter.io and firebase.flutter.dev ([#13152](https://github.com/firebase/flutterfire/issues/13152)). ([5f0874b9](https://github.com/firebase/flutterfire/commit/5f0874b91e28a203dd62d37d391e5760c91f5729))

## 5.1.4

 - **FIX**(firebase_auth): added supporting rawNonce for OAuth credential on Windows platform ([#13086](https://github.com/firebase/flutterfire/issues/13086)). ([12e87de9](https://github.com/firebase/flutterfire/commit/12e87de93ddc39d41a6a634d7d03766b3e36996a))

## 5.1.3

 - **DOCS**(auth): add information about error codes for email/password functions ([#13100](https://github.com/firebase/flutterfire/issues/13100)). ([aeafc356](https://github.com/firebase/flutterfire/commit/aeafc356953a0531003f765e766ffcff2387401d))

## 5.1.2

 - **DOCS**(auth): add information about error codes for `verifyBeforeUpdateEmail` ([#13036](https://github.com/firebase/flutterfire/issues/13036)). ([8ef7421d](https://github.com/firebase/flutterfire/commit/8ef7421d6a524938087769537ac70ec249096ed4))

## 5.1.1

 - **FIX**(auth,apple): bug with cached `AuthCredential`, hash key was producing different value ([#12957](https://github.com/firebase/flutterfire/issues/12957)). ([ef0077e3](https://github.com/firebase/flutterfire/commit/ef0077e37744360264eb60d6eea4359a5cc13227))
 - **FIX**(auth,windows): fix a crash that could happen when using `sendEmailVerification` or `sendPasswordResetEmail` ([#12946](https://github.com/firebase/flutterfire/issues/12946)). ([a1008290](https://github.com/firebase/flutterfire/commit/a100829087dbf83ea59e73c3811d87b67e2a4012))
 - **DOCS**: Update documentation for auth/user-not-found exception to reflect email enumeration protection ([#12964](https://github.com/firebase/flutterfire/issues/12964)). ([125f8209](https://github.com/firebase/flutterfire/commit/125f820971331ec75e7fe59cff3b296c42c7d8f3))

## 5.1.0

 - **FIX**(auth,ios): fix the parsing of an error that could specifically happen when using MicrosoftProvider ([#12920](https://github.com/firebase/flutterfire/issues/12920)). ([3b415e64](https://github.com/firebase/flutterfire/commit/3b415e641e6107b131a170277bbc1fa0e2908e27))
 - **FEAT**(auth,apple): create a credential with `idToken`, `rawNonce` & `appleFullPersonName` ([#12356](https://github.com/firebase/flutterfire/issues/12356)). ([17793080](https://github.com/firebase/flutterfire/commit/177930802ca13a3af1610968e54b8ce79f0781ca))

## 5.0.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: android plugins require `minSdk 21`, auth requires `minSdk 23` ahead of android BOM `>=33.0.0` ([#12873](https://github.com/firebase/flutterfire/issues/12873)). ([52accfc6](https://github.com/firebase/flutterfire/commit/52accfc6c39d6360d9c0f36efe369ede990b7362))
 - **BREAKING** **REFACTOR**: bump all iOS deployment targets to iOS 13 ahead of Firebase iOS SDK `v11` breaking change ([#12872](https://github.com/firebase/flutterfire/issues/12872)). ([de0cea2c](https://github.com/firebase/flutterfire/commit/de0cea2c3c36694a76361be784255986fac84a43))
 - **BREAKING** **REFACTOR**(auth): remove deprecated API ahead of breaking change release ([#12859](https://github.com/firebase/flutterfire/issues/12859)). ([995fa7e1](https://github.com/firebase/flutterfire/commit/995fa7e19540fe52ba75a66865823c8ca86b6657))

## 4.20.0

 - **FIX**(auth,android): remove unecessary error type guarding ([#12816](https://github.com/firebase/flutterfire/issues/12816)). ([7d4c200a](https://github.com/firebase/flutterfire/commit/7d4c200ac6f06a50c2e7ee852aea2c9fa7bcb0ff))
 - **FEAT**(auth,windows): `verifyBeforeUpdateEmail()` API  support ([#12825](https://github.com/firebase/flutterfire/issues/12825)). ([111b1ad9](https://github.com/firebase/flutterfire/commit/111b1ad91e985b0462532bc579e64342b7f46fe2))
 - **FEAT**(auth): update Pigeon version to 19 ([#12828](https://github.com/firebase/flutterfire/issues/12828)). ([5e76153f](https://github.com/firebase/flutterfire/commit/5e76153fbcd337a26e83abc2b43b651ab6c501bc))
 - **FEAT**: bump CPP SDK to version 11.10.0 ([#12749](https://github.com/firebase/flutterfire/issues/12749)). ([2e410a23](https://github.com/firebase/flutterfire/commit/2e410a232758292baa70f8e78464bd3c62ec0373))

## 4.19.6

 - **FIX**(auth,android): allow nullable `accessToken` when creating `OAuthProvider` ([#12795](https://github.com/firebase/flutterfire/issues/12795)). ([490319d4](https://github.com/firebase/flutterfire/commit/490319d4c046917bdd227c19fd37185d63076b4a))

## 4.19.5

 - **FIX**(auth,windows): allow `idToken` and `accessToken` to be nullable to stop windows crashing for `signInWithCredential()` ([#12688](https://github.com/firebase/flutterfire/issues/12688)). ([ca9f92d0](https://github.com/firebase/flutterfire/commit/ca9f92d05f717b46c80307987f560454b90a4d67))

## 4.19.4

 - Update a dependency to the latest release.

## 4.19.3

 - **FIX**(auth,ios): Give more details on internal error when calling `sendSignInLinkToEmail`. ([#12671](https://github.com/firebase/flutterfire/issues/12671)). ([2b086029](https://github.com/firebase/flutterfire/commit/2b0860296bf577c99810643bb286b7219ee9291f))

## 4.19.2

 - Update a dependency to the latest release.

## 4.19.1

 - Update a dependency to the latest release.

## 4.19.0

 - **FEAT**(android): Bump `compileSdk` version of Android plugins to latest stable (34) ([#12566](https://github.com/firebase/flutterfire/issues/12566)). ([e891fab2](https://github.com/firebase/flutterfire/commit/e891fab291e9beebc223000b133a6097e066a7fc))

## 4.18.0

 - **FIX**(auth,android): fixing an issue that could cause `getEnrolledFactors` to return an empty list if signing out in the same app session ([#12488](https://github.com/firebase/flutterfire/issues/12488)). ([04280a31](https://github.com/firebase/flutterfire/commit/04280a31310dbbe51a8e619f031f5190d02e695d))
 - **FEAT**(firebase_auth): add custom auth domain setter to Firebase Auth ([#12218](https://github.com/firebase/flutterfire/issues/12218)). ([e1297800](https://github.com/firebase/flutterfire/commit/e12978009e0fd785f267db560972ab0bbe021fcb))
 - **FEAT**(auth,windows): add support for oAuth with credentials on Windows ([#12154](https://github.com/firebase/flutterfire/issues/12154)). ([cc708e6f](https://github.com/firebase/flutterfire/commit/cc708e6fdce6053772da0f08c9872e1dbe9899b1))

## 4.17.9

 - Update a dependency to the latest release.

## 4.17.8

 - Update a dependency to the latest release.

## 4.17.7

 - Update a dependency to the latest release.

## 4.17.6

 - Update a dependency to the latest release.

## 4.17.5

 - Update a dependency to the latest release.

## 4.17.4

 - Update a dependency to the latest release.

## 4.17.3

 - Update a dependency to the latest release.

## 4.17.2

 - **FIX**(auth,web): fix null safety issue in typing JS Interop ([#12250](https://github.com/firebase/flutterfire/issues/12250)). ([d0d30405](https://github.com/firebase/flutterfire/commit/d0d30405a895ae221603ddd158b1cb1636312fb4))

## 4.17.1

 - Update a dependency to the latest release.

## 4.17.0

 - **FIX**(auth): deprecate `updateEmail()` & `fetchSignInMethodsForEmail()` ([#12143](https://github.com/firebase/flutterfire/issues/12143)). ([dcfd9e80](https://github.com/firebase/flutterfire/commit/dcfd9e801c3231d17821355df5865b179cf0bf11))
 - **FEAT**(auth,apple): Game Center sign-in support ([#12228](https://github.com/firebase/flutterfire/issues/12228)). ([ac625ec7](https://github.com/firebase/flutterfire/commit/ac625ec7a2ceb8c7ef78180f3bcaa8294cf06a2e))
 - **FEAT**(auth,android): Play Games provider sign-in support ([#12201](https://github.com/firebase/flutterfire/issues/12201)). ([1fb9019d](https://github.com/firebase/flutterfire/commit/1fb9019de1fd832223aa56139d98c1194b2d5efa))
 - **FEAT**(auth,windows): add support for `creationTime` and `lastSignInTime` ([#12116](https://github.com/firebase/flutterfire/issues/12116)). ([387e9434](https://github.com/firebase/flutterfire/commit/387e94343a237d0976bdfa4f5c0e20c6922456fa))

## 4.16.0

 - **FIX**(auth,windows): fix a parsing issue of the Pigeon message on Windows for sendPasswordResetEmail ([#12082](https://github.com/firebase/flutterfire/issues/12082)). ([17c4ab12](https://github.com/firebase/flutterfire/commit/17c4ab128650c8e7a4f7e3cea0c55d1fea0998fd))
 - **FEAT**: allow users to disable automatic host mapping ([#11962](https://github.com/firebase/flutterfire/issues/11962)). ([13c1ce33](https://github.com/firebase/flutterfire/commit/13c1ce333b8cd113241a1f7ac07181c1c76194bc))

## 4.15.3

 - **FIX**(auth): return email address if one is returned by the auth exception ([#11978](https://github.com/firebase/flutterfire/issues/11978)). ([ceee304d](https://github.com/firebase/flutterfire/commit/ceee304dd87cd66e34a7f7fa67c9961b72c10e72))

## 4.15.2

 - Update a dependency to the latest release.

## 4.15.1

 - Update a dependency to the latest release.

## 4.15.0

 - **FEAT**(auth): add support for custom domains on mobile ([#11925](https://github.com/firebase/flutterfire/issues/11925)). ([552119c7](https://github.com/firebase/flutterfire/commit/552119c78e2750a929c6226de22f9f6d8df948a4))

## 4.14.1

 - **FIX**(auth,apple): need to cache `AuthCredential` on native in case Dart exception passes `AuthCredential` back to user for sign-in ([#11889](https://github.com/firebase/flutterfire/issues/11889)). ([9c09f224](https://github.com/firebase/flutterfire/commit/9c09f22416f549e3b80bc7e618b07c1c3c24ee31))
 - **FIX**(auth,web): use the device language when using `setLanguageCode` with null ([#11905](https://github.com/firebase/flutterfire/issues/11905)). ([f9322b6f](https://github.com/firebase/flutterfire/commit/f9322b6f25cd9520c5e033361e63a4db3f375a15))
 - **FIX**(auth): add proper error message when trying to access the multifactor object on an unsupported platform ([#11894](https://github.com/firebase/flutterfire/issues/11894)). ([27d1c47d](https://github.com/firebase/flutterfire/commit/27d1c47d1168198e9fa296fcff52feb1f0a345d2))

## 4.14.0

 - **FEAT**(auth,windows): add Windows support for Google Sign In ([#11861](https://github.com/firebase/flutterfire/issues/11861)). ([cde57d05](https://github.com/firebase/flutterfire/commit/cde57d059e099913efc994db27141540a2a981d1))

## 4.13.0

 - **FEAT**(firebase_auth): export `AuthProvider` from `firebase_auth_interface` ([#11470](https://github.com/firebase/flutterfire/issues/11470)). ([39881e7e](https://github.com/firebase/flutterfire/commit/39881e7e4671faa94b274d980aad81829e6e0bfc))
 - **FEAT**(windows): add platform logging for core, auth, firestore and storage ([#11790](https://github.com/firebase/flutterfire/issues/11790)). ([e7d428d1](https://github.com/firebase/flutterfire/commit/e7d428d14be1535a2d579d4b2d376fbb81f06742))

## 4.12.1

 - Update a dependency to the latest release.

## 4.12.0

 - **FEAT**(storage,windows): Add windows support ([#11617](https://github.com/firebase/flutterfire/issues/11617)). ([87ea02c8](https://github.com/firebase/flutterfire/commit/87ea02c8ae03eb351636cf202961ad0df6caebd8))

## 4.11.1

 - **FIX**(ios): fix clashing filenames between Auth and Firestore ([#11731](https://github.com/firebase/flutterfire/issues/11731)). ([8770cafc](https://github.com/firebase/flutterfire/commit/8770cafccccb11607b5530311e3150ac08cd172e))

## 4.11.0

 - **FIX**(auth): ensure `PigeonAuthCredential` is passed back to Dart side within try/catch ([#11683](https://github.com/firebase/flutterfire/issues/11683)). ([d42c3396](https://github.com/firebase/flutterfire/commit/d42c33969b096a9825af21c624f8d93aebede8b2))
 - **FEAT**: Full support of AGP 8 ([#11699](https://github.com/firebase/flutterfire/issues/11699)). ([bdb5b270](https://github.com/firebase/flutterfire/commit/bdb5b27084d225809883bdaa6aa5954650551927))
 - **FEAT**(firestore,windows): add support to Windows ([#11516](https://github.com/firebase/flutterfire/issues/11516)). ([e51d2a2d](https://github.com/firebase/flutterfire/commit/e51d2a2d287f4162f5a67d8200f1bf57fc2afe14))

## 4.10.1

 - Update a dependency to the latest release.

## 4.10.0

 - **FIX**(auth): deprecate `FirebaseAuth.instanceFor`'s `persistence` parameter ([#11259](https://github.com/firebase/flutterfire/issues/11259)). ([a1966e82](https://github.com/firebase/flutterfire/commit/a1966e82c15f13119cb28a262a57c67b4f2b8d3b))
 - **FIX**(auth,apple): `fetchSignInMethodsForEmail` if value is `nil`, pass empty array. ([#11596](https://github.com/firebase/flutterfire/issues/11596)). ([6d261cc9](https://github.com/firebase/flutterfire/commit/6d261cc9a147befbfd203004aff8565492567f58))
 - **FEAT**(core,windows): Change the windows plugin compiling way ([#11594](https://github.com/firebase/flutterfire/issues/11594)). ([3dab95e0](https://github.com/firebase/flutterfire/commit/3dab95e01f7f71680aff84db4e9dccfe1e77643b))
 - **FEAT**(auth,windows): add Windows support to auth plugin ([#11089](https://github.com/firebase/flutterfire/issues/11089)). ([0cedfc85](https://github.com/firebase/flutterfire/commit/0cedfc8580bedd9e21b262537e643dbace0d7114))
 - **DOCS**: firebase_auth description ([#11292](https://github.com/firebase/flutterfire/issues/11292)). ([d9e05713](https://github.com/firebase/flutterfire/commit/d9e057137dffca09ea293b5df7292d7b7b21ca99))
 - **DOCS**(auth): update the incorrect "getting started" link ([#11440](https://github.com/firebase/flutterfire/issues/11440)). ([5db956dc](https://github.com/firebase/flutterfire/commit/5db956dc935dfec5be28e0463f7e8499a20d5577))

## 4.9.0

 - **FEAT**(auth): TOTP (time-based one-time password) support for multi-factor authentication ([#11420](https://github.com/firebase/flutterfire/issues/11420)). ([3cc1243c](https://github.com/firebase/flutterfire/commit/3cc1243c94368de44d3a5c4be96b905a0a37b963))

## 4.8.0

 - **FEAT**(auth): `revokeTokenWithAuthorizationCode()` implementation for revoking Apple sign-in token ([#11454](https://github.com/firebase/flutterfire/issues/11454)). ([92de98c9](https://github.com/firebase/flutterfire/commit/92de98c9e62f2bf20712dbfed22dd39f6883eb58))

## 4.7.3

 - **FIX**(auth): rename import header to "firebase_auth_messages.g.h". ([#11472](https://github.com/firebase/flutterfire/issues/11472)). ([693a6f3c](https://github.com/firebase/flutterfire/commit/693a6f3cba3620933b905a964126406ae6ae3374))
 - **FIX**(firebase_auth): Fix forceRefresh parameter conversion before calling native API ([#11464](https://github.com/firebase/flutterfire/issues/11464)). ([86639876](https://github.com/firebase/flutterfire/commit/86639876b8e9138af740a1c74c122fcdb5c4566d))
 - **FIX**(auth): set the tenant id on iOS `FIRAuth` instance ([#11427](https://github.com/firebase/flutterfire/issues/11427)). ([15f3cf5d](https://github.com/firebase/flutterfire/commit/15f3cf5d9b86f287fac22370ea09abf9e773ea60))
 - **FIX**(firebase_auth,android): Remove implicit default locale used in error message ([#11321](https://github.com/firebase/flutterfire/issues/11321)). ([3a20f41c](https://github.com/firebase/flutterfire/commit/3a20f41c0d8a4d61d789874d7bb16d6ef710c9d1))

## 4.7.2

 - **FIX**(auth): fix MFA issue where the error wouldn't be properly catched ([#11370](https://github.com/firebase/flutterfire/issues/11370)). ([72fef03f](https://github.com/firebase/flutterfire/commit/72fef03f775702aaf9a2ce0c6b31aea2a3c200a9))
 - **FIX**(auth,android): `getIdToken()` `IllegalStateException` crash fix ([#11362](https://github.com/firebase/flutterfire/issues/11362)). ([e925b4c9](https://github.com/firebase/flutterfire/commit/e925b4c9a937d90de0bdfb59ffa005938b3862dd))
 - **FIX**(auth,apple): pass in Firebase auth instance for correct app when using Provider sign in ([#11284](https://github.com/firebase/flutterfire/issues/11284)). ([1cffae79](https://github.com/firebase/flutterfire/commit/1cffae79ded28808ba55f2f4c9c1b47817987999))

## 4.7.1

 - **FIX**(auth,android): Fix crash on Android where detaching from engine ([#11296](https://github.com/firebase/flutterfire/issues/11296)). ([d0a37332](https://github.com/firebase/flutterfire/commit/d0a373323a818d5005a58e95042b7ea3652ead50))
 - **FIX**(auth,ios): fix scoping of import for message.g.h, could cause incompatibility with other packages ([#11300](https://github.com/firebase/flutterfire/issues/11300)). ([91ccc57d](https://github.com/firebase/flutterfire/commit/91ccc57d4b40b1b7a77dc0d871f9ff7d3f24ba13))

## 4.7.0

 - **FEAT**(auth): move to Pigeon for Platform channels ([#10802](https://github.com/firebase/flutterfire/issues/10802)). ([43e5b20b](https://github.com/firebase/flutterfire/commit/43e5b20b14799102a6544a4763476eaba44b9cfb))

## 4.6.3

 - Update a dependency to the latest release.

## 4.6.2

 - Update a dependency to the latest release.

## 4.6.1

 - Update a dependency to the latest release.

## 4.6.0

 - **FEAT**: update dependency constraints to `sdk: '>=2.18.0 <4.0.0'` `flutter: '>=3.3.0'` ([#10946](https://github.com/firebase/flutterfire/issues/10946)). ([2772d10f](https://github.com/firebase/flutterfire/commit/2772d10fe510dcc28ec2d37a26b266c935699fa6))
 - **FEAT**: update librairies to be compatible with Flutter 3.10.0 ([#10944](https://github.com/firebase/flutterfire/issues/10944)). ([e1f5a5ea](https://github.com/firebase/flutterfire/commit/e1f5a5ea798c54f19d1d2f7b8f2250f8819f44b7))

## 4.5.0

 - **FIX**: add support for AGP 8.0 ([#10901](https://github.com/firebase/flutterfire/issues/10901)). ([a3b96735](https://github.com/firebase/flutterfire/commit/a3b967354294c295a9be8d699a6adb7f4b1dba7f))
 - **FEAT**: upgrade to dart 3 compatible dependencies ([#10890](https://github.com/firebase/flutterfire/issues/10890)). ([4bd7e59b](https://github.com/firebase/flutterfire/commit/4bd7e59b1f2b09a2230c49830159342dd4592041))

## 4.4.2

 - Update a dependency to the latest release.

## 4.4.1

 - Update a dependency to the latest release.

## 4.4.0

 - **FEAT**(auth,ios): automatically save the Apple Sign In display name ([#10652](https://github.com/firebase/flutterfire/issues/10652)). ([257f1ffb](https://github.com/firebase/flutterfire/commit/257f1ffbce7abd458df91d8e4b6422d83b5b849f))
 - **FEAT**: bump dart sdk constraint to 2.18 ([#10618](https://github.com/firebase/flutterfire/issues/10618)). ([f80948a2](https://github.com/firebase/flutterfire/commit/f80948a28b62eead358bdb900d5a0dfb97cebb33))

## 4.3.0

 - **FIX**(auth): fix an issue where unenroll would not throw a FirebaseException ([#10572](https://github.com/firebase/flutterfire/issues/10572)). ([8dba33e1](https://github.com/firebase/flutterfire/commit/8dba33e1a95f03d70d527885aa58ce23622e359f))
 - **FEAT**(auth): improve error handling when Email enumeration feature is on ([#10591](https://github.com/firebase/flutterfire/issues/10591)). ([ff083025](https://github.com/firebase/flutterfire/commit/ff083025b724d683cc3a9ed5f4a4987c43663589))

## 4.2.10

 - **FIX**(auth,web): fix currentUser being null when using emulator or named instance ([#10565](https://github.com/firebase/flutterfire/issues/10565)). ([11e8644d](https://github.com/firebase/flutterfire/commit/11e8644df402a5abbb0d0c37714879272dec024c))

## 4.2.9

 - Update a dependency to the latest release.

## 4.2.8

 - Update a dependency to the latest release.

## 4.2.7

 - Update a dependency to the latest release.

## 4.2.6

 - **REFACTOR**: upgrade project to remove warnings from Flutter 3.7 ([#10344](https://github.com/firebase/flutterfire/issues/10344)). ([e0087c84](https://github.com/firebase/flutterfire/commit/e0087c845c7526c11a4241a26d39d4673b0ad29d))

## 4.2.5

 - **FIX**: fix a null pointer exception that could occur when removing an even listener ([#10210](https://github.com/firebase/flutterfire/issues/10210)). ([72d2e973](https://github.com/firebase/flutterfire/commit/72d2e97363d89d716963dd224a2b9578ba446624))

## 4.2.4

 - Update a dependency to the latest release.

## 4.2.3

 - Update a dependency to the latest release.

## 4.2.2

 - Update a dependency to the latest release.

## 4.2.1

 - Update a dependency to the latest release.

## 4.2.0

 - **FEAT**: improve error message when user cancels a sign in with a provider ([#10060](https://github.com/firebase/flutterfire/issues/10060)). ([6631da6b](https://github.com/firebase/flutterfire/commit/6631da6b6b165a0c1e3260d744df1d60f3c7abe0))

## 4.1.5

 - **FIX**: Apple Sign In on a secondary app doesnt sign in the correct Firebase Auth instance ([#10018](https://github.com/firebase/flutterfire/issues/10018)). ([f746d5da](https://github.com/firebase/flutterfire/commit/f746d5da0c784e28f08b9fcedfce18933a9e448e))

## 4.1.4

 - **FIX**: tentative fix for null pointer exception in `parseUserInfoList` ([#9960](https://github.com/firebase/flutterfire/issues/9960)). ([dad17407](https://github.com/firebase/flutterfire/commit/dad1740792b893920867528039a9c54398ae7e3e))

## 4.1.3

 - **FIX**: fix reauthenticateWithProvider on iOS with Sign In With Apple that would throw a linked exception ([#9919](https://github.com/firebase/flutterfire/issues/9919)). ([7318a8f3](https://github.com/firebase/flutterfire/commit/7318a8f32de07bd47026d3e07b80b4bab5df1e6a))

## 4.1.2

 - Update a dependency to the latest release.

## 4.1.1

 - Update a dependency to the latest release.

## 4.1.0

 - **REFACTOR**: add `verify` to `QueryPlatform` and change internal `verifyToken` API to `verify` ([#9711](https://github.com/firebase/flutterfire/issues/9711)). ([c99a842f](https://github.com/firebase/flutterfire/commit/c99a842f3e3f5f10246e73f51530cc58c42b49a3))
 - **FIX**: properly propagate the `FirebaseAuthMultiFactorException` for all reauthenticate and link methods ([#9700](https://github.com/firebase/flutterfire/issues/9700)). ([9ad97c82](https://github.com/firebase/flutterfire/commit/9ad97c82ead0f5c6f1307625374c34e0dcde730b))
 - **FEAT**: expose reauthenticateWithRedirect and reauthenticateWithPopup ([#9696](https://github.com/firebase/flutterfire/issues/9696)). ([2a1f910f](https://github.com/firebase/flutterfire/commit/2a1f910ff6cab21a126c62fd4322a14ec263b629))

## 4.0.2

 - Update a dependency to the latest release.

## 4.0.1

- Update a dependency to the latest release.

## 4.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: Firebase iOS SDK version: `10.0.0` ([#9708](https://github.com/firebase/flutterfire/issues/9708)). ([9627c56a](https://github.com/firebase/flutterfire/commit/9627c56a37d657d0250b6f6b87d0fec1c31d4ba3))

## 3.11.2

 - **DOCS**: update `setSettings()` inline documentation ([#9655](https://github.com/firebase/flutterfire/issues/9655)). ([39ca0029](https://github.com/firebase/flutterfire/commit/39ca00299ec5c6e0f2dc9b0b5a8d71b8d59d51d4))

## 3.11.1

 - **FIX**: fix an iOS crash when using Sign In With Apple due to invalid return of nil instead of NSNull ([#9644](https://github.com/firebase/flutterfire/issues/9644)). ([3f76b53f](https://github.com/firebase/flutterfire/commit/3f76b53f375f4398652abfa7c9236571ee0bd87f))

## 3.11.0

 - **FEAT**: add OAuth Access Token support to sign in with providers ([#9593](https://github.com/firebase/flutterfire/issues/9593)). ([cb6661bb](https://github.com/firebase/flutterfire/commit/cb6661bbc701031d6f920ace3a6efc8e8d56aa4c))
 - **FEAT**: add `linkWithRedirect` to the web ([#9580](https://github.com/firebase/flutterfire/issues/9580)). ([d834b90f](https://github.com/firebase/flutterfire/commit/d834b90f29fc1929a195d7d546170e4ea03c6ab1))

## 3.10.0

 - **FIX**: fix path of generated Pigeon files to prevent name collision ([#9569](https://github.com/firebase/flutterfire/issues/9569)). ([71bde27d](https://github.com/firebase/flutterfire/commit/71bde27d4e613096f121abb16d7ea8483c3fbcd8))
 - **FEAT**: add `reauthenticateWithProvider` ([#9570](https://github.com/firebase/flutterfire/issues/9570)). ([dad6b481](https://github.com/firebase/flutterfire/commit/dad6b4813c682e35315dda3965ea8aaf5ba030e8))

## 3.9.0

 - **REFACTOR**: deprecate `signInWithAuthProvider` in favor of `signInWithProvider` ([#9542](https://github.com/firebase/flutterfire/issues/9542)). ([ca340ea1](https://github.com/firebase/flutterfire/commit/ca340ea19c8dbb340f083e48cf1b0de36f7d64c4))
 - **FEAT**: add `linkWithProvider` to support for linking auth providers ([#9535](https://github.com/firebase/flutterfire/issues/9535)). ([1ac14fb1](https://github.com/firebase/flutterfire/commit/1ac14fb147f83cf5c7874004a9dc61838dce8da8))

## 3.8.0

 - **FIX**: remove default scopes on iOS for Sign in With Apple ([#9477](https://github.com/firebase/flutterfire/issues/9477)). ([3fe02b29](https://github.com/firebase/flutterfire/commit/3fe02b2937135ea6d576c7e445da5f4266ff0fdf))
 - **FEAT**: add Twitter login for Android, iOS and Web ([#9421](https://github.com/firebase/flutterfire/issues/9421)). ([0bc6e6d5](https://github.com/firebase/flutterfire/commit/0bc6e6d5333e6be0d5749a083206f3f5bb79a7ba))
 - **FEAT**: add Yahoo as provider for iOS, Android and Web ([#9443](https://github.com/firebase/flutterfire/issues/9443)). ([6c3108a7](https://github.com/firebase/flutterfire/commit/6c3108a767aca3b1a844b2b5da04b2da45bc9fbd))
 - **DOCS**: fix typo "apperance" in `platform_interface_firebase_auth.dart` ([#9472](https://github.com/firebase/flutterfire/issues/9472)). ([323b917b](https://github.com/firebase/flutterfire/commit/323b917b5eecf0e5161a61c66f6cabac5b23e1b8))

## 3.7.0

 - **FEAT**: add Microsoft login for Android, iOS and Web ([#9415](https://github.com/firebase/flutterfire/issues/9415)). ([1610ce8a](https://github.com/firebase/flutterfire/commit/1610ce8ac96d6da202ef014e9a3dfeb4acfacec9))
 - **FEAT**: add Sign in with Apple directly in Firebase Auth for Android, iOS 13+ and Web ([#9408](https://github.com/firebase/flutterfire/issues/9408)). ([da36b986](https://github.com/firebase/flutterfire/commit/da36b9861b7d635382705b4893eed85fd672125c))

## 3.6.4

 - **FIX**: fix an error where MultifactorInfo factorId could be null on iOS ([#9367](https://github.com/firebase/flutterfire/issues/9367)). ([88bded11](https://github.com/firebase/flutterfire/commit/88bded119607473c7546154ac8bdd149a2d3f21f))

## 3.6.3

 - **FIX**: use correct UTC time from server for `currentUser?.metadata.creationTime` & `currentUser?.metadata.lastSignInTime` ([#9248](https://github.com/firebase/flutterfire/issues/9248)). ([a6204128](https://github.com/firebase/flutterfire/commit/a6204128edf1f54ac734385d0ed6214d50cebd1b))
 - **DOCS**: explicit mention that `refreshToken` is empty string on native platforms on the `User`instance ([#9183](https://github.com/firebase/flutterfire/issues/9183)). ([1aa1c163](https://github.com/firebase/flutterfire/commit/1aa1c1638edc632dedf8de0f02127e26b1a86e17))

## 3.6.2

 - **DOCS**: update `getIdTokenResult` inline documentation ([#9150](https://github.com/firebase/flutterfire/issues/9150)). ([519518ce](https://github.com/firebase/flutterfire/commit/519518ce3ed36580e35713e791281b251018201c))

## 3.6.1

 - Update a dependency to the latest release.

## 3.6.0

 - **FIX**: pass `Persistence` value to `FirebaseAuth.instanceFor(app: app, persistence: persistence)` for setting persistence on Web platform ([#9138](https://github.com/firebase/flutterfire/issues/9138)). ([ae7ebaf8](https://github.com/firebase/flutterfire/commit/ae7ebaf8e304a2676b2acfa68aadf0538468b4a0))
 - **FIX**: fix crash on Android where detaching from engine was not properly resetting the Pigeon handler ([#9218](https://github.com/firebase/flutterfire/issues/9218)). ([96d35df0](https://github.com/firebase/flutterfire/commit/96d35df09914fbe40515fdcd20b17a802f37270d))
 - **FEAT**: expose the missing MultiFactor classes through the universal package ([#9194](https://github.com/firebase/flutterfire/issues/9194)). ([d8bf8185](https://github.com/firebase/flutterfire/commit/d8bf818528c3705350cdb1b4675d600ba1d29d14))

## 3.5.1

 - Update a dependency to the latest release.

## 3.5.0

 - **FEAT**: add all providers available to MFA ([#9159](https://github.com/firebase/flutterfire/issues/9159)). ([5a03a859](https://github.com/firebase/flutterfire/commit/5a03a859385f0b06ad9afe8e8c706c046976b8d8))
 - **FEAT**: add phone MFA ([#9044](https://github.com/firebase/flutterfire/issues/9044)). ([1b85c8b7](https://github.com/firebase/flutterfire/commit/1b85c8b7fbcc3f21767f23981cb35061772d483f))

## 3.4.2

 - Update a dependency to the latest release.

## 3.4.1

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

## 3.4.0

 - **FIX**: Web recaptcha hover removed after use. (#8812). ([790e450e](https://github.com/firebase/flutterfire/commit/790e450e8d6acd2fc50e0232c77a152430c7b3ea))
 - **FIX**: java.util.ConcurrentModificationException (#8967). ([dc6c04ae](https://github.com/firebase/flutterfire/commit/dc6c04aeb4fc535a8ccadf9c11fb4d5dc413606d))
 - **FEAT**: update GitHub sign in implementation (#8976). ([ffd3b019](https://github.com/firebase/flutterfire/commit/ffd3b019c3158c66476671d9a9df245035cc2295))

## 3.3.20

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8729). ([43df32d4](https://github.com/firebase/flutterfire/commit/43df32d457a28523f5956a2252dafd47856ac756))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **FIX**: update firebase_auth example to not be dependent on an emulator (#8601). ([bdc9772e](https://github.com/firebase/flutterfire/commit/bdc9772ec8a3fb6609b66c42166d6d132ddb67d9))
 - **DOCS**: fix two typos. (#8876). ([7390d5c5](https://github.com/firebase/flutterfire/commit/7390d5c51e61aeb4d59c0d74093921fad3f35083))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (#8814). ([78006e0d](https://github.com/firebase/flutterfire/commit/78006e0d5b9dce8038ce3606a43ddcbc8a4a71b9))

## 3.3.19

 - **DOCS**: use camel case style for "FlutterFire" in `README.md` (#8748). ([c6ff0b21](https://github.com/firebase/flutterfire/commit/c6ff0b21352eb0f9a9a576ca7ef737d203292a58))

## 3.3.18

 - Update a dependency to the latest release.

## 3.3.17

 - Update a dependency to the latest release.

## 3.3.16

 - **REFACTOR**: remove deprecated `Tasks.call()` API from Android. (#8452). ([3e92496b](https://github.com/firebase/flutterfire/commit/3e92496b2783ec149258c22d3167c5388dcb1c40))

## 3.3.15

 - **FIX**: Use iterator instead of enhanced for loop on android. (#8498). ([027c75a6](https://github.com/firebase/flutterfire/commit/027c75a60b39a40e6a3edc12edc51487cc954503))

## 3.3.14

 - Update a dependency to the latest release.

## 3.3.13

 - Update a dependency to the latest release.

## 3.3.12

 - Update a dependency to the latest release.

## 3.3.11

 - **FIX**: Update APN token once auth plugin has been initialized on `iOS`. (#8201). ([ab6239dd](https://github.com/firebase/flutterfire/commit/ab6239ddf5cb14211b76bced04ec52203919a57a))

## 3.3.10

 - **FIX**: return correct error code for linkWithCredential `provider-already-linked` on Android (#8245). ([ae090719](https://github.com/firebase/flutterfire/commit/ae090719ebbb0873cf227f76004feeae9a7d0580))
 - **FIX**: Fixed bug that sets email to `nil` on `iOS` when the `User` has no provider. (#8209). ([fb646438](https://github.com/firebase/flutterfire/commit/fb646438f219b0f0f7c6a8c52e2b9daa4afc833e))

## 3.3.9

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

## 3.3.8

 - Update a dependency to the latest release.

## 3.3.7

 - **DOCS**: Update documentation for `currentUser` property to make expectations clearer. (#7843). ([59bb47c2](https://github.com/firebase/flutterfire/commit/59bb47c2490fbd641a1fcc26f2f888e8f4f02671))

## 3.3.6

 - Update a dependency to the latest release.

## 3.3.5

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726). ([a9562bac](https://github.com/firebase/flutterfire/commit/a9562bac60ba927fb3664a47a7f7eaceb277dca6))

## 3.3.4

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8. ([7f0e82c9](https://github.com/firebase/flutterfire/commit/7f0e82c978a3f5a707dd95c7e9136a3e106ff75e))

## 3.3.3

 - Update a dependency to the latest release.

## 3.3.2

 - **DOCS**: Fix typos and remove unused imports (#7504).

## 3.3.1

 - Update a dependency to the latest release.

## 3.3.0

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

## 3.2.0

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

## 3.1.5

 - Update a dependency to the latest release.

## 3.1.4

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).
 - **STYLE**: macOS & iOS; explicitly include header that defines `TARGET_OS_OSX` (#7116).

## 3.1.3

 - **REFACTOR**: migrate example app to null-safety (#7111).

## 3.1.2

 - **FIX**: allow setLanguage to accept null (#7050).
 - **CHORE**: remove google-signin plugin temporarily to fix CI (#7047).

## 3.1.1

 - **FIX**: use Locale.ROOT while processing error code (#6946).

## 3.1.0

 - **FEAT**: expose linkWithPopup() & correctly parse credentials in exceptions (#6562).

## 3.0.2

 - **STYLE**: enable additional lint rules (#6832).
 - **FIX**: precise error message is propagated (#6793).
 - **FIX**: Use angle bracket import consistently when importing Firebase.h for iOS (#5891).
 - **FIX**: stop idTokenChanges & userChanges firing twice on initial listen (#6560).

## 3.0.1

 - **FIX**: reinstate deprecated emulator apis (#6626).

## 3.0.0

> Note: This release has breaking changes.

 - **FEAT**: setSettings now possible for android (#6367).
 - **DOCS**: phone provider account linking update (#6465).
 - **CHORE**: update v2 embedding support (#6506).
 - **CHORE**: verifyPhoneNumber() example (#6476).
 - **CHORE**: rm deprecated jcenter repository (#6431).
 - **BREAKING** **FEAT**: use<product>Emulator(host, port) API update (#6439).

## 2.0.0

> Note: This release has breaking changes.

 - **FEAT**: setSettings now possible for android (#6367).
 - **DOCS**: phone provider account linking update (#6465).
 - **CHORE**: verifyPhoneNumber() example (#6476).
 - **CHORE**: rm deprecated jcenter repository (#6431).
 - **BREAKING** **FEAT**: useAuthEmulator(host, port) API update.

## 1.4.1

 - Update a dependency to the latest release.

## 1.4.0

 - **FEAT**: add tenantId support  (#5736).

## 1.3.0

 - **FEAT**: add User.updateDisplayName and User.updatePhotoURL (#6213).
 - **DOCS**: Add Flutter Favorite badge (#6190).

## 1.2.0

 - **FEAT**: upgrade Firebase JS SDK version to 8.6.1.
 - **FIX**: podspec osx version checking script should use a version range instead of a single fixed version.

## 1.1.4

 - **FIX**: correctly cleanup Dictionary handlers (#6101).
 - **DOCS**: Update the documentation of sendPasswordResetEmail (#6051).
 - **CHORE**: publish packages (#6022).
 - **CHORE**: publish packages.

## 1.1.3

 - **FIX**: Fix firebase_auth not being registered as a plugin (#5987).
 - **CI**: refactor to use Firebase Auth emulator (#5939).

## 1.1.2

 - **FIX**: fixed an issue where Web could not connect to the Firebase Auth emulator (#5940).
 - **FIX**: Import all necessary headers from the header file. (#5890).
 - **FIX**: Move communication to EventChannels (#4643).
 - **DOCS**: remove implicit-cast in the doc of AuthProviders (#5862).

## 1.1.1

 - **FIX**: ensure web is initialized before sending stream events (#5766).
 - **DOCS**: Add UserInfoCard widget in auth example SignInPage (#4635).
 - **CI**: fix analyzer issues in example.
 - **CHORE**: update Web plugins to use Firebase JS SDK version 8.4.1 (#4464).

## 1.1.0

 - **FEAT**: PhoneAuthProvider.credential and PhoneAuthProvider.credentialFromToken now return a PhoneAuthCredential (#5675).
 - **CHORE**: update drive dependency (#5740).

## 1.0.3

 - **DOCS**: userChanges clarification (#5698).

## 1.0.2

 - Update a dependency to the latest release.

## 1.0.1

 - **DOCS**: note that auth emulator is not supported for web (#5169).

## 1.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.0.0-1.0.nullsafety.0

 - Bump "firebase_auth" to `1.0.0-1.0.nullsafety.0`.

## 0.21.0-1.1.nullsafety.3

 - Update a dependency to the latest release.

## 0.21.0-1.1.nullsafety.2

 - **TESTS**: update mockito API usage in tests

## 0.21.0-1.1.nullsafety.1

 - **REFACTOR**: pubspec & dependency updates (#4932).

## 0.21.0-1.1.nullsafety.0

 - **FEAT**: implement support for `useEmulator` (#4263).

## 0.21.0-1.0.nullsafety.0

 - **FIX**: bump firebase_core_* package versions to updated NNBD versioning format (#4832).

## 0.21.0-nullsafety.0

 - **FEAT**: Migrated to null safety (#4633)

## 0.20.0+1

 - **FIX**: package compatibility.

## 0.20.0

> Note: This release has breaking changes.

 - **FIX**: null pointer exception if user metadata null (#4622).
 - **FEAT**: add check on podspec to assist upgrading users deployment target.
 - **BUILD**: commit Podfiles with 10.12 deployment target.
 - **BUILD**: remove default sdk version, version should always come from firebase_core, or be user defined.
 - **BUILD**: set macOS deployment target to 10.12 (from 10.11).
 - **BREAKING** **BUILD**: set osx min supported platform version to 10.12.

## 0.19.0+1

 - Update a dependency to the latest release.

## 0.19.0

> Note: This release has breaking changes.

 - **CHORE**: harmonize dependencies and version handling.
 - **BREAKING** **REFACTOR**: remove all currently deprecated APIs.
 - **BREAKING** **FEAT**: forward port to firebase-ios-sdk v7.3.0.
   - Due to this SDK upgrade, iOS 10 is now the minimum supported version by FlutterFire. Please update your build target version.

## 0.18.4+1

 - Update a dependency to the latest release.

## 0.18.4

 - **FEAT**: bump android `com.android.tools.build` & `'com.google.gms:google-services` versions (#4269).
 - **DOCS**: Fixed two typos in method documentation (#4219).

## 0.18.3+1

 - **TEST**: Explicitly opt-out from null safety.
 - **FIX**: stop authStateChange firing twice for initial event (#4099).
 - **FIX**: updated email link signin to use latest format for ActionCodeSettings (#3425).
 - **CHORE**: add missing dependency to example app.
 - **CHORE**: bump gradle wrapper to 5.6.4 (#4158).

## 0.18.3

 - **FEAT**: migrate firebase interop files to local repository (#3973).
 - **FEAT**: bump `compileSdkVersion` to 29 in preparation for upcoming Play Store requirement.
 - **FEAT** [WEB] adds support for `EmailAuthProvider.credentialWithLink`
 - **FEAT** [WEB] adds support for `FirebaseAuth.setSettings`
 - **FEAT** [WEB] adds support for `User.tenantId`
 - **FEAT** [WEB] `FirebaseAuthException` now supports `email` & `credential` properties
 - **FEAT** [WEB] `ActionCodeInfo` now supports `previousEmail` field

## 0.18.2

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: update Firebase iOS SDK version to 6.33.0 (from 6.26.0).

## 0.18.1+2

 - **FIX**: on iOS use sendEmailVerificationWithActionCodeSettings instead of sendEmailVerificationWithCompletion (#3686).
 - **DOCS**: README updates (#3768).

## 0.18.1+1

 - **FIX**: Optional params for "signInWithCredential" method are converted to "nil" if "null" for iOS (#3731).

## 0.18.1

 - **FIX**: local dependencies in example apps (#3319).
 - **FIX**: fix IdTokenResult timestamps (web, ios) (#3357).
 - **FIX**: pub.dev score fixes (#3318).
 - **FIX**: use unknown APNS token type (#3345).
 - **FIX**: update FLTFirebaseAuthPlugin.m (#3360).
 - **FIX**: use correct FIRAuth instance on listeners (#3316).
 - **FEAT**: add support for linkWithPhoneNumber (#3436).
 - **FEAT**: use named arguments for ActionCodeSettings (#3269).
 - **FEAT**: implement signInWithPhoneNumber on web (#3205).
 - **FEAT**: expose smsCode (android only) (#3308).
 - **DOCS**: fixed signOut method documentation (#3342).

## 0.18.0+1

* Fixed an Android issue where certain network related Firebase Auth error codes would come through as `unknown`. [(#3217)](https://github.com/firebase/flutterfire/pull/3217)
* Added missing deprecations: `FirebaseUser` class and `photoUrl` getter.
* Bump `firebase_auth_platform_interface` dependency to fix an assertion issue when creating Google sign-in credentials.
* Bump `firebase_auth_web` dependency to `^0.3.0+1`.

## 0.18.0

Overall, Firebase Auth has been heavily reworked to bring it inline with the federated plugin setup along with adding new features, documentation and many more unit and end-to-end tests. The API has mainly been kept the same, however there are some breaking changes.

### General

- **BREAKING**: The `FirebaseUser` class has been renamed to `User`.
- **BREAKING**: The `AuthResult` class has been renamed to `UserCredential`.
- **NEW**: The `ActionCodeSettings` class is now consumable on all supporting methods.
  - **NEW**: Added support for the `dynamicLinkDomain` property.
- **NEW**: Added a new `FirebaseAuthException` class (extends `FirebaseException`).
  - All errors are now returned as a `FirebaseAuthException`, allowing you to access the code & message associated with the error.
  - In addition, it is now possible to access the `email` and `credential` properties on exceptions if they exist.

### `FirebaseAuth`

- **BREAKING**: Accessing the current user via `currentUser()` is now synchronous via the `currentUser` getter.
- **BREAKING**: `isSignInWithEmailLink()` is now synchronous.
- **DEPRECATED**: `FirebaseAuth.fromApp()` is now deprecated in favor of `FirebaseAuth.instanceFor()`.
- **DEPRECATED**: `onAuthStateChanged` has been deprecated in favor of `authStateChanges()`.
- **NEW**: Added support for `idTokenChanges()` stream listener.
- **NEW**: Added support for `userChanges()` stream listener.
  - The purpose of this API is to allow users to subscribe to all user events without having to manually hydrate app state in cases where a manual reload was required (e.g. `updateProfile()`).
- **NEW**: Added support for `applyActionCode()`.
- **NEW**: Added support for `checkActionCode()`.
- **NEW**: Added support for `verifyPasswordResetCode()`.
- **NEW**: Added support for accessing the current language code via the `languageCode` getter.
- **NEW**: `setLanguageCode()` now supports providing a `null` value.
  - On web platforms, if `null` is provided the Firebase projects default language will be set.
  - On native platforms, if `null` is provided the device language will be used.
- **NEW**: `verifyPhoneNumber()` exposes a `autoRetrievedSmsCodeForTesting` property.
  - This allows developers to test automatic SMS code resolution on Android devices during development.
- **NEW** (iOS): `appVerificationDisabledForTesting`  setting can now be set for iOS.
  - This allows developers to skip ReCaptcha verification when testing phone authentication.
- **NEW** (iOS): `userAccessGroup` setting can now be set for iOS & MacOS.
  - This allows developers to share authentication states across multiple apps or extensions on iOS & MacOS. For more information see the [Firebase iOS SDK documentation](https://firebase.google.com/docs/auth/ios/single-sign-on).

### `User`

- **BREAKING**: Removed the `UpdateUserInfo` class when using `updateProfile` in favor of named arguments.
- **NEW**: Added support for `getIdTokenResult()`.
- **NEW**: Added support for `verifyBeforeUpdateEmail()`.
- **FIX**: Fixed several iOS crashes when the Firebase SDK returned `nil` property values.
- **FIX**: Fixed an issue on Web & iOS where a users email address would still show after unlinking the email/password provider.

### `UserCredential`

- **NEW**: Added support for accessing the users `AuthCredential` via the `credential` property.

### `AuthProvider` & `AuthCredential`

- **DEPRECATED**: All sub-class (e.g. `GoogleAuthProvider`) `getCredential()` methods have been deprecated in favor of `credential()`.
  - **DEPRECATED**:  `EmailAuthProvider.getCredentialWithLink()` has been deprecated in favor of `EmailAuthProvider.credentialWithLink()`.
- **NEW**: Supporting providers can now assign scope and custom request parameters.
  - The scope and parameters will be used on web platforms when triggering a redirect or popup via `signInWithPopup()` or `signInWithRedirect()`.

## 0.17.0-dev.2

* Update plugin and example to use the same core.

## 0.17.0-dev.1

* Depend on `firebase_core` pre-release versions.

## 0.16.1+2

* Update README to make it clear which authentication options are possible.

## 0.16.1+1

* Fix bug #2656 (verifyPhoneNumber always use the default FirebaseApp, not the configured one)

## 0.16.1

* Update lower bound of dart dependency to 2.0.0.

## 0.16.0

* Migrate to Android v2 embedding.

## 0.15.5+3

* Fix for missing UserAgent.h compilation failures.

## 0.15.5+2

* Update the platform interface dependency to 1.1.7 and update tests.

## 0.15.5+1

* Make the pedantic dev_dependency explicit.

## 0.15.5

* Add macOS support

## 0.15.4+1

* Fix fallthrough bug in Android code.

## 0.15.4

* Add support for `confirmPasswordReset` on Android and iOS.

## 0.15.3+1

* Add integration instructions for the `web` platform.

## 0.15.3

* Add support for OAuth Authentication for iOS and Android to solve generic providers authentication.

## 0.15.2

* Add web support by default.
* Require Flutter SDK 1.12.13+hotfix.4 or later.

## 0.15.1+1

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 0.15.1

* Migrate to use `firebase_auth_platform_interface`.

## 0.15.0+2

*  Update homepage since this package was moved.

## 0.15.0+1

*  Added missing ERROR_WRONG_PASSWORD Exception to the `reauthenticateWithCredential` docs.

## 0.15.0

* Fixed `NoSuchMethodError` in `reauthenticateWithCredential`.
* Fixed `IdTokenResult` analyzer warnings.
* Reduced visibility of `IdTokenResult` constructor.

## 0.14.0+10

* Formatted lists in member documentations for better readability.

## 0.14.0+9

* Fix the behavior of `getIdToken` to use the `refresh` parameter instead of always refreshing.

## 0.14.0+8

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 0.14.0+7

* Remove AndroidX warning.

## 0.14.0+6

* Update example app with correct const constructors.

## 0.14.0+5

* On iOS, `fetchSignInMethodsForEmail` now returns an empty list when the email
  cannot be found, matching the Android behavior.

## 0.14.0+4

* Fixed "Register a user" example code snippet in README.md.

## 0.14.0+3

* Update documentation to reflect new repository location.
* Update unit tests to call `TestWidgetsFlutterBinding.ensureInitialized`.
* Remove executable bit on LICENSE file.

## 0.14.0+2

* Reduce compiler warnings on iOS port by replacing `int` with `long` backing in returned timestamps.

## 0.14.0+1

* Add dependency on `androidx.annotation:annotation:1.0.0`.

## 0.14.0

* Added new `IdTokenResult` class.
* **Breaking Change**. `getIdToken()` method now returns `IdTokenResult` instead of a token `String`.
  Use the `token` property of `IdTokenResult` to retrieve the token `String`.
* Added integration testing for `getIdToken()`.

## 0.13.1+1

* Update authentication example in README.

## 0.13.1

* Fixed a crash on iOS when sign-in fails.
* Additional integration testing.
* Updated documentation for `FirebaseUser.delete()` to include error codes.
* Updated Firebase project to match other Flutterfire apps.

## 0.13.0

* **Breaking change**: Replace `FirebaseUserMetadata.creationTimestamp` and
  `FirebaseUserMetadata.lastSignInTimestamp` with `creationTime` and `lastSignInTime`.
  Previously on iOS `creationTimestamp` and `lastSignInTimestamp` returned in
  seconds and on Android in milliseconds. Now, both platforms provide values as a
  `DateTime`.

## 0.12.0+1

* Fixes iOS sign-in exceptions when `additionalUserInfo` is `nil` or has `nil` fields.
* Additional integration testing.

## 0.12.0

* Added new `AuthResult` and `AdditionalUserInfo` classes.
* **Breaking Change**. Sign-in methods now return `AuthResult` instead of `FirebaseUser`.
  Retrieve the `FirebaseUser` using the `user` property of `AuthResult`.

## 0.11.1+12

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 0.11.1+11

* On iOS, `getIdToken()` now uses the `refresh` parameter instead of always using `true`.

## 0.11.1+10

* On Android, `providerData` now includes `UserInfo` for the phone authentication provider.

## 0.11.1+9

* Update README to clarify importance of filling out all fields for OAuth consent screen.

## 0.11.1+8

* Automatically register for iOS notifications, ensuring that phone authentication
  will work even if Firebase method swizzling is disabled.

## 0.11.1+7

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 0.11.1+6

* Add documentation of support email requirement to README.

## 0.11.1+5

* Fix `updatePhoneNumberCredential` on Android.

## 0.11.1+4

* Fix `updatePhoneNumberCredential` on iOS.

## 0.11.1+3

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.
* FirebaseUser private constructor takes `Map<String, dynamic>` instead of `Map<dynamic, dynamic>`.

## 0.11.1+2

* Suppress deprecation warning for BinaryMessages. See: https://github.com/flutter/flutter/issues/33446

## 0.11.1+1

* Updated the error code documentation for `linkWithCredential`.

## 0.11.1

* Support for `updatePhoneNumberCredential`.

## 0.11.0

* **Breaking change**: `linkWithCredential` is now a function of `FirebaseUser`instead of
  `FirebaseAuth`.
* Added test for newer `linkWithCredential` function.

## 0.10.0+1

* Increase Firebase/Auth CocoaPod dependency to '~> 6.0'.

## 0.10.0

* Update firebase_dynamic_links dependency.
* Update Android dependencies to latest.

## 0.9.0

* **Breaking change**: `PhoneVerificationCompleted` now provides an `AuthCredential` that can
  be used with `signInWithCredential` or `linkWithCredential` instead of signing in automatically.
* **Breaking change**: Remove internal counter `nextHandle` from public API.

## 0.8.4+5

* Increase Firebase/Auth CocoaPod dependency to '~> 5.19'.

## 0.8.4+4

* Update FirebaseAuth CocoaPod dependency to ensure availability of `FIRAuthErrorUserInfoNameKey`.

## 0.8.4+3

* Updated deprecated API usage on iOS to use non-deprecated versions.
* Updated FirebaseAuth CocoaPod dependency to ensure a minimum version of 5.0.

## 0.8.4+2

* Fixes an error in the documentation of createUserWithEmailAndPassword.

## 0.8.4+1

* Adds credential for email authentication with link.

## 0.8.4

* Adds support for email link authentication.

## 0.8.3

* Make providerId 'const String' to use in 'case' statement.

## 0.8.2+1

* Fixed bug where `PhoneCodeAutoRetrievalTimeout` callback was never called.

## 0.8.2

* Fixed `linkWithCredential` on Android.

## 0.8.1+5

* Added a driver test.

## 0.8.1+4

* Update README.
* Update the example app with separate pages for registration and sign-in.

## 0.8.1+3

* Reduce compiler warnings in Android plugin
* Raise errors early when accessing methods that require a Firebase User

## 0.8.1+2

* Log messages about automatic configuration of the default app are now less confusing.

## 0.8.1+1

* Remove categories.

## 0.8.1

* Fixes Firebase auth phone sign-in for Android.

## 0.8.0+3

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.8.0+2

* Update Google sign-in example in the README.

## 0.8.0+1

* Update a broken dependency.

## 0.8.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.7.0

* Introduce third-party auth provider classes that generate `AuthCredential`s
* **Breaking Change** Signing in, linking, and reauthenticating now require an `AuthCredential`
* **Breaking Change** Unlinking now uses providerId
* **Breaking Change** Moved reauthentication to FirebaseUser

## 0.6.7

* `FirebaseAuth` and `FirebaseUser` are now fully documented.
* `PlatformExceptions` now report error codes as stated in docs.
* Credentials can now be unlinked from Accounts with new methods on `FirebaseUser`.

## 0.6.6

* Users can now reauthenticate in response to operations that require a recent sign-in.

## 0.6.5

* Fixing async method `verifyPhoneNumber`, that would never return even in a successful call.

## 0.6.4

* Added support for Github signin and linking Github accounts to existing users.

## 0.6.3

* Add multi app support.

## 0.6.2+1

* Bump Android dependencies to latest.

## 0.6.2

* Add access to user metadata.

## 0.6.1

* Adding support for linkWithTwitterCredential in FirebaseAuth.

## 0.6.0

* Added support for `updatePassword` in `FirebaseUser`.
* **Breaking Change** Moved `updateEmail` and `updateProfile` to `FirebaseUser`.
  This brings the `firebase_auth` package inline with other implementations and documentation.

## 0.5.20

* Replaced usages of guava's: ImmutableList and ImmutableMap with platform
Collections.unmodifiableList() and Collections.unmodifiableMap().

## 0.5.19

* Update test package dependency to pick up Dart 2 support.
* Modified dependency on google_sign_in to point to a published
  version instead of a relative path.

## 0.5.18

* Adding support for updateEmail in FirebaseAuth.

## 0.5.17

* Adding support for FirebaseUser.delete.

## 0.5.16

* Adding support for setLanguageCode in FirebaseAuth.

## 0.5.15

* Bump Android and Firebase dependency versions.

## 0.5.14

* Fixed handling of auto phone number verification.

## 0.5.13

* Add support for phone number authentication.

## 0.5.12

* Fixed ArrayIndexOutOfBoundsException in handleStopListeningAuthState

## 0.5.11

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.5.10

* Updated iOS implementation to reflect Firebase API changes.

## 0.5.9

* Added support for signing in with a Twitter account.

## 0.5.8

* Added support to reload firebase user

## 0.5.7

* Added support to sendEmailVerification

## 0.5.6

* Added support for linkWithFacebookCredential

## 0.5.5

* Updated Google Play Services dependencies to version 15.0.0.

## 0.5.4

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 0.5.3

* Secure fetchProvidersForEmail (no providers)

## 0.5.2

* Fixed Dart 2 type error in fetchProvidersForEmail.

## 0.5.1

* Added support to fetchProvidersForEmail

## 0.5.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.4.7

* Fixed Dart 2 type errors.

## 0.4.6

* Fixed Dart 2 type errors.

## 0.4.5

* Enabled use in Swift projects.

## 0.4.4

* Added support for sendPasswordResetEmail

## 0.4.3

* Moved to the io.flutter.plugins organization.

## 0.4.2

* Added support for changing user data

## 0.4.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.4.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
* Relaxed GMS dependency to [11.4.0,12.0[

## 0.3.2

* Added FLT prefix to iOS types
* Change GMS dependency to 11.4.+

## 0.3.1

* Change GMS dependency to 11.+

## 0.3.0

* **Breaking Change**: Method FirebaseUser getToken was renamed to getIdToken.

## 0.2.5

* Added support for linkWithCredential with Google credential

## 0.2.4

* Added support for `signInWithCustomToken`
* Added `Stream<FirebaseUser> onAuthStateChanged` event to listen when the user change

## 0.2.3+1

* Aligned author name with rest of repo.

## 0.2.3

* Remove dependency on Google/SignIn

## 0.2.2

* Remove dependency on FirebaseUI

## 0.2.1

* Added support for linkWithEmailAndPassword

## 0.2.0

* **Breaking Change**: Method currentUser is async now.

## 0.1.2

* Added support for signInWithFacebook

## 0.1.1

* Updated to Firebase SDK to always use latest patch version for 11.0.x builds

## 0.1.0

* Updated to Firebase SDK Version 11.0.1
* **Breaking Change**: You need to add a maven section with the "https://maven.google.com" endpoint to the repository section of your `android/build.gradle`. For example:
```gradle
allprojects {
    repositories {
        jcenter()
        maven {                              // NEW
            url "https://maven.google.com"   // NEW
        }                                    // NEW
    }
}
```

## 0.0.4

* Add method getToken() to FirebaseUser

## 0.0.3+1

* Updated README.md

## 0.0.3

* Added support for createUserWithEmailAndPassword, signInWithEmailAndPassword, and signOut Firebase methods

## 0.0.2+1

* Updated README.md

## 0.0.2

* Bump buildToolsVersion to 25.0.3

## 0.0.1

* Initial Release
