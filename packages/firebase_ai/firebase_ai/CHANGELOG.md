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
