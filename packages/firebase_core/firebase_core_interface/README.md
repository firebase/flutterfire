# firebase_core_interface

The `Firebase` entry point (`Firebase`, `FirebaseApp`, `FirebaseService`), the
contracts that Firebase Core implementations extend (`FirebasePlatform`,
`FirebaseAppPlatform`, `FirebasePlugin`) and the types they use
(`FirebaseOptions`, `FirebaseException`, `defaultFirebaseAppName` and the core
exception helpers). It has no Flutter dependency.

Apps do not depend on it directly. `firebase_core` and `firebase_core_js`
re-export `Firebase`, `FirebaseApp`, `FirebaseService`, `FirebaseOptions`,
`FirebaseException` and `defaultFirebaseAppName`, and
`firebase_core_platform_interface` re-exports the contracts.

# Usage

Implementations extend `FirebasePlatform` and register an instance with
`FirebasePlatform.instance`. In a Dart web app that does not use Flutter, use
[`firebase_core_js`](https://pub.dev/packages/firebase_core_js), which
provides the web implementation.
