import 'package:flutter/material.dart';
import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui_example/widgets/sign_in_form.dart';

import 'phone_auth_flow.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  AuthMethod method = AuthMethod.signIn;
  late final ctrl = TabController(length: 2, vsync: this)
    ..addListener(() {
      setState(() {
        method = AuthMethod.values.elementAt(ctrl.index);
      });
    });

  @override
  Widget build(BuildContext context) {
    final tabs = TabBar(
      controller: ctrl,
      tabs: const [
        Tab(child: Text('Sign in')),
        Tab(child: Text('Sign up')),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase UI auth demo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IntrinsicHeight(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  tabs,
                  Expanded(
                    child: Column(
                      children: [
                        AuthFlowBuilder<EmailFlowController>(
                          method: method,
                          listener: (oldState, newState) {
                            if (newState is AuthFailed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    newState.exception.toString(),
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Padding(
                            padding: const EdgeInsets.all(16),
                            child: SignInForm(),
                          ),
                        ),
                        const Text('Other sign in options'),
                        Padding(
                          padding: const EdgeInsets.all(16).copyWith(top: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const PhoneAuthFlow(
                                        authMethod: AuthMethod.signIn,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.phone),
                              ),
                              AuthFlowBuilder<OAuthController>(
                                method: AuthMethod.signIn,
                                child: Row(
                                  children: [
                                    ProviderButton.google(),
                                    ProviderButton.apple(),
                                    ProviderButton.twitter(),
                                    ProviderButton.facebook(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
