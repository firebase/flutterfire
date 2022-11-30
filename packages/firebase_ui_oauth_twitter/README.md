# Firebase UI OAuth Twitter

[![pub package](https://img.shields.io/pub/v/firebase_ui_oauth_twitter.svg)](https://pub.dev/packages/firebase_ui_oauth_twitter)

Twitter Sign In for [Firebase UI Auth](https://pub.dev/packages/firebase_ui_auth)

## Installation

Add dependencies

```sh
flutter pub add firebase_ui_auth
flutter pub add firebase_ui_oauth_twitter

flutter pub global activate flutterfire_cli
flutterfire configure
```

Enable Twitter provider on [firebase console](https://console.firebase.twitter.com/).

## Usage

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_twitter/firebase_ui_oauth_twitter.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
        TwitterProvider(apiKey: 'apiKey', apiSecretKey: 'apiSecretKey'),
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
        provider: TwitterProvider(apiKey: 'apiKey'),
      ),
    );
  }
}
```

Also there is a standalone version of the `TwitterSignInButton`

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TwitterSignInButton(
      apiKey: 'apiKey',
      apiSecretKey: 'apiSecretKey',
      loadingIndicator: CircularProgressIndicator(),
      onSignedIn: (UserCredential credential) {
        // perform navigation.
      }
    );
  }
}
```

## API Secret Key notes

Don't hardcode your API secret key into the source code, instead use `--dart-define TWITTER_API_SECRET_KEY=secret` and `apiSecretKey: const String.fromEnvironment('TWITTER_API_SECRET_KEY)`.

For issues, please create a new [issue on the repository](https://github.com/firebase/flutterfire/issues).

For feature requests, & questions, please participate on the [discussion](https://github.com/firebase/flutterfire/discussions/6978) thread.

To contribute a change to this plugin, please review our [contribution guide](https://github.com/firebase/flutterfire/blob/master/CONTRIBUTING.md) and open a [pull request](https://github.com/firebase/flutterfire/pulls).

Please contribute to the [discussion](https://github.com/firebase/flutterfire/discussions/6978) with feedback.
