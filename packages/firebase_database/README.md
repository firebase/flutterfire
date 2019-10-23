# Firebase Realtime Database for Flutter

[![pub package](https://img.shields.io/pub/v/firebase_database.svg)](https://pub.dartlang.org/packages/firebase_database)

A Flutter plugin to use the [Firebase Realtime Database API](https://firebase.google.com/products/database/).

For Flutter plugins for other Firebase products, see [README.md](https://github.com/FirebaseExtended/flutterfire/blob/master/README.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/FirebaseExtended/flutterfire/issues) and [Pull Requests](https://github.com/FirebaseExtended/flutterfire/pulls) are most welcome!

## Usage
To use this plugin, add `firebase_database` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). You will also need the `firebase_core` dependency if you do not have it already.

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

final FirebaseApp app = FirebaseApp(name: '[DEFAULT]');
final DatabaseReference db = FirebaseDatabase(app: firebaseApp).reference();
db.child('your_db_child').once().then((result) => print('result = $result'));
```

## Getting Started

See the `example` directory for a complete sample app using Firebase Realtime Database.
