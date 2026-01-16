## 3.6.1

 - Update a dependency to the latest release.

## 3.6.0

 - **FEAT**(firebaseai): Added support for Server Prompt Template ([#17767](https://github.com/firebase/flutterfire/issues/17767)). ([8ff653e5](https://github.com/firebase/flutterfire/commit/8ff653e5bad247fe4f2f72afef45375606509d11))

## 3.5.0

 - **FEAT**(firebase_ai): add malformedFunctionCall reason to FinishReason enum and update tests ([#17834](https://github.com/firebase/flutterfire/issues/17834)). ([38fc083b](https://github.com/firebase/flutterfire/commit/38fc083b0f940158cb9aeb01fe9e9b96ed162e70))
 - **FEAT**(firebaseai): add bidi transcript ([#17700](https://github.com/firebase/flutterfire/issues/17700)). ([be12eede](https://github.com/firebase/flutterfire/commit/be12eede158bd4a7870bc9a5dcea11b534ca6112))

## 3.4.0

 - **FIX**: update topics in pubspec.yaml for firebase_ai ([#17759](https://github.com/firebase/flutterfire/issues/17759)). ([ab2301d2](https://github.com/firebase/flutterfire/commit/ab2301d2b2943c87279ce7ba4694a90b49eb98fc))
 - **FIX**(firebase_ai): add validation for PromptFeedback parsing and handle empty cases ([#17753](https://github.com/firebase/flutterfire/issues/17753)). ([91baa07b](https://github.com/firebase/flutterfire/commit/91baa07bb56198c687b670aa4617fb810dfad212))
 - **FIX**(ai): the package version number wasn't properly updated after migrating from vertex_ai ([#17745](https://github.com/firebase/flutterfire/issues/17745)). ([43059b9b](https://github.com/firebase/flutterfire/commit/43059b9b68b0ba1d9e8fdafffa4e85b6eea8aaf3))
 - **FEAT**(firebaseai): mark imagen generate function ga ([#17757](https://github.com/firebase/flutterfire/issues/17757)). ([a52255e2](https://github.com/firebase/flutterfire/commit/a52255e26306ea7cb890d48f3b9335d574147a82))
 - **FEAT**(firebaseai): update of bidi input api ([#17662](https://github.com/firebase/flutterfire/issues/17662)). ([6d1a0daf](https://github.com/firebase/flutterfire/commit/6d1a0daf524bc7a8e24ea45ceb8c7869be78dbc1))
 - **FEAT**(firebaseai): Add support for URL context ([#17736](https://github.com/firebase/flutterfire/issues/17736)). ([f3656634](https://github.com/firebase/flutterfire/commit/f3656634a5436ce7231aa39fc9b9814e906d2b9d))

## 3.3.0

 - **FIX**(firebaseai): fix the json parse for toolCallCancellation ([#17690](https://github.com/firebase/flutterfire/issues/17690)). ([7c0496d6](https://github.com/firebase/flutterfire/commit/7c0496d6434d81ac35f8df3fe965d0648dcc21bc))
 - **FEAT**(firebaseai): code execution ([#17661](https://github.com/firebase/flutterfire/issues/17661)). ([032a707d](https://github.com/firebase/flutterfire/commit/032a707dfc773f8dda1832635d2c969cfb426a14))
 - **FEAT**(firebaseai): add imagen safetysetting attributes ([#17707](https://github.com/firebase/flutterfire/issues/17707)). ([f7070f04](https://github.com/firebase/flutterfire/commit/f7070f042a3e3319dd1001d35e4926e01c78d4dc))

## 3.2.0

 - **FIX**(firebaseai): Added token details parsing for Dev API ([#17609](https://github.com/firebase/flutterfire/issues/17609)). ([4bab0b30](https://github.com/firebase/flutterfire/commit/4bab0b302898d7c1b613593c20c722125e09843d))
 - **FIX**(firebaseai): remove candidateCount from LiveGenerationConfig since the connection fails silently when it is set ([#17647](https://github.com/firebase/flutterfire/issues/17647)). ([537a3c30](https://github.com/firebase/flutterfire/commit/537a3c30397a82459c02dfdd70e3a9670c26fd59))
 - **FIX**(firebaseai): Export `UnknownPart` ([#17655](https://github.com/firebase/flutterfire/issues/17655)). ([a399e0e1](https://github.com/firebase/flutterfire/commit/a399e0e10328dee89affd1b1def50ebb96d0ae44))
 - **FIX**(firebase_ai): Add `GroundingMetadata` parsing for Developer API ([#17657](https://github.com/firebase/flutterfire/issues/17657)). ([f8ebbaf1](https://github.com/firebase/flutterfire/commit/f8ebbaf10c0ec8f38669371b40bfc125b285d3ea))
 - **FEAT**(firebaseai): add thinking feature ([#17652](https://github.com/firebase/flutterfire/issues/17652)). ([5faec2c1](https://github.com/firebase/flutterfire/commit/5faec2c1ddf0682ef9d88fb2d354f5f3f22405fa))
 - **FEAT**(firebaseai): Add support for limited-use tokens with Firebase App Check.
  These limited-use tokens are required for an upcoming optional feature called
  _replay protection_. We recommend
  [enabling the usage of limited-use tokens](https://firebase.google.com/docs/ai-logic/app-check)
  now so that when replay protection becomes available, you can enable it sooner
  because more of your users will be on versions of your app that send limited-use tokens. ([#17645](https://github.com/firebase/flutterfire/issues/17645)). ([f2a682a9](https://github.com/firebase/flutterfire/commit/f2a682a90254fb73ef7ef3613d38e4f08fc2fe35)). 
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
