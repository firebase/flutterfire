import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/auth/facebook.dart';
import 'package:firebase_ui/auth/google.dart';
import 'package:firebase_ui/auth/apple.dart';
import 'package:firebase_ui/auth/twitter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'profile.dart';
import '../config.dart';

class AuthResolver extends StatelessWidget {
  const AuthResolver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const Profile();
        }

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
          providerConfigs: const [
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
          ],
        );
      },
    );
  }
}
