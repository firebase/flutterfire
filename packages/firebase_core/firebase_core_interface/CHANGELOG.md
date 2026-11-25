## 1.0.0

 - Initial release. `FirebaseOptions`, `defaultFirebaseAppName`, the core exception helpers and the `FirebasePlatform`, `FirebaseAppPlatform` and `FirebasePlugin` contracts move here from `firebase_core_platform_interface`, which re-exports them.
 - `Firebase`, `FirebaseApp` and `FirebaseService` move here from `firebase_core`, which re-exports them. `Firebase.initializeApp(demoProjectId:)` now reads the platform for the demo app ID from the OS rather than from Flutter's `defaultTargetPlatform`, so it is `web` in any browser, and follows the host OS in `flutter test` rather than `android`.
