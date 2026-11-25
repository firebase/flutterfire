# firebase_core_js

Firebase Core for browser-based Dart web apps, built on the Firebase JS SDK. It
has no Flutter dependency, so it resolves with `dart pub get` and compiles with
`dart compile js` or `dart compile wasm` (for example in Jaspr).

> **Using Flutter?** Depend on [`firebase_core`](https://pub.dev/packages/firebase_core)
> instead. Its web plugin (`firebase_core_web`) wraps this package.

Only Firebase Core is decoupled from Flutter today; pure-Dart web packages for
other Firebase services (Auth, Firestore, and others) are tracked in
[#18645](https://github.com/firebase/flutterfire/issues/18645).

## Usage

Add the package:

```sh
dart pub add firebase_core_js
```

Initialize Firebase with the web app configuration from **Firebase Console >
Project settings > Your apps**:

```dart
import 'package:firebase_core_js/firebase_core_js.dart';

Future<void> main() async {
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

This package uses `dart:js_interop` and `package:web`, so import it only in
client-side browser code (not SSR or Dart VM targets; use
[`firebase_common`](https://pub.dev/packages/firebase_common) if shared
client/server code needs `FirebaseException`).

## Customizing JS SDK Loading

By default, `Firebase.initializeApp()` loads the tested Firebase JS SDK modules
from the `gstatic` CDN on first initialization. To customize loading, configure
`window` in a `<script>` tag in `web/index.html` before your Dart script runs:

- **Override the JS SDK version**: set `window.flutterfire_web_sdk_version = 'x.y.z'`.
- **Self-load specific service scripts**: set
  `window.flutterfire_ignore_scripts = ['analytics', ...]` and assign each
  module on `window` (`window.firebase_<service> = await import(...)`). Refer to
  [Disable Firebase JavaScript SDK auto-injection](https://firebase.google.com/docs/flutter/setup?platform=web#disable-auto).
- **Self-load all scripts**: setting `window.firebase_core = await import(...)`
  before `initializeApp()` skips all automatic script injection.

For web plugin authors, `package:firebase_core_js/firebase_core_js_interop.dart`
exports `guardWebExceptions` and the JS SDK interop bindings.
