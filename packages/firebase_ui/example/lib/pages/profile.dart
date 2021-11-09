import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/auth/apple.dart';
import 'package:firebase_ui/auth/facebook.dart';
import 'package:firebase_ui/auth/google.dart';
import 'package:firebase_ui/auth/twitter.dart';
import 'package:firebase_ui/responsive.dart';
import 'package:firebase_ui_example/config.dart';
import 'package:firebase_ui_example/widgets/email_verification_button.dart';
import 'package:firebase_ui_example/widgets/user_field_tile.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser!;
    final providers = u.providerData
        .map((e) => e.providerId)
        .where(isOAuthProvider)
        .map((e) => Icon(providerIconFromString(e)))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User profile'),
      ),
      body: Body(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  UserFieldTile(field: 'UID', value: u.uid),
                  UserFieldTile(field: 'Display name', value: u.displayName),
                  UserFieldTile(
                    field: 'Email',
                    value: u.email,
                    trailing: const EmailVerificationButton(),
                  ),
                  UserFieldTile(
                    field: 'Phone number',
                    value: u.phoneNumber,
                    trailing: u.phoneNumber == null
                        ? IconButton(
                            icon: const Icon(Icons.warning),
                            onPressed: () async {
                              await startPhoneVerification(context: context);
                              setState(() {});
                            },
                          )
                        : const VerifiedBadge(),
                  ),
                  UserFieldTile(
                    field: 'Providers',
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: providers.isNotEmpty
                          ? Row(children: providers)
                          : const Text('No providers linked'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Link providers',
                          style: Theme.of(context).textTheme.overline,
                        ),
                        AuthStateListener<AuthController>(
                          listener: (oldState, newState, controller) {
                            if (newState is CredentialLinked) {
                              u.reload().then((_) {
                                setState(() {});
                                controller.dispose();
                              });
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!u.isProviderLinked<Google>())
                                const GoogleSignInIconButton(),
                              if (!u.isProviderLinked<Apple>())
                                const AppleSignInIconButton(),
                              if (!u.isProviderLinked<Twitter>())
                                const TwitterSignInIconButton(
                                  apiKey: TWITTER_API_KEY,
                                  apiSecretKey: TWITTER_API_SECRET_KEY,
                                  redirectUri: TWITTER_REDIRECT_URI,
                                ),
                              if (!u.isProviderLinked<Facebook>())
                                const FacebookSignInIconButton(),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.currentUser!.delete();
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.red,
                      ),
                      overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.red.withAlpha(20),
                      ),
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete account'),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    label: const Text('Sign out'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
