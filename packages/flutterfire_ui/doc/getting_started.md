# Getting started with FlutterFIre UI

This guide will walk you through the installation and initial configuration process required for FlutterFIre UI.

## Installation

Activate FlutterFire CLI

```sh
flutter pub global activate
```

Install dependencies

```sh
flutter pub add firebase_core
flutter pub add flutterfire_ui
```

## Configuration

Configure firebase using cli:

```sh
flutterfire configure
```

Initialize firebase app:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
```

## macOS entitlements

If you're building for macOS, make sure to add necessary entitlements. Learn more [on the official Flutter documentation](https://docs.flutter.dev/development/platform-integration/macos/building).

## Next steps

- [Getting started with FlutterFireUI Auth](./auth.md)
- [Getting started with FlutterFireUI Firestore](./firestore.md)
- [Getting started with FlutterFireUI Realtime Database](./database.md)
