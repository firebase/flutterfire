import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/auth/apple.dart';
import 'package:flutterfire_ui/auth/google.dart';
import 'package:flutterfire_ui/i10n.dart';

import 'config.dart';
import 'pages/auth_resolver.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

const providerConfigs = [
  EmailProviderConfiguration(),
  GoogleProviderConfiguration(clientId: GOOGLE_CLIENT_ID),
  // PhoneProviderConfiguration(),
  AppleProviderConfiguration(),
  // FacebookProviderConfiguration(clientId: FACEBOOK_CLIENT_ID),
  // TwitterProviderConfiguration(
  //   apiKey: TWITTER_API_KEY,
  //   apiSecretKey: TWITTER_API_SECRET_KEY,
  //   redirectUri: TWITTER_REDIRECT_URI,
  // ),
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
            return const ProfileScreen(providerConfigs: providerConfigs);
          } else {
            return NavigationActions(
              actions: [
                ForgotPasswordAction(
                  action: (context, email) {
                    Navigator.pushNamed(
                      context,
                      '/forgot-password',
                      arguments: {'email': email},
                    );
                  },
                ),
              ],
              child: SignInScreen(
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
              ),
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
      },
      title: 'Firebase UI demo',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      localizationsDelegates: [
        FirebaseUILocalizations.withDefaultOverrides(const LabelOverrides()),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FirebaseUILocalizations.delegate,
      ],
    );
  }
}
