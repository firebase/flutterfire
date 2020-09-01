# Firebase Auth for Flutter
[![pub package](https://img.shields.io/pub/v/firebase_auth.svg)](https://pub.dev/packages/firebase_auth)

A Flutter plugin to use the [Firebase Authentication API](https://firebase.google.com/products/auth/).

To learn more about Firebase, please visit the [Firebase website](https://firebase.google.com)

## Getting Started

> If you are migrating your existing project to these new plugins, please start with the [migration guide](https://firebase.flutter.dev/docs/migration)

To get started with Firebase Auth for FlutterFire, please [see the documentation](https://firebase.flutter.dev/docs/auth/overview)
available at [https://firebase.flutter.dev](https://firebase.flutter.dev/docs/overview)

## Usage

To use any of the Firebase services, FlutterFire needs to be initialized.  To initialize FlutterFire,
call the `initializeApp` method on the `Firebase` class:

```dart
await Firebase.initializeApp();
```

### Basic Example

Firebase Auth enables you to subscribe to a realtime stream of a user's authentication state.
To subscribe to these changes, call the `authStateChanges` method on your `FirebaseAuth` instance:

```dart
FirebaseAuth.instance
  .authStateChanges()
  .listen((User user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
```

For more information on how to use this plugin,
please visit the [Authentication Usage documentation](https://firebase.flutter.dev/docs/auth/overview)

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to Flutterfire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
