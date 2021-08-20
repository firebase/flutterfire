import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui/firebase_ui.dart';

import 'package:firebase_ui/auth/google.dart';
import 'package:firebase_ui/auth/apple.dart';
import 'package:firebase_ui/auth/facebook.dart';
import 'package:firebase_ui/auth/twitter.dart';

import 'pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FirebaseAuthUIExample());
}

class FirebaseAuthUIExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FirebaseUIApp(
      initializers: [
        FirebaseUIAppInitializer(),
        FirebaseUIDynamicLinksInitializer(),
        FirebaseUIAuthInitializer(
          providerConfigs: [
            EmailProviderConfiguration(
              actionCodeSettings: ActionCodeSettings(
                url: 'https://react-native-firebase-testing.firebaseapp.com',
                dynamicLinkDomain: 'reactnativefirebase.page.link',
                androidPackageName:
                    'io.flutter.plugins.firebase_ui.firebase_ui_example',
                androidInstallApp: true,
                androidMinimumVersion: '21',
                handleCodeInApp: true,
              ),
            ),
            PhoneProviderConfiguration(),
            GoogleProviderConfiguration(),
            AppleProviderConfiguration(),
            FacebookProviderConfiguration(),
            TwitterProviderConfiguration(
              apiKey: 'uIwDYzdziDHOjNwA2IitM9wYI',
              apiSecretKey:
                  'jmvrMCEorotAZ5Y4gevmrAEJgxz5UV3c7qLZosaQhxDafee58F',
              redirectURI:
                  'https://react-native-firebase-testing.firebaseapp.com/__/auth/handler',
            ),
          ],
        ),
      ],
      child: MaterialApp(
        title: 'Firebase UI demo',
        theme: ThemeData(
          brightness: Brightness.dark,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: const Home(),
      ),
    );
  }
}
