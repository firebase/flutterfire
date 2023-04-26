# Navigation

Firebase UI uses Flutter navigation capabilities to navigate between pages.

By default, it uses "Navigator 1." when a new screen needs to be shown as a result of user interaction (`Navigator.push(context, route)` is used).

For applications using the standard navigation APIs, navigation will work out of the box and require no intervention. However, for applications using
a custom routing package, you will need to override the default navigation actions to integrate with your routing strategy.

## Custom routing

For this example, the application will create [named routes](https://docs.flutter.dev/cookbook/navigation/named-routes). Within the UI logic, we can
override the default actions (e.g. signing in or signing out) the UI performs to instead integrate with those named routes.

First, we define the root route that checks for authentication state and renders a `SignInScreen` or `ProfileScreen`:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const providers = [EmailAuthProvider()];

    return MaterialApp(
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/profile',
      routes: {
        '/sign-in': (context) => SignInScreen(providers: providers),
        '/profile': (context) => ProfileScreen(providers: providers),
      },
    );
  }
}
```

By default, when a user triggers a sign-in via the `SignInScreen`, no action default occurs. Since we are not subscribing to the authentication
state (via the `authStateChanges` API), we need to manually force the navigator to push to a new screen (the `/profile` route).

To do this, add a `AuthStateChangeAction` action to the `actions` property of the widget, for example for a successful sign in:

```dart
SignInScreen(
  actions: [
    AuthStateChangeAction<SignedIn>((context, _) {
      Navigator.of(context).pushReplacementNamed('/profile');
    }),
  ],
  // ...
)
```

You could also react to the user signing out in a similar manner:

```dart
ProfileScreen(
  actions: [
    SignedOutAction((context, _) {
      Navigator.of(context).pushReplacementNamed('/sign-in');
    }),
  ],
  // ...
)
```

Some UI widgets also come with internal actions which triggers navigation to a new screen. For example the `SignInScreen` widget allows users to
reset their password by pressing the "Forgot Password" button, which internally navigates to a `ForgotPasswordScreen`. To override this action and
navigate to a named route, provide the `actions` list with a `ForgotPasswordAction`:

```dart
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
              ForgotPasswordAction((context, email) {
                Navigator.of(context).pushNamed(
                  '/forgot-password',
                  arguments: {'email': email},
                );
              }),
            ],
          );
        },
        '/profile': (context) => ProfileScreen(providers: providers),
        '/forgot-password': (context) => MyCustomForgotPasswordScreen(),
      },
    );
  }
}
```

To learn more about the available actions, check out the [FirebaseUIActions API reference](https://pub.dev/documentation/firebase_ui_auth/latest/firebase_ui_auth/FirebaseUIActions-class.html).

## Other topics

- [EmailAuthProvider](./providers/email.md) - allows registering and signing using email and password.
- [EmailLinkAuthProvider](./providers/email-link.md) - allows registering and signing using a link sent to email.
- [PhoneAuthProvider](./providers/phone.md) - allows registering and signing using a phone number
- [UniversalEmailSignInProvider](./providers/universal-email-sign-in.md) - gets all connected auth providers for a given email.
- [OAuth](./providers/oauth.md)
- [Localization](../../firebase_ui_localizations/README.md)
- [Theming](./theming.md)
