# Building a Custom UI

The UI package provides various widgets to help you implement authentication in your
application. Widgets provide different layers of abstraction, such as fully styled sign-in screens
to underlying controllers enabling you to build your own UI experience. The terminology used for these
abstractions are:

- **Screen**: A fully functional, pre-styled and customizable widget which offers a complete authentication experience (such as Sign In, Register, Profile Screen).
- **View**: A fully controlled widget which offers authentication functionality (such as Sign In), however if minimally styled allowing you to build your own UI around the view.
- **Widget**: A bare-bones widget which renders basic elements of an authentication flow, such as text inputs, buttons, etc.
- **Controller**: The lowest level of abstraction which provides no UI, however provides authentication controls (such as signing in, triggering OAuth flows, etc.).

Internally the UI package builds upon these abstractions layers. For example a `SignInScreen` implements multiple `View`s, where a `View` implements and provides basic styling of multiple `Widget`s,
with the `Widget`s implementing a `Controller`.

## `AuthFlowBuilder` widget

[`AuthFlowBuilder`](https://pub.dev/documentation/flutterfire_ui/latest/auth/AuthFlowBuilder-class.html) is a widget which provides a simple way to wire built-in auth flows with the widget tree.

It takes care of creating an instance of `AuthFlow` with the provided `ProviderConfiguration`,
subscribing to the state changes that happen during the authentication process of a given provider
and calls back a `builder` with an instance of `BuildContext`, `AuthState` and `AuthController`.
The latter is used for the flow manipulations

Even if you want to have a full control over the look and feel of every single widget,
you could take advantage of the authentication logic provided by the FlutterFire UI library.

## Building a custom sign in screen

Let's have a look at how to use `AuthFlowBuilder` in your custom widgets.

First, let's build a simple `CustomSignInScreen` widget.

```dart
import 'package:flutter/material.dart';

class CustomSignInWidget extends StatelessWidget {
  const CustomSignInWidget({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomEmailSignInForm(),
    );
  }
}
```

### `EmailFlowController`

Now we need to implement a `CustomEmailSignInForm` and make it functional with [`EmailFlowController`](https://pub.dev/documentation/flutterfire_ui/latest/auth/EmailFlowController-class.html)

To take advantage of the `EmailFlowController` we need to use `AuthFlowBuilder<EmailFlowController>`

```dart
class CustomEmailSignInForm extends StatelessWidget {
  CustomEmailSignInForm({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailFlowController>(
      builder: (context, state, controller, _) {

      },
    );
  }
}
```

Next up, we need to handle different states of the `EmailFlow` that are being passed to the `builder`.
Initial state is `AwaitingEmailAndPassword`.

```dart
class CustomEmailSignInForm extends StatelessWidget {
  CustomEmailSignInForm({Key? key}) : super(key: key);

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailFlowController>(
      builder: (context, state, controller, _) {
        if (state is AwaitingEmailAndPassword) {
          return Column(
            children: [
              TextField(controller: emailCtrl),
              TextField(controller: passwordCtrl),
              ElevatedButton(
                onPressed: () {
                  controller.setEmailAndPassword(
                    emailCtrl.text,
                    passwordCtrl.text,
                  );
                },
                child: const Text('Sign in'),
              ),
            ],
          );
        }
      },
    );
  }
}
```

After button is pressed, controller starts the sign-in process, thus triggering an auth state transition, so `builder` gets called again, now with an instance of `SigningIn` state:

```dart
class CustomEmailSignInForm extends StatelessWidget {
  CustomEmailSignInForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailFlowController>(
      builder: (context, state, controller, _) {
        if (state is AwaitingEmailAndPassword) {
          // ...
        } else if (state is SigningIn) {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
```

The final state of the `EmailFlow` could be `SignedIn`, which means the user is signed in, or `AuthFailed` if the sign-in process failed.

```dart
class CustomEmailSignInForm extends StatelessWidget {
  CustomEmailSignInForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailFlowController>(
      listener: (oldState, state, controller) {
        if (state is SignedIn) {
          Navigator.of(context).pushReplacementNamed('/profile');
        }
      },
      builder: (context, state, controller, _) {
        if (state is AwaitingEmailAndPassword) {
          // ...
        } else if (state is SigningIn) {
          // ...
        } else if (state is AuthFailed) {
          // FlutterFireUIWidget that shows a human-readable error message.
          return ErrorText(exception: state.exception);
        }
      },
    );
  }
}
```

## Available auth controllers

Here's a list of all auth controllers provided by the FlutterFire UI library:

- [`EmailFlowController`](https://pub.dev/documentation/flutterfire_ui/latest/auth/EmailFlowController-class.html) – email and password sign in and email verification
- [`EmailLinkFlowController`](https://pub.dev/documentation/flutterfire_ui/latest/auth/EmailLinkFlowController-class.html) – email link sign in
- [`OAuthController`](https://pub.dev/documentation/flutterfire_ui/latest/auth/OAuthController-class.html) – sign in with OAuth providers

  - [`GoogleProviderConfiguration`](https://pub.dev/documentation/flutterfire_ui/latest/auth/GoogleProviderConfiguration-class.html) – Google sign in
  - [`FacebookProviderConfiguration`](https://pub.dev/documentation/flutterfire_ui/latest/auth/FacebookProviderConfiguration-class.html) – Facebook sign in
  - [`AppleProviderConfiguration`](https://pub.dev/documentation/flutterfire_ui/latest/auth/AppleProviderConfiguration-class.html) – Apple sign in
  - [`TwitterProviderConfiguration`](https://pub.dev/documentation/flutterfire_ui/latest/auth/TwitterProviderConfiguration-class.html) – Twitter sign in

- [`PhoneAuthController`](https://pub.dev/documentation/flutterfire_ui/latest/auth/PhoneAuthController-class.html) – sign in with phone number
