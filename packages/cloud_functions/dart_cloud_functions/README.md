# dart_cloud_functions

> [!WARNING]
> Experimental and unpublished. This package is a walking skeleton for
> investigating a pure-Dart Cloud Functions client. Don't use it in
> production.

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
| `FirebaseFunctionsException` | `DartFirebaseFunctionsException` |

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
  app or region. Instances are cached per app and region.
- Calls carry the ID token of the user signed in to Firebase Auth, as
  `Authorization: Bearer <token>`, like `cloud_functions`. If getting the
  token fails, the call fails with `unknown` on Android and Apple, and goes
  out without the token on web, as `cloud_functions` does on each platform.
- Once the app has set up App Check (`FirebaseAppCheck.instance.activate()`),
  calls also carry an App Check token as `X-Firebase-AppCheck`.
  `DartHttpsCallableOptions(limitedUseAppCheckToken: true)` sends a
  limited-use token instead, for functions that use replay protection. If
  fetching an App Check token fails, the call carries the same placeholder
  token as `cloud_functions` on Android and Apple, and no App Check header on
  web, as `cloud_functions` does there. Functions that enforce App Check
  reject both. These tokens are why the package depends on `firebase_auth`
  and `firebase_app_check`.
- Tokens are only sent over HTTPS or to the local machine (`localhost`,
  `127.0.0.1`, `::1`, or `10.0.2.2` from the Android emulator). A call that
  would send them over plain HTTP anywhere else fails with `unauthenticated`,
  as in the Apple SDK. To call an emulator at your computer's LAN address
  from a physical device, set `allowInsecureTokenAttachment = true`, as in
  `cloud_functions`. Only debug builds honor it.
- `httpsCallableFromUrl()` and `httpsCallableFromUri()` call a function by URL,
  such as a 2nd gen function's `*.run.app` URL.
- `DartHttpsCallableOptions(timeout: ...)` sets the call timeout (60 seconds by
  default).
- `DartFirebaseFunctionsException` extends `FirebaseException` and uses the
  same error codes as `cloud_functions`, so `on FirebaseException catch (e)`
  handles errors from both.

## Trying it next to the native plugin

The `cloud_functions` example app has a **Native / Dart** toggle that switches
implementations at runtime:

```sh
cd packages/cloud_functions/cloud_functions/example
flutter run -d macos
```

Its `integration_test/dart_cloud_functions_e2e_test.dart` runs the `call()`
cases of the native e2e suite against this package.

## Not yet supported

- FCM tokens: requests are sent without them.
- Streaming (`stream()`).
- 64-bit integer encoding, custom domains, and web.
