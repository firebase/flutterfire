> Note; this documentation is in a temporary location.

# Installation

Firstly ensure you have installed FlutterFire by following the
[documentation](https://firebase.flutter.dev/docs/overview) for your platform. The ODM also depends
on the `cloud_firestore` plugin, so ensure you it installed too by following the [Cloud Firestore
documentation](https://firebase.flutter.dev/docs/firestore/overview).

Before any usage of the ODM, ensure you have [Initialized Firebase](https://firebase.flutter.dev/docs/overview#initializing-flutterfire):

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(...)
);
```

## Add dependencies

Add the `cloud_firestore_odm` & `json_annotation` dependencies to your `pubspec.yaml`:

```yaml {4,5}
dependencies:
  firebase_core: "^1.7.0"
  cloud_firestore: "^2.5.3"
  cloud_firestore_odm: "^1.0.0-dev.1"
  json_annotation: ^4.0.0
```

Next, add the `build_runner`, `cloud_firestore_odm_generator` & `json_serializable` dependencies
to your `pubspec.yaml` development dependencies:

```yaml {4,5}
dev_dependencies:
  build_runner: ^2.0.0
  cloud_firestore_odm_generator: "^1.0.0-dev.1"
  json_serializable: ^5.0.0
```

To install the dependencies, install them via pub:

```bash
flutter pub get
```

## Next steps

Once installed, read the documentation on [defining schemas](/defining-schemas.md).
