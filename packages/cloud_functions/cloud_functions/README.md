# Cloud Functions Plugin for Flutter

[![pub package](https://img.shields.io/pub/v/cloud_functions.svg)](https://pub.dev/packages/cloud_functions)

A Flutter plugin to use the [Cloud Functions for Firebase API](https://firebase.google.com/docs/functions/callable)

To learn more about Firebase, please visit the [Firebase website](https://firebase.google.com)

## Getting Started

> If you are migrating your existing project to these new plugins, please start with the [migration guide](https://firebase.flutter.dev/docs/migration)

To get started with Cloud Functions for FlutterFire, please [see the documentation](https://firebase.flutter.dev/docs/functions/overview)
available at [https://firebase.flutter.dev](https://firebase.flutter.dev/docs/overview)

## Usage

To use any of the Firebase services, FlutterFire needs to be initialized.  To initialize FlutterFire,
call the `initializeApp` method on the `Firebase` class:

```dart
await Firebase.initializeApp();
```

### Basic Example

Assuming we have deployed a callable function named `listFruit` that returns an array of fruit names,
we can call the Cloud Function using the `httpsCallable` method:

```dart
Future<void> getFruit() async {
  HttpsCallable callable = CloudFunctions.instance.httpsCallable('listFruit');
  final results = await callable();
  List fruit = results.data;  // ["Apple", "Banana", "Cherry", "Date", "Fig", "Grapes"]
}
```

For more information on how to use this plugin,
please visit the [Cloud Functions Usage documentation](https://firebase.flutter.dev/docs/functions/overview)

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to Flutterfire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
