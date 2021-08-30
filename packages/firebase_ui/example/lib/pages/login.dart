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
      labelColor: Theme.of(context).accentColor,
      controller: ctrl,
      tabs: const [
        Tab(text: 'Sign in'),
        Tab(text: 'Sign up'),
      ],
    );

    return Scaffold(
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
                            padding: EdgeInsets.all(16),
                            child: SignInForm(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16).copyWith(top: 0),
                          child: AuthFlowBuilder<OAuthController>(
                            method: AuthMethod.signIn,
                            builder: (_, state, __, child) {
                              if (state is SigningIn) {
                                return const CircularProgressIndicator();
                              }

                              return child!;
                            },
                            child: Column(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PhoneAuthFlow(
                                          authMethod: AuthMethod.signIn,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Sign in with phone'),
                                ),
                                const ProviderButton<Google>(),
                                const ProviderButton<Apple>(),
                                const ProviderButton<Twitter>(),
                                const ProviderButton<Facebook>(),
                              ],
                            ),
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
