# dart_cloud_functions

> [!WARNING]
> Experimental and unpublished. The API and behavior may change, so don't use
> it in production.

A pure-Dart client for Firebase
[callable functions](https://firebase.google.com/docs/functions/callable). It
sends callable requests over HTTPS with `package:http`, without the native
Firebase SDKs.

Its API mirrors the `cloud_functions` plugin with a `Dart` prefix
(`DartFirebaseFunctions`, `DartHttpsCallable`, …), so the two can be used side
by side in the same app and compared one-to-one.

| `cloud_functions` | `dart_cloud_functions` |
|---|---|
| `FirebaseFunctions` | `DartFirebaseFunctions` |
| `HttpsCallable` | `DartHttpsCallable` |
| `HttpsCallableOptions` | `DartHttpsCallableOptions` |
| `HttpsCallableResult` | `DartHttpsCallableResult` |
| `StreamResponse`, `Chunk`, `Result` | `DartStreamResponse`, `DartChunk`, `DartResult` |
| `FirebaseFunctionsException` | `DartFirebaseFunctionsException` |

## Status

- **Supported** on Android, iOS, macOS and web: calls by name (with a region
  or custom domain) or by URL, streaming, the Cloud Functions emulator,
  timeouts, the Auth ID token, and App Check tokens, including limited-use
  ones.
- **Tested:** the unit tests run on the VM and in Chrome. The e2e suite passes
  against the emulators on Android, iOS, macOS and web, and against a deployed
  project on iOS and macOS; its streaming cases haven't run on Android yet.
  Windows and Linux are untested.
- **Not yet supported:**
  - FCM tokens: requests are sent without them.
  - Large integers: they're sent as plain JSON numbers rather than the
    protocol's `Int64Value` wrappers, and wrappers in responses aren't turned
    back into integers.
  - Cancelling a call, like `cloud_functions`' `webAbortSignal` on web. A
    stream is cancelled by cancelling its subscription.
- **Known differences from `cloud_functions`,** besides the deliberate ones
  under [Behavior by platform](#behavior-by-platform):
  - It depends on `firebase_auth` and `firebase_app_check`, even in apps that
    don't use them.
  - A call that can't reach the server fails with `unavailable`. On web,
    `cloud_functions` reports `internal`.
  - Requests go through `package:http`'s default client (`dart:io` on Android,
    iOS and macOS) instead of the platform networking the native SDKs use, so
    the system's proxy settings don't apply.

## Usage

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

final functions = DartFirebaseFunctions.instance
  ..useFunctionsEmulator('localhost', 5001); // Optional: local emulator.

try {
  final result = await functions.httpsCallable('listFruit').call();
  print(result.data);
} on DartFirebaseFunctionsException catch (e) {
  print('${e.code}: ${e.message} ${e.details}');
}
```

- `DartFirebaseFunctions.instanceFor(app: ..., region: ...)` selects another
  app or region. Instances are cached per app and region. The region may also
  be a custom domain such as `https://example.com`.
- Calls carry the ID token of the user signed in to Firebase Auth, as
  `Authorization: Bearer <token>`, like `cloud_functions`.
- Once the app has set up App Check (`FirebaseAppCheck.instance.activate()`),
  calls also carry an App Check token as `X-Firebase-AppCheck`.
  `DartHttpsCallableOptions(limitedUseAppCheckToken: true)` sends a
  limited-use token instead, for functions that use replay protection. These
  tokens are why the package depends on `firebase_auth` and
  `firebase_app_check`.
- Tokens are only sent over HTTPS or to the local machine (`localhost`,
  `127.0.0.1`, `::1`, or `10.0.2.2` from the Android emulator). A call that
  would send them over plain HTTP anywhere else fails with `unauthenticated`.
  To call an emulator at your computer's LAN address from a physical device,
  set `allowInsecureTokenAttachment = true`, as in `cloud_functions`. Only
  debug builds honor it.
- `httpsCallableFromUrl()` and `httpsCallableFromUri()` call a function by URL,
  such as a 2nd gen function's `*.run.app` URL.
- `DartHttpsCallableOptions(timeout: ...)` sets the call timeout (60 seconds by
  default). A call that takes longer fails with `deadline-exceeded`, and one
  that can't reach the server fails with `unavailable`.
- `DartFirebaseFunctionsException` extends `FirebaseException` and uses the
  same error codes as `cloud_functions`, so `on FirebaseException catch (e)`
  handles errors from both.

### Streaming

A 2nd gen function can send chunks with `sendChunk()` before it returns.
`stream()` delivers them as `DartChunk`s, then the return value as a
`DartResult`:

```dart
final responses = functions.httpsCallable('countdown').stream<int, String>();
await for (final response in responses) {
  switch (response) {
    case DartChunk(:final partialData):
      print('Chunk: $partialData');
    case DartResult(:final result):
      print('Result: ${result.data}');
  }
}
```

- The request starts when the stream is listened to. Cancelling the
  subscription aborts it.
- Errors, including those the function throws mid-stream, arrive as
  `DartFirebaseFunctionsException` errors on the stream.
- On Android, iOS and macOS, a stream fails with `deadline-exceeded` if
  nothing arrives for `DartHttpsCallableOptions.timeout`. The server's
  heartbeats count, so long streams keep going. Web streams have no timeout,
  as in the JS SDK.

## Behavior by platform

On each platform, the package follows the SDK that `cloud_functions` uses
there: the native SDKs on Android, iOS and macOS, and the JS SDK on web. An
app that switches between the two packages keeps its current behavior, apart
from the known differences under [Status](#status).

| When | Android | iOS and macOS | Web |
|---|---|---|---|
| Getting the Auth ID token fails | The call fails with `unknown` | The call fails with `unknown` | The call is sent without the token |
| Getting the App Check token fails | The call carries the App Check placeholder token | The call carries the App Check placeholder token | The call is sent without the header |
| An error response has no error body | The code comes from the HTTP status; 409 is `aborted` and unmapped statuses are `unknown` | The code comes from the HTTP status; 409 is `already-exists` and unmapped statuses are `internal` | As on Android |
| A stream receives nothing for `timeout` | The stream fails with `deadline-exceeded` | The stream fails with `deadline-exceeded` | No timeout |

Functions that enforce App Check reject calls with the placeholder token and
calls without the header alike.

Where this package deliberately differs from `cloud_functions`:

- It refuses to send tokens over plain HTTP to a host other than the local
  machine on every platform. `cloud_functions` only checks this on iOS and
  macOS.
- Custom domains work on every platform. `cloud_functions` doesn't support
  them on iOS and macOS.
- Streams ignore the server's heartbeats on every platform. On iOS and macOS,
  the native SDK fails the stream with `data-loss` when one arrives.

## Running the tests

Unit tests, from this directory:

```sh
flutter test
flutter test --platform chrome
```

The e2e suite, `integration_test/dart_cloud_functions_e2e_test.dart` in the
`cloud_functions` example app, runs the `call()` and `stream()` cases of the
native e2e suite against this package, plus a few of its own. By default, it
runs against the local emulators. From `.github/workflows/scripts`:

```sh
npm ci --prefix functions  # Once: installs and builds the test functions.
firebase emulators:start --only auth,functions --project flutterfire-e2e-tests
```

Then, from `packages/cloud_functions/cloud_functions/example`:

```sh
flutter test integration_test/dart_cloud_functions_e2e_test.dart -d macos
```

- **Android:** the Android emulator works as is. For a physical device, see
  `adbReverse` in the example's `lib/emulator_config.dart`.
- **Web:** start `chromedriver --port=4444`, then run
  `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/dart_cloud_functions_e2e_test.dart -d web-server --browser-name=chrome`.
- **A deployed project:** add `--dart-define-from-file=deployed.env.json`. See
  "Run against a deployed project" in the example's README.
- The Auth tests are skipped on macOS, where the example app has no keychain
  entitlement.

## Trying it next to the native plugin

The `cloud_functions` example app has a **Native / Dart** toggle that switches
implementations at runtime. With the emulators running:

```sh
cd packages/cloud_functions/cloud_functions/example
flutter run -d macos
```
