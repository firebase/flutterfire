import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/auth/facebook.dart';
import 'package:flutterfire_ui/auth/google.dart';
import 'package:flutterfire_ui/auth/apple.dart';
import 'package:flutterfire_ui/auth/twitter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'profile.dart';
import '../config.dart';

class AuthResolver extends StatelessWidget {
  const AuthResolver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const providerConfigs = [
      EmailProviderConfiguration(),
      PhoneProviderConfiguration(),
      GoogleProviderConfiguration(clientId: GOOGLE_CLIENT_ID),
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

        // return const UniversalEmailSignInScreen(
        //   providerConfigs: providerConfigs,
        // );

        return SignInScreen(
          headerBuilder: (context, constraints, _) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: SvgPicture.asset('assets/images/firebase_logo.svg'),
              ),
            );
          },
          sideBuilder: (context, constraints) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(constraints.maxWidth / 8),
                child: SvgPicture.asset(
                  'assets/images/firebase_logo.svg',
                  width: constraints.maxWidth / 2,
                  height: constraints.maxWidth / 2,
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
