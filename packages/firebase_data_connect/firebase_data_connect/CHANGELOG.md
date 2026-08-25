## 0.3.2

 - **REFACTOR**(tests): update listener completion logic and improve WebSocket channel handling ([#18524](https://github.com/firebase/flutterfire/issues/18524)). ([6b1fbc93](https://github.com/firebase/flutterfire/commit/6b1fbc93793db381a7d6d8cfb1a6cb4c8f078d9a))
 - **FIX**(ci): bump Kotlin Gradle plugin to 2.3.0 ([#18600](https://github.com/firebase/flutterfire/issues/18600)). ([4c3865e2](https://github.com/firebase/flutterfire/commit/4c3865e2e56bf59904a9f48a6e70f0f963df2cda))
 - **FIX**(ci): align Android toolchain and analyzer with Flutter 3.47 ([#18566](https://github.com/firebase/flutterfire/issues/18566)). ([87ace849](https://github.com/firebase/flutterfire/commit/87ace8496fec75c461f3b29a9b8a85d46e286957))
 - **FEAT**(sql_connect): update websocket URL for GSLB soft stickiness ([#18531](https://github.com/firebase/flutterfire/issues/18531)). ([5283f143](https://github.com/firebase/flutterfire/commit/5283f1431f9e48e4062c0bbf972c1b558e505014))

## 0.3.1

 - **FIX**(sql_connect): e2e listen test ([#18496](https://github.com/firebase/flutterfire/issues/18496)). ([e512d39a](https://github.com/firebase/flutterfire/commit/e512d39a88f3d8df0eaeb2b7d7a439460b00b8e7))
 - **FIX**(sql_connect): Refactor to improve caching performance for large result sets ([#18430](https://github.com/firebase/flutterfire/issues/18430)). ([fba86301](https://github.com/firebase/flutterfire/commit/fba86301665944a72959cba30bc433842ada37b3))
 - **FEAT**(sql_connect): merge "X-Client-Platform" header into "X-Client-Version" ([#18502](https://github.com/firebase/flutterfire/issues/18502)). ([049fe5ea](https://github.com/firebase/flutterfire/commit/049fe5ea61bbb88bef409788cbabd7ef53226f3e))
 - **FEAT**(sql_connect): add "X-Client-Platform" and "X-Client-Version" headers ([#18484](https://github.com/firebase/flutterfire/issues/18484)). ([04b94acf](https://github.com/firebase/flutterfire/commit/04b94acf8f0a0188d6abbf3770edfe31b4e5ef2e))
 - **FEAT**(data_connect,web): implement hot restart guard for WebSocket transport ([#18370](https://github.com/firebase/flutterfire/issues/18370)). ([3e0ae979](https://github.com/firebase/flutterfire/commit/3e0ae979d4786ace3becbbfc432f585b4f45eb04))

## 0.3.0+7

 - Update a dependency to the latest release.

## 0.3.0+6

 - Update a dependency to the latest release.

## 0.3.0+5

 - Update a dependency to the latest release.

## 0.3.0+4

 - Update a dependency to the latest release.

## 0.3.0+3

 - Update a dependency to the latest release.

## 0.3.0+2

 - Update a dependency to the latest release.

## 0.3.0+1

 - **REFACTOR**: move all packages to workspace ([#18182](https://github.com/firebase/flutterfire/issues/18182)). ([6cdfcb10](https://github.com/firebase/flutterfire/commit/6cdfcb103da7be46ccb190d7e107d8c537aa1ff8))
 - **FIX**: update core, auth and app-check logic so internal resources on method channels are properly disposed ([#18268](https://github.com/firebase/flutterfire/issues/18268)). ([a0de4ed8](https://github.com/firebase/flutterfire/commit/a0de4ed86b0dff89bb9e557f2a54f38cd2546016))
 - **FIX**(fdc): block reconnecting if there are no active subscribers or pending unary calls. ([#18265](https://github.com/firebase/flutterfire/issues/18265)). ([330bbb83](https://github.com/firebase/flutterfire/commit/330bbb83399f37911f938a59dc660ed84a0c83a3))
 - **FIX**(fdc): remove unused logs ([#18197](https://github.com/firebase/flutterfire/issues/18197)). ([4c17ca87](https://github.com/firebase/flutterfire/commit/4c17ca870a78ae6afeaad6006ca68e7999711ffd))

## 0.3.0

 - **FEAT**(fdc): Streaming implementation for data connect ([#18174](https://github.com/firebase/flutterfire/issues/18174)). ([6ce6f6b2](https://github.com/firebase/flutterfire/commit/6ce6f6b2369b9d43e69b24b284d8ef816c430e31))
 - **FEAT**(app_check,windows): add support for AppCheck for Windows ([#18140](https://github.com/firebase/flutterfire/issues/18140)). ([81f30325](https://github.com/firebase/flutterfire/commit/81f30325fc926fe94b630e49f56b795c781a4cbe))

## 0.2.4

 - **FIX**(data_connect): fix UTF 8 characters decoding in data connect ([#18120](https://github.com/firebase/flutterfire/issues/18120)). ([25ec5c42](https://github.com/firebase/flutterfire/commit/25ec5c429863c34f8473daad7f83487a31dcd7a1))
 - **FIX**(fdc,web): add WASM support and improve CI ([#18074](https://github.com/firebase/flutterfire/issues/18074)). ([904249eb](https://github.com/firebase/flutterfire/commit/904249ebc67b14115aebe619b2874b0fd325a3ce))
 - **FEAT**(ios): migrate iOS to UIScene lifecycle ([#18054](https://github.com/firebase/flutterfire/issues/18054)). ([3ffa4110](https://github.com/firebase/flutterfire/commit/3ffa411098132fd5182a84be4e7a226106bc7451))

## 0.2.3

 - **REFACTOR**(fdc): Support for entityId path extensions and hardening ([#17988](https://github.com/firebase/flutterfire/issues/17988)). ([fed585f5](https://github.com/firebase/flutterfire/commit/fed585f5a9b65d683cefdc7fa97ed2692e4ec817))
 - **FIX**: resolve lint issues ([#18017](https://github.com/firebase/flutterfire/issues/18017)). ([e8e85397](https://github.com/firebase/flutterfire/commit/e8e85397ccdcab6c8b84348884b4673f86b79d1c))
 - **FEAT**(fdc): Data Connect client sdk caching ([#17890](https://github.com/firebase/flutterfire/issues/17890)). ([02a019bc](https://github.com/firebase/flutterfire/commit/02a019bc25bb4a49d62c1079ed15e0c3aec8a5ec))

## 0.2.2+2

 - Update a dependency to the latest release.

## 0.2.2+1

 - Update a dependency to the latest release.

## 0.2.2

 - **FEAT**(database): add support for Pigeon. Update iOS to Swift and Android to Kotlin ([#17686](https://github.com/firebase/flutterfire/issues/17686)). ([dac0b0bd](https://github.com/firebase/flutterfire/commit/dac0b0bd033b1c51446aedf0413740ef426877b8))

## 0.2.1+2

 - Update a dependency to the latest release.

## 0.2.1+1

 - **FIX**(app_check): Deprecate androidProvider and appleProvider parameters in activate method ([#17742](https://github.com/firebase/flutterfire/issues/17742)). ([4e7f800e](https://github.com/firebase/flutterfire/commit/4e7f800e94a895c6553bd3c1595b4f06ac69bb81))

## 0.2.1

 - **FIX**(fdc): add support Int64 to nativeFromJson ([#17673](https://github.com/firebase/flutterfire/issues/17673)). ([451e7a46](https://github.com/firebase/flutterfire/commit/451e7a462ef8ecc2e4134ad6f8aec10f13793bf4))
 - **FIX**(fdc): issue where if path was empty on web, the app crashed ([#17704](https://github.com/firebase/flutterfire/issues/17704)). ([e9a6c045](https://github.com/firebase/flutterfire/commit/e9a6c045054b54d464ef6dbcc63c5be63db00db9))
 - **FEAT**(app-check): Debug token support for the activate method ([#17723](https://github.com/firebase/flutterfire/issues/17723)). ([3c638264](https://github.com/firebase/flutterfire/commit/3c638264565d902ddbe4dff5bb027aef9e1c2140))

## 0.2.0+2

 - Update a dependency to the latest release.

## 0.2.0+1

 - Update a dependency to the latest release.

## 0.2.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: bump iOS SDK to version 12.0.0 ([#17549](https://github.com/firebase/flutterfire/issues/17549)). ([b2619e68](https://github.com/firebase/flutterfire/commit/b2619e685fec897513483df1d7be347b64f95606))
 - **BREAKING** **FEAT**(auth): remove deprecated functions ([#17562](https://github.com/firebase/flutterfire/issues/17562)). ([d50aad95](https://github.com/firebase/flutterfire/commit/d50aad954443904d64d4ebd4442ebc63ed702986))
 - **BREAKING** **FEAT**: bump Android SDK to version 34.0.0 ([#17554](https://github.com/firebase/flutterfire/issues/17554)). ([a5bdc051](https://github.com/firebase/flutterfire/commit/a5bdc051d40ee44e39cf0b8d2a7801bc6f618b67))

## 0.1.5+4

 - **FIX**(fdc): Fixed readme link  ([#17504](https://github.com/firebase/flutterfire/issues/17504)). ([6068edf9](https://github.com/firebase/flutterfire/commit/6068edf9eab36dbb94768d46a6def97e76f30df2))

## 0.1.5+3

 - Update a dependency to the latest release.

## 0.1.5+2

 - Update a dependency to the latest release.

## 0.1.5+1

 - **FIX**(fdc): fix an issue where if null is set, an empty value was being sent ([#17373](https://github.com/firebase/flutterfire/issues/17373)). ([53320dc6](https://github.com/firebase/flutterfire/commit/53320dc60fa5639051fbb77d21ed493f23381273))

## 0.1.5

 - **FIX**(data_connect): avoid calling toJson on raw JSON map or null object ([#17356](https://github.com/firebase/flutterfire/issues/17356)). ([7bd63691](https://github.com/firebase/flutterfire/commit/7bd63691ffa7405d24ea4545bd1ac7f8971175b3))
 - **FEAT**(fdc): Included platform detection changes ([#17308](https://github.com/firebase/flutterfire/issues/17308)). ([e53c7071](https://github.com/firebase/flutterfire/commit/e53c7071e2566b7e016fda312d92dd03fcb1bc9e))

## 0.1.4+1

 - Update a dependency to the latest release.

## 0.1.4

 - **FEAT**(fdc): Implemented partial errors ([#17148](https://github.com/firebase/flutterfire/issues/17148)). ([e97eb0b2](https://github.com/firebase/flutterfire/commit/e97eb0b229390afa01e61b9e7bfbd496b51cc80a))
 - **FEAT**(fdc): Upgraded from v1beta to v1 ([#17152](https://github.com/firebase/flutterfire/issues/17152)). ([26ae7d36](https://github.com/firebase/flutterfire/commit/26ae7d36359c4daa001b634ca8a903f9d5735184))

## 0.1.3+2

 - **FIX**(fdc): Minor changes to improve score ([#17126](https://github.com/firebase/flutterfire/issues/17126)). ([dbe29870](https://github.com/firebase/flutterfire/commit/dbe29870e4dc81316517032c1eb4ecb95c7ee3f1))

## 0.1.3+1

 - Update a dependency to the latest release.

## 0.1.3

 - **FEAT**(fdc): Added x-firebase-client header ([#17015](https://github.com/firebase/flutterfire/issues/17015)). ([c67075e5](https://github.com/firebase/flutterfire/commit/c67075e537eda46774884d2e40b6e265e64f73b2))

## 0.1.2+7

 - Update a dependency to the latest release.

## 0.1.2+6

 - Update a dependency to the latest release.

## 0.1.2+5

 - **FIX**(fdc): Don't throw when FirebaseAuth is unable to get an ID Token ([#16711](https://github.com/firebase/flutterfire/issues/16711)). ([1ef2044a](https://github.com/firebase/flutterfire/commit/1ef2044a7a9f2004f933147a8494fb82fa4c3c26))

## 0.1.2+4

 - **FIX**(fdc): Don't throw when FirebaseAuth is unable to get an ID Token ([#16711](https://github.com/firebase/flutterfire/issues/16711)). ([1ef2044a](https://github.com/firebase/flutterfire/commit/1ef2044a7a9f2004f933147a8494fb82fa4c3c26))

## 0.1.2+3

 - Update a dependency to the latest release.

## 0.1.2+2

 - Update a dependency to the latest release.

## 0.1.2+1

 - **FIX**(fdc): Fix issue where auth wasn't properly refreshing id token ([#13509](https://github.com/firebase/flutterfire/issues/13509)). ([0158ad20](https://github.com/firebase/flutterfire/commit/0158ad20925646e8a21c17adc8793e870f3a65d6))
 - **FIX**(fdc): Updated licenses ([#13470](https://github.com/firebase/flutterfire/issues/13470)). ([a1de14fd](https://github.com/firebase/flutterfire/commit/a1de14fde34e6b352f0d4a098d88ee9df542cf27))

## 0.1.2

 - **FIX**(fdc): Fix serializing errors ([#13450](https://github.com/firebase/flutterfire/issues/13450)). ([9a5aba2a](https://github.com/firebase/flutterfire/commit/9a5aba2aedb2e1ab4f9a979f07392113630c1672))
 - **FEAT**(fdc): Update with builder notation ([#13434](https://github.com/firebase/flutterfire/issues/13434)). ([2c865056](https://github.com/firebase/flutterfire/commit/2c865056f4aba7afa4945b85e687afffccd66981))

## 0.1.1+1

 - **FIX**(fdc): errors are now properly propagated to the user ([#13433](https://github.com/firebase/flutterfire/issues/13433)). ([973a02f1](https://github.com/firebase/flutterfire/commit/973a02f1daf62f5ba4f65c33d09c8872164f9f6b))

## 0.1.1

 - **FEAT**(fdc): Restrict exports of firebase_data_connect ([#13403](https://github.com/firebase/flutterfire/issues/13403)). ([4bdd9472](https://github.com/firebase/flutterfire/commit/4bdd947269bd07ac4f47132b61559eda72aa597c))
 - **FEAT**(fdc): Fix NativeToJSON ([#13401](https://github.com/firebase/flutterfire/issues/13401)). ([60100850](https://github.com/firebase/flutterfire/commit/601008508d3a897c7ccdb4d0c99568259d0724e1))
 - **FEAT**(fdc): Implement any scalar support ([#13376](https://github.com/firebase/flutterfire/issues/13376)). ([b2500a97](https://github.com/firebase/flutterfire/commit/b2500a974ec66c032de4686ac49ce625b7c97363))
 - **FEAT**(fdc): Implement Timestamp and DateTime types ([#13387](https://github.com/firebase/flutterfire/issues/13387)). ([181f2081](https://github.com/firebase/flutterfire/commit/181f2081ab62b657024d669b93aa261e6aeaf14c))
 - **FEAT**(fdc): Updated to allow for sdktype to be set (core vs gen) ([#13392](https://github.com/firebase/flutterfire/issues/13392)). ([78655133](https://github.com/firebase/flutterfire/commit/7865513354712f0b16da62d79497456930f95449))
 - **FEAT**(fdc): Add GMP header ([#13358](https://github.com/firebase/flutterfire/issues/13358)). ([3a2ad61d](https://github.com/firebase/flutterfire/commit/3a2ad61d190712b2821743577377e00c07d01434))
 - **FEAT**(fdc): Upgrade to v1beta endpoint ([#13373](https://github.com/firebase/flutterfire/issues/13373)). ([77ded00f](https://github.com/firebase/flutterfire/commit/77ded00fef499c147938b997b858e9998c2a9c3b))
 - **FEAT**(fdc): Make Serializer required ([#13386](https://github.com/firebase/flutterfire/issues/13386)). ([eb9a8135](https://github.com/firebase/flutterfire/commit/eb9a8135a0467871ce8b1e798e672575d140a88b))

## 0.1.0

> Note: This release has breaking changes.

 - **FEAT**(fdc): Initial Release of Data Connect ([#13313](https://github.com/firebase/flutterfire/issues/13313)). ([603a6726](https://github.com/firebase/flutterfire/commit/603a67261a2f7cbdd6ef594bfaef480aeb820683))
 - **BREAKING** **FEAT**(fdc): commit as breaking change to bump `firebase_data_connect` to v0.1.0 ([#13345](https://github.com/firebase/flutterfire/issues/13345)). ([0022a353](https://github.com/firebase/flutterfire/commit/0022a3530642a0a483e20653502dd720268016c4))

## 0.0.1

- Initial development version.
