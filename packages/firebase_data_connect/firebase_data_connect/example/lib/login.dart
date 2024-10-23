// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
