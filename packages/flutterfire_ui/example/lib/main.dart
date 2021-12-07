import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';

import 'config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
      appId: '1:448618578101:android:5180baaa9cc2b8fcac3efc',
      projectId: 'react-native-firebase-testing',
      authDomain: 'react-native-firebase-testing.firebaseapp.com',
      messagingSenderId: '448618578101',
      iosClientId:
          '448618578101-4km55qmv55tguvnivgjdiegb3r0jquv5.apps.googleusercontent.com',
    ),
  );
  runApp(FirebaseAuthUIExample());
}

// Overrides a label for en locale
// To add localization for a custom language follow the guide here:
// https://flutter.dev/docs/development/accessibility-and-localization/internationalization#an-alternative-class-for-the-apps-localized-resources
class LabelOverrides extends DefaultLocalizations {
  const LabelOverrides();

  @override
  String get emailInputLabel => 'Enter your email';
}

final providerConfigs = [
  const EmailProviderConfiguration(),
  EmailLinkProviderConfiguration(
    actionCodeSettings: ActionCodeSettings(
      url: 'https://reactnativefirebase.page.link',
      handleCodeInApp: true,
      androidMinimumVersion: '12',
      androidPackageName:
          'io.flutter.plugins.flutterfire_ui.flutterfire_ui_example',
      iOSBundleId: 'io.flutter.plugins.flutterfireui.flutterfireUIExample',
    ),
  ),
  const PhoneProviderConfiguration(),
  const GoogleProviderConfiguration(clientId: GOOGLE_CLIENT_ID),
  const AppleProviderConfiguration(),
  const FacebookProviderConfiguration(clientId: FACEBOOK_CLIENT_ID),
  const TwitterProviderConfiguration(
    apiKey: TWITTER_API_KEY,
    apiSecretKey: TWITTER_API_SECRET_KEY,
    redirectUri: TWITTER_REDIRECT_URI,
  ),
];

class FirebaseAuthUIExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        visualDensity: VisualDensity.standard,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      routes: {
        '/': (context) {
          if (FirebaseAuth.instance.currentUser != null) {
            return ProfileScreen(providerConfigs: providerConfigs);
          } else {
            return SignInScreen(
              actions: [
                ForgotPasswordAction((context, email) {
                  Navigator.pushNamed(
                    context,
                    '/forgot-password',
                    arguments: {'email': email},
                  );
                }),
                AuthStateChangeAction<SignedIn>((context, state) {
                  Navigator.pushReplacementNamed(context, '/profile');
                }),
              ],
              headerBuilder: (context, constraints, _) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset('assets/images/flutterfire_logo.png'),
                );
              },
              sideBuilder: (context, constraints) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(constraints.maxWidth / 4),
                    child: Image.asset('assets/images/flutterfire_logo.png'),
                  ),
                );
              },
              subtitleBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    action == AuthAction.signIn
                        ? 'Welcome to FlutterFire UI! Please sign in to continue.'
                        : 'Welcome to FlutterFire UI! Please create an account to continue',
                  ),
                );
              },
              footerBuilder: (context, action) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      action == AuthAction.signIn
                          ? 'By signing in, you agree to our terms and conditions.'
                          : 'By registering, you agree to our terms and conditions.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
              providerConfigs: providerConfigs,
            );
          }
        },
        '/forgot-password': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;

          return ForgotPasswordScreen(
            email: arguments?['email'],
            headerMaxExtent: 200,
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20).copyWith(top: 40),
                child: Icon(
                  Icons.lock,
                  color: Colors.blue,
                  size: constraints.maxWidth / 4 * (1 - shrinkOffset),
                ),
              );
            },
            sideBuilder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Icon(
                  Icons.lock,
                  color: Colors.blue,
                  size: constraints.maxWidth / 3,
                ),
              );
            },
          );
        },
        '/profile': (context) {
          return ProfileScreen(
            providerConfigs: providerConfigs,
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(context, '/');
              }),
            ],
          );
        },
      },
      title: 'Firebase UI demo',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      localizationsDelegates: [
        FlutterFireUILocalizations.withDefaultOverrides(const LabelOverrides()),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterFireUILocalizations.delegate,
      ],
    );
  }
}
