# firebase_core_interface

The contracts that Firebase Core implementations extend (`FirebasePlatform`,
`FirebaseAppPlatform`, `FirebasePlugin`) and the types they use
(`FirebaseOptions`, `FirebaseException`, `defaultFirebaseAppName` and the core
exception helpers). It has no Flutter dependency.

Flutter apps and plugins do not depend on it directly:
`firebase_core_platform_interface` re-exports it, and `firebase_core`
re-exports `FirebaseOptions`, `FirebaseException` and `defaultFirebaseAppName`.

# Usage

In a Dart web app that does not use Flutter, depend on
`firebase_core_interface` and
[`firebase_core_js`](https://pub.dev/packages/firebase_core_js), and register
the implementation before using Firebase:

```dart
import 'package:firebase_core_interface/firebase_core_interface.dart';
import 'package:firebase_core_js/firebase_core_js.dart';

Future<void> main() async {
  FirebaseCoreWeb.registerWith(null);
  final app = await FirebasePlatform.instance.initializeApp(
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
