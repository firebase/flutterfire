// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_localizations_example/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var locale = const Locale('en', 'US');

    return StatefulBuilder(
      builder: (context, setState) {
        return MaterialApp(
          title: 'Firebase UI Localizations Demo',
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
          ],
          locale: locale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FirebaseUILocalizations.delegate,
          ],
          home: Column(
            children: [
              Material(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => locale = const Locale('en', 'US'));
                        },
                        child: const Chip(label: Text('en')),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => locale = const Locale('fr', 'FR'));
                        },
                        child: const Chip(label: Text('fr')),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SignInScreen(
                  providers: [
                    EmailAuthProvider(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
