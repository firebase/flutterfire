import 'package:flutter/material.dart';
import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui/responsive.dart';

import 'phone_auth_flow.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Body(
        child: SignInForm(
          surfaceBuilder: (context, child) {
            return Card(child: child);
          },
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PhoneAuthFlow(
                      authMethod: AuthAction.signIn,
                    ),
                  ),
                );
              },
              child: const Text('Sign in with phone'),
            ),
            Padding(
              padding: const EdgeInsets.all(16).copyWith(top: 0),
              child: AuthFlowBuilder<OAuthController>(
                action: AuthAction.signIn,
                builder: (_, state, __, child) {
                  if (state is SigningIn) {
                    return const CircularProgressIndicator();
                  }

                  return child!;
                },
                child: Column(
                  children: const [
                    ProviderButton<Google>(),
                    ProviderButton<Apple>(),
                    ProviderButton<Twitter>(),
                    ProviderButton<Facebook>(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
