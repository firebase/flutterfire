# Universal email sign in

Universal email sign in is a flow that will resolve connected auth providers with a given email.
This flow is intended to solve the problem where the user doesn't remember which provider was
previously used to authenticate.

## Using screen

Firebase UI provides a pre-built `UniversalEmailSignInScreen`.

```dart
UniversalEmailSignInScreen(
  // optional, shows a dialog with a sign in ui
  // with all connected providers.
  onProvidersFound: (email, providers) {
    // navigate to a custom sign in that provides
    // a UI for authentication for received providers.
  }
);
```

## Using view

If the pre-built screens don't suit the app's needs, you could use a `FindProvidersForEmailView` to build your custom screen:

```dart
class MyLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext) {
    return Scaffold(
      body: Row(
        children: [
          MyCustomSideBar(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FindProvidersForEmailView(
              onProvidersFound: (email, providers) {
                // navigate to a custom sign in that provides
                // a UI for authentication for received providers.
              },
            ),
          )
        ],
      ),
    );
  }
}
```

## Building a custom widget with `AuthFlowBuilder`

You could also use `AuthFlowBuilder` to facilitate the functionality of the `UniversalEmailSignInFlow`:

```dart
class MyCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<UniversalEmailSignInController>(
      listener: (oldState, newState, controller) {
        if (newState is DifferentSignInMethodsFound) {
          showDifferentMethodSignInDialog(
            context: context,
            availableProviders: newState.methods,
            providers: FirebaseUIAuth.providersFor(
              FirebaseAuth.instance.app,
            ),
          );
        }
      },
      builder: (context, state, ctrl, child) {
        if (state is Uninitialized) {
          return TextField(
            decoration: InputDecoration(
              labelText: 'Email',
            ),
            onSubmitted: (email) {
              ctrl.findProvidersForEmail(email);
            },
          );
        } else if (state is FetchingProvidersForEmail) {
          return CircularProgressIndicator();
        } else if (state is AuthFailed) {
          return ErrorText(exception: state.exception);
        } else {
          return Text('Unknown state $state');
        }
      },
    );
  }
}
```

## Building a custom stateful widget

For full control over every phase of the authentication lifecycle, you could build a stateful widget which implements `UniversalEmailSignInListener`:

```dart
class CustomUniversalEmailSignIn extends StatefulWidget {
  const CustomUniversalEmailSignIn({Key? key}) : super(key: key);

  @override
  State<CustomUniversalEmailSignIn> createState() =>
      _CustomUniversalEmailSignInState();
}

class _CustomUniversalEmailSignInState extends State<CustomUniversalEmailSignIn>
    implements UniversalEmailSignInListener {
  final auth = FirebaseAuth.instance;
  late final UniversalEmailSignInProvider provider =
      UniversalEmailSignInProvider()..authListener = this;

  late Widget child = TextField(
    decoration: const InputDecoration(
      labelText: 'Email',
    ),
    onSubmitted: provider.findProvidersForEmail,
  );

  @override
  void onBeforeProvidersForEmailFetch() {
    setState(() {
      child = CircularProgressIndicator();
    });
  }

  @override
  void onDifferentProvidersFound(
    String email,
    List<String> providers,
    AuthCredential? credential,
  ) {
    showDifferentMethodSignInDialog(
      context: context,
      availableProviders: providers,
      providers: FirebaseUIAuth.providersFor(FirebaseAuth.instance.app),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: child);
  }

  @override
  void onBeforeCredentialLinked(AuthCredential credential) {
    setState(() {
      child = CircularProgressIndicator();
    });
  }

  @override
  void onBeforeSignIn() {
    setState(() {
      child = CircularProgressIndicator();
    });
  }

  @override
  void onCanceled() {
    setState(() {
      child = Text('Authenticated cancelled');
    });
  }

  @override
  void onCredentialLinked(AuthCredential credential) {
    Navigator.of(context).pushReplacementNamed('/profile');
  }

  @override
  void onError(Object error) {
    try {
      // tries default recovery strategy
      defaultOnAuthError(provider, error);
    } catch (err) {
      setState(() {
        defaultOnAuthError(provider, error);
      });
    }
  }

  @override
  void onSignedIn(UserCredential credential) {
    Navigator.of(context).pushReplacementNamed('/profile');
  }
}
```

## Other topics

- [EmaiAuthProvider](./email.md) - allows registering and signing using email and password.
- [Email verification](./email-verification.md)
- [EmailLinkAuthProvider](./email-link.md) - allows registering and signing using a link sent to email.
- [PhoneAuthProvider](./phone.md) - allows registering and signing using a phone number
- [OAuth](./oauth.md)
- [Localization](../../../firebase_ui_localizations/README.md)
- [Theming](../theming.md)
- [Navigation](../navigation.md)
