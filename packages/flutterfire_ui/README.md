# FlutterFire UI

[![pub package](https://img.shields.io/pub/v/flutterfire_ui.svg)](https://pub.dev/packages/flutterfire_ui)

## Installation

```sh
flutter pub add flutterfire_ui
```

## Getting Started

To get started with FlutterFire UI, please
explore the [widget catalog](https://firebase.flutter.dev/docs/ui/widgets), the [storybook](https://flutterfire-ui.web.app/#/) and [see the documentation](https://firebase.flutter.dev/docs/ui/overview).

## Usage

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

Learn more in the [Integrating your first screen section](https://firebase.flutter.dev/docs/ui/auth/integrating-your-first-screen) of the documentation

## Issues and feedback

Please file FlutterFire UI specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
