import 'package:firebase_ui/firebase_ui.dart';
import 'package:flutter/material.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  String chooseButtonLabel() {
    final ctrl = AuthController.of(context);

    switch (ctrl.method) {
      case AuthMethod.signIn:
        return 'Sing in';
      case AuthMethod.signUp:
        return 'Sign up';
      case AuthMethod.link:
        return 'Next';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = AuthController.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: emailCtrl,
          decoration: const InputDecoration(labelText: 'Email'),
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordCtrl,
          decoration: const InputDecoration(labelText: 'Password'),
          autofocus: true,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            (ctrl as EmailFlowController).setEmailAndPassword(
              emailCtrl.text,
              passwordCtrl.text,
            );
          },
          child: Text(chooseButtonLabel()),
        ),
      ],
    );
  }
}
