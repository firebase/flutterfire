## Firebase UI Storage

[![pub package](https://img.shields.io/pub/v/firebase_ui_storage.svg)](https://pub.dev/packages/firebase_ui_storage)

Firebase UI Storage is a set of Flutter widgets and utilities designed to help you build and integrate your user interface with Firebase Storage.

## Installation

Install dependencies

```sh
flutter pub add firebase_core firebase_storage firebase_ui_storage
```

Donwload Firebase project config

```sh
flutterfire configure
```

## Configuration

This section will walk you through the configuration process of the Firebase UI Storage

### macOS

If you're building for macOS, you will need to add an entitlement for either read-only access if you only upload files:

```xml
  <key>com.apple.security.files.user-selected.read-only</key>
  <true/>
```

or read/write access if you want to be able to download files as well:

```xml
  <key>com.apple.security.files.user-selected.read-write</key>
  <true/>
```

Make sure to add network client entitlement as well:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

### FirebaseUIStorage.configure()

To reduce boilerplate for widgets, `FirebaseUIStroage` has a top-level configuration:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final storage = FirebaseStorage.instance;
  final config = FirebaseUIStorageConfiguration(storage: storage);

  await FirebaseUIStorage.configure(config);

  runApp(const MyApp());
}
```

See [API docs](https://pub.dev/documentation/firebase_ui_storage/latest/firebase_ui_storage/FirebaseUIStorageConfiguration-class.html) for more configuration options.

### Overriding configuration

It is possible to override a top-level configuration for a widget subtree:

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FirebaseUIStorageConfigOverride(
      config: FirebaseUIStorageConfiguration(
        uploadRoot: storage.ref('${FirebaseAuth.instance.currentUser.uid}/'),
        namingPolicy: const UuidFileUploadNamingPolicy(),
        child: const MyUserPage(),
      ),
    );
  }
}
```

## Widgets

### UploadButton

```dart
class MyUploadPage extends StatelessWidget {
  const MyUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: UploadButton(
          mimeTypes: const ['image/png', 'image/jpeg'],
          onError: (err, stackTrace) {
            print(err.toString());
          },
          onUploadComplete: (ref) {
            print('File uploaded to ${ref.fullPath}');
          },
        ),
      ),
    );
  }
}

```

### TaskProgressIndicator

```dart
class MyUploadProgress extends StatelessWidget {
  final UploadTask task;

  const MyUploadProgress({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Text('Uploading ${task.snapshot.ref.name}...'),
        TaskProgressIndicator(task: task),
      ]),
    );
  }
}
```
