import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui/auth/google.dart';

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
