# firebase_core_js

Firebase Core for Dart web apps, built on the Firebase JS SDK. It has no
Flutter dependency, so it resolves with `dart pub get` and builds with
`dart compile js` or `dart compile wasm`, for example in a Jaspr app.

Flutter apps do not depend on it directly: they use [`firebase_core`][1],
whose web implementation, `firebase_core_web`, re-exports this package.

# Usage

Register the implementation, then use `Firebase` as in a Flutter app. This
library exports the same names as `firebase_core`:

```dart
import 'package:firebase_core_js/firebase_core_js.dart';

Future<void> main() async {
  FirebaseCoreWeb.registerWith();
  final app = await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: '...',
      appId: '...',
      messagingSenderId: '...',
      projectId: '...',
    ),
  );
  print(app.name);
}
```

The Firebase JS SDK is loaded from the gstatic CDN when the first app is
initialized. Before that, set `window.flutterfire_ignore_scripts` (a list of
service names) to load some scripts yourself, or
`window.flutterfire_web_sdk_version` to use another JS SDK version.

[1]: https://pub.dev/packages/firebase_core
