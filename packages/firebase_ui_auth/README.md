# Firebase UI Auth

[![pub package](https://img.shields.io/pub/v/firebase_ui_auth.svg)](https://pub.dev/packages/firebase_ui_auth)

Firebase UI Auth is a set of Flutter widgets and utilities designed to help you build and integrate your user interface with Firebase Authentication.

> Please contribute to the [discussion](https://github.com/firebase/flutterfire/discussions/6978) with feedback.

## Platform support

| Feature/platform   | Android | iOS | Web              | macOS            | Windows          | Linux            |
| ------------------ | ------- | --- | ---------------- | ---------------- | ---------------- | ---------------- |
| Email              | ✓       | ✓   | ✓                | ✓                | ✓ <sup>(1)</sup> | ✓ <sup>(1)</sup> |
| Phone              | ✓       | ✓   | ✓                | ╳                | ╳                | ╳                |
| Email link         | ✓       | ✓   | ╳                | ╳                | ╳                | ╳                |
| Email verification | ✓       | ✓   | ✓ <sup>(2)</sup> | ✓ <sup>(2)</sup> | ✓ <sup>(1)</sup> | ✓ <sup>(1)</sup> |
| Sign in with Apple | ✓       | ✓   | ✓                | ✓                | ╳                | ╳                |
| Google Sign in     | ✓       | ✓   | ✓                | ✓                | ✓ <sup>(1)</sup> | ✓ <sup>(1)</sup> |
| Twitter Login      | ✓       | ✓   | ✓                | ✓                | ✓ <sup>(1)</sup> | ✓ <sup>(1)</sup> |
| Facebook Sign in   | ✓       | ✓   | ✓                | ✓                | ✓ <sup>(1)</sup> | ✓ <sup>(1)</sup> |

1. Available with [flutterfire_desktop](https://github.com/invertase/flutterfire_desktop)
2. No deep-linking into app, so email verification link opens a web page

## Installation

```sh
flutter pub add firebase_ui_auth
```

## Example

Here's a quick example that shows how to build a `SignInScreen` and `ProfileScreen` in your app

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
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

## Profile screen icons

If you're using `ProfileScreen`, make sure to add the following to your `pubspec.yaml`:

```yaml
fonts:
  - family: SocialIcons
    fonts:
      - asset: packages/firebase_ui_auth/fonts/SocialIcons.ttf
```

## Docs

Find relevant documentation [here](https://github.com/firebase/flutterfire/tree/master/packages/firebase_ui_auth/doc)

- [Getting started](https://github.com/firebase/flutterfire/tree/master/packages/firebase_ui_auth/doc)
- Auth providers.
  - [Email auth provider](https://github.com/firebase/flutterfire/blob/master/packages/firebase_ui_auth/doc/providers/email.md) – sign in using email and password.
  - [Email verification](https://github.com/firebase/flutterfire/blob/master/packages/firebase_ui_auth/doc/providers/email-verification.md) - verify email.
  - [Email link sign in](https://github.com/firebase/flutterfire/blob/master/packages/firebase_ui_auth/doc/providers/email-link.md) - sign in using a link sent to email.
  - [Phone auth provider](https://github.com/firebase/flutterfire/blob/master/packages/firebase_ui_auth/doc/providers/phone.md) - sign in using phone number.
  - [Universal email sign in](https://github.com/firebase/flutterfire/blob/master/packages/firebase_ui_auth/doc/providers/universal-email-sign-in.md) - resolve connected providers based on email and sign in using one of those.
  - [OAuth](https://github.com/firebase/flutterfire/blob/master/packages/firebase_ui_auth/doc/providers/oauth.md) - sign in using Apple, Google, Facebook or Twitter.

## Roadmap / Features

- For issues, please create a new [issue on the repository](https://github.com/firebase/flutterfire/issues).
- For feature requests, & questions, please participate on the [discussion](https://github.com/firebase/flutterfire/discussions/6978) thread.
- To contribute a change to this plugin, please review our [contribution guide](https://github.com/firebase/flutterfire/blob/master/CONTRIBUTING.md) and open a [pull request](https://github.com/firebase/flutterfire/pulls).
