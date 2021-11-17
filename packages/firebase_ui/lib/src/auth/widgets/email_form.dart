import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/i10n.dart';
import 'package:flutter/material.dart';

import '../configs/email_provider_configuration.dart';
import '../auth_state.dart';
import '../validators.dart';
import 'error_text.dart';

class EmailForm extends StatelessWidget {
  final FirebaseAuth? auth;
  final AuthAction action;
  final EmailProviderConfiguration? config;

  const EmailForm({
    Key? key,
    required this.action,
    this.auth,
    this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailFlowController>(
      action: action,
      config: config,
      child: const _SignInFormContent(),
    );
  }
}

class _SignInFormContent extends StatefulWidget {
  const _SignInFormContent({Key? key}) : super(key: key);

  @override
  _SignInFormContentState createState() => _SignInFormContentState();
}

class _SignInFormContentState extends State<_SignInFormContent> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  String chooseButtonLabel() {
    final ctrl = AuthController.ofType<EmailFlowController>(context);
    final l = FirebaseUILocalizations.labelsOf(context);

    switch (ctrl.action) {
      case AuthAction.signIn:
        return l.signInActionText;
      case AuthAction.signUp:
        return l.signUpActionText;
      case AuthAction.link:
        return l.linkEmailButtonText;
    }
  }

  String? validateEmail(String? value) {
    final l = FirebaseUILocalizations.labelsOf(context);

    if (value == null || value.isEmpty) {
      return l.emailIsRequiredErrorText;
    }

    if (!isValidEmail(value)) {
      return l.isNotAValidEmailErrorText;
    }

    return null;
  }

  void submit([String? value]) {
    final ctrl = AuthController.ofType<EmailFlowController>(context);

    if (formKey.currentState!.validate()) {
      ctrl.setEmailAndPassword(
        emailCtrl.text,
        passwordCtrl.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            focusNode: emailFocusNode,
            controller: emailCtrl,
            decoration: InputDecoration(labelText: l.emailInputLabel),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            validator: validateEmail,
            onFieldSubmitted: (v) {
              formKey.currentState?.validate();
              FocusScope.of(context).requestFocus(passwordFocusNode);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            focusNode: passwordFocusNode,
            controller: passwordCtrl,
            decoration: InputDecoration(labelText: l.passwordInputLabel),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            onFieldSubmitted: submit,
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              late Widget child;
              final state = AuthState.of(context);

              if (state is SigningIn) {
                child = const CircularProgressIndicator();
              } else {
                child = Text(chooseButtonLabel());
              }

              return OutlinedButton(
                onPressed: submit,
                child: child,
              );
            },
          ),
          Builder(
            builder: (context) {
              final authState = AuthState.of(context);
              if (authState is AuthFailed) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ErrorText(
                    textAlign: TextAlign.center,
                    exception: authState.exception,
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
