# firebase_core_interface

Pure-Dart platform contracts and core client types for Firebase Core, with no
Flutter dependency.

Apps do not depend on this package directly:

- **Flutter apps**: use [`firebase_core`](https://pub.dev/packages/firebase_core).
- **Dart web apps without Flutter**: use [`firebase_core_js`](https://pub.dev/packages/firebase_core_js).

Both packages expose the same app-facing API (`Firebase`, `FirebaseApp`,
`FirebaseOptions`, `FirebaseException`, and `defaultFirebaseAppName`).

## Usage

This package is for Firebase Core platform implementations and pure-Dart
Firebase service plugins:

- **Platform implementations**: **extend** (do not `implement`)
  `FirebasePlatform` and `FirebaseAppPlatform`, register via
  `FirebasePlatform.instance` (or `FirebasePlatform.fallbackInstanceFactory`),
  and use the shared core exception helpers (`noAppExists`, `duplicateApp`,
  `coreNotInitialized`).
- **Service plugins**: extend `FirebasePlugin` and implement `FirebaseService`
  to attach per-app instances with `FirebaseApp.registerService`.
- **Flutter method-channel plugins**: depend on
  [`firebase_core_platform_interface`](https://pub.dev/packages/firebase_core_platform_interface),
  which re-exports these contracts alongside `MethodChannelFirebase`.
