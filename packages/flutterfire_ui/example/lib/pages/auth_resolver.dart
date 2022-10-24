// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/material.dart';

import '../config.dart';

class AuthResolver extends StatelessWidget {
  const AuthResolver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const providerConfigs = [
      EmailProviderConfiguration(),
      GoogleProviderConfiguration(clientId: GOOGLE_CLIENT_ID),
      PhoneProviderConfiguration(),
      AppleProviderConfiguration(),
      FacebookProviderConfiguration(clientId: FACEBOOK_CLIENT_ID),
      TwitterProviderConfiguration(
        apiKey: TWITTER_API_KEY,
        apiSecretKey: TWITTER_API_SECRET_KEY,
        redirectUri: TWITTER_REDIRECT_URI,
      ),
    ];

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const ProfileScreen(providerConfigs: providerConfigs);
        }

        return SignInScreen(
          headerBuilder: (context, constraints, _) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset('assets/images/flutterfire_logo.png'),
            );
          },
          sideBuilder: (context, constraints) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(constraints.maxWidth / 4),
                child: Image.asset('assets/images/flutterfire_logo.png'),
              ),
            );
          },
          subtitleBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                action == AuthAction.signIn
                    ? 'Welcome to FlutterFire UI! Please sign in to continue.'
                    : 'Welcome to FlutterFire UI! Please create an account to continue',
              ),
            );
          },
          footerBuilder: (context, action) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  action == AuthAction.signIn
                      ? 'By signing in, you agree to our terms and conditions.'
                      : 'By registering, you agree to our terms and conditions.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
          providerConfigs: providerConfigs,
        );
      },
    );
  }
}
