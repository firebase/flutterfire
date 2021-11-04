// ignore_for_file: require_trailing_commas
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
    appId: '1:448618578101:ios:2bc5c1fe2ec336f8ac3efc',
    messagingSenderId: '448618578101',
    projectId: 'react-native-firebase-testing',
  ));

  // Activate app check after initialization, but before
  // usage of any Firebase services.
  await FirebaseAppCheck.instance
      .activate(webRecaptchaSiteKey: 'Your reCAPTCHA v3 site key...');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase App Check',
      home: FirebaseAppCheckExample(),
    );
  }
}

class FirebaseAppCheckExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text('App Check Example');
  }
}
