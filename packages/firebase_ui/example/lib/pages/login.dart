import 'package:flutter/material.dart';

import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/auth/google.dart';
import 'package:firebase_ui/auth/apple.dart';
import 'package:firebase_ui/auth/facebook.dart';
import 'package:firebase_ui/auth/twitter.dart';
import 'package:firebase_ui_example/config.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: EmailSignInForm(
          surfaceBuilder: (context, child) {
            return Card(child: child);
          },
          children: [
            TextButton(
              onPressed: () {
                startPhoneVerification(context: context);
              },
              child: const Text('Sign in with phone'),
            ),
            Padding(
              padding: const EdgeInsets.all(16).copyWith(top: 0),
              child: Column(
                children: [
                  GoogleSignInButton(clientId: GOOGLE_CLIENT_ID),
                  AppleSignInButton(),
                  TwitterSignInButton(
                    apiKey: TWITTER_API_KEY,
                    apiSecretKey: TWITTER_API_SECRET_KEY,
                    redirectUri: TWITTER_REDIRECT_URI,
                  ),
                  FacebookSignInButton(clientId: FACEBOOK_CLIENT_ID),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
