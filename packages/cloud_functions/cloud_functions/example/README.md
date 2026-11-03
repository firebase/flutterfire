# cloud_functions_example

Demonstrates how to use the cloud_functions plugin, side by side with the
experimental pure-Dart `dart_cloud_functions` package: a **Native | Dart**
toggle switches which one sends the calls.

## Functions

The example calls functions from the e2e test backend in
`.github/workflows/scripts/functions/src/index.ts`:

| Button | Function |
|---|---|
| **Call by Name** | `listFruit` |
| **Call by URL** | `listfruits2ndgen` |
| **Call Stream Function** (also runs at startup) | `testStreamResponse` |
| **Who am I?** | `testEchoContext` |

## Run against the emulators

From `.github/workflows/scripts`, install and build the test functions once
with `npm ci --prefix functions`, then start the emulators with
`firebase emulators:start --only auth,functions --project flutterfire-e2e-tests`.
Then run `flutter run` from this directory.

## Run against a deployed project

By default, the example calls the local emulators. To also call functions
deployed to a real Firebase project:

1. In the Firebase console, enable **Anonymous** sign-in and register the apps
   for the platforms you run: Android and iOS use
   `io.flutter.plugins.firebase.functions.example`, macOS reuses the iOS app,
   and web needs a web app.
2. Deploy the test functions in `.github/workflows/scripts/functions`:
   `firebase deploy --only functions --project <project-id>`.
3. Create `deployed.env.json` in this directory (it's git-ignored), with the
   values from the console's **Project settings**:

   ```json
   {
     "DEPLOYED_PROJECT_ID": "<Project ID>",
     "DEPLOYED_API_KEY": "<Web API Key>",
     "DEPLOYED_MESSAGING_SENDER_ID": "<Project number>",
     "DEPLOYED_ANDROID_APP_ID": "<Android app's App ID>",
     "DEPLOYED_IOS_APP_ID": "<iOS app's App ID>",
     "DEPLOYED_WEB_APP_ID": "<web app's App ID>"
   }
   ```

   You only need the App IDs for the platforms you run. **Call by URL** uses
   `listfruits2ndgen`'s `cloudfunctions.net` URL, unless you add another one,
   such as its `run.app` URL, as `DEPLOYED_LIST_FRUITS_URL`.
4. Run with `flutter run --dart-define-from-file=deployed.env.json`.

The app then shows an **Emulator | Deployed** toggle. Deployed calls go through
a second Firebase app named `deployed`, so the default app stays pointed at the
emulators.

The `dart_cloud_functions` e2e suite can run against the deployed project too.
Deploy all the test functions (`--only functions`), then pass the same file:

```sh
flutter test integration_test/dart_cloud_functions_e2e_test.dart --dart-define-from-file=deployed.env.json
```

The test names then include the project ID, so you can tell which run was
which.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.dev/).
