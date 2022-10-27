// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/material.dart';

import '../widgets/internal/loading_button.dart';
import '../validators.dart';

class ForgotPasswordAction extends FlutterFireUIAction {
  final void Function(BuildContext context, String? email) callback;

  ForgotPasswordAction(this.callback);
}

typedef EmailSubmitCallback = void Function(String email, String password);

class EmailFormStyle extends FlutterFireUIStyle {
  final ButtonVariant? signInButtonVariant;
  final InputDecorationTheme? inputDecorationTheme;

  const EmailFormStyle({
    this.signInButtonVariant = ButtonVariant.outlined,
    this.inputDecorationTheme,
  });

  @override
  Widget applyToMaterialTheme(BuildContext context, Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: inputDecorationTheme,
      ),
      child: child,
    );
  }
}

// FlutterFireUIStyle.defaultStyle = EmailFormStyle();

/// A barebones email form widget.
///
/// {@subCategory service:auth}
/// {@subCategory type:widget}
/// {@subCategory description:A widget rendering a barebones email form with an action button.}
/// {@subCategory img:https://place-hold.it/400x150}
class EmailForm extends StatelessWidget {
  final FirebaseAuth? auth;
  final AuthAction? action;
  final EmailProviderConfiguration? config;
  final EmailSubmitCallback? onSubmit;
  final String? email;

  const EmailForm({
    Key? key,
    this.action,
    this.auth,
    this.config,
    this.onSubmit,
    this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = _SignInFormContent(
      action: action ?? AuthAction.signIn,
      auth: auth,
      config: config,
      email: email,
      onSubmit: onSubmit,
    );

    return AuthFlowBuilder<EmailFlowController>(
      auth: auth,
      action: action,
      config: config,
      child: child,
    );
  }
}

class _SignInFormContent extends StatefulWidget {
  final FirebaseAuth? auth;
  final EmailSubmitCallback? onSubmit;
  final AuthAction? action;
  final String? email;
  final EmailProviderConfiguration? config;

  const _SignInFormContent({
    Key? key,
    this.auth,
    this.onSubmit,
    this.action,
    this.email,
    this.config,
  }) : super(key: key);

  @override
  _SignInFormContentState createState() => _SignInFormContentState();
}

class _SignInFormContentState extends State<_SignInFormContent> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  String _chooseButtonLabel() {
    final ctrl = AuthController.ofType<EmailFlowController>(context);
    final l = FlutterFireUILocalizations.labelsOf(context);

    switch (ctrl.action) {
      case AuthAction.signIn:
        return l.signInActionText;
      case AuthAction.signUp:
        return l.registerActionText;
      case AuthAction.link:
        return l.linkEmailButtonText;
    }
  }

  void _submit([String? password]) {
    final ctrl = AuthController.ofType<EmailFlowController>(context);
    final email = (widget.email ?? emailCtrl.text).trim();

    if (formKey.currentState!.validate()) {
      if (widget.onSubmit != null) {
        widget.onSubmit!(email, passwordCtrl.text);
      } else {
        ctrl.setEmailAndPassword(
          email,
          password ?? passwordCtrl.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);
    const spacer = SizedBox(height: 16);

    final children = [
      if (widget.email == null) ...[
        EmailInput(
          focusNode: emailFocusNode,
          controller: emailCtrl,
          onSubmitted: (v) {
            formKey.currentState?.validate();
            FocusScope.of(context).requestFocus(passwordFocusNode);
          },
        ),
        spacer,
      ],
      PasswordInput(
        focusNode: passwordFocusNode,
        controller: passwordCtrl,
        onSubmit: _submit,
        label: l.passwordInputLabel,
      ),
      if (widget.action == AuthAction.signIn) ...[
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ForgotPasswordButton(
            onPressed: () {
              final navAction =
                  FlutterFireUIAction.ofType<ForgotPasswordAction>(context);

              if (navAction != null) {
                navAction.callback(context, emailCtrl.text);
              } else {
                showForgotPasswordScreen(
                  context: context,
                  email: emailCtrl.text,
                  auth: widget.auth,
                );
              }
            },
          ),
        ),
      ],
      if (widget.action == AuthAction.signUp ||
          widget.action == AuthAction.link) ...[
        const SizedBox(height: 8),
        PasswordInput(
          autofillHints: const [AutofillHints.newPassword],
          focusNode: confirmPasswordFocusNode,
          controller: confirmPasswordCtrl,
          onSubmit: _submit,
          validator: Validator.validateAll([
            NotEmpty(l.confirmPasswordIsRequiredErrorText),
            ConfirmPasswordValidator(
              passwordCtrl,
              l.confirmPasswordDoesNotMatchErrorText,
            )
          ]),
          label: l.confirmPasswordInputLabel,
        ),
        const SizedBox(height: 8),
      ],
      const SizedBox(height: 8),
      Builder(
        builder: (context) {
          final state = AuthState.of(context);
          final style = FlutterFireUIStyle.ofType<EmailFormStyle>(
            context,
            const EmailFormStyle(),
          );

          return LoadingButton(
            variant: style.signInButtonVariant,
            label: _chooseButtonLabel(),
            isLoading: state is SigningIn || state is SigningUp,
            onTap: _submit,
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
    ];

    return AutofillGroup(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
