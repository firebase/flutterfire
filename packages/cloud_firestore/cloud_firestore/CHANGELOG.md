## 6.1.1

 - Update a dependency to the latest release.

## 6.1.0

 - **FEAT**(firestore): add client language support for Firestore plugin on Android and iOS ([#17830](https://github.com/firebase/flutterfire/issues/17830)). ([74a37ae6](https://github.com/firebase/flutterfire/commit/74a37ae68446e700ed6cc9f9307ff296a9ff20d8))

## 6.0.3

 - Update a dependency to the latest release.

## 6.0.2

 - Update a dependency to the latest release.

## 6.0.1

 - Update a dependency to the latest release.

## 6.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: bump iOS SDK to version 12.0.0 ([#17549](https://github.com/firebase/flutterfire/issues/17549)). ([b2619e68](https://github.com/firebase/flutterfire/commit/b2619e685fec897513483df1d7be347b64f95606))
 - **BREAKING** **FEAT**(firestore): remove deprecated functions ([#17559](https://github.com/firebase/flutterfire/issues/17559)). ([67017fd6](https://github.com/firebase/flutterfire/commit/67017fd6f139080cec7ecd1b4d75a05f13f238fa))
 - **BREAKING** **FEAT**: bump Android SDK to version 34.0.0 ([#17554](https://github.com/firebase/flutterfire/issues/17554)). ([a5bdc051](https://github.com/firebase/flutterfire/commit/a5bdc051d40ee44e39cf0b8d2a7801bc6f618b67))

## 5.6.12

 - Update a dependency to the latest release.

## 5.6.11

 - Update a dependency to the latest release.

## 5.6.10

 - Update a dependency to the latest release.

## 5.6.9

 - **FIX**(firestore,ios): fix an issue where unlimited cache wasn't properly set on iOS ([#17412](https://github.com/firebase/flutterfire/issues/17412)). ([cad28406](https://github.com/firebase/flutterfire/commit/cad28406d3baf8fa1087be35630c82a79b5c9d92))

## 5.6.8

 - Update a dependency to the latest release.

## 5.6.7

 - **FIX**(firestore): Change asserts to throw argumentError ([#17302](https://github.com/firebase/flutterfire/issues/17302)). ([ec1e6a5e](https://github.com/firebase/flutterfire/commit/ec1e6a5eef149680b2750900d1f16d8074e09b38))
 - **FIX**(cloud_firestore): correct nanoseconds calculation for pre-1970 dates ([#17195](https://github.com/firebase/flutterfire/issues/17195)). ([a13deae3](https://github.com/firebase/flutterfire/commit/a13deae3334045fb1a48817ff9300cbe0696d177))

## 5.6.6

 - Update a dependency to the latest release.

## 5.6.5

 - Update a dependency to the latest release.

## 5.6.4

 - **FIX**(firestore,macos): ensure Package.swift pulls firebase-ios-sdk version from local txt file ([#17097](https://github.com/firebase/flutterfire/issues/17097)). ([b7248e05](https://github.com/firebase/flutterfire/commit/b7248e05a0ab7689c1d634689fe660c9c7125713))

## 5.6.3

 - Update a dependency to the latest release.

## 5.6.2

 - **FIX**(cloud_firestore,android): suppress unchecked warning ([#16979](https://github.com/firebase/flutterfire/issues/16979)). ([684508da](https://github.com/firebase/flutterfire/commit/684508daf096acb50deb4c1d14c76f72fb52b8c5))

## 5.6.1

 - Update a dependency to the latest release.

## 5.6.0

 - **FEAT**(firestore): add support for VectorValue ([#16476](https://github.com/firebase/flutterfire/issues/16476)). ([cc23f179](https://github.com/firebase/flutterfire/commit/cc23f179082256fe9700f17e3856821b4a6d4240))

## 5.5.1

 - **FIX**(firestore,android): synchronize access to firestore instances ([#16675](https://github.com/firebase/flutterfire/issues/16675)). ([03e85ae6](https://github.com/firebase/flutterfire/commit/03e85ae63ece0924d376b98e35e8a73670b59fa8))

## 5.5.0

 - **FEAT**(firestore): Swift Package Manager support ([#13329](https://github.com/firebase/flutterfire/issues/13329)). ([0420eabb](https://github.com/firebase/flutterfire/commit/0420eabb3ab247e0e3998bedcb9779fe35c46920))

## 5.4.5

 - Update a dependency to the latest release.

## 5.4.4

 - **FIX**(cloud_firestore): remove single whereIn filter assertion ([#13436](https://github.com/firebase/flutterfire/issues/13436)). ([d770aa6a](https://github.com/firebase/flutterfire/commit/d770aa6a2616ed0535bbc2fbd2e9645da9ad18cd))

## 5.4.3

 - **FIX**(all,apple): use modular headers to import ([#13400](https://github.com/firebase/flutterfire/issues/13400)). ([d7d2d4b9](https://github.com/firebase/flutterfire/commit/d7d2d4b93e7c00226027fffde46699f3d5388a41))

## 5.4.2

 - Update a dependency to the latest release.

## 5.4.1

 - **FIX**(firestore,web): only set long polling options if it has a value ([#13295](https://github.com/firebase/flutterfire/issues/13295)). ([04b5002c](https://github.com/firebase/flutterfire/commit/04b5002c49904bae0b369f06147b5c2a90b978ee))

## 5.4.0

 - **FEAT**(firestore,web): expose `webExperimentalForceLongPolling`, `webExperimentalAutoDetectLongPolling` and `timeoutSeconds` on web ([#13201](https://github.com/firebase/flutterfire/issues/13201)). ([6ec2a103](https://github.com/firebase/flutterfire/commit/6ec2a103a3a325a73550bdfff4c0d524ae7e4068))

## 5.3.0

 - **FIX**(firestore): not passing correctly the ListenSource when listening to as single `DocumentReference` ([#13179](https://github.com/firebase/flutterfire/issues/13179)). ([ce6e1c97](https://github.com/firebase/flutterfire/commit/ce6e1c97efc1398bc3c209d7a522e3bb67db3d0f))
 - **FEAT**: bump iOS SDK to version 11.0.0 ([#13158](https://github.com/firebase/flutterfire/issues/13158)). ([c0e0c997](https://github.com/firebase/flutterfire/commit/c0e0c99703ea394d1bb873ac225c5fe3539b002d))
 - **DOCS**: remove reference to flutter.io and firebase.flutter.dev ([#13152](https://github.com/firebase/flutterfire/issues/13152)). ([5f0874b9](https://github.com/firebase/flutterfire/commit/5f0874b91e28a203dd62d37d391e5760c91f5729))

## 5.2.1

 - **FIX**: compilation issue on Windows ([#13135](https://github.com/firebase/flutterfire/issues/13135)). ([de8c9e0f](https://github.com/firebase/flutterfire/commit/de8c9e0f2d3117b3614ac8295b041fea7ed3ee7f))

## 5.2.0

 - **FIX**(firestore,web): stop cleaning up snapshot listeners in debug ([#13119](https://github.com/firebase/flutterfire/issues/13119)). ([82a63c8b](https://github.com/firebase/flutterfire/commit/82a63c8bf9bad0c262ed48d7829fb05110a9fe08))
 - **FEAT**(firestore): support for `PersistentCacheIndexManager` for firestore instances for managing cache indexes. ([#13070](https://github.com/firebase/flutterfire/issues/13070)). ([806c15d7](https://github.com/firebase/flutterfire/commit/806c15d7eadaf48b8dfb22586bea4ed684672a86))

## 5.1.0

 - **FEAT**(firestore,windows): support multiple databases ([#12998](https://github.com/firebase/flutterfire/issues/12998)). ([f80768a4](https://github.com/firebase/flutterfire/commit/f80768a4a4258932cac75dbd310589573bf14306))

## 5.0.2

 - Update a dependency to the latest release.

## 5.0.1

 - **FIX**(firestore,macos): add Nonull decorator to PigeonParser to remove warnings when building ([#12930](https://github.com/firebase/flutterfire/issues/12930)). ([264b7643](https://github.com/firebase/flutterfire/commit/264b764346e0f35cc11e0a2b1f8070a6036c6631))
 - **FIX**(firestore,web): ensure streams are removed on "hot restart" ([#12913](https://github.com/firebase/flutterfire/issues/12913)). ([c1a67e54](https://github.com/firebase/flutterfire/commit/c1a67e54894cbfb316b3445505b5803e2d041ed5))

## 5.0.0

> Note: This release has breaking changes.

 - **DOCS**(firestore): update documentation for `clearPersistence` ([#12843](https://github.com/firebase/flutterfire/issues/12843)). ([35b78f04](https://github.com/firebase/flutterfire/commit/35b78f04edd12f2319d3d6cce06c66bfdbd13d8c))
 - **BREAKING** **REFACTOR**: android plugins require `minSdk 21`, auth requires `minSdk 23` ahead of android BOM `>=33.0.0` ([#12873](https://github.com/firebase/flutterfire/issues/12873)). ([52accfc6](https://github.com/firebase/flutterfire/commit/52accfc6c39d6360d9c0f36efe369ede990b7362))
 - **BREAKING** **REFACTOR**: bump all iOS deployment targets to iOS 13 ahead of Firebase iOS SDK `v11` breaking change ([#12872](https://github.com/firebase/flutterfire/issues/12872)). ([de0cea2c](https://github.com/firebase/flutterfire/commit/de0cea2c3c36694a76361be784255986fac84a43))

## 4.17.5

 - Update a dependency to the latest release.

## 4.17.4

 - **FIX**(firestore,ios): fix document stream handler options. ([#12764](https://github.com/firebase/flutterfire/issues/12764)). ([786e73ca](https://github.com/firebase/flutterfire/commit/786e73ca17527493a47914c7ead1a12a4f0adde5))

## 4.17.3

 - **FIX**(firestore,ios): fix query stream handler options. ([#12739](https://github.com/firebase/flutterfire/issues/12739)). ([953bf929](https://github.com/firebase/flutterfire/commit/953bf929bf19e7bbb3564c69901f5a4fca5fc981))
 - **FIX**(web): fix test for Web on WASM ([#12697](https://github.com/firebase/flutterfire/issues/12697)). ([e343df58](https://github.com/firebase/flutterfire/commit/e343df585280e0ff088eb21a7a7accb727b150ed))

## 4.17.2

 - Update a dependency to the latest release.

## 4.17.1

 - Update a dependency to the latest release.

## 4.17.0

 - **FIX**(firestore): remove `nanopb` version constraints from podspec ([#12632](https://github.com/firebase/flutterfire/issues/12632)). ([c899a7bc](https://github.com/firebase/flutterfire/commit/c899a7bc9cdd7b552d3c10058f4899106a4c1994))
 - **FIX**(firestore): deprecate `databaseURL` in favor of `databaseId` ([#12593](https://github.com/firebase/flutterfire/issues/12593)). ([8966f483](https://github.com/firebase/flutterfire/commit/8966f4837afe7e32a3847b7b677d787b1398b682))
 - **FEAT**(firestore): add support for listening snapshot from cache ([#12585](https://github.com/firebase/flutterfire/issues/12585)). ([f2cef8c1](https://github.com/firebase/flutterfire/commit/f2cef8c13f590cdeda0cadbe3d85d6e246d5ad7f))

## 4.16.1

 - **FIX**(firestore,android): lint warnings and deprecated API ([#12577](https://github.com/firebase/flutterfire/issues/12577)). ([1b6ef739](https://github.com/firebase/flutterfire/commit/1b6ef73935062a4fa2c43bb4ef9b6d080a3ca5b4))
 - **FIX**(firestore,windows): improve memory management ([#12575](https://github.com/firebase/flutterfire/issues/12575)). ([7f10940b](https://github.com/firebase/flutterfire/commit/7f10940bef3ea17255c4e33663d152473874c25b))

## 4.16.0

 - **FEAT**(android): Bump `compileSdk` version of Android plugins to latest stable (34) ([#12566](https://github.com/firebase/flutterfire/issues/12566)). ([e891fab2](https://github.com/firebase/flutterfire/commit/e891fab291e9beebc223000b133a6097e066a7fc))
 - **FEAT**(firestore): allow query with range and inequality filters on multiple fields ([#12564](https://github.com/firebase/flutterfire/issues/12564)). ([00ae837f](https://github.com/firebase/flutterfire/commit/00ae837fecf893d8b1eda927fb7085a7d917e671))

## 4.15.10

 - Update a dependency to the latest release.

## 4.15.9

 - Update a dependency to the latest release.

## 4.15.8

 - **FIX**(firestore): fix an issue that would cause FieldValue.increment to be interpreted as double ([#12444](https://github.com/firebase/flutterfire/issues/12444)). ([e9823a41](https://github.com/firebase/flutterfire/commit/e9823a415bec0a46209608fdaf856c2413d46fbf))

## 4.15.7

 - **FIX**(firestore): fix an issue that would cause FieldValue.increment to not work for big int ([#12426](https://github.com/firebase/flutterfire/issues/12426)). ([a776dec5](https://github.com/firebase/flutterfire/commit/a776dec5e181b2656bfc659a23514d21930b5556))

## 4.15.6

 - **FIX**(firestore,windows): fix compilation issue on Windows ([#12375](https://github.com/firebase/flutterfire/issues/12375)). ([f24d0a76](https://github.com/firebase/flutterfire/commit/f24d0a76ff384cf40605ae59af705b2854e53ba7))

## 4.15.5

 - **FIX**(firestore,web): Propagate `FirebaseException` properly, fix `mergeFields` bug, fix `bytesLoaded` different type under different conditions ([#12334](https://github.com/firebase/flutterfire/issues/12334)). ([fdde75b0](https://github.com/firebase/flutterfire/commit/fdde75b02fe4bd4d40ce14798e7212eca7c8e557))
 - **FIX**(firestore): expose `AggregateField` type to users ([#12305](https://github.com/firebase/flutterfire/issues/12305)). ([2b83defa](https://github.com/firebase/flutterfire/commit/2b83defa84056e717bb230a7abd220f211c2e15e))
 - **FIX**(firestore): cannot use `not-in` & `in` filters in the same query ([#12307](https://github.com/firebase/flutterfire/issues/12307)). ([e538338c](https://github.com/firebase/flutterfire/commit/e538338c7e1bef38973ee43db37f3def20a3d4b0))
 - **FIX**(firestore): aggregate query `average()` is `null` when collection is empty or collection doesn't exist or the property doesn't exist on docs ([#12304](https://github.com/firebase/flutterfire/issues/12304)). ([4d3b578d](https://github.com/firebase/flutterfire/commit/4d3b578dbb88da441e308179f3656822c5612ef1))

## 4.15.4

 - **FIX**(firestore,web): fix an issue where nested object could be incorrectly decoded from JSObjects ([#12289](https://github.com/firebase/flutterfire/issues/12289)). ([991f5bd4](https://github.com/firebase/flutterfire/commit/991f5bd416880d0a5a49e1ff466f4769d6730e77))

## 4.15.3

 - **FIX**(firestore,web): fix an issue where nested object could be incorrectly decoded from JSObjects ([#12272](https://github.com/firebase/flutterfire/issues/12272)). ([bd27d1d9](https://github.com/firebase/flutterfire/commit/bd27d1d9763acdff88a6a5f42142986f8643fae9))

## 4.15.2

 - Update a dependency to the latest release.

## 4.15.1

 - Update a dependency to the latest release.

## 4.15.0

 - **FIX**(firestore): revert breaking change to where() API. `null` cannot be used for `isEqualTo` or `isNotEqualTo` in a query. ([#12164](https://github.com/firebase/flutterfire/issues/12164)). ([cff6f767](https://github.com/firebase/flutterfire/commit/cff6f7674014037688815bdbe3198dd903a4b08e))
 - **FIX**(firestore,web): update `setSettings` to allow usage of a up-to-date persistence on web ([#12041](https://github.com/firebase/flutterfire/issues/12041)). ([c9174334](https://github.com/firebase/flutterfire/commit/c917433452fb9125197c385cb121d8174cc56c20))
 - **FEAT**(firestore,web): migrate web to js_interop to be compatible with WASM ([#12169](https://github.com/firebase/flutterfire/issues/12169)). ([57ebd529](https://github.com/firebase/flutterfire/commit/57ebd529de5def2bab1557a1bd9967ee4267c08a))
 - **DOCS**: change old documentation links of packages in README files ([#12136](https://github.com/firebase/flutterfire/issues/12136)). ([24b9ac7e](https://github.com/firebase/flutterfire/commit/24b9ac7ec29fc9ca466c0941c2cff26d75b8568d))

## 4.14.0

 - **FIX**(firestore): `transaction.get()` should throw `FirebaseException` on exception. ([#12064](https://github.com/firebase/flutterfire/issues/12064)). ([3cfc5019](https://github.com/firebase/flutterfire/commit/3cfc5019d4f9a5f3c610a44ef370541bf22cd028))
 - **FIX**(firestore): export `LoadBundleTaskState` in `cloud_firestore` ([#12065](https://github.com/firebase/flutterfire/issues/12065)). ([97903034](https://github.com/firebase/flutterfire/commit/97903034b6bf720be141ded3eb74961323ec72f5))
 - **FEAT**(firestore): add support for `sum` and `average` aggregated queries ([#11757](https://github.com/firebase/flutterfire/issues/11757)). ([82af6c2f](https://github.com/firebase/flutterfire/commit/82af6c2f40160a9e2f74e2d48652003fa48bb161))
 - **FEAT**: allow users to disable automatic host mapping ([#11962](https://github.com/firebase/flutterfire/issues/11962)). ([13c1ce33](https://github.com/firebase/flutterfire/commit/13c1ce333b8cd113241a1f7ac07181c1c76194bc))

## 4.13.6

 - **FIX**(firestore): revert changes to `isLessThan`, `isLessThanOrEqualTo`,`isGreaterThan`, `isGreaterThanOrEqualTo` & `arrayContains`. `null` is not valid.. ([#12017](https://github.com/firebase/flutterfire/issues/12017)). ([2712ea4e](https://github.com/firebase/flutterfire/commit/2712ea4e73ab02cf2f4ac3719b41200efd2e8dc0))

## 4.13.5

 - Update a dependency to the latest release.

## 4.13.4

 - Update a dependency to the latest release.

## 4.13.3

 - Update a dependency to the latest release.

## 4.13.2

 - **FIX**(firestore): allow `null` value to `isEqualsTo` & `isNotEqualsTo` in `where()` query ([#11896](https://github.com/firebase/flutterfire/issues/11896)). ([3ee59a7c](https://github.com/firebase/flutterfire/commit/3ee59a7c4aff589cc5845107099cc012d7b19b53))
 - **FIX**(firestore,web): fix being able to use normal `where` conditions and `Filter.OR` together ([#11891](https://github.com/firebase/flutterfire/issues/11891)). ([c8410acd](https://github.com/firebase/flutterfire/commit/c8410acd79fe6f8f4cd36b4eacb384c5874d61d2))

## 4.13.1

 - **FIX**(firestore,android): fix a race condition that could cause a crash when adding event channels while closing the app ([#11881](https://github.com/firebase/flutterfire/issues/11881)). ([963c1b8d](https://github.com/firebase/flutterfire/commit/963c1b8d2d54e03f6d6edcb4b6a05f43c62b345c))
 - **FIX**(firestore): ensure `collectionGroup().count()` aggregate query works ([#11850](https://github.com/firebase/flutterfire/issues/11850)). ([85e71293](https://github.com/firebase/flutterfire/commit/85e712937cd609977a9681712b3afaf8f3018903))

## 4.13.0

 - **FIX**(firestore,ios): remove a warning that would be printed when using transactions ([#11783](https://github.com/firebase/flutterfire/issues/11783)). ([355ab9a5](https://github.com/firebase/flutterfire/commit/355ab9a515551afd5f01bbbc94341a85757e8c8c))
 - **FEAT**(windows): add platform logging for core, auth, firestore and storage ([#11790](https://github.com/firebase/flutterfire/issues/11790)). ([e7d428d1](https://github.com/firebase/flutterfire/commit/e7d428d14be1535a2d579d4b2d376fbb81f06742))

## 4.12.2

 - **FIX**(firestore,android): `cacheSizeBytes` value cannot be null when setting `persistenceEnabled` ([#11794](https://github.com/firebase/flutterfire/issues/11794)). ([a10399eb](https://github.com/firebase/flutterfire/commit/a10399eb1cad2207eba7d2efa64267c9d0176b4a))

## 4.12.1

 - **FIX**(firestore,ios): fix freeze when doing a get in transactions when auth is also installed ([#11773](https://github.com/firebase/flutterfire/issues/11773)). ([180c0918](https://github.com/firebase/flutterfire/commit/180c0918336cdee6efd95bb9926be931d69eedce))
 - **FIX**(firestore,android): fix hot reload freezing the app on Android ([#11776](https://github.com/firebase/flutterfire/issues/11776)). ([bd1ab457](https://github.com/firebase/flutterfire/commit/bd1ab457a4dde19e18457fe05413d1096565f45f))

## 4.12.0

 - **FIX**(firestore): cleaned up use of previous method channel ([#11758](https://github.com/firebase/flutterfire/issues/11758)). ([8cfc69bf](https://github.com/firebase/flutterfire/commit/8cfc69bf7c773fac26f12f01863e7853791fce8f))
 - **FEAT**: bump Firebase iOS SDK `10.16.0` ([#11698](https://github.com/firebase/flutterfire/issues/11698)). ([666f90ea](https://github.com/firebase/flutterfire/commit/666f90ea1eb090ee3f2397c9ffde8ddaf934f36c))

## 4.11.0

 - **FIX**(ios): fix clashing filenames between Auth and Firestore ([#11731](https://github.com/firebase/flutterfire/issues/11731)). ([8770cafc](https://github.com/firebase/flutterfire/commit/8770cafccccb11607b5530311e3150ac08cd172e))
 - **FEAT**(firestore,windows): add Filters to windows ([#11726](https://github.com/firebase/flutterfire/issues/11726)). ([dde59d46](https://github.com/firebase/flutterfire/commit/dde59d466e1b6cc483ba29654a35f198d6e8c9ae))

## 4.10.0

 - **FEAT**: Full support of AGP 8 ([#11699](https://github.com/firebase/flutterfire/issues/11699)). ([bdb5b270](https://github.com/firebase/flutterfire/commit/bdb5b27084d225809883bdaa6aa5954650551927))
 - **FEAT**(firestore,windows): add support to Windows ([#11516](https://github.com/firebase/flutterfire/issues/11516)). ([e51d2a2d](https://github.com/firebase/flutterfire/commit/e51d2a2d287f4162f5a67d8200f1bf57fc2afe14))

## 4.9.3

 - Update a dependency to the latest release.

## 4.9.2

 - **FIX**(firestore): allow `DocumentReference` to be used to in Filter queries ([#11593](https://github.com/firebase/flutterfire/issues/11593)). ([3f570c6d](https://github.com/firebase/flutterfire/commit/3f570c6d42305bef299e75de6053eb57d8520c8a))
 - **FIX**(firestore): Correct static property getter `serverTimestampMap` ([#11570](https://github.com/firebase/flutterfire/issues/11570)). ([251d15e9](https://github.com/firebase/flutterfire/commit/251d15e970c771f30bc03aeda319538e9b3b76fc))

## 4.9.1

 - **FIX**(cloud_firestore): Fix crashes on iOS/macOS ([#11501](https://github.com/firebase/flutterfire/issues/11501)). ([3ed53470](https://github.com/firebase/flutterfire/commit/3ed53470f0536294d4d1905c759c91aabf1d39ff))

## 4.9.0

 - **FEAT**(firestore): add support for multiple database instances ([#11310](https://github.com/firebase/flutterfire/issues/11310)). ([ce6efcc1](https://github.com/firebase/flutterfire/commit/ce6efcc16ced0317e86b0ad12aa02ff5795a8207))

## 4.8.5

 - **FIX**(firestore): allow `FieldPath.documentId` as a field argument in queries ([#11443](https://github.com/firebase/flutterfire/issues/11443)). ([4e01a9d8](https://github.com/firebase/flutterfire/commit/4e01a9d84ededf0e0ba74bdc2eba75492e1aa532))

## 4.8.4

 - **FIX**(firestore): remove assertion for `arrayContainsAny` & `whereIn` query combined ([#11342](https://github.com/firebase/flutterfire/issues/11342)). ([199e1fc4](https://github.com/firebase/flutterfire/commit/199e1fc43654b913ddb8257c4e3a3ceddcbb97d1))

## 4.8.3

 - **FIX**(firestore): allow 30 conjunctive & disjunctive queries for "in" & "array-contains-any" via where() API ([#11265](https://github.com/firebase/flutterfire/issues/11265)). ([f5477b1a](https://github.com/firebase/flutterfire/commit/f5477b1ae83c37d727f12dd6ed5440cac0bc0bcd))
 - **FIX**: null check error when using `withConverter` and returning null from `fromFirestore` ([#11224](https://github.com/firebase/flutterfire/issues/11224)). ([4dd0f3f0](https://github.com/firebase/flutterfire/commit/4dd0f3f0409d58c263d3af523611d2eb0fd79619))
 - **FIX**(firestore): allow up to 30 Filter queries within `Filter.or()` & `Filter.and()` ([#11140](https://github.com/firebase/flutterfire/issues/11140)). ([e1f0064d](https://github.com/firebase/flutterfire/commit/e1f0064db7f24b360da131b991e39020f47ffd1c))

## 4.8.2

 - **FIX**(firestore,apple): issue where setting persistence caused a crash. `kFIRFirestoreCacheSizeUnlimited` no longer usable. ([#11174](https://github.com/firebase/flutterfire/issues/11174)). ([536cbf07](https://github.com/firebase/flutterfire/commit/536cbf07f6b07c0539e0f31552ae15dfa56c6352))

## 4.8.1

 - **FIX**(firestore): update deprecated persistence API ([#11069](https://github.com/firebase/flutterfire/issues/11069)). ([076e7af8](https://github.com/firebase/flutterfire/commit/076e7af86ddc74ac63ec85078ea9c4077afd2e31))

## 4.8.0

 - **FEAT**(firestore): add the ability to enable debug logging ([#11019](https://github.com/firebase/flutterfire/issues/11019)). ([ec4c4474](https://github.com/firebase/flutterfire/commit/ec4c44742d33c5032075310efc2c567bf0a5fa35))
 - **DOCS**(firestore): improve wording of what `set()` API does ([#11038](https://github.com/firebase/flutterfire/issues/11038)). ([883cbff9](https://github.com/firebase/flutterfire/commit/883cbff92f1245d7e96b7f845e3f363d8dbb0441))

## 4.7.1

 - **FIX**(firestore): fix emulator reload on Flutter 3.10 ([#10965](https://github.com/firebase/flutterfire/issues/10965)). ([f099eb0b](https://github.com/firebase/flutterfire/commit/f099eb0bd010af6ba0fae1fdb5ea5cd6a2cb680f))
 - **FIX**(firestore,ios): tentative fix for a crash that could occur during Snapshot serialization ([#10728](https://github.com/firebase/flutterfire/issues/10728)). ([2f4ba33a](https://github.com/firebase/flutterfire/commit/2f4ba33ad31d431a9042c7dc179b768cb43e0d17))

## 4.7.0

 - **FEAT**: update dependency constraints to `sdk: '>=2.18.0 <4.0.0'` `flutter: '>=3.3.0'` ([#10946](https://github.com/firebase/flutterfire/issues/10946)). ([2772d10f](https://github.com/firebase/flutterfire/commit/2772d10fe510dcc28ec2d37a26b266c935699fa6))
 - **FEAT**: update libraries to be compatible with Flutter 3.10.0 ([#10944](https://github.com/firebase/flutterfire/issues/10944)). ([e1f5a5ea](https://github.com/firebase/flutterfire/commit/e1f5a5ea798c54f19d1d2f7b8f2250f8819f44b7))

## 4.6.0

 - **FIX**: add support for AGP 8.0 ([#10901](https://github.com/firebase/flutterfire/issues/10901)). ([a3b96735](https://github.com/firebase/flutterfire/commit/a3b967354294c295a9be8d699a6adb7f4b1dba7f))
 - **FEAT**: upgrade to dart 3 compatible dependencies ([#10890](https://github.com/firebase/flutterfire/issues/10890)). ([4bd7e59b](https://github.com/firebase/flutterfire/commit/4bd7e59b1f2b09a2230c49830159342dd4592041))

## 4.5.3

 - **FIX**(firestore,ios): clean up event listeners on engine detach only ([#10579](https://github.com/firebase/flutterfire/issues/10579)). ([0ac13b6f](https://github.com/firebase/flutterfire/commit/0ac13b6fc06f6839686437dc2d5b6feab179aa83))

## 4.5.2

 - Update a dependency to the latest release.

## 4.5.1

 - **FIX**(firestore): ensure all index URLs are captured and passed to the user ([#10674](https://github.com/firebase/flutterfire/issues/10674)). ([9800435a](https://github.com/firebase/flutterfire/commit/9800435abc562fadc67a945e771591186576c34d))

## 4.5.0

 - **FEAT**(firestore): add the `Filter` class and support for the OR query ([#10678](https://github.com/firebase/flutterfire/issues/10678)). ([ac434044](https://github.com/firebase/flutterfire/commit/ac434044bbfa91d0d8b33ff39736d8eb4062e824))
 - **FEAT**: bump dart sdk constraint to 2.18 ([#10618](https://github.com/firebase/flutterfire/issues/10618)). ([f80948a2](https://github.com/firebase/flutterfire/commit/f80948a28b62eead358bdb900d5a0dfb97cebb33))

## 4.4.5

 - Update a dependency to the latest release.

## 4.4.4

 - Update a dependency to the latest release.

## 4.4.3

 - Update a dependency to the latest release.

## 4.4.2

 - Update a dependency to the latest release.

## 4.4.1

 - Update a dependency to the latest release.

## 4.4.0

 - **FIX**: supports Iterable in queries instead of List ([#10411](https://github.com/firebase/flutterfire/issues/10411)). ([9d91d513](https://github.com/firebase/flutterfire/commit/9d91d513fad326f9c928d7d96d03e2c031875903))
 - **FEAT**: add support to `update` using FieldPath ([#10388](https://github.com/firebase/flutterfire/issues/10388)). ([538090fc](https://github.com/firebase/flutterfire/commit/538090fc49078b8d6c484d8db9049f06d05157dd))

## 4.3.2

 - **REFACTOR**: upgrade project to remove warnings from Flutter 3.7 ([#10344](https://github.com/firebase/flutterfire/issues/10344)). ([e0087c84](https://github.com/firebase/flutterfire/commit/e0087c845c7526c11a4241a26d39d4673b0ad29d))
 - **FIX**: fix an issue when removing a value that didn't exist in ServerTimestampBehavior map ([#10391](https://github.com/firebase/flutterfire/issues/10391)). ([2929ac9d](https://github.com/firebase/flutterfire/commit/2929ac9da037bc231d156425166422da380d5a2e))
 - **FIX**: fix an issue when removing a value that didn't exist in ServerTimestampBehavior map ([#10370](https://github.com/firebase/flutterfire/issues/10370)). ([6da87036](https://github.com/firebase/flutterfire/commit/6da870363a947110ebf80696a7ed3887c4f2c557))
 - **FIX**: startAfterDocument could throw when used with a DocumentReference ([#10339](https://github.com/firebase/flutterfire/issues/10339)). ([8224acbe](https://github.com/firebase/flutterfire/commit/8224acbee991e508b949c4dac11910df4d6fe323))

## 4.3.1

 - **FIX**: fix crash that could occur when using transactions ([#10184](https://github.com/firebase/flutterfire/issues/10184)). ([d14b545a](https://github.com/firebase/flutterfire/commit/d14b545adb6052f1e5acd7a0e679d790a4741122))

## 4.3.0

 - **FIX**: propagate COLLECTION_GROUP_ASC index error message ([#10130](https://github.com/firebase/flutterfire/issues/10130)). ([6b321cbe](https://github.com/firebase/flutterfire/commit/6b321cbec3a22e5899e61342b5163efa511bdd9b))
 - **FEAT**: add ServerTimestampBehavior to the GetOptions class.  ([#9590](https://github.com/firebase/flutterfire/issues/9590)). ([c25bd2fe](https://github.com/firebase/flutterfire/commit/c25bd2fe4c13bc9f13d93410842c00e25aaac2b2))

## 4.2.0

 - **FEAT**: `setIndexConfigurationFromJSON()` API. Allow users to pass JSON string ([#10029](https://github.com/firebase/flutterfire/issues/10029)). ([be4b42b1](https://github.com/firebase/flutterfire/commit/be4b42b11b6ceddf83d4fbc77a95a41879ec3c8d))

## 4.1.0

 - **FEAT**: experimental `setIndexConfiguration()` API ([#9928](https://github.com/firebase/flutterfire/issues/9928)). ([bf6eda18](https://github.com/firebase/flutterfire/commit/bf6eda1893a4f29c4b501c4aa31026548ad2b286))

## 4.0.5

 - Update a dependency to the latest release.

## 4.0.4

 - **FIX**: fix aggregated count to use the current query and not only the collection on Web ([#9824](https://github.com/firebase/flutterfire/issues/9824)). ([ada39355](https://github.com/firebase/flutterfire/commit/ada39355722e316217934ad8cf1dfa789e47f058))

## 4.0.3

 - **REFACTOR**: add `verify` to `QueryPlatform` and change internal `verifyToken` API to `verify` ([#9711](https://github.com/firebase/flutterfire/issues/9711)). ([c99a842f](https://github.com/firebase/flutterfire/commit/c99a842f3e3f5f10246e73f51530cc58c42b49a3))

## 4.0.2

 - Update a dependency to the latest release.

## 4.0.1

 - Update a dependency to the latest release.

## 4.0.0

> Note: This release has breaking changes.

 - **FEAT**: `count()` feature for counting documents without retrieving documents. ([#9699](https://github.com/firebase/flutterfire/issues/9699)). ([ac0bf733](https://github.com/firebase/flutterfire/commit/ac0bf7330d7de73d0ea36c740b79a426187291d2))
 - **FEAT**: Add namedQueryWithConverterGet ([#9715](https://github.com/firebase/flutterfire/issues/9715)). ([6d025fd4](https://github.com/firebase/flutterfire/commit/6d025fd4c89830d5975f4ed981aa0aa0777c13d8))
 - **BREAKING** **FEAT**: Firebase iOS SDK version: `10.0.0` ([#9708](https://github.com/firebase/flutterfire/issues/9708)). ([9627c56a](https://github.com/firebase/flutterfire/commit/9627c56a37d657d0250b6f6b87d0fec1c31d4ba3))

## 3.5.1

 - **FIX**: fix a query error in Flutter Web that was affecting the parsing of ancient dates ([#9633](https://github.com/firebase/flutterfire/issues/9633)). ([9250d45f](https://github.com/firebase/flutterfire/commit/9250d45f1d7ece9335b2c4c4795fecc728df3de5))

## 3.5.0

 - **FEAT**: add OAuth Access Token support to sign in with providers ([#9593](https://github.com/firebase/flutterfire/issues/9593)). ([cb6661bb](https://github.com/firebase/flutterfire/commit/cb6661bbc701031d6f920ace3a6efc8e8d56aa4c))
 - **FEAT**: Bump Firebase iOS SDK to `9.6.0` ([#9531](https://github.com/firebase/flutterfire/issues/9531)). ([2138f4aa](https://github.com/firebase/flutterfire/commit/2138f4aaaace51d5dce4809fb42e1e4ff20ed251))

## 3.4.9

 - Update a dependency to the latest release.

## 3.4.8

 - **FIX**: fix `queryGet()` & `namedQueryGet()`. Check if `query` is `[NSNull null]` value ([#9410](https://github.com/firebase/flutterfire/issues/9410)). ([ae035fe2](https://github.com/firebase/flutterfire/commit/ae035fe2b060264153386ae5c2a1eb90c22e90f3))

## 3.4.7

 - Update a dependency to the latest release.

## 3.4.6

 - Update a dependency to the latest release.

## 3.4.5

 - Update a dependency to the latest release.

## 3.4.4

 - **FIX**: stop `FirebaseError` appearing in console on hot restart & hot refresh ([#9321](https://github.com/firebase/flutterfire/issues/9321)). ([4ba0ff9d](https://github.com/firebase/flutterfire/commit/4ba0ff9d9c7d13f7e040d80375d6db3edb8d37d5))

## 3.4.3

 - Update a dependency to the latest release.

## 3.4.2

 - Update a dependency to the latest release.

## 3.4.1

 - Update a dependency to the latest release.

## 3.4.0

 - **FEAT**: add max attempts for Firestore transactions ([#9163](https://github.com/firebase/flutterfire/issues/9163)). ([9da7cc36](https://github.com/firebase/flutterfire/commit/9da7cc36cb266e4f5a0de26dfe727e0a4687f1a0))
 - **FEAT**: update to 9.3.0 ([#9137](https://github.com/firebase/flutterfire/issues/9137)). ([97f6417b](https://github.com/firebase/flutterfire/commit/97f6417bf66f88e6621afa177c73245b9a7d5c73))

## 3.3.0

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

## 3.2.1

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

## 3.2.0

 - **FEAT**: Bump Firebase iOS SDK to `9.2.0` (#8594). ([79610162](https://github.com/firebase/flutterfire/commit/79610162460b8877f3bc727464a7065106f08079))

## 3.1.18

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8724). ([fd3f3102](https://github.com/firebase/flutterfire/commit/fd3f3102a0614e0e155756239a57b54fab324c2c))
 - **REFACTOR**: migrate from hash* to Object.hash* (#8797). ([3dfc0997](https://github.com/firebase/flutterfire/commit/3dfc0997050ee4351207c355b2c22b46885f971f))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

## 3.1.17

 - Update a dependency to the latest release.

## 3.1.16

 - **REFACTOR**: remove deprecated `Tasks.call` for android and replace with `TaskCompletionSource`. (#8522). ([45e27201](https://github.com/firebase/flutterfire/commit/45e27201480088fab71af60963001baeae61d80d))

## 3.1.15

 - Update a dependency to the latest release.

## 3.1.14

 - Update a dependency to the latest release.

## 3.1.13

 - Update a dependency to the latest release.

## 3.1.12

 - Update a dependency to the latest release.

## 3.1.11

 - **REFACTOR**: recreate ios, android, web and macOS folders for example app (#8255). ([cdae0613](https://github.com/firebase/flutterfire/commit/cdae0613a359da41013721f601c20169807d214f))
 - **DOCS**: Fix method name typo in code documentation (#8291). ([7b4e06db](https://github.com/firebase/flutterfire/commit/7b4e06db305ff9f785a1bfcf1888fec1a53970c4))

## 3.1.10

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

## 3.1.9

 - Update a dependency to the latest release.

## 3.1.8

 - Update a dependency to the latest release.

## 3.1.7

 - **FIX**: Fix Android Firestore transaction crash when running in background caused by `null` `Activity`. (#7627). ([8d60d474](https://github.com/firebase/flutterfire/commit/8d60d474438fccc5d6dcb41b840221ae385a853c))

## 3.1.6

 - Update a dependency to the latest release.

## 3.1.5

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8. ([7f0e82c9](https://github.com/firebase/flutterfire/commit/7f0e82c978a3f5a707dd95c7e9136a3e106ff75e))

## 3.1.4

 - Update a dependency to the latest release.

## 3.1.3

 - **DOCS**: update firestore dartpad example.

## 3.1.2

 - Update a dependency to the latest release.

## 3.1.1

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FIX**: suppress Java unchecked cast lint warning in Android plugin (#7431).

## 3.1.0

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

## 3.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: update Android `minSdk` version to 19 as this is required by Firebase Android SDK `29.0.0` (#7298).

## 2.5.4

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7147).
 - **STYLE**: macOS & iOS; explicitly include header that defines `TARGET_OS_OSX` (#7116).

## 2.5.3

 - **FIX**: value encoding fails when using `DocumentReference` & `withConverter` (#7020).
 - **FIX**: propagate query index link  to firebase console for user (#7087).
 - **FIX**: fixed a bug where `withConverter.endBeforeDocument` incorrectly behaved as `endAtDocument`.
 - **FIX**: an issue where `Query.==` throws when using `withConverter` (#6997).
 - **CHORE**: update gradle version across packages (#7054).

## 2.5.2

 - **REVERT**: Firestore cache snapshot connections with underlying native listener (#6819) (#6974).
 - **CHORE**: Reduce hash conflicts on objects (#6928).

## 2.5.1

 - Update a dependency to the latest release.

## 2.5.0

 - **STYLE**: enable additional lint rules (#6832).
 - **FIX**: transactionHandler was losing ref to self in blocks (#6791).
 - **FIX**: allow querying on 'is not null' properties (#6788).
 - **FIX**: improve query filter assertions (#6627).
 - **FEAT**: cache snapshot connections with underlying native listener (#6819).
 - **FEAT**: override ==/hashCode for Firestore Queries (#6797).
 - **DOCS**: Transaction timeout correction (#6761).

## 2.4.0

 - **FIX**: export PersistenceSettings (#6603).
 - **FIX**: Fixed variable name (#6564).
 - **FIX**: withConverter examples in docs (#6438).
 - **FIX**: DocumentReference @sealed annotation (#6436).
 - **FEAT**: useFirestoreEmulator(host, port) API for firestore (#6428).
 - **CHORE**: update v2 embedding support (#6506).
 - **CHORE**: rm deprecated jcenter repository (#6431).

## 2.3.0

 - **FIX**: withConverter examples in docs (#6438).
 - **FIX**: DocumentReference @sealed annotation (#6436).
 - **FEAT**: useFirestoreEmulator(host, port) API for firestore (#6428).
 - **CHORE**: rm deprecated jcenter repository (#6431).

## 2.2.2

 - Update a dependency to the latest release.

## 2.2.1

 - **TEST**: error handling for loadBundle() & namedQueryGet() (#6197).
 - **TEST**: improve query assertions (#6249).
 - **TEST**: update and assert documentId field & isNotEqualTo filter test (#6225).
 - **DOCS**: Add Flutter Favorite badge (#6190).

## 2.2.0

 - **FEAT**: support for `loadBundle()` & `namedQueryGet()` (#6037).
 - **FEAT**: upgrade Firebase JS SDK version to 8.6.1.
 - **FIX**: podspec osx version checking script should use a version range instead of a single fixed version.
 - **FIX**: pass GetOptions to web Query.get (#6132).

## 2.1.0

 - **FIX**: Fix FirebaseOptions hashCode (#3263).
 - **FEAT**: Add withConverter for Query (#6065).
 - **DOCS**: add QueryDocumentSnapshot to the list of classes that received a breaking change (#6092).
 - **CHORE**: publish packages (#6022).
 - **CHORE**: publish packages.

## 2.0.0

> Note: This release has breaking changes.

 - **FEAT**: Add withConverter function to CollectionReference, DocumentReference and Query (#6015).
    This new method allows interacting with collections/documents in a type-safe way:

    ```dart
    final modelsRef = FirebaseFirestore
        .instance
        .collection('models')
        .withConverter<Model>(
          fromFirestore: (snapshot, _) => Model.fromJson(snapshot.data()!),
          toFirestore: (model, _) => model.toJson(),
        );

    Future<void> main() async {
      // Writes now take a Model as parameter instead of a Map
      await modelsRef.add(Model());
      final Model model = await modelsRef.doc('123').get().then((s) => s.data());
    }
    ```

 - **BREAKING** **REFACTOR**: `DocumentReference`, `CollectionReference`, `Query`, `DocumentSnapshot`,
   `CollectionSnapshot`, `QuerySnapshot`, `QueryDocumentSnapshot`, `Transaction.get`, `Transaction.set`
   and `WriteBatch.set` now take an extra generic parameter.  (#6015).

   See the [migration guide](https://firebase.flutter.dev/docs/firestore/2.0.0_migration) for more
   information on how to update your code.

 - **BREAKING** **FEAT**: convert FieldPath parameters from dynamic to Object (#5997).

## 1.0.7

 - **FIX**: Clear event listeners when firebase core is reinitialised (#5852).

## 1.0.6

 - Update a dependency to the latest release.

## 1.0.5

 - Update a dependency to the latest release.

## 1.0.4

 - **FIX**: made QueryDocumentSnapshot.data() non-nullable (#5476).
 - **CHORE**: add repository urls to pubspecs (#5542).

## 1.0.3

 - **FIX**: cannot store null values in firestore on the web (#5335).
 - **DOCS**: remove incorrect ARCHS in ios examples (#5450).
 - **CHORE**: bump min Dart SDK constraint to 2.12.0 (#5430).
 - **CHORE**: publish packages (#5429).

## 1.0.2

 - **FIX**: cannot store null values in firestore on the web (#5335).

## 1.0.1

 - Update a dependency to the latest release.

## 1.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.0.0-1.0.nullsafety.0

 - Bump "cloud_firestore" to `1.0.0-1.0.nullsafety.0`.

## 0.17.0-1.0.nullsafety.2

 - **FIX**: Fix type issue. (#5081).
 - **FIX**: Fixed crashes due to null `Settings` (#5031).

## 0.17.0-1.0.nullsafety.1

 - Update a dependency to the latest release.

## 0.17.0-1.0.nullsafety.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: migrate to NNBD (#4780).

## 0.16.0

> Note: This release has breaking changes.

 - **FIX**: add missing symlinks (fixes #4628).
 - **FEAT**: add check on podspec to assist upgrading users deployment target.
 - **CHORE**: add missing file license headers.
 - **BUILD**: commit Podfiles with 10.12 deployment target.
 - **BUILD**: remove default sdk version, version should always come from firebase_core, or be user defined.
 - **BUILD**: set macOS deployment target to 10.12 (from 10.11).
 - **BREAKING** **BUILD**: set osx min supported platform version to 10.12.

## 0.15.0

> Note: This release has breaking changes.

 - **FIX**: Add missing sdk version constraints inside example pubspec.yaml (#4604).
 - **FIX**: ensure web FieldValue types are converted (#4247).
 - **FEAT**: Move Snapshot handling into a EventChannel (#4209).
 - **BREAKING** **REFACTOR**: remove all currently deprecated APIs.
 - **BREAKING** **FEAT**: forward port to firebase-ios-sdk v7.3.0.
   - Due to this SDK upgrade, iOS 10 is now the minimum supported version by FlutterFire. Please update your build target version.
 - **CHORE**: harmonize dependencies and version handling.

## 0.14.4

 - **FEAT**: bump android `com.android.tools.build` & `'com.google.gms:google-services` versions (#4269).
 - **CHORE**: Migrate iOS example projects (#4222).

## 0.14.3+1

 - Update a dependency to the latest release.

## 0.14.3

 - **FEAT**: migrate firebase interop files to local repository (#3973).
 - **FEAT**: add not-in & != query support (#3748).
 - **FEAT**: bump `compileSdkVersion` to 29 in preparation for upcoming Play Store requirement.
 - **FEAT** [WEB] `FirebaseFirestore.enablePersistence` now accepts `PersistenceSettings`
 - **FEAT** [WEB] adds `PersistenceSettings` class
 - **FEAT** [WEB] adds support for `FirebaseFirestore.clearPersistence`
 - **FEAT** [WEB] adds support for `FirebaseFirestore.terminate`
 - **FEAT** [WEB] adds support for `FirebaseFirestore.waitForPendingWrites`
 - **FEAT** [WEB] adds support for `SetOptions.mergeFields`
 - **FEAT** [WEB] adds `GetOptions` support for querying against server/cache
 - **FEAT** [WEB] adds support for `Query.limitToLast`
 - **FEAT** [WEB] adds support for `FirebaseFirestore.snapshotsInSync`

## 0.14.2

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: update Firebase iOS SDK version to 6.33.0 (from 6.26.0).
 - **CHORE**: update Firestore example app podfile.

## 0.14.1+3

 - **FIX**: remove unused dart:async import (#3611).
 - **FIX**: fix returning of transaction result (#3747).

## 0.14.1+2

 - Update a dependency to the latest release.

## 0.14.1+1

 - **FIX**: remove listener if available (#3452).
 - **DOCS**: remove `updateBlock` reference in Firestore docs (#3728).

## 0.14.1

 - **FIX**: local dependencies in example apps (#3319).
 - **FIX**: pub.dev score fixes (#3318).
 - **FIX**: add missing deprecated static methods (#3278).
 - **FEAT**: add a [] operator to DocumentSnapshot, acting as get() (#3387).
 - **DOCS**: Fixed docs typo (#3471).

## 0.14.0+2

* Added missing deprecated `Firestore` static methods.

## 0.14.0+1

* Fixed issue #3210 (`Query.orderBy(FieldPath.documentId)` throws exception).
* Fixed issue #3237 (`DocumentReference` not being parsed correctly).
* Bump `cloud_firestore_web` dependency.
* Bump `cloud_firestore_platform_interface` dependency to fix 2 race conditions. [(#3251)](https://github.com/firebase/flutterfire/pull/3251)

## 0.14.0

Along with the below changes, the plugin has undergone a quality of life update to better support exceptions thrown. Any Firestore specific errors now return a `FirebaseException`, allowing you to directly access the code (e.g. `permission-denied`) and message.

**`Firestore`**:
- **BREAKING**: `settings()` is now a synchronous setter that accepts a `Settings` instance.
  - **NEW**: This change allows us to support changing Firestore settings (such as using the Firestore emulator) without having to quit the application, e.g. Hot Restarts.
- **BREAKING**: `enablePersistence()` is now a Web only method, use `[Settings.persistenceEnabled]` instead for other platforms.
- **DEPRECATED**: Calling `document()` is deprecated in favor of `doc()`.
- **DEPRECATED**: Class `Firestore` is now deprecated. Use `FirebaseFirestore` instead.
- **DEPRECATED**: Calling `Firestore(app: app)` is now deprecated. Use `FirebaseFirestore.instance` or `FirebaseFirestore.instanceFor(app: app)` instead.
- **NEW**: Added `clearPersistence()` support.
- **NEW**: Added `disableNetwork()` support.
- **NEW**: Added `enableNetwork()` support.
- **NEW**: Added `snapshotInSync()` listener support.
- **NEW**: Added `terminate()` support.
- **NEW**: Added `waitForPendingWrites()` support.
- **FIX**: All document/query listeners & currently in progress transactions are now correctly torn down between Hot Restarts.

**`CollectionReference`**:
- **BREAKING**: Getting a collection parent document via `parent()` has been changed to a getter `parent`.
- **BREAKING**: Getting the collection `path` now always returns the `path` without leading and trailing slashes.
- **DEPRECATED**: Calling `document()` is deprecated in favor of `doc()`.
- **FIX**: Equality checking of `CollectionReference` now does not depend on the original path used to create the `CollectionReference`.

**`Query`**:
- **BREAKING**: The internal query logic has been overhauled to better assert invalid queries locally.
- **DEPRECATED**: Calling `getDocuments()` is deprecated in favor of `get()`.
- **BREAKING**: `getDocuments`/`get` has been updated to accept an instance of `GetOptions` (see below).
- **NEW**: Query methods can now be chained.
- **NEW**: It is now possible to call same-point cursor based queries without throwing (e.g. calling `endAt()` and then `endBefore()` will replace the "end" cursor query with the `endBefore`).
- **NEW**: Added support for the `limitToLast` query modifier.

**`QuerySnapshot`**:
- **DEPRECATED**: `documents` has been deprecated in favor of `docs`.
- **DEPRECATED**: `documentChanges` has been deprecated in favor of `docChanges`.
- **NEW**: `docs` now returns a `List<QueryDocumentSnapshot>` vs `List<DocumentSnapshot>`. This doesn't break existing functionality.

**`DocumentReference`**:
- **BREAKING**: `setData`/`set` has been updated to accept an instance of `SetOptions` (see below, supports `mergeFields`).
- **BREAKING**: `get()` has been updated to accept an instance of `GetOptions` (see below).
- **BREAKING**: Getting a document parent collection via `parent()` has been changed to a getter `parent`.
- **BREAKING**: Getting the document `path` now always returns the `path` without leading and trailing slashes.
- **DEPRECATED**: `documentID` has been deprecated in favor of `id`.
- **DEPRECATED**: `setData()` has been deprecated in favor of `set()`.
- **DEPRECATED**: `updateData()` has been deprecated in favor of `update()`.
- **FIX**: Equality checking of `DocumentReference` now does not depend on the original path used to create the `DocumentReference`.

**`DocumentChange`**:
- **DEPRECATED**: Calling `document()` is deprecated in favor of `doc()`.

**`DocumentSnapshot`**:
- **BREAKING**: The `get data` getter is now a `data()` method instead.
- **DEPRECATED**: `documentID` has been deprecated in favor of `id`.
- **NEW**: Added support for fetching nested snapshot data via the `get()` method. If no data exists at the given path, a `StateError` will be thrown.
- **FIX**: `NaN` values stored in your Firestore instance are now correctly parsed when reading & writing data.
- **FIX**: `INFINITY` values stored in your Firestore instance are now correctly parsed when reading & writing data.
- **FIX**: `-INFINITY` values stored in your Firestore instance are now correctly parsed when reading & writing data.

**`WriteBatch`**:
- **DEPRECATED**: `setData()` has been deprecated in favor of `set()`.
- **DEPRECATED**: `updateData()` has been deprecated in favor of `update()`.
- **BREAKING**: `setData`/`set` now supports `SetOptions` to merge data/fields (previously this accepted a `Map`).

**`Transaction`**:
- **BREAKING**: Transactions have been overhauled to address a number of critical issues:
  - Values returned from the transaction will now be returned from the Future. Previously, only JSON serializable values were supported. It is now possible to return any value from your transaction handler, e.g. a `DocumentSnapshot`.
  - When manually throwing an exception, the context was lost and a generic `PlatformException` was thrown. You can now throw & catch on any exceptions.
  - The modify methods on a transaction (`set`, `delete`, `update`) were previously Futures. These have been updated to better reflect how transactions should behave - they are now synchronous and are executed atomically once the transaction handler block has finished executing.
- **FIX**: Timeouts will now function correctly.
- **FIX**: iOS: transaction completion block incorrectly resolving a `FlutterResult` multiple times.

See the new [transactions documentation](https://firebase.flutter.dev/docs/firestore/usage#transactions) to learn more.

**`FieldPath`**:
- **NEW**: The constructor has now been made public to accept a `List` of `String` values. Previously field paths were accessible only via a dot-notated string path. This meant attempting to access a field in a document with a `.` in the name (e.g. `foo.bar@gmail.com`) was impossible.

**`GetOptions`**: New class created to support how data is fetched from Firestore (`server`, `cache`, `serverAndCache`).

**`SetOptions`**: New class created to both `merge` and `mergeFields` when setting data on documents.

**`GeoPoint`**:
- **BREAKING**: Add latitude and longitude validation when constructing a new `GeoPoint` instance.

## 0.13.7+1

* Fix crash where listeners are not removed when app quits.

## 0.13.7

* Clean up snapshot listeners when Android Activity is destroyed.

## 0.13.6

* Update lower bound of dart dependency to 2.0.0.

## 0.13.5

* Migrate cloud_firestore to android v2 embedding.

## 0.13.4+2

* Fix for missing UserAgent.h compilation failures.

## 0.13.4+1

* Fix crash with pagination with `DocumentReference` (#2044)
* Minor tweaks to integ tests.

## 0.13.4

* Support equality comparison on `FieldValue` instances.
* Updated version of endorsed web implementation.

## 0.13.3+1

* Make the pedantic dev_dependency explicit.

## 0.13.3

* Add macOS support

## 0.13.2+3

* Fixed decoding & encoding platform interface instances in nested maps

## 0.13.2+2

* Fixed crashes when using `FieldValue.arrayUnion` & `FieldValue.arrayRemove` with `DocumentReference` objects

## 0.13.2+1

* Add Web integration documentation to README.

## 0.13.2

* Add web support by default.
* Require Flutter SDK 1.12.13+hotfix.4 or later
* Add web support to the example app.

## 0.13.1+1

* Fixed crashes when using `Query#where` with `DocumentReference` objects

## 0.13.1

* Migrate to `cloud_firestore_platform_interface`.

## 0.13.0+2

* Fixed `persistenceEnabled`, `sslEnabled`, and `timestampsInSnapshotsEnabled` on iOS.

## 0.13.0+1

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 0.13.0

* **Breaking change** Remove use of [deprecated](https://firebase.google.com/docs/reference/android/com/google/firebase/firestore/FirebaseFirestoreSettings.Builder.html#setTimestampsInSnapshotsEnabled(boolean))
  setting `setTimestampsInSnapshotsEnabled`. If you are already setting it to true, just remove the setting. If you are
  setting it to false, you should update your code to expect Timestamps.

## 0.12.11

* Added support for `in` and `array-contains-any` query operators.

## 0.12.10+5

* Moved `.gitignore` which was left behind in previous change.

## 0.12.10+4

* Moved package to `cloud_firestore/cloud_firestore` subdir, to allow for federated implementations.

## 0.12.10+3

* Fixed test that used `FirebaseApp.channel`.

## 0.12.10+2

* Fixed analyzer warnings about unused fields.

## 0.12.10+1

* Formatted method documentations.

## 0.12.10

* Added `FieldPath` class and `FieldPath.documentId` to refer to the document id in queries.
* Added assertions and exceptions that help you building correct queries.

## 0.12.9+8

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 0.12.9+7

* Remove AndroidX warning.

## 0.12.9+6

* Cast error.code to long to avoid using NSInteger as %ld format warnings.

## 0.12.9+5

* Fixes a crash on Android when running a transaction without an internet connection.

## 0.12.9+4

* Fix integer conversion warnings on iOS.

## 0.12.9+3

* Updated error handling on Android for transactions to prevent crashes.

## 0.12.9+2

* Fix flaky integration test for `includeMetadataChanges`.

## 0.12.9+1

* Update documentation to reflect new repository location.
* Update unit tests to call `TestWidgetsFlutterBinding.ensureInitialized`.
* Remove executable bit on LICENSE file.

## 0.12.9

* New optional `includeMetadataChanges` parameter added to `DocumentReference.snapshots()`
 and `Query.snapshots()`
* Fix example app crash when the `message` field was not a string
* Internal renaming of method names.

## 0.12.8+1

* Add `metadata` to `QuerySnapshot`.

## 0.12.8

* Updated how document ids are generated to more closely match native implementations.

## 0.12.7+1

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 0.12.7

* Methods of `Transaction` no longer require `await`.
* Added documentation to methods of `Transaction`.
* Removed an unnecessary log on Android.
* Added an integration test for rapidly incrementing field value.

## 0.12.6

* Support for `orderBy` on map fields (e.g. `orderBy('cake.flavor')`) for
  `startAtDocument`, `startAfterDocument`, `endAtDocument`, and `endBeforeDocument` added.

## 0.12.5+2

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 0.12.5+1
* Added support for combining any of `Query.startAtDocument` and `Query.startAfterDocument`
  with any of `Query.endAtDocument` and `Query.endBeforeDocument`.

## 0.12.5

* Makes `startAtDocument`, `startAfterDocument`, `endAtDocument` and `endBeforeDocument` work
  with `Query.collectionGroup` queries.
* Fixes `startAtDocument`, `startAfterDocument`, `endAtDocument` and `endBeforeDocument` to
  also work with a descending order as the last explicit sort order.
* Fixed an integration test by increasing the value of `cacheSizeBytes` to a valid value.

## 0.12.4

* Added support for `Query.collectionGroup`.

## 0.12.3

* Added support for `cacheSizeBytes` to `Firestore.settings`.

## 0.12.2

* Ensure that all channel calls to the Dart side from the Java side are done
  on the UI thread. This change allows Transactions to work with upcoming
  Engine restrictions, which require channel calls be made on the UI thread.
  **Note** this is an Android only change, the iOS implementation was not impacted.
* Updated the Firebase reporting string to `flutter-fire-fst` to be consistent
  with other reporting libraries.

## 0.12.1

* Added support for `Source` to `Query.getDocuments()` and `DocumentReference.get()`.

## 0.12.0+2

* Bump the minimum Flutter version to 1.5.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.12.0+1

* Send user agent to Firebase.

## 0.12.0

* **Breaking change**. Fixed `CollectionReference.parent` to correctly return a `DocumentReference`.
  If you were using the method previously to obtain the parent
  document's id via `collectionReference.parent().id`,
  you will have to use `collectionReference.parent().documentID` now.
* Added `DocumentReference.parent`.

## 0.11.0+2

* Remove iOS dependency on Firebase/Database and Firebase/Auth CocoaPods.

## 0.11.0+1

* Update iOS CocoaPod dependencies to '~> 6.0' to ensure support for `FieldValue.increment`.

## 0.11.0

* Update Android dependencies to latest.

## 0.10.1

* Support for `startAtDocument`, `startAfterDocument`, `endAtDocument`, `endBeforeDocument`.
* Added additional unit and integration tests.

## 0.10.0

* Support for `FieldValue.increment`.
* Remove `FieldValue.type` and `FieldValue.value` from public API.
* Additional integration testing.

## 0.9.13+1

* Added an integration test for transactions.

## 0.9.13

* Remove Gradle BoM to avoid Gradle version issues.

## 0.9.12

* Move Android dependency to Gradle BoM to help maintain compatibility
  with other FlutterFire plugins.

## 0.9.11

* Bump Android dependencies to latest.

# 0.9.10

* Support for cloud_firestore running in the background on Android.
* Fixed a bug in cleanup for DocumentReference.snapshots().
* Additional integration testing.

## 0.9.9

* Remove `invokeMapMethod` calls to prevent crash.

## 0.9.8

* Add metadata field to DocumentSnapshot.

## 0.9.7+2

* Bump the minimum Flutter version to 1.2.0.
* Add template type parameter to `invokeMethod` calls.

## 0.9.7+1

* Update README with example of getting a document.

## 0.9.7

* Fixes a NoSuchMethodError when using getDocuments on iOS (introduced in 0.9.6).
* Adds a driver test for getDocuments.

## 0.9.6

* On iOS, update null checking to match the recommended pattern usage in the Firebase documentation.
* Fixes a case where snapshot errors might result in plugin crash.

## 0.9.5+2

* Fixing PlatformException(Error 0, null, null) which happened when a successful operation was performed.

## 0.9.5+1

* Log messages about automatic configuration of the default app are now less confusing.

## 0.9.5

* Fix an issue on some iOS devices that results in reading incorrect dates.

## 0.9.4

* No longer sends empty snapshot events on iOS when encountering errors.

## 0.9.3

* Fix transactions on iOS when getting snapshot that doesn't exist.

## 0.9.2

* Fix IllegalStateException errors when using transactions on Android.

## 0.9.1

* Fixed Firebase multiple app support in transactions and document snapshots.

## 0.9.0+2

* Remove categories.

## 0.9.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.9.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.8.2+3

* Resolved "explicit self reference" and "loses accuracy" compiler warnings.

## 0.8.2+2

* Clean up Android build logs. @SuppressWarnings("unchecked")

## 0.8.2+1

* Avoid crash in document snapshot callback.

## 0.8.2

* Added `Firestore.settings`
* Added `Timestamp` class

## 0.8.1+1

* Bump Android dependencies to latest.

## 0.8.1

* Fixed bug where updating arrays in with `FieldValue` always throws an Exception on Android.

## 0.8.0

Note: this version depends on features available in iOS SDK versions 5.5.0 or later.
To update iOS SDK in existing projects run `pod update Firebase/Firestore`.

* Added `Firestore.enablePersistence`
* Added `FieldValue` with all currently supported values: `arrayUnion`, `arrayRemove`, `delete` and
  `serverTimestamp`.
* Added `arrayContains` argument in `Query.where` method.

## 0.7.4

* Bump Android and Firebase dependency versions.

## 0.7.3

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.7.2

* Fixes crash on Android if a FirebaseFirestoreException happened.

## 0.7.1

* Updated iOS implementation to reflect Firebase API changes.
* Fixed bug in Transaction.get that would fail on no data.
* Fixed error in README.md code sample.

## 0.7.0+2

* Update transactions example in README to add `await`.

## 0.7.0+1

* Add transactions example to README.

## 0.7.0

* **Breaking change**. `snapshots` is now a method instead of a getter.
* **Breaking change**. `setData` uses named arguments instead of `SetOptions`.

## 0.6.3

* Updated Google Play Services dependencies to version 15.0.0.

## 0.6.2

* Support for BLOB data type.

## 0.6.1

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 0.6.0

* **Breaking change**. Renamed 'getCollection()' to 'collection().'

## 0.5.1

* Expose the Firebase app corresponding to a Firestore
* Expose a constructor for a Firestore with a non-default Firebase app

## 0.5.0

* **Breaking change**. Move path getter to CollectionReference
* Add id getter to CollectionReference

## 0.4.0

* **Breaking change**. Hide Firestore codec class from public API.
* Adjusted Flutter SDK constraint to match Flutter release with extensible
  platform message codec, required already by version 0.3.1.
* Move each class into separate files

## 0.3.2

* Support for batched writes.

## 0.3.1

* Add GeoPoint class
* Allow for reading and writing DocumentReference, DateTime, and GeoPoint
  values from and to Documents.

## 0.3.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.2.12

* Fix handling of `null` document snapshots (document not exists).
* Add `DocumentSnapshot.exists`.

## 0.2.11
* Fix Dart 2 type errors.

## 0.2.10
* Fix Dart 2 type errors.

## 0.2.9
* Relax sdk upper bound constraint to  '<2.0.0' to allow 'edge' dart sdk use.

## 0.2.8
* Support for Query.getDocuments

## 0.2.7

* Add transaction support.

## 0.2.6

* Build fixes for iOS
* Null checking in newly added Query methods

## 0.2.5

* Query can now have more than one orderBy field.
* startAt, startAfter, endAt, and endBefore support
* limit support

## 0.2.4

* Support for DocumentReference.documentID
* Support for CollectionReference.add

## 0.2.3

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.2.2

* Add `get` to DocumentReference.

## 0.2.1

* Fix bug on Android where removeListener is sometimes called without a handle

## 0.2.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
* Relaxed GMS dependency to [11.4.0,12.0[

## 0.1.2

* Support for `DocumentReference` update and merge writes
* Suppress unchecked warnings and package name warnings on Android

## 0.1.1

* Added FLT prefix to iOS types.

## 0.1.0

* Added reference to DocumentSnapshot
* Breaking: removed path from DocumentSnapshot
* Additional test coverage for reading collections and documents
* Fixed typo in DocumentChange documentation

## 0.0.6

* Support for getCollection

## 0.0.5

* Support `isNull` filtering in `Query.where`
* Fixed `DocumentChange.oldIndex` and `DocumentChange.newIndex` to be signed
  integers (iOS)

## 0.0.4

* Support for where clauses
* Support for deletion

## 0.0.3

* Renamed package to cloud_firestore

## 0.0.2

* Add path property to DocumentSnapshot

## 0.0.1+1

* Update project homepage

## 0.0.1

* Initial Release
