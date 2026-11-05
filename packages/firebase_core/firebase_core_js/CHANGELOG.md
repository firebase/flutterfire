## 1.0.0

 - Initial release. The web implementation of Firebase Core (`FirebaseCoreWeb` and its JS SDK interop) moves here from `firebase_core_web`, which re-exports it.
 - `FirebaseCoreWeb.registerWith` no longer needs a registrar: Dart apps without Flutter call `FirebaseCoreWeb.registerWith()`.
