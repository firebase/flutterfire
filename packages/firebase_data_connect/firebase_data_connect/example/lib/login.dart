// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_data_connect_example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<void> initFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider
          .addScope('https://www.googleapis.com/auth/contacts.readonly');

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  void logIn() async {
    await initFirebase();
    await signInWithGoogle();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const MyHomePage(
                title: "Data Connect Home Page",
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Login"),
      ),
      body: Center(
        child: Container(
          height: 150.0,
          width: 190.0,
          padding: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: TextButton(
              onPressed: logIn,
              child: const Text("Log in"),
            ),
          ),
        ),
      ),
    );
  }
}
