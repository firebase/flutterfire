# Firebase Crashlytics for Flutter

[![pub package](https://img.shields.io/pub/v/firebase_crashlytics.svg)](https://pub.dev/packages/firebase_crashlytics)

A Flutter plugin to use the [Firebase Crashlytics Service](https://firebase.google.com/docs/crashlytics/).

To learn more about Firebase, please visit the [Firebase website](https://firebase.google.com)

## Getting Started

> If you are migrating your existing project to these new plugins, please start with the [migration guide](https://firebase.flutter.dev/docs/migration)

To get started with FlutterFire, please [see the documentation](https://firebase.flutter.dev/docs/crashlytics/overview)
available at [https://firebase.flutter.dev](https://firebase.flutter.dev/crashlytics/overview)

## Usage

To use any of the Firebase services, FlutterFire needs to be initialized.  To initialize FlutterFire,
call the `initializeApp` method on the `Firebase` class:

```dart
await Firebase.initializeApp();
```

### Basic Example

To add custom Crashlytics log messages to your app, use the `log` method:

```dart
FirebaseCrashlytics.instance.log("Higgs-Boson detected! Bailing out");
```

For more information on how to use this plugin,
please visit the [Authentication Usage documentation](https://firebase.flutter.dev/docs/crashlytics/usage)

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to Flutterfire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
