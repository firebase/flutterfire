import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui/firebase_ui.dart';

import 'package:firebase_ui/auth/google.dart';
import 'package:firebase_ui/auth/apple.dart';
import 'package:firebase_ui/auth/facebook.dart';
import 'package:firebase_ui/auth/twitter.dart';

import 'pages/auth_resolver.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FirebaseAuthUIExample());
}

class FirebaseAuthUIExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FirebaseUIInit(
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
            GoogleProviderConfiguration(
              clientId:
                  '448618578101-sg12d2qin42cpr00f8b0gehs5s7inm0v.apps.googleusercontent.com',
              redirectUri:
                  'https://react-native-firebase-testing.firebaseapp.com/__/auth/handler',
            ),
            AppleProviderConfiguration(),
            FacebookProviderConfiguration(),
            TwitterProviderConfiguration(
              apiKey: 'YEXSiWv5UeCHyy0c61O2LBC3B',
              apiSecretKey:
                  'DOd9dCCRFgtnqMDQT7A68YuGZtvcO4WP1mEFS4mEJAUooM4yaE',
              redirectURI: 'ffire://',
            ),
          ],
        ),
      ],
      child: MaterialApp(
        title: 'Firebase UI demo',
        theme: ThemeData(
          brightness: Brightness.light,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        builder: FirebaseUIInit.builder,
        home: const AuthResolver(),
      ),
    );
  }
}
