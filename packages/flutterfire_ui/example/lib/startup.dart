import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui_example/config.dart';
import 'package:flutterfire_ui_example/profile.dart';

import 'decorations.dart';

final emailLinkProviderConfig = EmailLinkProviderConfiguration(
  actionCodeSettings: ActionCodeSettings(
    url: 'https://reactnativefirebase.page.link',
    handleCodeInApp: true,
    androidMinimumVersion: '12',
    androidPackageName:
        'io.flutter.plugins.flutterfire_ui.flutterfire_ui_example',
    iOSBundleId: 'io.flutter.plugins.flutterfireui.flutterfireUIExample',
  ),
);

final providerConfigs = [
  const EmailProviderConfiguration(),
  emailLinkProviderConfig,
  const PhoneProviderConfiguration(),
  const GoogleProviderConfiguration(clientId: GOOGLE_CLIENT_ID),
  const AppleProviderConfiguration(),
  const FacebookProviderConfiguration(clientId: FACEBOOK_CLIENT_ID),
  const TwitterProviderConfiguration(
    apiKey: TWITTER_API_KEY,
    apiSecretKey: TWITTER_API_SECRET_KEY,
    redirectUri: TWITTER_REDIRECT_URI,
  ),
];

class StartUpView extends StatelessWidget {
  const StartUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const Profile();
        } else {
          return Scaffold(
            body: SignInScreen(
              headerBuilder: headerImage('assets/images/flutterfire_logo.png'),
              sideBuilder: sideImage('assets/images/flutterfire_logo.png'),
              subtitleBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    action == AuthAction.signIn
                        ? 'Welcome to Flipper Please sign in to continue.'
                        : 'Welcome to Flipper Please create an account to continue',
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
              providerConfigs: providers(),
            ),
          );
        }
      },
    );
  }

  List<ProviderConfiguration> providers() {
    return providerConfigs;
  }
}
