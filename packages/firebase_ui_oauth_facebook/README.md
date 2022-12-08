# Firebase UI OAuth Facebook

[![pub package](https://img.shields.io/pub/v/firebase_ui_oauth_facebook.svg)](https://pub.dev/packages/firebase_ui_oauth_facebook)

Facebook Sign In for [Firebase UI Auth](https://pub.dev/packages/firebase_ui_auth)

## Installation

Add dependencies

```sh
flutter pub add firebase_ui_auth
flutter pub add firebase_ui_oauth_facebook

flutter pub global activate flutterfire_cli
flutterfire configure
```

Enable Facebook provider on [firebase console](https://console.firebase.google.com/).

## Usage

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_facebook/firebase_ui_oauth_facebook.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
        FacebookProvider(clientId: 'clientId'),
    ]);

    runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInScreen(
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {
            // redirect to other screen
          })
        ],
      ),
    );
  }
}
```

Alternatively you could use the `OAuthProviderButton`

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthStateListener<OAuthController>(
      listener: (oldState, newState, controller) {
        if (newState is SignedIn) {
          // navigate to other screen.
        }
      },
      child: OAuthProviderButton(
        provider: FacebookProvider(clientId: 'clientId'),
      ),
    );
  }
}
```

Also there is a standalone version of the `FacebookSignInButton`

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FacebookSignInButton(
      clientId: 'clientId',
      loadingIndicator: CircularProgressIndicator(),
      onSignedIn: (UserCredential credential) {
        // perform navigation.
      }
    );
  }
}
```

For issues, please create a new [issue on the repository](https://github.com/firebase/flutterfire/issues).

For feature requests, & questions, please participate on the [discussion](https://github.com/firebase/flutterfire/discussions/6978) thread.

To contribute a change to this plugin, please review our [contribution guide](https://github.com/firebase/flutterfire/blob/master/CONTRIBUTING.md) and open a [pull request](https://github.com/firebase/flutterfire/pulls).

Please contribute to the [discussion](https://github.com/firebase/flutterfire/discussions/6978) with feedback.
