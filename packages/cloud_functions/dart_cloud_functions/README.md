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

- Auth, App Check and FCM tokens: requests are sent without them.
- Streaming (`stream()`).
- 64-bit integer encoding, custom domains, and web.
