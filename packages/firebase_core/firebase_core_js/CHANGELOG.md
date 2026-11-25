## 1.0.0

 - Initial release. The web implementation of Firebase Core (`FirebaseCoreWeb` and its JS SDK interop) moves here from `firebase_core_web`, which re-exports it.
 - `FirebaseCoreWeb.registerWith` no longer needs a registrar: Dart apps without Flutter call `FirebaseCoreWeb.registerWith()`.
 - Exports `Firebase`, `FirebaseApp`, `FirebaseService`, `FirebaseOptions`, `FirebaseException` and `defaultFirebaseAppName`, like `firebase_core`. Its `Firebase` uses `FirebaseCoreWeb` unless another implementation is registered, so apps don't need to call `FirebaseCoreWeb.registerWith()`.
 - `FirebaseCoreWeb` reports the `flutter-fire-core` version when it initializes an app, however it was registered.
 - `guardWebExceptions` moves here from `_flutterfire_internals`, which re-exports it. It is exported from `firebase_core_js_interop.dart`, and so from `firebase_core_web_interop.dart`. It no longer throws a `TypeError` for JS errors without a `message` or `code`.
