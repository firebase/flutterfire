# FlutterFire UI

[![pub package](https://img.shields.io/pub/v/flutterfire_ui.svg)](https://pub.dev/packages/flutterfire_ui)

FlutterFire UI is a set of Flutter widgets and utilities designed to help you build and integrate your user interface with Firebase.

> FlutterFire UI is still in beta and is subject to change. Please contribute to the [discussion](https://github.com/firebase/flutterfire/discussions/6978) with feedback.

## Installation

```sh
flutter pub add flutterfire_ui
```

## Getting Started

Here's a quick example that shows how to build a `SignInScreen` and `ProfileScreen` in your app

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const providerConfigs = [EmailProviderConfiguration()];

    return MaterialApp(
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/profile',
      routes: {
        '/sign-in': (context) {
          return SignInScreen(
            providerConfigs: providerConfigs,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, '/profile');
              }),
            ],
          );
        },
        '/profile': (context) {
          return ProfileScreen(
            providerConfigs: providerConfigs,
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

Learn more in the [Integrating your first screen section](doc/auth/integrating-your-first-screen.md) of the documentation

## Roadmap / Features

FlutterFire UI is still in active development.

- For issues, please create a new [issue on the repository](https://github.com/firebase/flutterfire/issues).
- For feature requests, & questions, please participate on the [discussion](https://github.com/firebase/flutterfire/discussions/6978) thread.
- To contribute a change to this plugin, please review our [contribution guide](https://github.com/firebase/flutterfire/blob/master/CONTRIBUTING.md) and open a [pull request](https://github.com/firebase/flutterfire/pulls).

Please contribute to the [discussion](https://github.com/firebase/flutterfire/discussions/6978) with feedback.

## Next Steps

Once installed, you can read the following documentation to learn more about the FlutterFire UI widgets and utilities:

- [Authentication](doc/auth.md)
- [Firestore](doc/firestore.md)
- [Realtime Database](doc/database.md)
