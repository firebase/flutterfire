# firebase_common

Foundational pure-Dart types (currently `FirebaseException`) designed to be
shared across Firebase client and server Dart SDKs. It has no Flutter or browser
dependency, so it resolves with `dart pub get` on both the Dart VM and web.

Most apps do not need to depend on this package directly:

- **Flutter apps**: use [`firebase_core`](https://pub.dev/packages/firebase_core),
  which re-exports `FirebaseException`.
- **Dart web apps without Flutter**: use
  [`firebase_core_js`](https://pub.dev/packages/firebase_core_js), which
  re-exports `FirebaseException`.
- **Shared client/server Dart packages**: depend on `firebase_common` directly
  to handle `FirebaseException` without pulling in Flutter or browser APIs.

Client platform contracts live in
[`firebase_core_interface`](https://pub.dev/packages/firebase_core_interface) so
that breaking changes to client contracts do not affect server SDKs.
