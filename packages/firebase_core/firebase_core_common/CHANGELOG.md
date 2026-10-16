## 0.1.0

- Initial release.
- Pure Dart types and platform interfaces extracted from
  `firebase_core_platform_interface` (`FirebaseApp`, `FirebaseAppPlatform`,
  `FirebaseOptions`, `FirebaseException`, `FirebasePlatform`, `FirebasePlugin`
  and the shared exception helpers), so that Firebase Core platform
  implementations can be consumed outside of Flutter.
- `FirebasePlatform.instance` no longer defaults to the `MethodChannel`
  implementation: implementations must register themselves (`FirebaseCoreWeb`
  does so from `registerWith`) and `FirebasePlatform.isRegistered` allows
  checking whether that happened.
