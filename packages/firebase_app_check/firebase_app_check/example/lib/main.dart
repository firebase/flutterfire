import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
