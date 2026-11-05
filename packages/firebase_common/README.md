# firebase_common

Pure-Dart types shared by the Firebase client and server Dart SDKs. It has no
Flutter dependency, so it resolves with `dart pub get` in any Dart app,
including on the Dart VM.

Today it holds `FirebaseException`. Apps do not depend on it directly:
`firebase_core` and the other FlutterFire packages re-export it.

The contracts that `firebase_core` implementations extend live in
[`firebase_core_interface`](https://pub.dev/packages/firebase_core_interface),
so that their breaking changes stay out of this package.
