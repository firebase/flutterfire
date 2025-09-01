## 3.2.0

 - **FIX**(firebaseai): Added token details parsing for Dev API ([#17609](https://github.com/firebase/flutterfire/issues/17609)). ([4bab0b30](https://github.com/firebase/flutterfire/commit/4bab0b302898d7c1b613593c20c722125e09843d))
 - **FIX**(firebaseai): remove candidateCount from LiveGenerationConfig since the connection fails silently when it is set ([#17647](https://github.com/firebase/flutterfire/issues/17647)). ([537a3c30](https://github.com/firebase/flutterfire/commit/537a3c30397a82459c02dfdd70e3a9670c26fd59))
 - **FIX**(firebaseai): Export `UnknownPart` ([#17655](https://github.com/firebase/flutterfire/issues/17655)). ([a399e0e1](https://github.com/firebase/flutterfire/commit/a399e0e10328dee89affd1b1def50ebb96d0ae44))
 - **FIX**(firebase_ai): Add `GroundingMetadata` parsing for Developer API ([#17657](https://github.com/firebase/flutterfire/issues/17657)). ([f8ebbaf1](https://github.com/firebase/flutterfire/commit/f8ebbaf10c0ec8f38669371b40bfc125b285d3ea))
 - **FEAT**(firebaseai): add thinking feature ([#17652](https://github.com/firebase/flutterfire/issues/17652)). ([5faec2c1](https://github.com/firebase/flutterfire/commit/5faec2c1ddf0682ef9d88fb2d354f5f3f22405fa))
 - **FEAT**(firebaseai): Add app check limited use token ([#17645](https://github.com/firebase/flutterfire/issues/17645)). ([f2a682a9](https://github.com/firebase/flutterfire/commit/f2a682a90254fb73ef7ef3613d38e4f08fc2fe35))
 - **FEAT**(firebaseai): imagen editing ([#17556](https://github.com/firebase/flutterfire/issues/17556)). ([62811a61](https://github.com/firebase/flutterfire/commit/62811a61354d412c6322bd68004b8d1537e3e483))
 - **FEAT**(firebaseai): add responseJsonSchema to GenerationConfig ([#17564](https://github.com/firebase/flutterfire/issues/17564)). ([def807a7](https://github.com/firebase/flutterfire/commit/def807a7cc6a65bf51aa223c9b2f96e37acfdf79))

## 3.1.0

 - **FIX**(firebaseai): Fix `usageMetadata.thoughtsTokenCount` ([#17608](https://github.com/firebase/flutterfire/issues/17608)). ([fe9ddd33](https://github.com/firebase/flutterfire/commit/fe9ddd331d0ea113d97862728d18b67fb8d3085f))
 - **FIX**(firebase_ai): Expose ThinkingConfig class in firebase_ai.dart for use in GenerationConfig ([#17599](https://github.com/firebase/flutterfire/issues/17599)). ([b03381a4](https://github.com/firebase/flutterfire/commit/b03381a479c6f8c63207b3f709d6d190fd6374d6))
 - **FEAT**(firebaseai): make Live API working with developer API ([#17503](https://github.com/firebase/flutterfire/issues/17503)). ([467eaa18](https://github.com/firebase/flutterfire/commit/467eaa1810257a420039d29a070314784218a03f))
 - **FEAT**(dev-api): add inlineData support to Developer API ([#17600](https://github.com/firebase/flutterfire/issues/17600)). ([5199edb7](https://github.com/firebase/flutterfire/commit/5199edb7dec526ebb8454c0a2eed3ca33947be7f))
 - **FEAT**(firebaseai): handle unknown parts when parsing content ([#17522](https://github.com/firebase/flutterfire/issues/17522)). ([ac59c249](https://github.com/firebase/flutterfire/commit/ac59c249ade0388b9b375766fb6c2f1b0c4daddd))

## 3.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: bump iOS SDK to version 12.0.0 ([#17549](https://github.com/firebase/flutterfire/issues/17549)). ([b2619e68](https://github.com/firebase/flutterfire/commit/b2619e685fec897513483df1d7be347b64f95606))

## 2.3.0

 - **FEAT**(firebase_ai): Add support for Grounding with Google Search ([#17468](https://github.com/firebase/flutterfire/issues/17468)). ([2aaf5af0](https://github.com/firebase/flutterfire/commit/2aaf5af08d46d90bd723997b20109362d9f18d32))
 - **FEAT**(firebaseai): add think feature ([#17409](https://github.com/firebase/flutterfire/issues/17409)). ([18f56142](https://github.com/firebase/flutterfire/commit/18f5614263750e350f549c077040335883fab0b3))

## 2.2.1

 - **FIX**(firebaseai): Fix Imagen image format requests ([#17478](https://github.com/firebase/flutterfire/issues/17478)). ([a90c93f8](https://github.com/firebase/flutterfire/commit/a90c93f88e9c2decd2c45461901fb437ff7ce7a7))

## 2.2.0

 - **FIX**(core): bump Pigeon to v25.3.2 ([#17438](https://github.com/firebase/flutterfire/issues/17438)). ([4d24ef53](https://github.com/firebase/flutterfire/commit/4d24ef534464b39dcaef4151c83c78f87b36fb78))
 - **FEAT**(firebaseai): Add flutter_soloud for sound output in Live API audio streaming example.  ([#17305](https://github.com/firebase/flutterfire/issues/17305)). ([86350e9f](https://github.com/firebase/flutterfire/commit/86350e9f36534cb0dd871f61dba70a44aee7a427))

## 2.1.0

 - **FEAT**(firebaseai): Add flutter_soloud for sound output in Live API audio streaming example.  ([#17305](https://github.com/firebase/flutterfire/issues/17305)). ([86350e9f](https://github.com/firebase/flutterfire/commit/86350e9f36534cb0dd871f61dba70a44aee7a427))

## 2.0.0

[feature] Initial release of the Firebase AI Logic SDK (`FirebaseAI`). This SDK *replaces* the previous Vertex AI in Firebase SDK (`FirebaseVertexAI`) to accommodate the evolving set of supported features and services.
The new Firebase AI Logic SDK provides **preview** support for the Gemini Developer API, including its free tier offering.
Using the Firebase AI Logic SDK with the Vertex AI Gemini API is still generally available (GA).

To start using the new SDK, import the `firebase_ai` package and use the top-level `FirebaseAI` class. See details in the [migration guide](https://firebase.google.com/docs/vertex-ai/migrate-to-latest-sdk).
