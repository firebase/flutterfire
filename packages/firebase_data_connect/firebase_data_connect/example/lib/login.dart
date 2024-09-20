// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect_example/main.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<void> signInWithGoogle() async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '${Random().nextInt(100000)}@mail.com', password: 'password');
  }

  void logIn() async {
    final navigator = Navigator.of(context);
    await signInWithGoogle();

    navigator.push(
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
