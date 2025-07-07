## 1.8.2

 - Update a dependency to the latest release.

## 1.8.1

 - **FIX**(core): bump Pigeon to v25.3.2 ([#17438](https://github.com/firebase/flutterfire/issues/17438)). ([4d24ef53](https://github.com/firebase/flutterfire/commit/4d24ef534464b39dcaef4151c83c78f87b36fb78))

## 1.8.0

 - **FEAT**(firebaseai): Add flutter_soloud for sound output in Live API audio streaming example.  ([#17305](https://github.com/firebase/flutterfire/issues/17305)). ([86350e9f](https://github.com/firebase/flutterfire/commit/86350e9f36534cb0dd871f61dba70a44aee7a427))

## 1.7.0

[changed] **Renamed / Replaced:** Vertex AI in Firebase and its `FirebaseVertexAI` library have been renamed and replaced by the new Firebase AI Logic SDK: `FirebaseAI`. This is to accommodate the evolving set of supported features and services. Please migrate to the new `FirebaseAI` module. See details in the [migration guide](https://firebase.google.com/docs/vertex-ai/migrate-to-latest-sdk).

Note: Existing `FirebaseVertexAI` users may continue to use `import firebase_vertexai` and the `FirebaseVertexAI` top-level class, though these will be removed in a future release. Also, going forward, new features will only be added into the new `FirebaseAI` module.

## 1.6.0

 - **FIX**(vertexai): add missing HarmBlockThreshold to exported APIs ([#17249](https://github.com/firebase/flutterfire/issues/17249)). ([59d902c6](https://github.com/firebase/flutterfire/commit/59d902c63bd1bd040f5357cb6a341db446429430))
 - **FEAT**(vertexai): Live API breaking changes ([#17299](https://github.com/firebase/flutterfire/issues/17299)). ([69cd2a64](https://github.com/firebase/flutterfire/commit/69cd2a640d25e0f2b623f2e631d090ead8af140d))

## 1.5.0

 - **FIX**(vertex_ai): handle null predictions ([#17211](https://github.com/firebase/flutterfire/issues/17211)). ([d559703d](https://github.com/firebase/flutterfire/commit/d559703d71904918fc5c0e8ad02b86313738d263))
 - **FIX**(vertexai): follow up changes for LiveModel ([#17236](https://github.com/firebase/flutterfire/issues/17236)). ([a7a842ef](https://github.com/firebase/flutterfire/commit/a7a842ef3ecee197dc5c2eefd12781086071d53b))
 - **FIX**(vertexai): Add meta to the dependency list ([#17208](https://github.com/firebase/flutterfire/issues/17208)). ([5c9c2221](https://github.com/firebase/flutterfire/commit/5c9c222198dc9ea8d1af8535e8d64ca2e2174ea4))
 - **FEAT**(vertexai): Add repetition penalties to GenerationConfig ([#17234](https://github.com/firebase/flutterfire/issues/17234)). ([6e23afc2](https://github.com/firebase/flutterfire/commit/6e23afc2d7d1ed177f8c54741f2e26a6cbb892e8))
 - **FEAT**(vertexai): Add Live streaming feature ([#16991](https://github.com/firebase/flutterfire/issues/16991)). ([4ab6b4c9](https://github.com/firebase/flutterfire/commit/4ab6b4c92878eec4c12b2bf57553d85a2288b8f3))
 - **FEAT**(vertexai): Add HarmBlockMethod ([#17125](https://github.com/firebase/flutterfire/issues/17125)). ([bbf618db](https://github.com/firebase/flutterfire/commit/bbf618dbb0def1c9afaccedf6fcddda80d8c96ac))
 - **FEAT**(vertexai): Unhandled ContentModality fix with more multimodal examples for vertexai testapp ([#17150](https://github.com/firebase/flutterfire/issues/17150)). ([76461d78](https://github.com/firebase/flutterfire/commit/76461d78631d5e9ce128f5cb79bc21483fd53508))

## 1.4.0

 - **FEAT**(vertexai): add Imagen support ([#16976](https://github.com/firebase/flutterfire/issues/16976)). ([cd9d896d](https://github.com/firebase/flutterfire/commit/cd9d896d87ffe9f4949b025ddbb13b88bafbc176))

## 1.3.0

 - **FEAT**(vertexai): add support for token-based usage metrics ([#17065](https://github.com/firebase/flutterfire/issues/17065)). ([b1bd93fb](https://github.com/firebase/flutterfire/commit/b1bd93fb25dbe36621fbc4b13e13bec805b79328))

## 1.2.0

 - **FIX**(firebase_vertexai): Corrected minor typo in VertexAISDKException ([#17033](https://github.com/firebase/flutterfire/issues/17033)). ([ba543d08](https://github.com/firebase/flutterfire/commit/ba543d08a68f60476ce2b2260506fe035c503aaa))
 - **FEAT**(vertexai): organize example page and functions ([#17008](https://github.com/firebase/flutterfire/issues/17008)). ([6b76260d](https://github.com/firebase/flutterfire/commit/6b76260de7bc03aa6e1cd68bed2e224d53437239))

## 1.1.1

 - Update a dependency to the latest release.

## 1.1.0

 - **FIX**(firebase_vertexai): Remove unnecessary trailing whitespace ([#16926](https://github.com/firebase/flutterfire/issues/16926)). ([d9c98c40](https://github.com/firebase/flutterfire/commit/d9c98c403b4652c2a962c015e0f05d21ae580a71))

## 1.0.4

 - Update a dependency to the latest release.

## 1.0.3

 - Update a dependency to the latest release.

## 1.0.2

 - **FIX**(vertexai): fix the url in the service not available error ([#13547](https://github.com/firebase/flutterfire/issues/13547)). ([a8bfebd7](https://github.com/firebase/flutterfire/commit/a8bfebd7295f26f7ef16e2ed51a8ccaa35755c46))

## 1.0.1

 - **FIX**(vertexai): hotfix for vertexai auth access to storage ([#13534](https://github.com/firebase/flutterfire/issues/13534)). ([9f693094](https://github.com/firebase/flutterfire/commit/9f6930947dbd35a61c583c17bb128f1af4702a5d))

## 1.0.0

Use the Vertex AI in Firebase SDK to call the Vertex AI Gemini API directly from your app. This client SDK is built specifically for use with Flutter apps, offering security options against unauthorized clients as well as integrations with other Firebase services.

  * If you're new to this SDK, visit the getting started guide.
  * If you used the preview version of the library, visit the migration guide to learn about some important updates.

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**(vertexai): Vertex AI in Firebase is now Generally Available (GA) and can be used in production apps. ([#13453](https://github.com/firebase/flutterfire/issues/13453)). ([77b48800](https://github.com/firebase/flutterfire/commit/77b488001a2b68b46ccff4fc96d143ef891d3e5a))

## 0.2.3+4

 - Update a dependency to the latest release.

## 0.2.3+3

 - Update a dependency to the latest release.

## 0.2.3+2

 - Update a dependency to the latest release.

## 0.2.3+1

 - Update a dependency to the latest release.

## 0.2.3

 - **FIX**(vertexai): update history getter to reflect google_generative_ai updates ([#13040](https://github.com/firebase/flutterfire/issues/13040)). ([cc542d76](https://github.com/firebase/flutterfire/commit/cc542d76b989d550f29a9b0a1adb761da64372a7))
 - **FEAT**: bump iOS SDK to version 11.0.0 ([#13158](https://github.com/firebase/flutterfire/issues/13158)). ([c0e0c997](https://github.com/firebase/flutterfire/commit/c0e0c99703ea394d1bb873ac225c5fe3539b002d))

## 0.2.2+4

 - Update a dependency to the latest release.

## 0.2.2+3

 - Update a dependency to the latest release.

## 0.2.2+2

 - Update a dependency to the latest release.

## 0.2.2+1

 - Update a dependency to the latest release.

## 0.2.2

 - **FEAT**(vertexai): add name constructor for function calling schema ([#12898](https://github.com/firebase/flutterfire/issues/12898)). ([466884b6](https://github.com/firebase/flutterfire/commit/466884b6474b47ffe4f3f4ca5b3e989a5898dba9))

## 0.2.1

 - **FIX**(vertexai): fix the countTokens brokage ([#12899](https://github.com/firebase/flutterfire/issues/12899)). ([e946eb9b](https://github.com/firebase/flutterfire/commit/e946eb9b429da16bea617b68dda32f23d0deb5bc))

## 0.2.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: bump all iOS deployment targets to iOS 13 ahead of Firebase iOS SDK `v11` breaking change ([#12872](https://github.com/firebase/flutterfire/issues/12872)). ([de0cea2c](https://github.com/firebase/flutterfire/commit/de0cea2c3c36694a76361be784255986fac84a43))

## 0.1.1

 - **REFACTOR**(vertexai): Split into separate libraries ([#12794](https://github.com/firebase/flutterfire/issues/12794)). ([85a517f4](https://github.com/firebase/flutterfire/commit/85a517f42930ce902881be9b321e360b0801530f))
 - **FEAT**(vertexai): Add support for UsageMetaData ([#12787](https://github.com/firebase/flutterfire/issues/12787)). ([08f61ecb](https://github.com/firebase/flutterfire/commit/08f61ecb05526d52a469436248833d5d93f85298))
 - **FEAT**(vertexai): Add a few more parameters to the model request ([#12824](https://github.com/firebase/flutterfire/issues/12824)). ([35ad8d41](https://github.com/firebase/flutterfire/commit/35ad8d41237af2190c9a6ef2ebdfff08b4e813cf))
 - **FEAT**(vertex): Add auth support in the vertexai ([#12797](https://github.com/firebase/flutterfire/issues/12797)). ([3241c0b8](https://github.com/firebase/flutterfire/commit/3241c0b8a9a7dbb4d8ba85d5d0ace35b82204222))

## 0.1.0+1

 - Update a dependency to the latest release.

## 0.1.0

- Initial release of the Vertex AI in Firebase SDK (public preview). Learn how to [get started](https://firebase.google.com/docs/vertex-ai/get-started) with the SDK in your app.
