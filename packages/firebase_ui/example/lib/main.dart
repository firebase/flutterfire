import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/auth_resolver.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FirebaseAuthUIExample());
}

class FirebaseAuthUIExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase UI demo',
      theme: ThemeData(
        brightness: Brightness.light,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const AuthResolver(),
    );
  }
}
