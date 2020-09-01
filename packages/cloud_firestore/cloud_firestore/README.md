# Cloud Firestore Plugin for Flutter

A Flutter plugin to use the [Cloud Firestore API](https://firebase.google.com/docs/firestore/).

To learn more about Firebase Cloud Firestore, please visit the [Firebase website](https://firebase.google.com/products/firestore)

[![pub package](https://img.shields.io/pub/v/cloud_firestore.svg)](https://pub.dev/packages/cloud_firestore)

## Getting Started

> If you are migrating your existing project to these new plugins, please start with the [migration guide](https://firebase.flutter.dev/docs/migration)

To get started with Cloud Firestore for Flutter, please [see the documentation](https://firebase.flutter.dev/docs/firestore/overview) available
 at [https://firebase.flutter.dev](https://firebase.flutter.dev)

## Usage

To use any of the Firebase services, FlutterFire needs to be initialized.  To initialize FlutterFire,
call the `initializeApp` method on the `Firebase` class:

```dart
await Firebase.initializeApp();
```

### Basic Example

When getting document data from Firestore, it is returned as a `DocumentSnapshot`. A snapshot is always returned,
even if no document exists, however you can use the `exists` property to determine if the document exists:

```dart
FirebaseFirestore.instance
  .collection('users')
  .document(userId)
  .get()
  .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      print('Document exists on the database');
    }
  });
```
For more information on how to use this plugin,
please visit the [Firestore Usage documentation](https://firebase.flutter.dev/docs/firestore/usage)


## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
