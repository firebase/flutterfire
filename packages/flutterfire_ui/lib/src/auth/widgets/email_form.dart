import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutterfire_ui/src/auth/widgets/internal/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/src/auth/widgets/password_input.dart';

import '../configs/email_provider_configuration.dart';
import '../auth_state.dart';
import '../validators.dart';
import 'error_text.dart';

typedef EmailSubmitCallback = void Function(String email, String password);

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

  const EmailForm({
    Key? key,
    this.action,
    this.auth,
    this.config,
    this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailFlowController>(
      action: action,
      config: config,
      child: _SignInFormContent(
        action: action,
        onSubmit: onSubmit,
      ),
    );
  }
}

class _SignInFormContent extends StatefulWidget {
  final EmailSubmitCallback? onSubmit;
  final AuthAction? action;
  const _SignInFormContent({
    Key? key,
    this.onSubmit,
    this.action,
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

  String? _validateConfirmPassword(String? value) {
    final l = FirebaseUILocalizations.labelsOf(context);

    if (value == null || value.isEmpty) {
      return l.confirmPasswordIsRequiredErrorText;
    }

    if (value != passwordCtrl.text) {
      return l.confirmPasswordDoesNotMatchErrorText;
    }

    return null;
  }

  void _submit([String? value]) {
    final ctrl = AuthController.ofType<EmailFlowController>(context);

    if (formKey.currentState!.validate()) {
      if (widget.onSubmit != null) {
        widget.onSubmit!(emailCtrl.text, passwordCtrl.text);
      } else {
        ctrl.setEmailAndPassword(
          emailCtrl.text,
          passwordCtrl.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    const spacer = SizedBox(height: 16);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          EmailInput(
            focusNode: emailFocusNode,
            controller: emailCtrl,
            onSubmitted: (v) {
              formKey.currentState?.validate();
              FocusScope.of(context).requestFocus(passwordFocusNode);
            },
          ),
          spacer,
          PasswordInput(
            focusNode: passwordFocusNode,
            controller: passwordCtrl,
            onSubmit: _submit,
            validator: NotEmpty(l.passwordIsRequiredErrorText).validate,
            label: l.passwordInputLabel,
          ),
          if (widget.action == AuthAction.signIn) ...[
            spacer,
            Align(
              alignment: Alignment.centerRight,
              child: ForgotPssswordButton(
                onPressed: () {
                  showForgotPasswordScreen(context);
                },
              ),
            ),
          ],
          if (widget.action == AuthAction.signUp) ...[
            spacer,
            PasswordInput(
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
            spacer,
          ],
          Builder(
            builder: (context) {
              final state = AuthState.of(context);

              return LoadingButton(
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
        ],
      ),
    );
  }
}
