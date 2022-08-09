# Firebase UI Auth

[![pub package](https://img.shields.io/pub/v/firebase_ui_auth.svg)](https://pub.dev/packages/firebase_ui_auth)

Firebase UI Auth is a set of Flutter widgets and utilities designed to help you build and integrate your user interface with Firebase Authentication.

> Please contribute to the [discussion](https://github.com/firebase/flutterfire/discussions/6978) with feedback.

## Installation

```sh
flutter pub add firebase_ui_auth
```

## Getting Started

Here's a quick example that shows how to build a `SignInScreen` and `ProfileScreen` in your app

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const providers = [EmailAuthProvider()];

    return MaterialApp(
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/profile',
      routes: {
        '/sign-in': (context) {
          return SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, '/profile');
              }),
            ],
          );
        },
        '/profile': (context) {
          return ProfileScreen(
            providers: providers,
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(context, '/sign-in');
              }),
            ],
          );
        },
      },
    );
  }
}
```

Learn more in the [Getting started guide](doc/getting-started.md).

## Roadmap / Features

- For issues, please create a new [issue on the repository](https://github.com/firebase/flutterfire/issues).
- For feature requests, & questions, please participate on the [discussion](https://github.com/firebase/flutterfire/discussions/6978) thread.
- To contribute a change to this plugin, please review our [contribution guide](https://github.com/firebase/flutterfire/blob/master/CONTRIBUTING.md) and open a [pull request](https://github.com/firebase/flutterfire/pulls).
